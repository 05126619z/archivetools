#!/bin/bash
location=
passwordsfile=
destination="./extracted"





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
        echo "Found -f option"
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


readarray -t passwords < "${passwordsfile}" 
#this is horrible and i will not be allowed to write code ever again

breaked=1
for file in "$location"/*.rar
do
    filename=$(basename "$file" .rar)
    newfilefolder="${destination}/${filename}"
    IFS=$'\n'
    for testpassword in "${passwords[@]}"
    do  
        breaked=1
        if unrar t -p"${testpassword}" "${file}">/dev/null 2>&1; then
            password=${testpassword}
            breaked=0
            echo "${testpassword} is correct for the ${file}"
            break
        else
            echo "${testpassword} is wrong for the ${file}"
        fi
    done

    if [ $breaked -eq 0 ]; then
        mkdir -p ${newfilefolder}
        chmod +w ${newfilefolder}
        unrar x -o- -p"${password}" "${file}" "${newfilefolder}"
        echo "${file} extracted with password ${password}"
    else
        echo "No password found for the ${file}, assuming no password."
        if unrar t -p- "${file}">/dev/null 2>&1;then
            mkdir -p ${newfilefolder}
            chmod +w ${newfilefolder}
            unrar x -o- -p- "${file}" "${newfilefolder}"
            echo "${file} was extracted with on password"
        else
            echo "No correct password was found for the ${file}, skipping..."
        fi
    fi
done