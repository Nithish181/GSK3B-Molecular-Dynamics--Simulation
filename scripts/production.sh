#!/bin/bash
#SBATCH --job-name=production
#SBATCH --partition=short
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --time=2-00:00:00
#SBATCH --output=production.out
#SBATCH --error=production.err

# -------------------------
# Environment setup
# -------------------------
module purge
module load AMBER/24
module load cuda/12.8.0
module load  nvidia-hpc-sdk/24.7

# -------------------------
# Run your script
# -------------------------

# -c equil.rst : Input from equilibration
# -r prod.rst  : Output restart file
# -x prod.nc   : Output trajectory (NetCDF)

pmemd.cuda -O \
           -i prod.in \
           -o prod.out \
           -p complex.prmtop \
           -c equil4.rst \
           -r prod.rst \
           -x prod.nc \
           -ref complex.inpcrd

