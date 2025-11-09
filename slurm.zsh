# ────────────────────────────────────────────────
# Slurm Utilities for Zsh
# ────────────────────────────────────────────────

# --- Aliases ---
alias sq='squeue -u $USER -o "%.10i %.50j %.8T %.10M %.15R %.20V"'

# --- Functions ---

get_slurm_stderr() {
    local jobid="$1"
    scontrol show job "$jobid" | awk -F= '/StdErr=/{print $2}'
}

slogerr() {
    local jobid=$1
    local file
    file=$(scontrol show job "$jobid" | awk -F= '/StdErr=/{print $2}')
    [ -f "$file" ] && tail -f "$file" || echo "stderr not available"
}

slogout() {
    local jobid=$1
    local file
    file=$(scontrol show job "$jobid" | awk -F= '/StdOut=/{print $2}')
    [ -f "$file" ] && less +F "$file" || echo "stdout not available"
}

scd() {
  local jobid="$1" file dir
  if [[ -z "$jobid" ]]; then
    echo "usage: scd <jobid>"
    return 1
  fi
  file=$(
    scontrol show job "$jobid" 2>/dev/null \
    | awk -F= '/StdErr=/{print $2; exit}'
  )
  if [[ -z "$file" ]]; then
    echo "stderr not available"
    return 1
  fi
  dir=${file:h}
  if [[ -d "$dir" ]]; then
    builtin cd -- "$dir"
  else
    echo "directory not found: $dir"
    return 1
  fi
}

showjob() {
    scontrol show job "$1"
}

# --- Load completion file ---
fpath=("${0:A:h}/completions" $fpath)
autoload -Uz compinit
if ! whence compinit >/dev/null; then
  autoload -Uz compinit
fi
compinit -C

