#!/bin/bash
#SBATCH --job-name=GSK3b_equil1
#SBATCH --partition=courses-gpu
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=04:00:00
#SBATCH --output=equil1.out
#SBATCH --error=equil1.err

module purge
module load AMBER/24
module load cuda/12.8.0
module load  nvidia-hpc-sdk/24.7


pmemd.cuda -O \
           -i equil1.in \
           -o equil1.out \
           -p complex.prmtop \
           -c heat.rst \
           -r equil1.rst \
           -x equil1.nc \
           -ref complex.inpcrd

echo "Equilibration stage 1 Done "
