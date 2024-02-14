# C4L busco phylogenomics pipeline

**Directory Structure**
- `busco/`
  - _`phy_sub.sh`_
  - _`BUSCO_phylogenomics.py`_
  - `genomes/`
    - downloaded genome fasta files
  - `busco_out/`
    - _`busco.sh`_
    - results from busco run
  - `phy_input/`
    - some of the busco results will be moved here as input for busco_phylogenomics
  - `slurmout/`
    - where slurm output files will go

## Create conda environment
- First we will need to make a conda environment to run `busco` and `busco_phylogenomics`
- To do this you will make an environment using the provided [`busco.yml`](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/busco.yml) file
- If you have never used conda on amarel before, there will be some initial steps that you will need to follow [here](https://github.com/lizardroom/conda_on_amarel/)

```
conda env create -f busco.yml
conda activate busco # make sure that the environment installed properly
```

---

## Download genomes
- Next, we will download 5 fly genomes from NCBI
- [_Drosophila ananassae_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_017639315.1/)
- [_Drosophila miranda_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_003369915.1/)
- [_Drosophila albomicans_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_009650485.2/)
- [_Drosophila innubila_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_004354385.1/)
- [_Drosophila simulans_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_016746395.2/)
- **Outgroup:** [_Ephydra gracilis_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_001014675.1/)

To download these genomes onto amarel, we will use `curl` commands from the NCBI website
```
# example commands
cd busco/genomes/

curl -OJX GET [command copied from NCBI]
```

Once you have downloaded each genome, unzip the downloaded folder and the genome will be the `.fna` file within `ncbi_dataset/data/[GCA#######_specific to species]`

Then we can rename these genomes and delete the files we don't need 

Typical genome naming is the first 3 letters of the genus followed by the first three letters of the specific epithet `Drosophila ananassae = DroAna.fa`
```
unzip ncbi_dataset.zip

# rename genome
mv ncbi_dataset/data/GCF_017639315.1/GCF_017639315.1_ASM1763931v2_genomic.fna DroAna.fa

# delete extra files
rm ncbi_dataset.zip
rm -R ncbi_dataset
rm README.md
```

---

## Run BUSCO on all downloaded genomes
- You will need to edit these slurm files to be specific to your paths
- Wherever this `busco.sh` script is, the output files will be written so make sure to write these files into your `busco_out/`
- We will write a `busco.sh` script with the specific busco commands
- We will also write a `run_busco.sh` loop script to loop through all of our genome files automatically
- We will be using the `diptera_odb10` busco dataset, which will be downloaded from the busco online database
- This step should take 10-20 minutes per genome
- You will know that busco completed successfully if in the output folder, a `short_summary...txt` file is created

[busco.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/busco.sh)

**You will need to do some editing of this loop file:**
- The cut command (`cut -d "/" -f 10`) at the end of the `ls -1` line will need to be altered so that running this line (from `ls -1` to `sort`) will output the genome names only (e.g. `DroAna.fa`, etc.)
- You should edit the number to remove more or less "/"
  ```
  # example use
  /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes/new/*.fa | cut -d "/" -f 10 | sort
  # this will produce only the genome file names without the path
  ```

[run_busco.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/run_busco.sh)

**run commands**
- Once you have edited the file, you can uncomment the `eval $CMD` line so the script will submit our `busco.sh` script
- I like to run the script with `echo $CMD` uncommented and the `eval $CMD` commented out first to make sure that it is submitting the `busco.sh` script correctly

```
chmod 755 run_busco.sh       # makes this an executable file
./run_busco.sh
```

### Troubleshooting
Sometimes when running busco, the lineage files will not download properly and this will cause your busco run to fail. If this happens, just re-submitting the busco job should solve the problem as busco will re-try to download the lineage files.

If this does not work, you can try downloading the lineage file manually with this command
```
busco download diptera_odb10
```

### BUSCO completeness results
In each `short_summary...txt` file, you will find the completeness scores for that genome assembly. They should match the graph below.

[BUSCO results figure](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/busco_results.pdf)

---

## Running busco_phylogenomics
- Now that we have downloaded the genomes and run busco on all of them, we can perform phylogenetic analyses with busco_phylogenomics
- First, we need to rename and move our busco results to our `phy_input/` folder to be in the format that busco_phylogenomics needs
- What we need to do here is to extract the `run_diptera_odb10/` folder for each species and put it in the format of `run_[species]/`
- This step should take ~18 hours to finish 

[move.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/move.sh)

**This loop file should be almost identical to your `run_busco.sh` file**
- You will just need to change the `CMD=` line to be submitting the `move.sh` script instead of the `busco.sh` script

[run_move.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/run_move.sh)

```
chmod 755 run_move.sh       # makes this an executable file
./run_move.sh
```

**Now we can run busco_phylogenomics**
- This program is a python file found [here](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/BUSCO_phylogenomics.py)
- Required parameters
  - `-d --directory`: input directory containing BUSCO runs
  - `-o --output`: output directory
  - `-t --threads`: number of threads to use
  - `--supermatrix` and/or `--supertree`: choose to run supermatrix and/or supertree methods
- Optional parameters:
  - `-psc`: BUSCO families that are present and single-copy in N% of species will be included in supermatrix analysis (default = 100%). Families that are missing for a species will be replaced with missing characters ("?")
  - `--stop_early`: stop pipeline early before phylogenetic inference (i.e., for the supermatrix approach this will stop after generating the concatenated alignment)
  - Do **NOT** make the output directory before running the script. The script will make this directory, you just need to name it in the script.
- We are going to be running this program in `supermatrix` mode where all the genes are analyzed together as one alignment file
- We are also going to be using genes that are present in at least 75% of species so we will be using the `-psc 75` flag

[phy_sub.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/phy_sub.sh)

---

## Visualizing Output
- busco_phylogenomics will produce many output files
- In the `.iqtree` file, we will have the logs and an unrooted maximum likelihood tree
- The preferred method to view this tree is to save the `SUPERMATRIX.aln.treefile` file (this file is a representation of the phylogeny in Newick format) and open it in the software [FigTree](http://tree.bio.ed.ac.uk/software/figtree/)
- In FigTree, you will click on the `Ephydra gracilis` branch and reroot with this lineage














