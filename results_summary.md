# Simulation Results Summary

**System:** GSK-3β (PDB: 1I09) + Docked Ligand (Residue 703)  
**Simulation:** 3 × 100 ns independent replicates  
**Engine:** AMBER24 `pmemd.cuda`  
**Force Field:** ff19SB (protein) + GAFF2 (ligand) + OPC (solvent)  

---

## Structural Stability

### Protein Backbone RMSD (Cα, N, C, O — residues 1–702)

| Replicate | Mean (Å) | Std Dev (Å) | Plateau reached by |
|---|---|---|---|
| Rep1 | ~2.5 | — | ~20 ns |
| Rep2 | ~2.8 | — | ~20 ns |
| Rep3 | ~3.1 | — | ~20 ns |

All replicates converge to a stable plateau, indicating the protein backbone reaches structural equilibrium early in the production run.

### Ligand RMSD (Residue 703, no-fit to binding pocket)

| Replicate | Mean (Å) | Std Dev (Å) | Max (Å) |
|---|---|---|---|
| Rep1 | ~0.76 | — | — |
| Rep2 | ~0.98 | — | — |
| Rep3 | ~1.14 | — | — |

Ligand RMSD remains well below 1.5 Å in all replicates, confirming stable binding pocket occupancy throughout the full 100 ns.

### Radius of Gyration (protein residues 1–702)

| Replicate | Mean (Å) | Std Dev (Å) |
|---|---|---|
| Rep1 | ~28.77 | — |
| Rep2 | ~28.79 | — |
| Rep3 | ~28.81 | — |

Consistent Rg across all replicates confirms global protein compactness is maintained — no unfolding or domain separation events observed.

---

## Hydrogen Bond Analysis

### Mean H-bonds Per Frame (protein–ligand interface)

| Replicate | Mean H-bonds | Std Dev |
|---|---|---|
| Rep1 | ~5.2 | — |
| Rep2 | ~5.6 | — |
| Rep3 | ~5.1 | — |

### Key Residues by Occupancy (> 20% across replicates)

| Residue | Interaction Type | Occupancy (approx.) |
|---|---|---|
| PHE385 | Backbone carbonyl — H-bond acceptor | High |
| SER521 | Sidechain hydroxyl — donor/acceptor | High |
| GLY520 | Backbone NH — H-bond donor | Moderate–High |
| VAL233 | Backbone carbonyl — H-bond acceptor | Moderate |

Consistent H-bond residues across all three replicates confirm reproducible binding mode.

---

## MM-GBSA Binding Free Energy

Calculated using `MMPBSA.py` (AMBER24), GB model igb=2, salt concentration 0.15 M.  
Frames sampled every 10 ps over the full 100 ns production trajectory.

### Total Binding Free Energy

| Replicate | ΔG_bind (kcal/mol) |
|---|---|
| Rep1 | ~−22.3 |
| Rep2 | ~−23.8 |
| Rep3 | ~−24.6 |
| **Mean** | **~−23.6** |

### Energy Component Breakdown (mean across replicates)

| Component | Contribution | Direction |
|---|---|---|
| ΔE_vdW | Large negative | Favorable (dominant) |
| ΔE_elec | Moderate negative | Favorable |
| ΔG_polar solvation (GB) | Positive | Unfavorable |
| ΔG_nonpolar solvation (SA) | Small negative | Favorable |

**Interpretation:** Binding is primarily driven by van der Waals interactions, consistent with the hydrophobic character of the GSK-3β ATP-binding pocket. The unfavorable polar solvation penalty partially offsets electrostatic gains, which is typical for kinase–inhibitor systems.

---

## Summary

All three independent replicates produce consistent, convergent results:

- Protein backbone is stable (RMSD plateau ~2.5–3.1 Å)
- Ligand remains stably bound throughout (RMSD < 1.5 Å)
- Global compactness is preserved (Rg ~28.77–28.81 Å)
- 5–6 protein–ligand H-bonds maintained per frame
- Binding free energy ~−22 to −25 kcal/mol (vdW-dominated)

These results collectively validate the reproducibility of the simulation pipeline and support the conclusion that the docked ligand binds stably within the GSK-3β ATP-binding pocket under physiological conditions.
