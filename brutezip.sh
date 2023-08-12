#!/bin/bash
location=
passwordsfile=
destination="./extracted"
#comments later maybe


function usage {
  echo "Usage: bruterar.sh [-h|--help] -p passwords [-d directory] -f file"
  echo "  -h, --help      Display this help message"
  echo "  -f archives     Specify a archives folder"
  echo "  -p passwords    Specify a passwords file"
  echo "  -d directory    Specify a directory to extract to"
}


if [ $# -eq 0 ]; then
    usage
    exit 1
fi


while [ "$1" != "" ]; do
    case $1 in
    -f)
        location=$2
        echo "location: ${location}"
        shift
        ;;
    -p)
        passwordsfile=$2
        echo "passwordsfile: ${passwordsfile}"
        shift
        ;;
    -d)
        destination=$2
        echo "destination: ${destination}"
        shift
        ;;
    -h | --help)
        usage
        exit 1
        ;;
    *)
        usage
        exit 1
        ;;
    esac
    shift
done

if [ -z "${location}" ]; then
  echo "Error: file option (-f) is required"
  exit 1
fi

if [ -z "${passwordsfile}" ]; then
  echo "Error: file option (-p) is required"
  exit 1
fi

function cleanup {
    echo "Cleaning up and exiting..."
    exit 1
}
trap 'cleanup' SIGINT
# TODO
# make no password check earlier
# read passwords into array
readarray -t passwords < "${passwordsfile}" 
breaked=1
# write filename with extention into "file" var
for file in "$location"/*.zip
do
    # make filename without extention
    filename=$(basename "$file" .zip)
    # save destenation into var
    newfilefolder="${destination}/${filename}"
    # separator
    IFS=$'\n'
    breaked=1
    # test passwords with cycle
    for testpassword in "${passwords[@]}"
    do  
        # if correct exit cycle with breaked = 0 which means success
        # output discarded
        if ! [ $(unzip -t -P "${testpassword}" "${file}">/dev/null 2>&1) -gt 2 ]; then
            password=${testpassword}
            breaked=0
            echo "${testpassword} is correct for the ${file}"
            break
        # otherwise not
        else
            echo "${testpassword} is wrong for the ${file}"
        fi
    done
    # if breaked is 0 then create folder, chmod for write, then unzip
    if [ $breaked -eq 0 ]; then
        mkdir -p ${newfilefolder}
        chmod +w ${newfilefolder}
        unzip -n -P ${password} -d ${newfilefolder} ${file}
        echo "${file} extracted with password ${password}"
        #echo "${filename}\n" > ./extracted.txt
    else
        # otherwise assume no password
        echo "No password found for the ${file}, assuming no password."
        if ! [ $(unzip -t ${file}>/dev/null 2>&1) -gt 2 ];then
            mkdir -p ${newfilefolder}
            chmod +w ${newfilefolder}
            unzip -n -d ${newfilefolder} ${file}
            echo "${file} was extracted with on password"
            #echo "${filename}\n" > ./extracted.txt
        # no password was found, skipping
        else
            echo "No correct password was found for the ${file}, skipping..."
        fi
    fi
done