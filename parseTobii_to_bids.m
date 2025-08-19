function parseTobii_to_bids(tobiiFile, subLabel, sesLabel, taskLabel, runIndex )

%Usage: parseTobii(tobiiDataDir/gazedata', 'tobiiData.mat')
%tobiiFile = string, path to input tobii gazedata file
%outputFile = string, path to output matFile

subj_path = '';
if ~isempty(subLabel) && ~isempty(taskLabel)
    subj_path = ['sub-' subLabel filesep 'nirs' filesep];
    subj_path0 = ['sub-' subLabel filesep];
    if isempty(sesLabel)
        baseFileNameNoExt = sprintf('sub-%s_task-%s', subLabel, taskLabel );
    else
        baseFileNameNoExt = sprintf('sub-%s_ses-%s_task-%s', subLabel, sesLabel, taskLabel );
    end
    if ~isempty(runIndex)
        baseFileNameNoExt_physio = sprintf('%s_run-%s_recording-eyetracking_physio', baseFileNameNoExt, runIndex );
        baseFileNameNoExt = sprintf('%s_run-%s_nirs', baseFileNameNoExt, runIndex );
    else
        baseFileNameNoExt_physio = sprintf('%s_physio_recording-eyetracking_physio', baseFileNameNoExt );
        baseFileNameNoExt = sprintf('%s_nirs', baseFileNameNoExt );
    end
end

if ~isempty(subj_path)
    if exist(['..' filesep '..' filesep '..' filesep subj_path], 'dir') % ???
        folder = ['..' filesep '..' filesep '..' filesep subj_path];
    elseif exist(['..' filesep '..' filesep '..' filesep 'sourcedata'], 'dir') % e.g. /sourcedata/raw/sub-id
        folder = ['..' filesep '..' filesep '..' filesep subj_path];
        if ~exist( ['..' filesep '..' filesep '..' filesep subj_path0], 'dir' )
            mkdir( ['..' filesep '..' filesep '..' filesep subj_path0] );
        end
        if ~exist( ['..' filesep '..' filesep '..' filesep subj_path], 'dir' )
            mkdir( ['..' filesep '..' filesep '..' filesep subj_path] );
        end
    elseif exist(['..' filesep '..' filesep '..' filesep '..' filesep 'sourcedata'], 'dir') % e.g. /sourcedata/raw/sub-id/gradCPT
        folder = ['..' filesep '..' filesep '..' filesep '..' filesep subj_path];
        if ~exist( ['..' filesep '..' filesep '..' filesep '..' filesep subj_path0], 'dir' )
            mkdir( ['..' filesep '..' filesep '..' filesep '..' filesep subj_path0] );
        end
        if ~exist( ['..' filesep '..' filesep '..' filesep '..' filesep subj_path], 'dir' )
            mkdir( ['..' filesep '..' filesep '..' filesep '..' filesep subj_path] );
        end
        % if ~exist(folder_plots, 'dir')
        %     mkdir(folder_plots)
        % end
    end
end

fid = fopen(tobiiFile);
fullText=fileread(tobiiFile);
tline = fgetl(fid);
format long
counter=1;

while ischar(tline)
    [l,i]=regexp(tline, '"(.*?)(?<!\\)"', 'tokens'); %labels, index
    l=string(l);

    %timestamp
    s=find(contains(l,'timestamp')); %start
    timestamp=str2num(cell2mat(extractBetween(tline(i(s):i(s+1)),":",",")));
    tobiiData.timestamps(counter)=timestamp;

    %gaze2d
    if any(ismember(l,'gaze2d'))
        s=find(contains(l,'gaze2d')); %start
        gaze2dX=str2num(cell2mat(extractBetween(tline(i(s):i(s+1)),"[",",")));
        gaze2dY=str2num(cell2mat(extractBetween(tline(i(s):i(s+1)),",","]")));
        tobiiData.gaze2dX(counter)=gaze2dX;
        tobiiData.gaze2dY(counter)=gaze2dY;
    else
        tobiiData.gaze2dX(counter) = nan;
        tobiiData.gaze2dY(counter) = nan;
    end

    %gaze3d
    if any(ismember(l,'gaze3d'))
        s=find(contains(l,'gaze3d')); %start
        gaze3dX=str2num(cell2mat(extractBetween(tline(i(s):i(s+1)),"[",",")));
        gaze3dY=str2num(cell2mat(extractBetween(tline(i(s):i(s+1)),",",",")));
        gaze3dZ=str2num(cell2mat(extractBetween(tline(i(s):i(s+1)),",","]")));
        tobiiData.gaze3dX(counter)=gaze3dX;
        tobiiData.gaze3dY(counter)=gaze3dY;
        tobiiData.gaze3dZ(counter)=gaze3dZ(end);
    else
        tobiiData.gaze3dX(counter)=nan;
        tobiiData.gaze3dY(counter)=nan;
        tobiiData.gaze3dZ(counter)=nan;
    end

    %eyeleft *check end index
    if any(ismember(l,'eyeleft')) && ~contains(tline,'eyeleft":{}')
        s=find(contains(l,'eyeleft')); %start
        gazeOrigin=str2num(cell2mat(extractBetween(tline(i(s):i(s+2)),'gazeorigin":[',']')));
        gazeDirection=str2num(cell2mat(extractBetween(tline(i(s+2):i(s+3)),'gazedirection":[',']')));
        pupilDiameter=str2num(cell2mat(extractBetween(tline(i(s+3)-3:i(s+4)),'pupildiameter":','}')));
        tobiiData.eyeleft_gazeOriginX(counter)=gazeOrigin(1);
        tobiiData.eyeleft_gazeOriginY(counter)=gazeOrigin(2);
        tobiiData.eyeleft_gazeOriginZ(counter)=gazeOrigin(3);
        tobiiData.eyeleft_gazeDirectionX(counter)=gazeDirection(1);
        tobiiData.eyeleft_gazeDirectionX(counter)=gazeDirection(2);
        tobiiData.eyeleft_gazeDirectionX(counter)=gazeDirection(3);
        tobiiData.eyeleft_pupilDiameter(counter)=pupilDiameter;
    else
        tobiiData.eyeleft_gazeOriginX(counter)=nan;
        tobiiData.eyeleft_gazeOriginY(counter)=nan;
        tobiiData.eyeleft_gazeOriginZ(counter)=nan;
        tobiiData.eyeleft_gazeDirectionX(counter)=nan;
        tobiiData.eyeleft_gazeDirectionX(counter)=nan;
        tobiiData.eyeleft_gazeDirectionX(counter)=nan;
        tobiiData.eyeleft_pupilDiameter(counter)=nan;
    end

    %eyeright
    if any(ismember(l,'eyeright')) && ~contains(tline,'eyeright":{}')
        s=find(contains(l,'eyeright')); %start
        gazeOrigin=str2num(cell2mat(extractBetween(tline(i(s):i(s+2)),'gazeorigin":[',']')));
        gazeDirection=str2num(cell2mat(extractBetween(tline(i(s+2):i(s+3)),'gazedirection":[',']')));
        pupilDiameter=str2num(cell2mat(extractBetween(tline(i(s+3)-3:end),'pupildiameter":','}')));
        tobiiData.eyeright_gazeOriginX(counter)=gazeOrigin(1);
        tobiiData.eyeright_gazeOriginY(counter)=gazeOrigin(2);
        tobiiData.eyeright_gazeOriginZ(counter)=gazeOrigin(3);
        tobiiData.eyeright_gazeDirectionX(counter)=gazeDirection(1);
        tobiiData.eyeright_gazeDirectionX(counter)=gazeDirection(2);
        tobiiData.eyeright_gazeDirectionX(counter)=gazeDirection(3);
        tobiiData.eyeright_pupilDiameter(counter)=pupilDiameter;
    else
        tobiiData.eyeright_gazeOriginX(counter)=nan;
        tobiiData.eyeright_gazeOriginY(counter)=nan;
        tobiiData.eyeright_gazeOriginZ(counter)=nan;
        tobiiData.eyeright_gazeDirectionX(counter)=nan;
        tobiiData.eyeright_gazeDirectionX(counter)=nan;
        tobiiData.eyeright_gazeDirectionX(counter)=nan;
        tobiiData.eyeright_pupilDiameter(counter)=nan;
    end
    counter=counter+1;
    tline = fgetl(fid);
end

% get the offset the from the snirf file trigger
snirf = SnirfClass([folder baseFileNameNoExt '.snirf']);
idx = find(diff(snirf.aux(2).dataTimeSeries)>0.2); % CHECK HOW THESE TRIGGERS WORK
t_nirs_offset_sessions = snirf.aux(2).time(idx(1)); 
tobiiData.timestamps = tobiiData.timestamps + t_nirs_offset_sessions;


% take tobiiData object and make tsv file
dataMatrix = cell2mat(struct2cell(tobiiData)); % Result: 16 x 38873
dataMatrix = dataMatrix'; % Now it's 38873 x 16 (rows x columns)
dataTable = array2table(dataMatrix);
dataTable.Properties.VariableNames = fieldnames(tobiiData);

writetable(dataTable, join([folder, baseFileNameNoExt_physio, '.tsv']), 'FileType', 'text', 'Delimiter', '\t')

% make json file with relevant data
tobii_meta.SamplingFrequency = 1 / (tobiiData.timestamps(2) - tobiiData.timestamps(1));
tobii_meta.StartTime = t_nirs_offset_sessions;
tobii_meta.Columns = fieldnames(tobiiData);
tobii_meta.Manufacturer = 'Tobii';

phys_json = jsonencode(tobii_meta);

filename = join([folder, baseFileNameNoExt_physio, '.json']);
fid = fopen(filename, 'w');
if fid == -1
    error('Cannot create JSON file.');
end
fprintf(fid, '%s', phys_json);
fclose(fid);


end
