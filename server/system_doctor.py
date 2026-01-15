# This script is a System Doctor Pro - Storage Intelligence Analysis Tool
# status: tested
# published by: Deepak Raj
# published on: 2026-01-16

"""
System Doctor Pro - Storage Intelligence Analysis Tool

A comprehensive disk analysis tool that collects system storage metrics
and uses AI to provide intelligent insights and cleanup recommendations.
"""


import os
import re
import subprocess
import sys
import threading
import time
from pathlib import Path
from typing import Optional

from groq import Groq
from md2htmlify import MarkdownConverter


# Configuration
GROQ_API_KEY_URL = "https://console.groq.com/keys"
AI_MODEL = "openai/gpt-oss-120b"
TEMP_REPORT_PATH = "/tmp/disk_doctor_raw.txt"
SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

# System Commands
COMMANDS = {
    "filesystem": "df -hT",
    "devices": "lsblk -o NAME,TYPE,FSTYPE,SIZE,MOUNTPOINT,MODEL",
    "inodes": "df -ih",
    "root_usage": "sudo du -xh --max-depth=1 / | sort -hr | head -n 15",
    "home_usage": "sudo du -xh --max-depth=1 /home | sort -hr | head -n 15",
    "large_files": (
        "sudo find / -xdev -type f -size +1G -printf '%s %p\\n' | "
        "sort -nr | head -n 15 | "
        "awk '{ cmd=\"numfmt --to=iec --suffix=B \"$1; "
        "cmd | getline h; close(cmd); print h, $2 }'"
    ),
    "docker": "docker system df 2>/dev/null",
    "cache": "sudo du -sh /var/cache/apt /var/lib/snapd /var/log",
    "journal": "sudo journalctl --disk-usage",
    "docker_ps": "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Size}}' 2>/dev/null",
    "docker_stats": "docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}' 2>/dev/null | head -n 11",
    "os_version": "cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"'",
    "kernel": "uname -sr",
    "cpu_model": "lscpu | grep 'Model name' | cut -d':' -f2 | sed 's/^[ \t]*//'",
    "cpu_cores": "nproc",
    "memory": "free -h",
    "load_uptime": "uptime",
    "io_wait": "vmstat 1 2 | tail -n 1 | awk '{print $16}'",
    "networking": "sudo ss -tulpn | head -n 20",
    "ufw_status": "sudo ufw status verbose",
    "failed_services": "systemctl --failed --no-legend --no-pager",
    "recent_errors": "sudo journalctl -p 3 -xb -n 10 --no-pager",
    "swap_usage": "swapon --show --noheadings",
    "last_logins": "last -n 5",
    "system_type": "hostnamectl 2>/dev/null | grep -E 'Static hostname|Icon name|Chassis|Deployment|Virtualization|Operating System|Kernel|Architecture' || echo 'N/A'",
    "top_processes": "ps aux --sort=-%mem | head -n 10",
    "user_cron": "crontab -l 2>/dev/null",
    "root_cron": "sudo crontab -l 2>/dev/null",
}

