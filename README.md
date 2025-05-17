# MD-MMPBSA Analysis Pipeline

A GROMACS and gmx_MMPBSA-based workflow for protein-ligand binding free energy calculations.

## Introduction

This script is designed for post-processing molecular dynamics simulation trajectories and performing MM-PBSA calculations for protein-ligand binding free energy analysis. The workflow includes handling periodic boundary conditions (PBC), trajectory fitting to remove rotational and translational motions, and final binding free energy calculations using gmx_MMPBSA.

## Features

- Automatic processing of molecular dynamics trajectories to remove periodic boundary conditions
- Rotational and translational fitting to eliminate global molecular motion
- MM-PBSA binding free energy calculations on processed trajectories

## Dependencies

- GROMACS (recommended version 2021 or higher)
- gmx_MMPBSA
- MPI environment (for parallel computation)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/your-username/MD-MMPBSA-Analysis-Pipeline.git
cd MD-MMPBSA-Analysis-Pipeline
```

2. Ensure that GROMACS and gmx_MMPBSA are properly installed and configured in your environment

## Usage

### Basic Usage

```bash
bash run_mmpbsa.sh [GROMACS_PATH]
```

If no GROMACS path parameter is provided, the script will use the default value `/opt/software/gromacs2021-GPU/bin`.

### Examples

```bash
# Using default GROMACS path
bash run_mmpbsa.sh

# Specifying a custom GROMACS path
bash run_mmpbsa.sh /path/to/your/gromacs/bin
```

## Input Files

The script requires the following files to be in the same directory:

- `md_0_1.tpr` - GROMACS topology file
- `md_0_1.xtc` - GROMACS trajectory file
- `index.ndx` - Index file defining the required atom groups
- `topol.top` - System topology file
- `Ligand_GMX.itp` - Ligand parameter file
- `mmpbsa.in` - Input parameter file for MM-PBSA calculations

## Workflow Description

1. **Removing Periodic Boundary Conditions**:
   ```bash
   echo -e "22\n0" | $GMXBIN/gmx_mpi trjconv -s md_0_1.tpr -f md_0_1.xtc -o md_noPBC.xtc -pbc mol -center -n -ur compact
   ```
   This step uses the `trjconv` tool to remove periodic boundary conditions from the trajectory and centers it by molecule. Group 22 is used for centering, and the entire system (group 0) is processed.

2. **Rotational and Translational Fitting**:
   ```bash
   echo -e "22\n0" | $GMXBIN/gmx_mpi trjconv -s md_0_1.tpr -f md_noPBC.xtc -o md_fit.xtc -n -fit rot+trans
   ```
   The `trjconv` tool is used to perform rotational and translational fitting on the PBC-removed trajectory, eliminating the global motion of the protein to better analyze local conformational changes.

3. **MM-PBSA Calculation**:
   ```bash
   mpirun -np 16 gmx_MMPBSA -O -i mmpbsa.in -cs md_0_1.tpr -ci index.ndx -cg 1 19 -ct md_fit.xtc -cp topol.top
   ```
   MM-PBSA is calculated in parallel using 16 cores to analyze the protein-ligand binding free energy. Groups 1 and 19 represent the protein and ligand index groups, respectively.

## Output Files

- `md_noPBC.xtc` - Trajectory with periodic boundary conditions removed
- `md_fit.xtc` - Trajectory after rotational and translational fitting
- FINAL_DECOMP_MMPBSA.dat
- FINAL_RESULTS_MMPBSA.dat
And it will help you make some figures like：
![image](https://github.com/user-attachments/assets/f9305de6-71f8-4c1e-be09-9b8356849f43)
![7f8bfa5e17df695ab3f6143489b01d7](https://github.com/user-attachments/assets/985c41ff-bcf4-45b9-9b2d-e1b4f582446a)

## Notes

1. In the index file, group 22 should represent atoms suitable for centering and fitting (typically the protein backbone)
2. In the index file, groups 1 and 19 should represent the protein and ligand, respectively
3. Ensure that the `mmpbsa.in` file is correctly configured before running

## MM-PBSA Parameter Explanation

MM-PBSA calculation parameters are defined in the `mmpbsa.in` file. Common parameters include:
- Solvent model selection
- Salt concentration settings
- Internal dielectric constant
- External dielectric constant
- Entropy contribution calculation options
- And more


