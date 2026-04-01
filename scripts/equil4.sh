#!/bin/bash
#SBATCH --job-name=GSK3b_equil4
#SBATCH --partition=courses-gpu
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=04:00:00
#SBATCH --output=equil4.out
#SBATCH --error=equil4.err

module purge
module load AMBER/24
module load cuda/12.8.0
module load  nvidia-hpc-sdk/24.7


pmemd.cuda -O \
           -i equil4.in \
           -o equil4.out \
           -p complex.prmtop \
           -c equil3.rst \
           -r equil4.rst \
           -x equil4.nc \
           -ref complex.inpcrd
