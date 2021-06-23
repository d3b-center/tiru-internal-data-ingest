# Log acquisitions for QA
#
#


# ======== MAIN PROCESSES =======================================
import os
import pandas as pd
import glob

def listdir_nohidden(path):
    return glob.glob(os.path.join(path, '*'))

## create dataframe with data directories
data = []
data_dir = 'data'
bad_accessions=[]
for sub in listdir_nohidden(data_dir):
    if 'backup' not in sub:
        for session in listdir_nohidden(sub):
            acq_num = 0
            for acq in listdir_nohidden(session):
                acq_num += 1
                files = listdir_nohidden(acq)
                nifti=0
                png=0
                for file in files[:]:
                    if file.endswith('.nii.gz'):
                        nifti+=1
                    if file.endswith('.png'):
                        png+=1

                path_info=acq.split('/')
                scan_type = path_info[3].split()[0]
                mrn = path_info[1].split()[0]
                accession = path_info[2].split()[0]

                data.append(( mrn, accession, path_info[1], path_info[2], path_info[3] , scan_type, nifti, png ))
            if acq_num < 2:
                bad_accessions.append(( mrn, accession, path_info[1], path_info[2], path_info[3] , scan_type, nifti, png ))

df = pd.DataFrame(data, columns=['mrn','accession','sub', 'session', 'acquisition', 'scan_type','nifti','png'])
df_bad = pd.DataFrame(bad_accessions, columns=['mrn','accession','sub', 'session', 'acquisition', 'scan_type','nifti','png'])
# if len(df) > 0:
    # df.to_csv('log_acquisitions.csv')


with pd.ExcelWriter('log_acquisitions.xlsx', engine='xlsxwriter') as writer:
  df.to_excel(writer, sheet_name='Main')
  df_bad.to_excel(writer, sheet_name='Bad')