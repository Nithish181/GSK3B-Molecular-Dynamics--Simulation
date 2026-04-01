# Molecular Dynamics Simulation of GSK-3β Kinase–Ligand Complex

**Author:** Nithish  
**Institution:** Northeastern University  
**Simulation Engine:** AMBER24 (`pmemd.cuda`)  
**System:** GSK-3β kinase (PDB: 1I09) with docked small-molecule ligand  
**Simulation Length:** 3 × 100 ns independent replicates  

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Repository Structure](#2-repository-structure)
3. [Dependencies & Software](#3-dependencies--software)
4. [System Preparation](#4-system-preparation)
5. [Simulation Protocol](#5-simulation-protocol)
6. [Analysis Pipeline](#6-analysis-pipeline)
7. [Key Results](#7-key-results)
8. [Reproducing This Work](#8-reproducing-this-work)
9. [Known Issues & HPC Notes](#9-known-issues--hpc-notes)
10. [License](#10-license)

---

## 1. Project Overview

This repository documents a complete, reproducible Molecular Dynamics (MD) simulation pipeline for characterizing the binding stability and free energy of a small-molecule ligand within the ATP-binding pocket of **Glycogen Synthase Kinase-3β (GSK-3β)** — a validated therapeutic target implicated in Alzheimer's disease, Type 2 diabetes, and various cancers.

The crystal structure used is **PDB ID: 1I09**, which contains GSK-3β in complex with a staurosporine-derived inhibitor. The ligand was docked into the binding pocket using AutoDock Vina, and the resulting complex was subjected to three independent 100 ns production MD simulations to characterize binding stability and compute binding free energies via MM-GBSA.

**Scientific goals:**
- Assess structural stability of the protein–ligand complex over 100 ns
- Characterize key binding interactions (hydrogen bonds, van der Waals contacts)
- Quantify binding affinity using MM-GBSA free energy decomposition
- Validate reproducibility across three independent simulation replicates

---

## 2. Repository Structure

```
GSK3B-MD-Simulation/
│
├── README.md                        # This file
├── LICENSE
│
├── scripts/
│   └── slurm/
│       ├── 01_minimization.sh       # Energy minimization (2-stage)
│       ├── 02_heating.sh            # Heating 0 → 300 K (NVT, 100 ps)
│       ├── 03_equilibration.sh      # Equilibration stages 1–4 (NPT, 4 ns total)
│       ├── 04_production.sh         # Production MD (100 ns, NPT)
│       └── 05_mmgbsa.sh             # MM-GBSA binding free energy
│
├── analysis/
│   ├── imaging.cpptraj              # Trajectory imaging (autoimage, PBC fix)
│   ├── rmsd.cpptraj                 # Protein backbone + ligand RMSD
│   ├── rg.cpptraj                   # Radius of gyration
│   ├── hbonds.cpptraj               # Hydrogen bond occupancy analysis
│   └── strip_for_mmgbsa.cpptraj     # Strip water/ions for MM-GBSA topology
│
├── figures/
│   ├── rmsd_all_replicates.png      # RMSD time series (Rep1–3)
│   ├── rg_all_replicates.png        # Radius of gyration (Rep1–3)
│   ├── hbond_occupancy.png          # H-bond occupancy bar chart
│   └── mmgbsa_summary.png           # MM-GBSA energy decomposition
│
└── data/
    └── results_summary.md           # Numerical results across all replicates
```

---

## 3. Dependencies & Software

| Software | Version | Purpose |
|---|---|---|
| AMBER | 24 | MD simulation engine (`pmemd.cuda`) |
| AmberTools | 24 | `tleap`, `antechamber`, `parmchk2`, `cpptraj`, `MMPBSA.py` |
| OpenBabel | ≥ 3.0 | Ligand format conversion (PDBQT → mol2) |
| Python | ≥ 3.8 | Pre-processing scripts |
| CUDA | Compatible with GPU nodes | GPU acceleration |
| SLURM | HPC scheduler | Job submission |

**Force fields used:**
- Protein: `ff19SB`
- Ligand: `GAFF2` (General Amber Force Field v2)
- Water: `OPC` (4-point explicit solvent model)
- Ions: `ionslm_126_opc` (Li/Merz ion parameters for OPC)

---

## 4. System Preparation

### 4.1 Starting Structure

The protein–ligand complex was prepared from PDB ID **1I09**. The ligand (residue 703, assigned residue name `LIG`) was docked into the GSK-3β binding pocket using AutoDock Vina. **Critically, the protein and ligand coordinates must originate from the same docked complex file** to avoid coordinate frame mismatches.

### 4.2 Ligand Parameterization

```bash
# Convert PDBQT output to PDB, then to mol2
obabel ligand.pdbqt -O ligand.mol2 --gen3d

# Generate GAFF2 parameters
antechamber -i ligand.mol2 -fi mol2 \
            -o LIG.mol2 -fo mol2 \
            -c bcc -s 2 -at gaff2 -rn LIG

# Generate missing force field parameters
parmchk2 -i LIG.mol2 -f mol2 -o LIG.frcmod
```

> **Note:** Duplicate bonds in mol2 files produced by OpenBabel must be deduplicated before running antechamber. A Python script for this is available in `scripts/`.

### 4.3 Topology & Coordinate Files (tleap)

```bash
source leaprc.protein.ff19SB
source leaprc.gaff2
source leaprc.water.opc
loadamberparams LIG.frcmod
LIG = loadmol2 LIG.mol2

complex = loadpdb complex.pdb
solvateoct complex OPCBOX 12.0
addions complex Na+ 0
addions complex Cl- 0

saveamberparm complex complex.prmtop complex.inpcrd
quit
```

The system was solvated in a truncated octahedral OPC water box with 12 Å padding, and neutralized with Na⁺/Cl⁻ ions.

---

## 5. Simulation Protocol

All stages were run using `pmemd.cuda` on GPU nodes via SLURM. See `scripts/slurm/` for full input files.

### Stage Overview

| Stage | Type | Length | Restraints | Barostat |
|---|---|---|---|---|
| Minimization 1 | Energy min | 5,000 steps | Heavy atoms (500 kcal/mol·Å²) | — |
| Minimization 2 | Energy min | 10,000 steps | None | — |
| Heating | NVT | 100 ps | Backbone + ligand (10 kcal/mol·Å²) | — |
| Equilibration 1–3 | NPT | 1 ns each | Backbone + ligand (10→1 kcal/mol·Å²) | Berendsen |
| Equilibration 4 | NPT | 1 ns | None | Monte Carlo |
| Production | NPT | 100 ns | None | Monte Carlo |

### Key Simulation Parameters

```
dt       = 0.002       # 2 fs timestep
cut      = 10.0        # Non-bonded cutoff (Å)
temp0    = 300.0       # Target temperature (K)
pres0    = 1.0         # Target pressure (atm)
ntp      = 1           # Pressure coupling
ntc      = 2           # SHAKE constraints on H-bonds
ntf      = 2           # No force eval for SHAKE bonds
ntwx     = 5000        # Write coordinates every 5000 steps (10 ps)
ntwr     = 5000        # Write restart every 5000 steps
```

### Critical Protocol Notes

- **Restraint mask:** `@CA,C,N,O | :703` — the pipe operator combines backbone atoms and ligand (residue 703). Omitting the ligand from restraints during heating/equilibration causes ligand escape from the binding pocket.
- **Barostat selection:** The Monte Carlo barostat (`barostat=2`) causes density explosion when used with positional restraints. Berendsen (`barostat=1`) must be used for all restrained stages (equil1–3). Monte Carlo is only used for unrestrained equilibration (equil4) and production.
- **AMBER namelists:** Only Fortran-style comments are valid *outside* `&cntrl` blocks. `#` or `!` characters inside `&cntrl` will cause input file errors.

---

## 6. Analysis Pipeline

All analysis was performed using `cpptraj` from AmberTools24. Trajectories from all three replicates were analyzed independently and results compared for reproducibility.

### 6.1 Trajectory Imaging (Critical First Step)

Raw trajectories must be re-imaged before any distance-based analysis to correct for periodic boundary condition (PBC) artifacts:

```
parm complex.prmtop
trajin production.nc
autoimage anchor :1-702
trajout production_imaged.nc
run
```

> **Warning:** Skipping this step produces artifactual ligand drift of 50–100 Å due to molecules jumping across PBC boundaries, which completely invalidates RMSD and hydrogen bond calculations.

### 6.2 RMSD

```
parm complex.prmtop
trajin production_imaged.nc
reference minimized.rst
rms backbone @CA,C,N,O out rmsd_backbone.dat
rms ligand :703 out rmsd_ligand.dat nofit
run
```

### 6.3 Radius of Gyration

```
parm complex.prmtop
trajin production_imaged.nc
radgyr :1-702 out rg.dat mass
run
```

### 6.4 Hydrogen Bond Occupancy

```
parm complex.prmtop
trajin production_imaged.nc
hbond :1-702 :703 out hbonds.dat avgout hbond_avg.dat \
      solventdonor :WAT solventacceptor :WAT:O
run
```

### 6.5 MM-GBSA Binding Free Energy

Requires a stripped (no water/ions) topology:

```bash
# Source AMBER environment
source /shared/EL9/explorer/AMBER/24/amber.sh
module load anaconda3/2024.06

# Run MM-GBSA
MMPBSA.py -O -i mmgbsa.in \
          -o mmgbsa_results.dat \
          -cp complex_nowater.prmtop \
          -rp receptor_nowater.prmtop \
          -lp ligand.prmtop \
          -y production_imaged.nc
```

MM-GBSA input (`mmgbsa.in`):
```
&general
  startframe=1, endframe=10000, interval=10,
  verbose=2,
/
&gb
  igb=2, saltcon=0.150,
/
```

---

## 7. Key Results

Full numerical results are in `data/results_summary.md`. Summary below:

### Structural Stability

| Metric | Rep1 | Rep2 | Rep3 |
|---|---|---|---|
| Protein backbone RMSD (mean, Å) | ~2.5 | ~2.8 | ~3.1 |
| Ligand RMSD (mean, Å) | ~0.76 | ~0.98 | ~1.14 |
| Radius of gyration (mean, Å) | ~28.77 | ~28.79 | ~28.81 |
| Mean H-bonds per frame | ~5.2 | ~5.6 | ~5.1 |

All three replicates show stable protein structure (RMSD plateau within ~20 ns) and a stably bound ligand (RMSD < 1.5 Å throughout), confirming convergence.

### Key Binding Residues (H-bond occupancy > 20%)

- **PHE385** — backbone carbonyl H-bond acceptor
- **SER521** — sidechain hydroxyl donor/acceptor
- **GLY520** — backbone NH donor
- **VAL233** — backbone carbonyl acceptor

### MM-GBSA Binding Free Energy

| Component | Rep1 | Rep2 | Rep3 |
|---|---|---|---|
| ΔG_bind (kcal/mol) | ~−22.3 | ~−23.8 | ~−24.6 |
| ΔE_vdW (kcal/mol) | dominant contributor | | |
| ΔE_elec (kcal/mol) | moderate | | |
| ΔG_polar solvation | unfavorable | | |

Van der Waals interactions are the primary driver of binding, consistent with the hydrophobic character of the ATP-binding pocket in GSK-3β.

---

## 8. Reproducing This Work

### Step-by-step

1. **Clone this repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/GSK3B-MD-Simulation.git
   cd GSK3B-MD-Simulation
   ```

2. **Obtain the starting structure**
   - Download PDB 1I09 from [RCSB PDB](https://www.rcsb.org/structure/1I09)
   - Dock ligand using AutoDock Vina; save complex as `complex.pdb`

3. **Parameterize the ligand**
   - Follow Section 4.2 using `antechamber` and `parmchk2`

4. **Build topology**
   - Run `tleap` as in Section 4.3

5. **Submit SLURM jobs in order**
   ```bash
   sbatch scripts/slurm/01_minimization.sh
   sbatch scripts/slurm/02_heating.sh
   sbatch scripts/slurm/03_equilibration.sh
   sbatch scripts/slurm/04_production.sh
   ```

6. **Run analysis**
   ```bash
   cpptraj -i analysis/imaging.cpptraj
   cpptraj -i analysis/rmsd.cpptraj
   cpptraj -i analysis/rg.cpptraj
   cpptraj -i analysis/hbonds.cpptraj
   sbatch scripts/slurm/05_mmgbsa.sh
   ```

---

## 9. Known Issues & HPC Notes

- **Excluded GPU nodes:** Nodes `d1004`, `c2193`, `c2194` produce illegal memory access (CUDA) errors with AMBER24. These are excluded via `--exclude=d1004,c2193,c2194` in all SLURM scripts.
- **Performance:** Using `pmemd.cuda` on the `short` partition achieves ~149 ns/day.
- **Monte Carlo barostat with restraints:** Using `barostat=2` with `ntr=1` causes catastrophic density explosion. Always use `barostat=1` (Berendsen) when positional restraints are active.
- **MM-GBSA environment:** Must source `/shared/EL9/explorer/AMBER/24/amber.sh` and `module load anaconda3/2024.06` before running `MMPBSA.py`.

---

## 10. License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

*For questions or issues, please open a GitHub Issue.*
