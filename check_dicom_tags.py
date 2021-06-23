# expects the following sub-dir structure:
#       subject > session > acquisition > *dcm

import pydicom
import os
import pandas as pd
import json

# ======== extract all tags ====================
tag_count=[]
with open('all_dicom_fields.txt', 'r') as f:
    tag_count.append(f.read().splitlines())
tag_count=tag_count[0]

dcm_count=0
new_tags=[]
for subdir, dirs, files in os.walk('data'):
    for file in files:
        dcm_path = os.path.join(subdir,file)
        if dcm_path.endswith(r'.json'):
            print(subdir)
            with open(dcm_path) as json_file: 
                ds = json.load(json_file)
            # ds.decode()  # change strings to unicode
            dcm_count += 1
            for k, v in ds.items():
                if k not in tag_count:
                    new_tags.append(k)
                    # tag_count[k] = [[ds[k]['Name']], 0, str([ds[k]['Value']])]
                # if [ds[k]['Name']] not in tag_count[k][0]:
                    # tag_count[k][0].append([ds[k]['Name']])
                # tag_count[k][1] += 1

if new_tags:
    with open('new_dicom_fields.txt', 'w') as f:
        for item in new_tags:
            f.write("%s\n" % item)
else:
    print('No new fields found!')
