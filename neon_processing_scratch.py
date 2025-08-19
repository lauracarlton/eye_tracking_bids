#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jul 21 10:47:09 2025

@author: lcarlton
"""

import pupil_labs.neon_recording as nr 
import pandas as pd
import numpy as np 
import matplotlib.pyplot as plt

#%%
parent_dir = '/projectnb/nphfnirs/s/datasets/gradCPT_NN24/sourcedata/raw/sub-661/eye_tracking/2024-06-15-10-39-47/'

recording = nr.open(parent_dir)

# get basic info
print("Recording Info:")
print(f"\tStart time (ns): {recording.start_ts}")
print(f"\tWearer         : {recording.wearer['name']}")
print(f"\tDevice serial  : {recording.device_serial}")
print(f"\tGaze samples   : {len(recording.gaze)}")
print("")

# read 10 gaze samples
print("First 10 gaze samples:")
timestamps = recording.gaze.ts[:10]
subsample = recording.gaze.sample(timestamps)
for gaze_datum in subsample:
    print(f"\t{gaze_datum.ts} : ({gaze_datum.x:0.2f}, {gaze_datum.y:0.2f})")
    

#%% want to save everything in a dataframe 
# Eye states
print("Working eye states...")
df_eye_state = recording.eye_state.pd
df_eye_state["ts_rel"] = ( df_eye_state["ts"] - recording.start_ts ) / 1e9

# reorder so that ts_rel is the first column
cols = df_eye_state.columns.tolist()
cols = cols[-1:] + cols[:-1]
df_eye_state = df_eye_state[cols]
# df_eye_state.to_csv(os.path.join(target_path, "eye_state.csv"), sep=",", index=False)
df_eye_state = df_eye_state.rename(columns={'pupil_diameter_left_mm': 'eyeleft_pupilDiameter',
                                            'pupil_diameter_right_mm': 'eyeright_pupilDiameter',
                                            'optical_axis_right_x': 'eyeright_gazeOriginX',
                                            'optical_axis_right_y': 'eyeright_gazeOriginY',
                                            'optical_axis_right_z': 'eyeright_gazeOriginZ',
                                            'optical_axis_left_x': 'eyeleft_gazeOriginX',
                                            'optical_axis_left_y': 'eyeleft_gazeOriginY',
                                            'optical_axis_left_z': 'eyeleft_gazeOriginZ',
                                            'eyeball_center_right_x': 'eyeright_gazeDirectionX',
                                            'eyeball_center_right_y': 'eyeright_gazeDirectionY',
                                            'eyeball_center_right_z': 'eyeright_gazeDirectionZ',
                                            'eyeball_center_left_x': 'eyeleft_gazeDirectionX',
                                            'eyeball_center_left_y': 'eyeleft_gazeDirectionY',
                                            'eyeball_center_left_z': 'eyeleft_gazeDirectionZ',
                                            'eyelid_angle_bottom_left': 'eyeleft_eyelidAngleBottom',
                                            'eyelid_angle_top_left': 'eyeleft_eyelidAngleTop',
                                            'eyelid_angle_bottom_right': 'eyeright_eyelidAngleBottom',
                                            'eyelid_angle_top_right': 'eyeright_eyelidAngleTop',
                                            'eyelid_aperture_left_mm': 'eyeleft_eyelidAperture',
                                            'eyelid_aperture_right_mm': 'eyeright_eyelidAperture',
                                            })

# IMU
print("Working IMU...")
df_imu = recording.imu.pd
df_imu["ts_rel"] = ( df_imu["ts"] - recording.start_ts ) / 1e9
# reorder so that ts_rel is the first column
cols = df_imu.columns.tolist()
cols = cols[-1:] + cols[:-1]
df_imu = df_imu[cols]
# df_imu.to_csv(os.path.join(target_path, "imu_neon.csv"), sep=",", index=False)

# Gaze
print("Working gaze...")
df_gaze = recording.gaze.pd
df_gaze["ts_rel"] = ( df_gaze["ts"] - recording.start_ts ) / 1e9
# reorder so that ts_rel is the first column
cols = df_gaze.columns.tolist()
cols = cols[-1:] + cols[:-1]
df_gaze = df_gaze[cols]
df_gaze = df_gaze.rename(columns={'x': 'gaze2dX', 
                                  'y': 'gaze2dY'})
# df_gaze.to_csv(os.path.join(target_path, "gaze.csv"), sep=",", index=False)

# Events
print("Working events...")
df_events = recording.events.pd
df_events["ts_rel"] = ( df_events["ts"] - recording.start_ts ) / 1e9
# reorder so that ts_rel is the first column
cols = df_events.columns.tolist()
cols = cols[-1:] + cols[:-1]
df_events = df_events[cols]
# df_events.to_csv(os.path.join(target_path, "events_neon.csv"), sep=",", index=False)


df_eye_tracking = pd.merge(df_eye_state, df_gaze, on='ts_rel', how='outer')
df_eye_tracking = df_eye_tracking.drop(['ts_x', 'ts_y'], axis=1)
# df_eye_tracking = df_eye_tracking.rename({'ts_rel':
#                                          })
#%%  NEED TO ALIGN TIMESTAMPS WITH SNIRF TIMESTAMPS
from cedalion import io 

snirf = io.read_snirf('/projectnb/nphfnirs/s/datasets/gradCPT_NN24/sub-661/nirs/sub-661_task-RS_run-01_nirs.snirf')




#%% TOBII column names 

# tobii_csv = pd.read_csv('/projectnb/nphfnirs/s/datasets/gradCPT_NN24/sub-629/nirs/sub-629_task-RS_run-01_recording-eyetracking_physio.tsv', sep='\t')
                        
# tobii_column_names = tobii_csv.columns




   
   
   
   
