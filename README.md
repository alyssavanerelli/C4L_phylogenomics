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

## Download dependencies for busco_phylogenomics
- [trimAl](http://trimal.cgenomics.org/)
  - we will be using version 1.2
    ```
    cd
    # FOR LINUX OR MACOS
    wget http://trimal.cgenomics.org/_media/trimal.v1.2rev59.tar.gz

    # FOR WINDOWS
    wget http://trimal.cgenomics.org/_media/trimal.v1.2rev59.zip
    
    gunzip trimal.v1.2rev59.tar.gz
    tar -xvf trimal.v1.2rev59.tar
  
    # compile package
    cd trimAl/source
    make
  
    # move programs to bin/
    mv readal trimal bin/
    ```
- [MUSCLE](https://www.drive5.com/muscle/)
  - download links [here](https://github.com/rcedgar/muscle/releases/tag/v5.0.1428)
  - we will be using version 3
    ```
    cd
    wget https://drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux32.tar.gz

    gunzip muscle3.8.31_i86linux32.tar.gz
    tar -xvf muscle3.8.31_i86linux32.tar

    mv muscle3.8.31_i86linux32 bin/muscle
    ```

---

## Download genomes
- Next, we will download 6 genomes from NCBI
- [_Drosophila ananassae_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_017639315.1/)
- [_Drosophila miranda_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_003369915.1/)
- [_Drosophila albomicans_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_009650485.2/)
- [_Drosophila innubila_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_004354385.1/)
- [_Drosophila simulans_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_016746395.2/)
- **Outgroup:** [_Ephydra gracilis_](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_001014675.1/)

**To download: **
- You can download a genome from NCBI using the script below
- On the genome NCBI page, you should press the `curl` button and copy the link to download the genome (I have provided the links below for you)
- The script below will download the genome, rename it, and delete the unneeded files.
- Typical genome naming is the first 3 letters of the genus followed by the first three letters of the specific epithet
- To run this script, you will need to **add the path to the directory where you want**
- This URL is the only thing you need to input for this script
- You should **run this script from the directory where you want the genome saved**

[process_genome.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/process_genome.sh)

For the following links:
```
https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_017639315.1/download?include_annotation_type=GENOME_FASTA
https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_003369915.1/download?include_annotation_type=GENOME_FASTA
https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_009650485.2/download?include_annotation_type=GENOME_FASTA
https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_004354385.1/download?include_annotation_type=GENOME_FASTA
https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_016746395.2/download?include_annotation_type=GENOME_FASTA
https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCA_001014675.1/download?include_annotation_type=GENOME_FASTA
```

You should run this command:
```
chmod 755 process_genome.sh    # makes file executable and only needs to be done once
./process_genome.sh [GENOME_DOWNLOAD_URL]
```

---

## Editing scripts
For the scripts below, you will need to edit them to have your specific path to your files. You can do this manually or by using a `sed` command:
- The `-i` specifies that this command should edit the file directly
- The `\` is needed before every instance of `[`, `]`, or `/` in either the search string or the replacement string
- Syntax for `sed` follows: `'s/SEARCH_STRING/REPLACEMENT_STRING/g'` (more info on sed [here](https://www.geeksforgeeks.org/sed-command-in-linux-unix-with-examples/))
- The `-g` means that every instance of the search string will be replaced with the replacement string

```
# Example replacement usage
sed -i 's/\[YOUR_PATH_HERE\]/\/projects\/f_geneva_1\/alyssa/g' test.sh
```

---

## Run BUSCO on all downloaded genomes
- Now we will be running the `busco.sh` and `run_busco.sh` scripts linked below
  - The `busco.sh` script below has the busco commands and the `run_busco.sh` script will run the `busco.sh` script on all your genome files.
- You will need to edit these files to be specific to your paths
- We will be using the `diptera_odb10` busco dataset, which will be downloaded from the busco online database

### Download busco dataset
- There are a couple different options for accessing the busco dataset
  - The default is to use the `-l [dataset_name]` flag which will prompt busco to connect to their online server and download the most recent version of this dataset. The issue with this option is that busco frequently has issues connecting to the online server which causes the job to fail. Resubmitting normally fixes this issue.
  - The second option is to download the dataset manually and either change the `-l` flag to contain the path to the dataset (e.g. `/my/own/path/vertebrata_odb10`) or just add the `--offline` flag to your busco command (with the `-l` flag only containing the dataset name). Making either of these changes will not allow busco to connect to the server to try and download a new version of the dataset.
  ```
  busco download [dataset_name]
  ```
- We will be using the **second option** in this tutorial:
```
cd busco_out/
srun --partition=cmain --mem=10G --time=2:00:00 --ntasks-per-node=10 --pty bash
conda activate busco
busco --download diptera_odb10
``` 

### `busco.sh`
- **Important:** The busco output files will be written to wherever you have this `busco.sh` script saved so make sure to save (and run) this script in whatever folder you want the output to be stored in
- You will know busco has completed successfully when a `short_summary...txt` file is created in your busco output folder
- This step should take 10-20 minutes per genome

[busco.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/busco.sh)

### `run_busco.sh`
- **You will need to do some editing of this loop file:**
- The `FILES=$(ls -1 [YOUR PATH HERE]/busco/genomes/*.fa | cut -d "/" -f 10 | sort)` line in this script will produce **output the genome names only**. For example, the output should look like:
  ```
  # running this line from the command line
  ls -1 /projects/f_geneva_1/alyssa/grahami/busco/test/genomes/*.fa | cut -d "/" -f 9 | sort

  # will produce this output
  DroAlb.fa
  DroAna.fa
  DroInn.fa
  DroMir.fa
  DroSim.fa
  EphGra.fa
  ```
- The cut command at the end of this line will be removing information from the path of the file to only keep the genome name. **You will need to alter this line to be specific to your file path**.
- **Typical syntax for `cut`** (more info [here](https://www.geeksforgeeks.org/cut-command-linux-examples/)):
  - `-d` specifies the delimiter that you will cut on (in this example we are using `/` as the delimiter)
  - `-f` specifies how many instances of the delimiter to remove. You can have one number here (e.g. `cut -d "/" -f 2` will give you the string in between the first and second instances of `/`) or you can have a range (e.g. `cut -d "/" -f 2-3` will give you the string after the first `/` and before the third `/`)
- For my path, I needed to cut after 9 instances of `/` to only leave the file name. Your number will likely be different.
- You can run this `ls -1 [YOUR PATH HERE]/busco/genomes/*.fa | cut -d "/" -f 10 | sort` line in your terminal and **change the number after `-f`** to determine where you will need to cut to leave only the genome names.

[run_busco.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/run_busco.sh)

**run commands**
- Once you have edited the file, you can uncomment the `eval $CMD` line so the script will submit our `busco.sh` script
- I like to run the script first with `echo $CMD` uncommented and the `eval $CMD` commented out to make sure that it is submitting the `busco.sh` script correctly

```
chmod 755 run_busco.sh       # makes this an executable file
./run_busco.sh
```

### BUSCO completeness results
In each `short_summary...txt` file, you will find the completeness scores for that genome assembly. They should match the graph below (the graph below will not be produced with the busco code but the numbers should match).

[BUSCO results figure](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/busco_results.pdf)

---

## Running busco_phylogenomics
- Now that we have downloaded the genomes and run busco on all of them, we can perform phylogenetic analyses with busco_phylogenomics
- First, we need our busco results to be in our `phy_input/` folder to be in the format that busco_phylogenomics needs
- What we need to do here is to extract the `run_diptera_odb10/` folder for each species and put it in the format of `run_[species]/`
- We will do this by soft-linking to our busco folder
- In this file, **you will need to edit**:
  - The `FILES=` line with your specific path and cut command (should be identical to the line in your `run_busco.sh`)
  - Path for `INPUT_DIR`
  - Path for `OUTDIR`

[run_softlink.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/run_softlink.sh)

```
chmod 755 run_softlink.sh       # makes this an executable file and only needs to be done once
./run_softlink.sh
```

**Now we can run busco_phylogenomics**
- This program is a python file found [here](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/BUSCO_Phylogenomics.py)
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
- This step should take ~18 hours to finish 

[phy_sub.sh](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/phy_sub.sh)

---

## Visualizing Output
- busco_phylogenomics will produce many output files
- In the `.iqtree` file, we will have the logs and an unrooted maximum likelihood tree

**1. Save the `SUPERMATRIX.aln.treefile` file**
- this file is a representation of the phylogeny in Newick format
- copy the contents of this file and saving it as a `.tre` file onto your computer

**2. Download FigTree**
- This is the software we will be using to visualize the phylogeny
- You can download FigTree [here](http://tree.bio.ed.ac.uk/software/figtree/)

**3. Open the `.tre` file in FigTree**
- Once opening the tree, FigTree will ask what you want the nodes/branches labeled as. You should write **bootstrap**

**4. Reroot the tree using our outgroup**
- You should click on the branch leading to **_Ephydra gracilis_** and reroot with this lineage using the `reroot` button at the top of the screen

**5. Display support values**
- We will also want to display the bootstrap support values on the nodes
- Click the checkbox next to `Node Labels` on the left
- Change the dropdown `Display` to `Bootstrap`

**6. Optional aesthetic changes**
- FigTree has many different aesthetic changes that you can make (e.g. font size, root length, etc.) so feel free to play around with these options if you would like

**7. Save your tree**
- Click `File` and `Export PDF` to save your tree


**Your tree should look like the tree below**

[Drosophila Phylogeny](https://github.com/alyssavanerelli/C4L_phylogenomics/blob/main/drosophila_tree.pdf)












