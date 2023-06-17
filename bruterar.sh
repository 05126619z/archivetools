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
breaked=1
for file in "$location"/*.rar
do
    filename=$(basename "$file" .rar)
    newfilefolder="${destination}/${filename}"
    IFS=$'\n'
    mkdir -p ${newfilefolder}
    chmod +w ${newfilefolder}
    unrar x -o- -p- "${file}" "${newfilefolder}"
    for password in "${passwords[@]}"
    do  
                unrar x -o- -p"${password}" "${file}" "${newfilefolder}"
    done
done