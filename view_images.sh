#!/bin/bash
#

cd data

for d in */ ; do
    if [[ "${d}" != "backup/" ]] ; then
        cd "${d}"
        for ses in */ ; do
            cd "${ses}"
            for acq in */ ; do
                if [[ ${acq:0:2} == 'MR' ]] ; then
                    cd "${acq}"
                    for file in *.png ; do
                        if [[ -f ${file} ]] ; then
                            open ${file}
                            echo "Showing ${d} ${file} - Press any key to continue"
                            read -s -n 1 # wait for user key press
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