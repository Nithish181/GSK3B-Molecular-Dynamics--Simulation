#!/bin/bash
#SBATCH --job-name=GSK3b_equil3
#SBATCH --partition=courses-gpu
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=04:00:00
#SBATCH --output=equil3.out
#SBATCH --error=equil3.err

module purge
module load AMBER/24
module load cuda/12.8.0
module load  nvidia-hpc-sdk/24.7


pmemd.cuda -O \
           -i equil3.in \
           -o equil3.out \
           -p complex.prmtop \
           -c equil2.rst \
           -r equil3.rst \
           -x equil3.nc \
           -ref complex.inpcrd
