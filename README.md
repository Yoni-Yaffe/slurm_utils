# Slurm Utils

A lightweight collection of **Zsh utilities and completions** for interacting with [Slurm](https://slurm.schedmd.com/) job schedulers.  
Includes handy functions for viewing job logs, jumping to job directories, and quick job-ID completion for common commands.

---

## 📁 Repository Structure

slurm-utils/
├── slurm.zsh # Main utility functions and aliases
└── completions/
└── _jobid # Job ID autocompletion for common Slurm commands




---

## ⚙️ Installation

1. **Clone the repo:**
   ```bash
   git clone https://github.com/<your-username>/slurm-utils.git ~/.slurm-utils
   ```


2. Source the utilities in your ~/.zshrc:

```bash
source ~/.slurm-utils/slurm.zsh
```

3. Enable completions by adding to your ~/.zshrc:

```bash
if [[ ":$fpath:" != *":$HOME/.slurm-utils/completions:"* ]]; then
  fpath+=("$HOME/.slurm-utils/completions")
fi
autoload -U compinit && compinit
```
You may need to restart your shell for the changes to take effect.


## 🧩 Features

### 🔹 Aliases

| Alias | Description |
|-------|--------------|
| `sq` | Compact `squeue` view for the current user (`squeue -u $USER -o "%.10i %.50j %.8T %.10M %.15R %.20V"`) |

---

### 🔹 Functions

| Function | Description |
|-----------|--------------|
| `get_slurm_stderr <jobid>` | Print the path to the job’s stderr file. |
| `slogerr <jobid>` | Tail the stderr of a running or finished job (`tail -f`). |
| `slogout <jobid>` | Follow the stdout of a job using `less +F`. |
| `scd <jobid>` | Change directory to the job’s stderr output folder. |
| `showjob <jobid>` | Show detailed job information via `scontrol show job`. |

---

### 🔹 Completions

The `_jobid` completion script provides **smart autocompletion of Slurm job IDs** for the following commands:

```
slogerr, slogout, scancel, scd, showjob
```

When you press <kbd>Tab</kbd>, you’ll see a formatted list of your active jobs (from `squeue --me`) including partition, job name, user, state, runtime, and node.


---

## 🧠 Example Usage

```bash
sq

# 108123 train_model.py  RUNNING  00:34:12  gpu-node03  2025-11-09T15:03:00

slogerr 108123      # Follow job stderr in real time
slogout 108123      # Follow stdout
scd 108123          # Jump to the job’s output directory
showjob 108123      # Show full scontrol info
```

## 🧰 Requirements

- **Zsh** (for the completions)
- **Slurm** client utilities (`squeue`, `scontrol`, etc.) available in PATH.

---

### 💡 Note

You can use all the functions (`slogerr`, `slogout`, `scd`, `showjob`, etc.) **without enabling autocompletion** — just type the commands manually with a job ID.  

Autocompletion is optional and currently implemented **only for Zsh**.  
If you’re using **Bash**, you can still source `slurm.zsh` (or rename it to `slurm.sh`) and call the functions normally; only the <kbd>Tab</kbd> completion feature will be unavailable.


## 🧾 License

MIT License © 2025 Jonathan Yaffe

