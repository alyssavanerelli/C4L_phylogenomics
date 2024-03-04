#!/bin/bash
INPUT_DIR="[YOUR_PATH_HERE]/busco/busco_out"
OUTDIR="[YOUR_PATH_HERE]/busco/phy_input"
BUSCO_SET="diptera_odb10"

FILES=$(ls -1 [YOUR_PATH_HERE]/busco/genomes/*.fa | cut -d "/" -f 10 | sort)
for FILE in $FILES
        do
        CMD="ln -s ${INPUT_DIR}/${FILE}/run_${BUSCO_SET} ${OUTDIR}/run_${FILE}"
        echo $CMD
        #eval $CMD
        sleep 0.25
done
