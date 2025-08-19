cd /projectnb/nphfnirs/s/code/Homer3/
setpaths

cd /projectnb/nphfnirs/s/datasets/gradCPT_NN24/code/eyetracking/
path(path, cd)

cd /projectnb/nphfnirs/s/code/ninjaGUI/device_functions/ninjaNIRS2024/
path(path, cd)

cd /projectnb/nphfnirs/s/datasets/gradCPT_NN24/code/gradCPT/
path(path, cd)
%%
sub_id = '672';
task_list = ["RS", "gradCPT", "gradCPT", "gradCPT"];
run_list = ["01", "01", "02", "03"];
eye_tracking = 'Neon';
data_dir = '/projectnb/nphfnirs/s/datasets/gradCPT_NN24/';
%% GENERATE SNIRF FILES

raw_files = join([data_dir, 'sourcedata/raw/sub-', sub_id, '/nirs']);

cd(raw_files)

desired_extension = '.bin'; 

% Get a list of files in the directory
file_list = dir(fullfile(raw_files, ['*' desired_extension]));

% loop through each file and convert bin to snirf 
for f = 3:length(file_list)
    
    run = run_list(f);
    task = task_list(f);
    [~, name, ~] = fileparts(file_list(f).name);
    disp(name)

    snirf = convertBintoSnirf_NN24(name, 1, 0, sub_id, '', task, run)
    
end

%% GENERATE TOBII EYETRACKING FILES

raw_files = join([data_dir, 'sourcedata/raw/sub-', sub_id, '/eye_tracking']);

file_list = dir(fullfile(raw_files, ['*', 'Z']));
cd(raw_files)

for f = 1:length(file_list)
    
    [~, name, ~] = fileparts(file_list(f).name);
    disp(name)
    if strcmp(eye_tracking, 'Tobii')
        gaze_zip_path = join([name, "/gazedata.gz"], '');
        gunzip(gaze_zip_path)
    
        tobii_file = join([name, "/gazedata"], '');
    
        parseTobii_to_bids(tobii_file, sub_id, '', task_list(f), run_list(f))

    elseif strcmp(eye_tracking, 'Neon')
        print('go to python to analyze')
    end
end

%% GENERATE GRADCPT FILES
task_list = ["gradCPT", "gradCPT", "gradCPT"];
run_list = ["01", "02", "03"];

raw_files = join([data_dir, 'sourcedata/raw/sub-', sub_id, '/gradCPT']);
cd(raw_files)

desired_extension = '.mat'; 

% Get a list of files in the directory
file_list = dir(fullfile(raw_files, ['*' desired_extension]));

% loop through each file and convert bin to snirf 
for f = 1:length(file_list)
    
    run = run_list(f);
    [~, name, ~] = fileparts(file_list(f).name);
    disp(name)

    gradCPT_data2events(name, sub_id, '', task_list(f), run_list(f))
    
end

%% GENERATE EVENTS FOR RS RUN

snirf_path = [data_dir, 'sub-' sub_id, '/nirs/' 'sub-' sub_id '_task-RS_run-01_nirs.snirf'];
snirf = SnirfLoad(snirf_path);

t = find(diff(snirf.aux(1).dataTimeSeries) > 0);
events = table(snirf.aux(1).time(t), 360, 1, "Resting State");
events.Properties.VariableNames = {'onset', 'duration', 'amplitude', 'trial_type'};

events_path  = [data_dir, 'sub-' sub_id, '/nirs/' 'sub-' sub_id '_task-RS_run-01_events.tsv'];
writetable(events, events_path, "FileType","text", 'Delimiter','\t' )

