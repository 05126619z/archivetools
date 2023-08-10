#!/bin/bash
#Script to extract Multiple RAR files and place each RAR file's content in its own directory

function cleanup {
    echo "Cleaning up and exiting..."
    exit 1
}
trap 'cleanup' SIGINT
readarray -t passwords < ${echo rars.txt}
# for z in *.rar
# do 
#   # removing all white space. Generating Directory name
# 	c="$(echo -e "${z}" | tr -d '[:space:]')"
  
#   # Creating directory. Replace <Directory Address> with your own Directory Address.
# 	mkdir /mnt/f/unpacked/$c;
#   for testpassword in "${passwords[@]}"
#   do
#     # Extracting rar file into its own new Directory. Replace <Directory Address> with your own Directory Address.
# 	  unrar x -r "$z" /mnt/f/unpacked/$c;
#   done
# done

#---------------------------------------------------------------------------
#Script to extract Multiple Zip files and place each RAR file's content in its own directory 

for z in *.zip
do 
  # removing all white space. Generating Directory name
	c="$(echo -e "${z}" | tr -d '[:space:]')"
  
  # Creating directory. Replace <Directory Address> with your own Directory Address.
	mkdir /mnt/f/unpacked/$c;
    for testpassword in "${passwords[@]}"
    do
    # Extracting rar file into its own new Directory. Replace <Directory Address> with your own Directory Address.
	  unzip "$z" -p ${testpassword} -d /mnt/f/unpacked/$c;
    done
done