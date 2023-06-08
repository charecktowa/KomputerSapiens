#!/bin/bash

# This needs some refactoring, but it works

remove_resolutions() {
    CURRENT_DIR="$(pwd)/$1"

    # Delete all files except images 
    find ${CURRENT_DIR} -maxdepth 1 -type f -delete

    WORKING_DIR="${CURRENT_DIR}/SOB/"

    RESOLUTIONS=$(find ${WORKING_DIR} -mindepth 2  -type d) 

    for dir in ${RESOLUTIONS}
    do
        if [ -d "$dir"  ]
        then
            if [[ "$dir" =~ X$ ]]
            then
                # Now we delete the resolutions we don't want
                if [[ "$dir" =~ 900X$ ]]
                then
                    rm -rf "$dir"
                fi
            fi
        fi

    done
}

move_to_root() {
    for dir in *
    do
        if [ -d "$dir" ]
        then
            type="$dir"
            remove_resolutions $dir

            IMAGE_DIR="$(pwd)/$type/"
            find ${IMAGE_DIR} -type f -print0 | xargs -0 mv -t ${IMAGE_DIR}
        fi
    done

    rm -rf "$(pwd)/benign/SOB/"
    rm -rf "$(pwd)/malignant/SOB/"
}

# This function moves all subtypes to the label folder
# for example carcinoma it is moved to benign folder
subclass_to_label() {
    CURRENT_DIR=$(pwd)
    WORKING_DIR="${CURRENT_DIR}/histology_slides/breast/"

    (cd -- "${WORKING_DIR}" && move_to_root)

    # After moving all the images to the root folder we
    # can delete the remaining files like .py or .txt
    find ${WORKING_DIR} -maxdepth 1 -type f -print0 | xargs -0 rm 
}

extract() {
    for file in *.tar.gz
    do
        tar -xpf "$file"
        [ -d "${file%%.tar.gz}" ]
    done
}

if [ -f "./BreaKHis_v1.tar.gz" ]
then
    echo "Extracting dataset..."

else
    echo "Downloading dataset..."
    wget http://www.inf.ufpr.br/vri/databases/BreaKHis_v1.tar.gz
    

    # Check just in case if for some reason the file is not there
    if ! [ [ -f "./BreaKHis_v1.tar.gz"] ]
    then 
        echo "File not found, exiting..."
        exit 1
    fi
fi

(extract && cd -- "./BreaKHis_v1" && subclass_to_label)