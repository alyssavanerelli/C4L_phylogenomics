#!/bin/bash
FILES=$(ls -1 [YOUR_PATH_HERE]/busco/genomes/*.fa | cut -d "/" -f 10 | sort)
for FILE in $FILES
        do
	CMD="sbatch busco.sh ${FILE}"
        echo $CMD
        #eval $CMD
        sleep 0.25
done
