#!/bin/bash
#SBATCH --job-name=GSK3b_mmgbsa
#SBATCH --partition=courses-gpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=1-00:00:00
#SBATCH --output=mmgbsa.out
#SBATCH --error=mmgbsa.err

module purge
module load AMBER/24
source /shared/EL9/explorer/AMBER/24/amber.sh
module load cuda/12.8.0
module load  nvidia-hpc-sdk/24.7

python3 /shared/EL9/explorer/AMBER/24/bin/MMPBSA.py -O \
          -i mmgbsa.in \
          -o FINAL_RESULTS_MMGBSA.dat \
          -cp com.prmtop \
          -rp rec.prmtop \
          -lp lig.prmtop \
          -y prod_dry.nc

echo "Binding affinity is done !!"

