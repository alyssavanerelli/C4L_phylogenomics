#!/bin/bash
#SBATCH --partition=main
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=move
#SBATCH --output=[YOUR PATH HERE]/busco/slurmout/slurm-%j-%x.out
#SBATCH --mem=5G
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --time=0-02:00:00
#SBATCH --requeue
#SBATCH --mail-user=[YOUR NETID]@rutgers.edu
#SBATCH --mail-type=FAIL

SPECIES=$1

cp -R [YOUR PATH HERE]/busco/busco_out/${SPECIES}/run_diptera_odb10 [YOUR PATH HERE]/busco/phy_input/run_${SPECIES}
