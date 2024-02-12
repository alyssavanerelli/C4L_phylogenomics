#!/bin/bash
FILES=$(ls -1 /projects/f_geneva_1/alyssa/grahami/busco/busco_phylogenomics/genomes/new/*.fa | cut -d "/" -f 10 | sort)
for FILE in $FILES
        do
	CMD="sbatch busco.sh ${FILE}"
        echo $CMD
        #eval $CMD
        sleep 0.25
done
