#!/bin/bash
#SBATCH --partition=p_ccib_1
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=buscophy
#SBATCH --output=[YOUR PATH HERE]/busco/slurmout/slurm-%j-%x.out
#SBATCH --mem=180G
#SBATCH -n 20
#SBATCH -N 1
#SBATCH --time=7-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=[YOUR NETID]@rutgers.edu
#SBATCH --mail-type=FAIL
 
echo "load modules"
 
eval "$(conda shell.bash hook)"
conda activate busco

 
echo "run busco supermatrix"
 
python BUSCO_Phylogenomics.py -d phy_input -o phy_out_supermatrix_psc75 --supermatrix --threads 20 -psc 75

echo "done"
