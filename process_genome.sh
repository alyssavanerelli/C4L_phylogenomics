#!/bin/bash

# load variables
URL=$1

# download genome
curl -OJX GET ${URL}

# unzip downloaded dataset
unzip ncbi_dataset.zip

# move genome file into base genome directory
find . -name "*.fna" -type f -exec mv {} . \;

# rename genome based on first line of fasta file
FILE_NAME=$(ls -1 *.fna)

declare -i num
default=3
num=$default

while [ -f ./${FILE_NAME} ]
do
  	FIRST_ABBR=$(cat ${FILE_NAME} | head -n 1 | cut -d " " -f2 | cut -c1-3)
        SECOND_ABBR=$(cat ${FILE_NAME} | head -n 1 | cut -d " " -f3 | cut -c1-$num)
        SECOND_ABBR=${SECOND_ABBR^}
        if [ -f ./${FIRST_ABBR}${SECOND_ABBR}.fa ]
        then
            	echo "File with this name exists already. Trying a new name!"
                num=$num+1
        else
            	mv ${FILE_NAME} ${FIRST_ABBR}${SECOND_ABBR}.fa
        fi
done

# delete extra files
rm ncbi_dataset.zip
rm -R ncbi_dataset
rm README.md

echo "Finished!"
