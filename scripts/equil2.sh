#!/bin/bash
#SBATCH --job-name=GSK3b_equil2
#SBATCH --partition=courses-gpu
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=04:00:00
#SBATCH --output=equil2.out
#SBATCH --error=equil2.err

module purge
module load AMBER/24
module load cuda/12.8.0
module load  nvidia-hpc-sdk/24.7


pmemd.cuda -O \
           -i equil2.in \
           -o equil2.out \
           -p complex.prmtop \
           -c equil1.rst \
           -r equil2.rst \
           -x equil2.nc \
           -ref complex.inpcrd
