# Pipeline for transferring data from Orthanc to Flywheel
## &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Ariana Familiar
## &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; June 2021

This code is intended to grab imaging data from Orthanc, de-identify, map to target project labels, and upload to Flywheel. QC steps are included as appropriate.

Requires input manifest "naming_manifest.csv" (no blank cells) in the same directory as main scripts, with the following header:
| flywheel-project | subject_id | SDG-ID* | imaging_type | age_at_imaging | anatomical_position | accession_num | Radiology Request |

NOTE: only pushes "MR" acquisitions (excludes "SR", "OT", etc.)

## <u> Download data from Orthanc </u>

download_data.sh

Grab uuids based on accession numbers in input manifest & download each as .zip. Moves files to data/

## <u> QC </u>

check_for_missing_data.sh

Checks for local file for each accession # in naming manifest, outputs any missing accessions to command line.

## <u> Unpack, convert 2 Nifti format </u>

dcm2niix.sh

Unzips downloaded files. Moves all original files (.zip) to backup/. Converts each acquisition to Nifti using dcm2niix. Ouput includes a JSON file with DICOM metadata. Removes PHI-containing fields from JSON (based on exclude-list). 

## <u> QC </u>

check_dicom_tags.py

Check if there are new DICOM fields not already accounted for (compare all JSON fields with the white-list: all_dicom_fields.txt). Output is "new_dicom_fields.txt"

## <u> Create snapshots of each acquisition </u>

check_images.sh

Generates a PNG for every Nifti file (using FSL's slicer command) of 3 slices per acquisition. NOTE: "ep2d_diff_mddw_30_p2 2mm_ColFA" diffusion acquisitions won't generate a PNG but are not expected to contain PHI (scanner generated files).

## <u> Summarize all files </u>

summarize_acquisitions.py

Generate a log of all files and corresponding info called "log_acquisitions.xlsx". Used to see which files do not have corresponding PNG (e.g., b/c they are not valid DICOMs & should be removed), and to check for PHI in file names.

## <u> Check for burned-in PHI </u>

view_images.sh

Visually inspect each PNG for PHI.

## <u> Delete files of non-interest </u>

delete_files.sh

Delete any images without a corresponding PNG (except "ep2d_diff_mddw_30_p2 2mm_ColFA").

## <u> Rename with desired mapping </u>

map.py

Rename the directories to match the target subject ID and session labels based on naming_manifest.csv, move files to flywheel/ and make sure data structure matches Flywheel hierarchy.

## <u> Upload to Flywheel </u>

fw_upload.sh

Upload processed files to Flywheel. Requires config.yaml


# To do:
-- create a master list of accession #s to check against before pulling (so don't reprocess same data)
-- create a master list of all visually inspected acquisitions
-- establish a persistent file structure
-- automate between steps where possible
-- transition to AWS ecosystem
-- potentially cluster-ize depending on size of ingest (e.g., map-reduce framework with spark)
