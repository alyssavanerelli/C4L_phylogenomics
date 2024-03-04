#!/bin/bash
#SBATCH --partition=main
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=busco_$1
#SBATCH --output=[YOUR_PATH_HERE]/busco/slurmout/slurm-%j-%x.out
#SBATCH --mem=10G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=[YOUR_NETID]@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load conda environment"
eval "$(conda shell.bash hook)"
conda activate busco

echo "load variables"
FASTA=$1

echo "run busco"
busco -i [YOUR_PATH_HERE]/busco/genomes/${FASTA} -c 16 -l diptera_odb10 -o ${FASTA} -m genome --offline

echo "done"