# AI System Prompt
AI_SYSTEM_PROMPT = """You are a senior Linux SRE & Storage Performance Engineer. 
Your goal is to provide a comprehensive, systematic storage intelligence report.

STRUCTURE YOUR RESPONSE AS FOLLOWS:

# 📊 Storage Intelligence Dashboard
## 🟢 Executive Health Summary 
Provide a high-level overview of the system health. Use indicators (e.g., [CRITICAL], [WARNING], [HEALTHY]). 
**System Context:** Summarize the OS, CPU, and Core count.
**Holistic Health:** Compare total capacity vs. actual consumption. Identify any critical bottlenecks in Memory, System Load, or Disk I/O.

## 📈 Capacity, Performance & Security Analysis
- **Disk Capacity:** Raw vs Usable space.
- **Inodes Health:** Status of file entry usage.
- **Memory & Swap:** Analyze RAM efficiency and swap pressure.
- **I/O & Load:** Identify if the system is CPU-bound or Disk-bound.
- **Security Posture:** Analyze UFW status and open ports. Assess if the current networking configuration is "Safe" or "Risky" based on exposed services.

# 🔍 Deep-Dive Diagnostic
## 🕵️ Storage Hotspots & Offenders
Identify the top 7 storage consumers. Explain *why* they might be growing.

## 🛠️ Performance & Service Insights
Analyze SSD wear, filesystem bottlenecks, and networking status. 
- Identify any unexpected services listening on ports.
- **UFW Status:** Evaluate if the firewall is active and if the ruleset is restrictive enough.
- **Security Verdict:** Provide a clear "Safe" or "Risky" assessment for the current networking setup.

# 🐳 Docker Intelligence (Service Deep-Dive)
Analyze the Docker ecosystem (CPU/RAM/Uptime/Health).

# 📅 Tasks & Automation Audit
Analyze scheduled tasks (crontab). Are there any processes that might cause storage spikes or resource contention?

# ⚡ Tactical Action Plan (Immediate Cleanup)
## 🚮 Safe Purge Commands
Provide specific, copy-pasteable commands to reclaim space safely (e.g., apt-get, docker prune, journalctl vacuum). 

## ⚠️ High-Risk Warning
Clearly list directories or files that MUST NOT be touched to avoid system instability.

# 🚀 Strategic Optimization (Long-term)
Provide a systematic workflow for preventing future storage crises:
1. **Automation:** Recommendation for cron jobs or monitoring alerts.
2. **Architecture:** Advice on data offloading or disk expansion if necessary.
3. **Policy:** Suggested log retention or backup cleanup policies.

OUTPUT GUIDELINES:
- Ensure markdown is clean and readable.

# ⚠️ LEGAL DISCLAIMER
Include this EXACT text at the end of the report:
*Disclaimer: The recommendations in this report are suggestions based on AI analysis of system storage metrics. All commands should be reviewed by an expert Linux administrator before execution. We do not accept responsibility for any system instability, data loss, or breaking changes resulting from following these suggestions.*"""


def convert_md_to_html(
    input_path: str | Path,
    output_path: Optional[str | Path] = None,
    *,
    use_cdn: bool = False,
    encoding: str = "utf-8",
) -> Path:
    """
    Convert a Markdown file to HTML.

    Args:
        input_path: Path to the markdown file
        output_path: Destination HTML file (defaults to input with .html extension)
        use_cdn: Whether to embed CSS via CDN
        encoding: File encoding to use

    Returns:
        Path object pointing to the generated HTML file

    Raises:
        FileNotFoundError: If the input markdown file doesn't exist
    """
    input_path = Path(input_path)

    if not input_path.exists():
        raise FileNotFoundError(f"Markdown file not found: {input_path}")

    output_path = Path(output_path) if output_path else input_path.with_suffix(".html")

    markdown_content = input_path.read_text(encoding=encoding)
    converter = MarkdownConverter()
    html_output = converter.convert_markdown_to_html(markdown_content, use_cdn=use_cdn)
    output_path.write_text(html_output, encoding=encoding)

    return output_path


def run_command(cmd: str) -> str:
    """
    Execute a shell command and return its output.

    Args:
        cmd: Shell command to execute

    Returns:
        Command output as a string, or empty string on error
    """
    try:
        result = subprocess.check_output(
            cmd, shell=True, text=True, stderr=subprocess.DEVNULL
        )
        return result.strip()
    except subprocess.CalledProcessError:
        return ""


def create_section(title: str) -> str:
    """
    Create a markdown section header.

    Args:
        title: Section title

    Returns:
        Formatted markdown section header
    """
    return f"\n## {title}\n"


