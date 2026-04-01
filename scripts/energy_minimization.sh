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

pmemd.cuda -O -i min.in -o min.out -p complex.prmtop -c complex.inpcrd -r min.rst -ref complex.inpcrd


# AMBER min.in parameter explanation:
# imin=1          : Perform energy minimization
# maxcyc=5000     : Maximum 5000 minimization cycles
# ncyc=2500       : First 2500 = steepest descent, next 2500 = conjugate gradient
# ntb=1           : Periodic boundary conditions at constant volume
# ntp=0           : No pressure scaling during minimization
# ntf=1           : Calculate forces for ALL bonds including hydrogen
# ntc=1           : No SHAKE - all bond lengths free during minimization
# cut=10.0        : Nonbonded cutoff = 10 Angstroms
# ntpr=100        : Print energy every 100 steps
# ntxo=1          : Write restart file in ASCII format
# ntr=1           : Turn ON positional restraints
# restraint_wt    : 10 kcal/mol/Å² - strong enough to keep ligand in pocket
# restraintmask   : Restrain protein backbone (CA,C,N,O) AND ligand (:LIG)
#                   This prevents ligand escaping during clash removal

# Run energy minimization
# -O   : overwrite output files if they exist
# -i   : input file (min.in)
# -o   : output file (energies and progress)
# -p   : topology file (connectivity and parameters)
# -c   : input coordinates (starting structure from tleap)
# -r   : output restart file (minimized coordinates for next step)
# -ref : reference coordinates for restraints
 
