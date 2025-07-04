#!/bin/bash
#
#SBATCH -p test # partition (queue)
#SBATCH -c 2 # number of cores 
#SBATCH --mem 5GB # memory 
#SBATCH -t 0-00:05 # time (D-HH:MM)
#SBATCH -o job_render_dashboard.%N.%j.out # STDOUT
#SBATCH -e job_render_dashboard.%N.%j.err # STDERR


# Render Quarto dashboard from cron
date

# Load your environment – required for R, quarto, github authorization
source ~/.bashrc
mamba activate compute_tracker
quarto check
git config -l
gh auth status

# Change to the project directory
cd /n/holylabs/LABS/cgolden_lab/Lab/projects/compute_tracker

# run data collection
sshare --account=cgolden_lab -apmU > data.txt

# Render the dashboard
quarto render

# Commit and push changes if any

## git diff --exit-code is a very handy way to check if there are changes
## to the repo. Basically, if there are changes, it will return a non-zero exit code.
if ! git diff --exit-code; then
    echo "Changes detected, committing and pushing..."
    git add .
    git commit -m "Re-render dashboard on $(date)"
    git push origin main    
    echo "Changes pushed to the repository."
else
    echo "No changes detected, skipping commit and push."
fi