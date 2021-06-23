#!/bin/bash
#
# https://unix.stackexchange.com/questions/477210/looping-through-json-array-in-shell-script/477218

localhost=<user:password@ip>

## grab list of accession #s from the naming manifest to query Orthanc with
# download_list=(4472066) # accession #'s to include
download_list=()
INPUT="naming_manifest.csv"
OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read project_name subject_id  sdg_id im_type object_info_age anatomical_position accession_number radiology_request || [ -n "$accession_number" ]; do
    download_list+=(${accession_number})
done < $INPUT
IFS=$OLDIFS
# echo "${download_list[@]}"


## name for temporary file
file_name=studies_uuids.json

## get all unique "studies" currently on Orthanc (scan sessions) & put into temporary file
curl http://${localhost}:8042/studies > ${file_name}

## for each study, grab the accession # and check against the list of sessions to download
## if it's in the list, download the data and name it with the subject's MRN
for uuid in $(jq -r '.[]' ${file_name}); do
    accession=$(curl -s http://${localhost}:8042/studies/${uuid} | jq -r '.MainDicomTags.AccessionNumber')
    if [[ " ${download_list[@]} " =~ " ${accession} " ]]; then
        if [[ -f data/${accession}.zip ]] ; then
            if [[ -f data/${accession}_0.zip ]] ; then
                let app_end=${app_end}+1
                curl http://${localhost}:8042/studies/${uuid}/archive > ${accession}_${app_end}.zip
            else
                app_end=0
                curl http://${localhost}:8042/studies/${uuid}/archive > ${accession}_${app_end}.zip
            fi
        else
            # echo ${accession}
            # mrn=$(curl -s http://orthanc:orthanc@10.30.40.159:8042/studies/${uuid} | jq -r '.PatientMainDicomTags.PatientID')
            curl http://${localhost}:8042/studies/${uuid}/archive > ${accession}.zip
        fi
            if [[ ! -d data/ ]] ; then mkdir data ; fi
            mv *.zip data/
    fi
done

## clean up
rm ${file_name}
