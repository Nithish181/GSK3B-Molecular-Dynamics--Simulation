#!/bin/bash
#SBATCH --job-name=energy_minimization
#SBATCH --partition=courses-gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --time=1-00:00:00
#SBATCH --output=energy_minimization.out
#SBATCH --error=energy_minimization.err

# -------------------------
# Environment setup
# -------------------------
module purge
module load AMBER/24
module load cuda/12.8.0
module load nvidia-hpc-sdk/24.7

# -------------------------
# Run your script
# -------------------------

pmemd.cuda -O \
           -i heat.in \
           -o heat.out \
           -p complex.prmtop \
           -c min.rst \
           -r heat.rst \
           -x heat.nc \
           -ref complex.inpcrd

echo "Rep2 Heating Complete!"
