import requests
from datetime import datetime

def get_pypi_package_info(package_name):
    url = f"https://pypi.org/pypi/{package_name}/json"
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        
        # Get latest version
        latest_version = data["info"]["version"]
        
        # Get the latest release date
        releases = data.get("releases", {})
        if latest_version in releases and releases[latest_version]:
            upload_time = releases[latest_version][0]["upload_time_iso_8601"]
            last_updated = datetime.fromisoformat(upload_time.rstrip('Z')).strftime('%Y-%m-%d %H:%M:%S')
        else:
            last_updated = "N/A"
        
        return {
            "name": package_name,
            "latest_version": latest_version,
            "last_updated": last_updated
        }

    except requests.exceptions.HTTPError as http_err:
        return {"error": f"HTTP error occurred: {http_err}"}
    except Exception as err:
        return {"error": f"Other error occurred: {err}"}

# Example usage
if __name__ == "__main__":
    pkg = input("Enter PyPI package name: ").strip()
    info = get_pypi_package_info(pkg)
    print(info)
