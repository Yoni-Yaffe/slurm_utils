# Slurm Utils

A lightweight toolkit for **running, monitoring, and managing Slurm jobs**.  
Includes:
- Python scripts for launching and logging tasks 
- Zsh utilities and completions for inspecting jobs 

---

## 📁 Repository Structure

```
.
├── completions/           # Directory containing Zsh completion scripts
│   └── _jobid             # Zsh job-ID autocompletion for Slurm commands (slogerr, scd, etc.)
├── config.yaml            # Example or default YAML configuration file for defining job parameters
├── main.py                # Entry point for job execution; parses YAML config and runs tasks
├── README.md              # Documentation describing usage, setup, and features
├── requirements.txt       # Python dependencies (e.g., pyyaml)
├── send_to_slurm.py       # Script for submitting tasks to Slurm using YAML configurations
├── slurm.zsh              # Zsh utilities for inspecting jobs, tailing logs, and quick navigation
└── start_job              # Bash wrapper script that initializes environment, logs metadata, and runs main.py

```

## 📊 Job Monitoring and Management

---

## ⚙️ Installation

1. Clone the repo.

2. Create slurm utils directory under home dir (optional):
```bash
mkdir -p ~/.slurm-utils
```
3. copy slurm.zsh and completions/_jobid under it
4. Source the utilities in your ~/.zshrc:

```bash
source ~/.slurm-utils/slurm.zsh
```

5. Enable completions by adding to your ~/.zshrc:

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



## 🚀 Task Submission

The `slurm_tasks` part of this toolkit provides an easy way to define and submit Slurm jobs through YAML configuration files.

### 🧩 Example Configuration (`config.yaml`)

Below is an example configuration file that controls both the Slurm parameters and the task itself:

```yaml
slurm_params:
  output: "slurmlog.out"        # Redirect stdout
  error: "slurmlog.err"         # Redirect stderr
  partition: studentkillable    # Slurm partition (queue)
  time: "240"                   # Max time (minutes)
  signal: "USR1@120"            # Signal before timeout (120s)
  nodes: "1"                    # Number of machines
  ntasks: "1"                   # Number of processes
  mem: "16000"                  # CPU memory (MB)
  cpus-per-task: "8"            # CPU cores per process
  gpus: "1"                     # Total GPUs to allocate
  # constraint: "titan_xp"
  exclude: "s-002"              # Nodes to exclude

train_params:
  # training-specific parameters go here
  # e.g., batch_size: 32, epochs: 100

inference_params:
  # inference-specific parameters go here

command: "start_job"            # Script or command to run
run_type: "train"               # Custom field used by main.py
run_name: "your_run_name"       # Must not contain spaces; used in logdir and job name
```

### 🧠 How Submission Works

1. Prepare your YAML configuration file (for example: config.yaml) with the desired Slurm parameters, command, and run settings.  
2. Launch the job using:
```bash
python send_to_slurm.py --yaml_config path/to/config.yaml  
```
3. The script send_to_slurm.py will:  
   • Parse the YAML configuration.  
   • Create a dedicated log directory based on run_name and the log directory.  
   • Generate and submit an sbatch command that calls start_job, passing along the YAML path and log directory.  

4. Once the job starts, start_job will:  
   • Log metadata such as JobID, Host, start time, and runtime into job_launch.log.  
   • Print system details (for example: nvidia-smi, node info, CPU/GPU resources).  
   • Activate your virtual environment (defined in the YAML or the script).  
   • Run main.py, which loads the YAML configuration and executes logic based on the run_type field (for example: train or inference).  

### 🗂️ Log Output

Each submitted job creates its own folder under your log base directory:

    logs/your_run_name/
    ├── slurmlog.out         # Stdout captured by Slurm
    ├── slurmlog.err         # Stderr captured by Slurm
    ├── run_config.yaml      # YAML configuration used for this run
    └── job_launch.log       # Job metadata (start, end, runtime)

You can monitor job output in real time with the provided utilities:

    slogerr <jobid>     # Follow stderr live
    slogout <jobid>     # Follow stdout live
    scd <jobid>         # Jump to the job's output directory

### 🪵 Log Directory Configuration

By default, all submitted jobs are logged under:

    /vol/scratch/<username>/runs

You can change this default path in `send_to_slurm.py` by editing the line that defines `DEFAULT_LOG_DIR`.  
The script automatically detects your $USER env variable


### 🧾 Requirements

- A working Slurm setup on your system.  
- Python dependencies listed in requirements.txt (at least pyyaml).  
- Any paths defined in the YAML (such as virtual environment or data paths) must point to valid locations.

## 🧾 License

MIT License © 2025 Jonathan Yaffe

