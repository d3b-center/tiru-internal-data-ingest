#!/bin/bash
#

function arraydiff() {
  awk 'BEGIN{RS=ORS=" "}
       {NR==FNR?a[$0]++:a[$0]--}
       END{for(k in a)if(a[k])print k}' <(echo -n "${!1}") <(echo -n "${!2}")
}

## grab list of accession #s from the naming manifest to query Orthanc with
download_list=()
INPUT="naming_manifest.csv"
OLDIFS=$IFS
IFS=','
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read project_name subject_id  sdg_id im_type object_info_age anatomical_position accession_number radiology_request || [ -n "$accession_number" ]; do
    if [[ "${download_list[@]} " =~ "${accession_number} " ]]; then
        accession_number_0=
        if [[ "${download_list[@]}" =~ "${accession_number}_0" ]]; then
            let app_end=${app_end}+1
            new_acc=
            download_list+=("${accession_number}_${app_end}")
        else
            app_end=0
            download_list+=("${accession_number}_${app_end}")
        fi
    else
        download_list+=(${accession_number})
    fi
done < $INPUT
IFS=$OLDIFS
IFS=$OLDIFS
# echo "${download_list[@]}"

## get list of downloaded files
cd data
file_list=()
for f in *.zip; do
    [[ -e $f ]] || continue
    file_list+=(${f%.zip})
done
cd ..
# echo "${file_list[@]}"

download_list=("${download_list[@]/accession_number}")
missing_files=($(arraydiff download_list[@] file_list[@]))
echo "Missing files: " ${missing_files[@]}
# echo "Download list: " ${download_list[@]}
# echo "File list: " ${file_list[@]}