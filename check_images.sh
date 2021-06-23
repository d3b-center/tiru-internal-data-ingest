#!/bin/bash
#
#   REQUIRES FSL install

cd data

for d in */ ; do
    if [[ "${d}" != "backup/" ]] ; then
        cd "${d}"
        for ses in */ ; do
            cd "${ses}"
            for acq in */ ; do
                if [[ ${acq:0:2} == 'MR' ]] ; then
                    cd "${acq}"
                    for file in *.nii.gz ; do
                        if [[ ! -f ${file%.nii.gz}.png ]] ; then
                            slicer "$file" -a ${file%.nii.gz}.png
                        fi
                    done
                    cd ..
                fi
            done
            cd ..
        done
        cd ..
    fi
done

cd ..