# C4L busco phylogenomics pipeline

**Directory Structure**
- `busco/`
  - `genomes/`
    - downloaded genome fasta files
  - `busco_out/`
    - results from busco run
  - `phy_input/`
    - some of the busco results will be moved here as input for busco_phylogenomics
  - `phy_output/`
    - directory where output from busco_phylogenomics will go
  - `slurmout/`
    - where slurm output files will go

## Create conda environment
- First we will need to make a conda environment to run `busco` and `busco_phylogenomics`
- To do this you will make an environment using the provided [`busco.yml`](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/busco.yml) file
- If you have never used conda before, there will be some initial steps that you can follow [here]()

```
conda env create -f busco.yml
conda activate busco # make sure that the environment installed properly
```

---

## Download genomes
- Next, we will download 5 fly genomes from NCBI
- [Drosophila ananassae](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_017639315.1/)
- [Drosophila miranda](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_003369915.1/)
- [Drosophila albomicans](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_009650485.2/)
- [Drosophila innubila](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_004354385.1/)
- [Drosophila simulans](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_016746395.2/)

To download these genomes onto amarel, we will use `curl` commands from the NCBI website
```
# example commands
cd busco/genomes/

curl -OJX GET [command copied from NCBI]
```

Once you have downloaded each genome, unzip the downloaded folder and the genome will be the `.fna` file within `ncbi_dataset/data/[GCA#######_specific to species]`

Then we can rename these genomes and delete the files we don't need (typical genome naming is the first 3 letters of the genus followed by the first three letters of the specific epithet `Drosophila ananassae = DroAna.fa`)
```
unzip ncbi_dataset.zip

# rename genome
mv ncbi_dataset/data/GCF_017639315.1/GCF_017639315.1_ASM1763931v2_genomic.fna DroAna.fa

# delete extra files
rm ncbi_dataset.zip
rm -R ncbi_dataset
```

---

## Run BUSCO on all downloaded genomes
- You will need to edit these slurm files to be specific to your paths
- Wherever this `busco.sh` script is, the output files will be written so make sure to write these files into your `busco_out/`
- We will write a `busco.sh` script with the specific busco commands
- We will also write a `run_busco.sh` loop script to loop through all of our genome files automatically
- We will be using the `diptera_odb10` busco dataset, which will be downloaded from the busco online database

[busco.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/tree/main)

[run_busco.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/run_busco.sh)

**run commands**
```
chmod 755 run_busco.sh
./run_busco.sh
```



