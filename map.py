import pandas as pd 
import glob
import os
import shutil

proj_name='flywheel'

def listdir_nohidden(path):
    return glob.glob(os.path.join(path, '*')) # ignores hidden files


df = pd.read_csv('naming_manifest.csv')

if not os.path.isdir(proj_name):
    os.mkdir(proj_name)

data_dir = 'data'
for sub in listdir_nohidden(data_dir):
    if 'backup' not in sub:
        for session in listdir_nohidden(sub):
            for acq in listdir_nohidden(session):
                files = listdir_nohidden(acq)
                path_info=acq.split('/')
                accession = path_info[2].split()[0] # accession number from DICOM path
                acq_name = path_info[3][3:]
                for file in files[:]:
                    if file.endswith('.nii.gz') or file.endswith('.bval') or file.endswith('.bvec') or file.endswith('.json'):
                        # print(accession)
                        subj_row = df.loc[df['accession_num'].astype('str') == accession] # compare to naming manifest
                        # print(subj_row)
                        subj_id = subj_row.subject_id.item()
                        session_id = str(subj_row.age_at_imaging.item())+'d_'+subj_row.anatomical_position.item()

                        subj_path = proj_name+'/'+subj_id
                        if not os.path.isdir(subj_path):
                            os.mkdir(subj_path)

                        session_path = subj_path+'/'+session_id
                        if not os.path.isdir(session_path):
                            os.mkdir(session_path)

                        acq_path = session_path+'/'+acq_name
                        if not os.path.isdir(acq_path):
                            os.mkdir(acq_path)
                        shutil.move(file, acq_path+'/')