class Spinner:
    """A terminal spinner for showing progress during long-running operations."""

    def __init__(self, message: str = "Processing"):
        """
        Initialize the spinner.

        Args:
            message: Message to display alongside the spinner
        """
        self.spinner_frames = SPINNER_FRAMES
        self.message = message
        self.running = False
        self.thread: Optional[threading.Thread] = None

    def _spin(self) -> None:
        """Internal method to animate the spinner."""
        idx = 0
        while self.running:
            frame = self.spinner_frames[idx % len(self.spinner_frames)]
            sys.stdout.write(f"\r{frame} {self.message}...")
            sys.stdout.flush()
            time.sleep(0.1)
            idx += 1

    def start(self) -> None:
        """Start the spinner animation."""
        self.running = True
        self.thread = threading.Thread(target=self._spin, daemon=True)
        self.thread.start()

    def stop(self, final_message: str = "") -> None:
        """
        Stop the spinner animation.

        Args:
            final_message: Optional completion message to display
        """
        self.running = False
        if self.thread:
            self.thread.join()

        message = final_message or f"{self.message} complete!"
        sys.stdout.write(f"\r✓ {message}\n")
        sys.stdout.flush()


def collect_disk_data() -> str:
    """
    Collect comprehensive disk usage data from the system.

    Returns:
        Markdown-formatted report containing all disk metrics
    """
    report = "# 🦾 System Doctor PRO — Full Storage Intelligence Report\n\n---\n"

    # System Configuration section at the top
    report += create_section("💻 System Configuration")
    sys_info = {
        "OS Version": "os_version",
        "Kernel": "kernel",
        "CPU Model": "cpu_model",
        "CPU Cores": "cpu_cores",
        "System Type": "system_type"
    }
    for label, cmd_key in sys_info.items():
        report += f"**{label}:**\n{run_command(COMMANDS[cmd_key])}\n\n"

    sections = [
        ("Filesystem Overview (Capacity & Usage)", "filesystem"),
        ("Physical Devices & Partitions", "devices"),
        ("Inode Usage (File Exhaustion Risk)", "inodes"),
        ("Top Space Consumers (Root)", "root_usage"),
        ("Top Space Consumers (/home)", "home_usage"),
        ("Largest Files On System (>1GB)", "large_files"),
    ]

    for title, cmd_key in sections:
        report += create_section(title)
        report += f"```\n{run_command(COMMANDS[cmd_key])}\n```\n"

    report += create_section("🐳 Docker Infrastructure Status")
    docker_cmds = ["docker", "docker_ps", "docker_stats"]
    for cmd_key in docker_cmds:
        title = cmd_key.replace('_', ' ').title()
        report += f"### {title}\n"
        report += f"```\n{run_command(COMMANDS[cmd_key])}\n```\n"

    report += create_section("🚨 System Stability & Logs")
    report += "### Failed Services\n"
    report += f"```\n{run_command(COMMANDS['failed_services'])}\n```\n"
    report += "### Recent Critical Errors\n"
    report += f"```\n{run_command(COMMANDS['recent_errors'])}\n```\n"

    report += create_section("🧠 Memory & Performance Dashboard")
    perf_cmds = ["memory", "swap_usage", "load_uptime", "io_wait", "top_processes"]
    for cmd_key in perf_cmds:
        title = cmd_key.replace('_', ' ').title()
        report += f"### {title}\n"
        report += f"```\n{run_command(COMMANDS[cmd_key])}\n```\n"

    report += create_section("🌐 Networking & Security Audit")
    report += "### Listening Ports\n"
    report += f"```\n{run_command(COMMANDS['networking'])}\n```\n"
    report += "### UFW Firewall Status\n"
    report += f"```\n{run_command(COMMANDS['ufw_status'])}\n```\n"
    report += "### Recent Logins\n"
    report += f"```\n{run_command(COMMANDS['last_logins'])}\n```\n"

    report += create_section("📅 Scheduled Tasks Audit (Crontab)")
    report += "#### User Crontab\n"
    report += f"```\n{run_command(COMMANDS['user_cron'])}\n```\n"
    report += "#### Root Crontab\n"
    report += f"```\n{run_command(COMMANDS['root_cron'])}\n```\n"

    report += create_section("Package Cache & Log Weight")
    cache_output = run_command(COMMANDS["cache"])
    journal_output = run_command(COMMANDS["journal"])
    report += f"```\n{cache_output}\n{journal_output}\n```\n"

    return report


