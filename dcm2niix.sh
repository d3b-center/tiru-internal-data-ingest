#!/bin/bash
#
#   REQUIRES dcm2niix install
#
#   dcm2niix should be run from within acquisition directory

# dcm2niix -f "%p_%s" -p y -z y "InputDicomDir"

install_dir=/Users/familiara/

cd data

# unzip the folders
if [[ ! -d backup ]] ; then mkdir backup ; fi
for f in *.zip ; do
    unzip -n ${f} # -n: never overwrite existing files
    mv ${f} backup/
done

for d in */ ; do
    if [[ "${d}" != "backup/" ]] ; then
        cd "${d}"
        for ses in */ ; do
            cd "${ses}"
            for acq in */ ; do
                if [[ ${acq:0:2} == 'MR' ]] ; then
                    cd "${acq}"
                    rm *.nii.gz
                    rm *.bval
                    rm *.bvec
                    rm *.json
                    ${install_dir}dcm2niix -b y -ba y -m y -f "%d" -p y -z y . # BIDS and nii
                    # ${install_dir}dcm2niix -b o -ba y -m y -f "%d" -p y -z y . # BIDS only
                    # ${install_dir}dcm2niix -b n -m y -f "%d" -p y -z y . # nii only

                    ## de-id fields
                    for sidecar in *.json ; do
                        jq 'del(.description) | .description=""' ${sidecar} > temp_${sidecar} && mv temp_${sidecar} ${sidecar}
                        jq 'del(.DeviceSerialNumber) | .description=""' ${sidecar} > temp_${sidecar} && mv temp_${sidecar} ${sidecar}
                        jq 'del(.ImageComments) | .description=""' ${sidecar} > temp_${sidecar} && mv temp_${sidecar} ${sidecar}
                        jq 'del(.InstitutionAddress) | .description=""' ${sidecar} > temp_${sidecar} && mv temp_${sidecar} ${sidecar}
                        jq 'del(.InstitutionalDepartmentName) | .description=""' ${sidecar} > temp_${sidecar} && mv temp_${sidecar} ${sidecar}
                        jq 'del(.InstitutionName) | .description=""' ${sidecar} > temp_${sidecar} && mv temp_${sidecar} ${sidecar}
                        jq 'del(.ProcedureStepDescription) | .description=""' ${sidecar} > temp_${sidecar} && mv temp_${sidecar} ${sidecar}
                        jq 'del(.ProtocolName) | .description=""' ${sidecar} > temp_${sidecar} && mv temp_${sidecar} ${sidecar}
                        jq 'del(.StationName) | .description=""' ${sidecar} > temp_${sidecar} && mv temp_${sidecar} ${sidecar}
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