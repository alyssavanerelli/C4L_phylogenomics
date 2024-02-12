#!/bin/bash
#SBATCH --partition=main
#SBATCH --exclude=gpuc001,gpuc002
#SBATCH --job-name=busco
#SBATCH --output=[YOUR PATH HERE]/busco/slurmout/slurm-%j-%x.out
#SBATCH --mem=160G
#SBATCH -n 16
#SBATCH -N 1
#SBATCH --time=3-00:00:00
#SBATCH --requeue
#SBATCH --mail-user=[YOUR NETID]@rutgers.edu
#SBATCH --mail-type=FAIL


echo "load conda environment"
eval "$(conda shell.bash hook)"
conda activate busco

echo "load variables"
FASTA=$1

echo "run busco"
busco -i [YOUR PATH HERE]/busco/genomes/${FASTA} -c 16 -l diptera_odb10 -o ${FASTA} -m genome

echo "done"