def analyze_with_ai(data: str) -> str:
    """
    Analyze disk data using Groq AI.

    Args:
        data: Raw disk analysis data in markdown format

    Returns:
        AI-generated analysis and recommendations in markdown format
    """
    client = Groq()

    completion = client.chat.completions.create(
        model=AI_MODEL,
        messages=[
            {"role": "system", "content": AI_SYSTEM_PROMPT},
            {"role": "user", "content": data},
        ],
        temperature=0.3,
        max_completion_tokens=4096,
        stream=True,
    )

    ai_response = ""
    for chunk in completion:
        ai_response += chunk.choices[0].delta.content or ""

    return ai_response


def check_api_key() -> None:
    """
    Verify that the Groq API key is configured.

    Exits the program with an error message if the key is not found.
    """
    if not os.getenv("GROQ_API_KEY"):
        print("\n❌ ERROR: Groq API key not found!")
        print("═" * 60)
        print("Please generate an API key from:")
        print(f"🔑 {GROQ_API_KEY_URL}")
        print("\nThen set it as an environment variable:")
        print("   export GROQ_API_KEY='your-api-key-here'")
        print("═" * 60 + "\n")
        sys.exit(1)


def print_header() -> None:
    """Print the application header."""
    print("\n🦾 System Doctor PRO — Storage Intelligence Analysis")
    print("═" * 60 + "\n")


def print_results(markdown_path: Path, html_path: Path) -> None:
    """
    Print the final results with file paths.

    Args:
        markdown_path: Path to the generated markdown report
        html_path: Path to the generated HTML report
    """
    print("\n" + "═" * 60)
    print("✅ Analysis Complete!")
    print("═" * 60)
    print(f"📝 Markdown: {markdown_path}")
    print(f"🌐 HTML:     {html_path}")
    print("═" * 60 + "\n")


def main() -> None:
    """Main application entry point."""
    check_api_key()
    print_header()

    # Collect disk data (without charts)
    spinner = Spinner("Collecting disk usage data")
    spinner.start()
    report_data = collect_disk_data()

    with open(TEMP_REPORT_PATH, "w", encoding="utf-8") as f:
        f.write(report_data)
    spinner.stop("Data collection complete")

    # AI analysis
    spinner = Spinner("🧠 AI analyzing storage patterns")
    spinner.start()

    with open(TEMP_REPORT_PATH, "r", encoding="utf-8") as f:
        raw_data = f.read()

    ai_analysis = analyze_with_ai(raw_data)
    spinner.stop("AI analysis complete")

    # Save results
    home_dir = Path.home()
    markdown_path = home_dir / "disk_doctor_report.md"
    
    disclaimer = """

---

> [!WARNING]
> **Legal Disclaimer:** The recommendations in this report are suggestions based on AI analysis of system storage metrics. All commands should be reviewed by an expert Linux administrator before execution. We do not accept responsibility for any system instability, data loss, or breaking changes resulting from following these suggestions.

"""

    with open(markdown_path, "w", encoding="utf-8") as f:
        f.write(ai_analysis)
        if "Disclaimer" not in ai_analysis:
            f.write(disclaimer)

    # Generate HTML
    spinner = Spinner("📄 Generating HTML report")
    spinner.start()
    html_path = convert_md_to_html(markdown_path, use_cdn=False)
    spinner.stop("Report generation complete")

    print_results(markdown_path, html_path)


if __name__ == "__main__":
    main()
