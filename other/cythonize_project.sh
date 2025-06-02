#!/bin/bash

# ----------------------------------------
# 🚀 Python Build System with Cython
# ----------------------------------------

set -euo pipefail
trap 'error "❌ Error occurred. Exiting..."; exit 1' ERR

# Constants
readonly ROOT_DIRECTORY=$(pwd)
readonly COMPILED_CODE_SOURCE_DIRECTORY="$ROOT_DIRECTORY/build"

# Directories to exclude (will be pruned recursively)
readonly EXCLUDED_PATTERNS=(*/.git* */__pycache__* */venv* ./build*)

# Optional: Read excluded files from .exclude_files if it exists
EXCLUDE_FILES=()
if [[ -f .exclude_files ]]; then
    IFS=$'\n' read -d '' -r -a EXCLUDE_FILES < .exclude_files || true
fi

# ---------- Logging Utilities ----------
log() {
    local BLUE="\033[1;34m"
    local RESET="\033[0m"
    echo -e "${BLUE}[INFO]${RESET} $*"
}

error() {
    local RED="\033[1;31m"
    local RESET="\033[0m"
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}

# ---------- Helpers ----------
is_excluded() {
    local rel_path="$1"
    for excluded in "${EXCLUDE_FILES[@]}"; do
        [[ "$rel_path" == "$excluded" ]] && return 0
    done
    return 1
}

prune_expr=()
for pattern in "${EXCLUDED_PATTERNS[@]}"; do
    prune_expr+=(-path "$pattern" -o)
done

# ---------- Directory Preparation ----------
prepare_output_dirs() {
    log "Preparing output directories..."
    mkdir -p "$COMPILED_CODE_SOURCE_DIRECTORY"
    find . \( "${prune_expr[@]}" -false \) -prune -o -type d -print | while read -r dir; do
        mkdir -p "$COMPILED_CODE_SOURCE_DIRECTORY/${dir#./}"
    done
}

# ---------- Python Compilation ----------
compile_python_files() {
    log "Converting Python files to shared objects..."
    find . \( "${prune_expr[@]}" -false \) -prune -o -name '*.py' -type f -print | while read -r py_file; do
        rel_path="${py_file#./}"
        if is_excluded "$rel_path"; then
            log "Excluded: $rel_path"
            cp "$py_file" "$COMPILED_CODE_SOURCE_DIRECTORY/$rel_path"
            continue
        fi

        c_file="${py_file%.py}.c"
        log "Compiling: $rel_path"
        cython "$py_file" -3 -o "$c_file"

        output_dir="$(dirname "$COMPILED_CODE_SOURCE_DIRECTORY/$rel_path")"
        base_name="$(basename "$py_file" .py)"
        gcc -shared -o "$output_dir/$base_name.so" -fPIC $(python3 -m pybind11 --includes) "$c_file"

        rm "$c_file"
    done
}

# ---------- Copy Static Assets ----------
copy_other_files() {
    log "Copying non-Python files..."
    find . \( "${prune_expr[@]}" -false \) -prune -o -type f ! -name '*.py' ! -name '*.c' -print | while read -r file; do
        rel_path="${file#./}"
        target_path="$COMPILED_CODE_SOURCE_DIRECTORY/$rel_path"
        mkdir -p "$(dirname "$target_path")"
        cp "$file" "$target_path"
    done
}

# ---------- Cleanup (Optional) ----------
cleanup() {
    log "Cleaning up temporary files..."
    rm -rf build
}

# ---------- Timer ----------
start_timer() { date +%s.%N; }
elapsed_time() { echo "$(echo "$(date +%s.%N) - $1" | bc)"; }

# ---------- Execution ----------
log "🚀 Build started from current directory..."
start=$(start_timer)
prepare_output_dirs
compile_python_files
copy_other_files
log "✅ Build completed in $(elapsed_time "$start") seconds"
log "🎉 Compiled project is in: $COMPILED_CODE_SOURCE_DIRECTORY"
