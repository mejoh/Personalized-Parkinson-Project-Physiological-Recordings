function ChangeMarkersAllSubs(Task, ProjectNr, Subset, Force)
% Task = 'motor' / 'reward' / 'rest';                 % From which task do you want to process data
% ProjectNr = '3022026.01';       % From which subjects do you want to process subjects
% Subset = number; % double indicating number of subjects to be processed
% Force = true/false %true=reanalyze already processed subjects, false=skip already proccessed subjects, if left empty default = false

%% ToDo
%Improve descriptions
%Improve error handling
%Task = rest errors after a few subjects

if isempty(Force)
    Force = false;
end

%% OS CHECK
if ispc
    pfProject="P:\";
elseif isunix
    pfProject="/project/";
else
    warning('Platform not supported - Linux settings are used')
    pfProject="/project/";
end


%% USER SETTINGS
%Options: 

%Standard settings: 


%Settings specific to task
if strcmp(Task, "motor")
    settings.TR         = 1;                                                                %double with TR time in seconds
    settings.Scan = '^sub-.*task-motor_acq-MB6.*nii.gz$';        %Regular expression used to search for relevant image
    settings.NewFolder  = fullfile(pfProject, "3022026.01", "analyses", "EMG", "motor");                 %Output folder for the new files
elseif strcmp(Task, "reward")
    settings.TR         = 2.24;                                                                %double with TR time in seconds
    settings.Scan = '^sub-.*task-reward_acq-ME.*nii.gz$';      %Regular expression used to search for relevant image
    settings.NewFolder  = fullfile(pfProject, "3022026.01", "analyses", "EMG", "reward");                 %Output folder for the new files
elseif strcmp(Task, "rest")
    settings.TR         = 0.735;                                                                %double with TR time in seconds
    settings.Scan = '^sub-.*task-rest_acq-MB8.*bold.*nii.gz$';      %Regular expression used to search for relevant image
    settings.NewFolder  = fullfile(pfProject, "3022026.01", "analyses", "kevin", "Freek-PDresttremor","Corrected_BVAfiles");                 %Output folder for the new files
end

%% Execution
fprintf("Processing physiological data from %s task in project %s\n", Task, ProjectNr)

%Retrieve subjects
addpath('/home/common/matlab/spm12')
pDir = fullfile(pfProject, ProjectNr);
pBIDSDir = char(fullfile(pDir, 'pep', 'bids'));
Sub = cellstr(spm_select('List', fullfile(pBIDSDir), 'dir', '^sub-POM.*'));
Sel = true(numel(Sub),1);

%Exclude subjects without fmri/task data
for n = 1:numel(Sub)
    cSessions = cellstr(spm_select('FPList', fullfile(pBIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    TaskData_fmri = cellstr(spm_select('List', fullfile(cSessions, 'func'), ['.*task-', Task, '.*.nii.gz']));
    TaskData_beh  = cellstr(spm_select('List', fullfile(cSessions, 'beh'), ['.*task-', Task, '.*.tsv']));
    if isempty(TaskData_fmri{1}) || isempty(TaskData_beh{1})
        Sel(n) = false;
        fprintf('Skipping %s without fmri or without beh data for task \n', Sub{n})
    end
end
% Exclude subjects that do not have eeg data
for n = 1:numel(Sub)
    cSessions = cellstr(spm_select('List', fullfile(pBIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    for i = 1:numel(cSessions)
        eeg = spm_select('List', fullfile(pBIDSDir, Sub{n}, cSessions{i}, 'eeg'), [Sub{n}, '_', cSessions{i}, '.*', Task, '.*_eeg.eeg']);
        vmrk = spm_select('List', fullfile(pBIDSDir, Sub{n}, cSessions{i}, 'eeg'), [Sub{n}, '_', cSessions{i}, '.*', Task, '.*_eeg.vmrk']);
        vhdr = spm_select('List', fullfile(pBIDSDir, Sub{n}, cSessions{i}, 'eeg'), [Sub{n}, '_', cSessions{i}, '.*', Task, '.*_eeg.vhdr']);
        if isempty(eeg) || isempty(vmrk) || isempty(vhdr)
            Sel(n) = false;
            fprintf('Skipping %s without task-related eeg data \n', Sub{n})
        end
    end
end

%Exclude subjects that have already been processed
if ~Force
for n = 1:numel(Sub)
    cSessions = cellstr(spm_select('List', fullfile(pBIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    for i = 1:numel(cSessions)
        eeg = spm_select('List', settings.NewFolder, [Sub{n}, '_', cSessions{i}, '.*', Task, '.*_eeg.eeg']);
        vmrk = spm_select('List', settings.NewFolder, [Sub{n}, '_', cSessions{i}, '.*', Task, '.*_eeg.vmrk']);
        vhdr = spm_select('List', settings.NewFolder, [Sub{n}, '_', cSessions{i}, '.*', Task, '.*_eeg.vhdr']);
        if ~isempty(eeg) && ~isempty(vmrk) && ~isempty(vhdr)
            Sel(n) = false;
            fprintf('Skipping %s with already processed data \n', Sub{n})
        end
    end
end
end

Sub = Sub(Sel);

% Generate an input table for the ChangeMarkersEMG function
inputTable = cell2table(cell(0,2), 'VariableNames', {'Subject', 'oldFile'});
for n = 1:numel(Sub)
    cSessions = cellstr(spm_select('FPList', fullfile(pBIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    cSessions = strcat(cSessions, filesep, 'eeg');
    sVmrk = "";
    for ses = 1:size(cSessions,1)
        dVmrk = dir(fullfile(cSessions{ses}, [Sub{n}, '*', Task, '*.vmrk']));
        if isempty(dVmrk)
            sVmrk(ses,1) = "";
        else
            sVmrk(ses,1) = string(join([dVmrk(end).folder, filesep, dVmrk(end).name]));
        end
    end
    SubjectID = string(repmat(Sub{n}, numel(sVmrk), 1));
    inputTable = [inputTable; table(SubjectID, 'VariableNames', {'Subject'}), table(sVmrk, 'VariableNames', {'oldFile'})];
end

%Check whether a .vmrk is present and select the last run
% DEPRECATED inputTable = rowfun(@(cSub) getFiles2(pDir, Task, cSub, Session), cell2table(Sub), 'NumOutputs', 2, 'OutputVariableNames', {'Subject', 'oldFile'});
if isempty(Subset)
    Subset = height(inputTable);
    fprintf('Processing all %i remaining participants \n', Subset)
elseif ~isempty(Subset) && Subset > height(inputTable)
    Subset = height(inputTable);
    fprintf('Subset is greater than total number of participants. Processing all %i participants instead \n', Subset)
end
inputTable = inputTable(~ismissing(inputTable.oldFile),:); %remove subjects without folder
inputTable = inputTable(1:Subset,:);            % Subset for testing
settings.EEGfolder  = table2array(rowfun(@fileparts, inputTable(:,2)));

%Check markers
logFile.LogTable = rowfun(@(Subject, oldFile) ChangeMarkersEMG(Subject, oldFile, settings), inputTable, ...
    'NumOutputs', 3, ...
    'OutputVariableNames', ["Subject", "File", "Error"]);

%Remove duplicated 'response' events in .vmrk files
for n=1:size(inputTable,1)
    cSub = char(table2array(inputTable(n,1)));
    VMRKfiles = cellstr(spm_select('FPList', fullfile(settings.NewFolder), [cSub '.*task-', Task, '*._eeg.vmrk'])); % Locates multiple visits if available
    for i=1:numel(VMRKfiles)
        ChangeDoubleResponse(VMRKfiles{i});
    end
end

%Log
logFile.settings = settings;
logFile.MissingOriginalFile = inputTable.Subject(ismissing(inputTable.oldFile));
Logname = fullfile(settings.NewFolder, strcat("LogFile", datestr(now,'_mm-dd-yyyy_HH-MM-SS'), ".mat"));
save(Logname, 'logFile');
disp(strcat("Saved log to: '", Logname, "'"));

%% Functions
%This functions changes marker files
function [cSub, oldFile, cError] = ChangeMarkersEMG(cSub, oldFile, settings)
%CHANGEMARKERSEMG Summary of this function goes here
%    Detailed explanation goes here

%Start Disp & check if not already ran for this sub
disp(strcat("Analysing Sub: ", cSub));
[~, cFileID, ~] = fileparts(oldFile);
newFile = fullfile(settings.NewFolder, strcat(cFileID, ".vmrk"));
if exist(newFile, 'file')
    warning(strcat("There is already a new markerfile in the new folder for: ", oldFile))
    cError = "There is already a new markerfile in the new folder";
    return
end

%Load file
%-----------------------------------
%Data
cError = string;
cData = readtable(oldFile, ...
    'FileType', 'text', ...
    'ReadVariableNames', false, ...
    'Delimiter', {'=', ','}, ...
    'HeaderLines', 11);
if(size(cData,2) == 6)
    cData.Properties.VariableNames = {'MarkerNumber','MarkerType','Description','PositionInDatapoints','SizeInDataPoints', 'ChannelNumber'};
elseif(size(cData,2) == 7)
    cData.Properties.VariableNames = {'MarkerNumber','MarkerType','Description','PositionInDatapoints','SizeInDataPoints', 'ChannelNumber', 'Unknown'};
end

%Header
cFile = fopen(oldFile);
header=strings(12,1);
for cLine = 1:12
    header(cLine)=string(fgetl(cFile));
end
fclose(cFile);

%Checks for whether the marker file is acceptable.
%-----------------------------------
%Check 1) acceptable R1 notations, remove all others.
%All possible markers
acceptableDescriptions = [strcat("R  ", string(3:2:9)), strcat("R ", string(11:2:31))];
if any(ismember(string(cData.Description), acceptableDescriptions))
    warning(strcat("Adjusted R pulses to R1 for: ", oldFile));
    cError = strcat(cError, " & Adjusted R pulses to R1");
    cData = cData(ismember(string(cData.Description), ["R  1", acceptableDescriptions]), :);
else
    cData = cData(ismember(string(cData.Description), "R  1"), :);
end

%Check 2) acceptable timings, will also show additional pulses
acceptableTimings=[settings.TR*5000, (settings.TR*5000)-1, (settings.TR*5000)+1];
if ~all(ismember(diff(cData.PositionInDatapoints), round(acceptableTimings)))
    warning(strcat("Not all R1 scans have the same interval for: ", oldFile, "trying to fix..."))
    cError = strcat(cError, " & Not all R1 pulses have the same interval FIXED!!!!!");
    cData = fixTimings(cData, acceptableTimings);
    
    %Check if fixed
    if ~all(ismember(diff(cData.PositionInDatapoints), round(acceptableTimings)))
        warning(strcat("Not all R1 scans have the same interval for: ", oldFile))
        cError = strcat(cError, " & Not all R1 pulses have the same interval");
        return
    end
end

%Check 3) Check if there are sufficient pulses
%Find number of pulses
cImgDir = strrep(fileparts(oldFile), '/eeg', '/func');
cImg = spm_select('FPList', cImgDir, settings.Scan);
cImgSize = size(spm_vol(cImg(size(cImg,1),:)),1);
if (size(cData, 1) == cImgSize+1)
    warning(strcat("One pulse too many for: ", oldFile));
    cError = strcat(cError, " & One pulse too many - REMOVED LAST PULSE");
    cData(end,:)=[];
elseif (size(cData, 1) > cImgSize)
    warning(strcat("More then one pulse too many for: ", oldFile));
    cError = strcat(cError, " & More then one pulse too many");
    return
elseif (size(cData, 1) < cImgSize)
    warning(strcat("Not enough pulses for: ", oldFile));
    cError = strcat(cError, " & Not enough pulses");
    return
end

%Check 4) acceptable header name
cHeaderRow = contains(header, "DataFile");
cHeaderID = extractBetween(header(cHeaderRow),"DataFile=",".eeg");
if cHeaderID ~= cFileID
    warning(strcat("Headerfile does not match with filename for: ", oldFile))
    cError = strcat(cError, " & Headerfile does not match with filename");
end

%If no error
if strcmp(cError, ""); cError = "No error detected"; end

% Fix potential problems
%-----------------------------------
%Update fileChange Header "\1" to make it interpretable
header = replace(header, '"\1".', '\"\\1\".');

%Fix Header ID
if contains(cError, "Headerfile")
    header(cHeaderRow)=replace(header(cHeaderRow), cHeaderID, cFileID);
end

%Rework marker numbers & remove unnecessary columns
cData.MarkerNumber = strcat("Mk", string(2:length(cData.MarkerNumber)+1))';
cData.MarkerNumber = strcat(cData.MarkerNumber, "=", cData.MarkerType);
if(size(cData,2) == 6)
    cData=removevars(cData, {'MarkerType'});
elseif(size(cData,2) == 7)
    cData=removevars(cData, {'MarkerType', 'Unknown'});
end

%Set Description markers to "R  1"
cData.Description = repmat("R  1", size(cData,1), 1);

%Save new file
%-----------------------------------
%Make a file with the updated header
cFile = fopen(newFile, 'w+');
for cLine = 1:12
    fprintf(cFile, strcat(header(cLine), '\r\n'));
end
fclose(cFile);

%Make a temp file with the data
tempDataFile = fullfile(settings.NewFolder, strcat(cFileID, "_tempData.vmrk"));
writetable(cData, tempDataFile, 'WriteVariableNames', false, 'FileType', 'text');

%Merge
cHeaderFile = fopen(newFile, 'a'); %open
cDataFile = fopen(tempDataFile, 'r');
cDataFileContents = fread(cDataFile); %read data as binary
fwrite(cHeaderFile,cDataFileContents); %append to headerfile
fclose(cHeaderFile); %close
fclose(cDataFile);

%Remove tempData file
delete(tempDataFile)

%Copy .eeg and .vhdr files
cBase = fullfile(fileparts(oldFile), cFileID);
cTarget = fullfile(settings.NewFolder, cFileID);
copyfile(strcat(cBase, ".eeg"), strcat(cTarget, ".eeg")); %.eeg
copyfile(strcat(cBase, ".vhdr"), strcat(cTarget, ".vhdr")); %.vhdr

%End disp
disp("Done! Next file...");
end

%This function will fix wrong timings
function newData = fixTimings (cData, allTimings)
cDiff = diff(cData.PositionInDatapoints);
cWrong = ~ismember(cDiff, round(allTimings));

%If the pulses are in the beginning, they can just be removed
while cWrong(1)
    cData(1, :) = [];
    cDiff = diff(cData.PositionInDatapoints);
    cWrong = ~ismember(cDiff, allTimings);
end

%Otherwise, find the first one and remove the one afterwards.
while sum(cWrong)>0
    RemovePulse = find(cWrong,1)+1;
    cData(RemovePulse, :) = [];
    cDiff = diff(cData.PositionInDatapoints);
    cWrong = ~ismember(cDiff, round(allTimings));
end

%Parse cData
newData = cData;
end

%%%%%-------------DEPRECATED-------------%%%%%
%This function retrieves the old Marker file for a subject
function [cSub, cFile] = getFiles(pDir, Task, ProjectNr, cSub)
%Check what to search for
switch Task
    case "rest"
        cTask = 'rest';
    case "reward" 
        cTask = 'reward';
    case "motor" 
        cTask = 'motor';
end

%Check original file is present
if strcmp(ProjectNr, "3022026.01")  % ParkinsonOpMaat
    vmrkPath = dir(fullfile(pDir, 'DataEMG', [char(cSub), '*', cTask, '*.vmrk']));
    if isempty(vmrkPath)
        fprintf("Skipping sub-%s with no vmrk file\n", cSub)
        cFile = missing;
    else
        cFile = string(join([vmrkPath(end).folder, filesep, vmrkPath(end).name])); %Note that I only take the last file (if there are multiple i.g. task1, task2)
    end
elseif strcmp(ProjectNr, "3024006.01") % ParkinsonInToom
    vmrkPath = dir(fullfile(pDir, 'bids', ['sub-' char(cSub)], 'emg', ['*', cTask, '*.vmrk']));
    if isempty(vmrkPath)            % Check for subjects with missing vmrk file
        fprintf("Skipping sub-%s with no vmrk file\n", cSub)
        cFile = missing;
    else
        cFile = string(join([vmrkPath(end).folder, filesep, vmrkPath(end).name])); %Note that I only take the last file (if there are multiple i.g. task1, task2)
    end
else
    fprintf("Project number not recognized as either PIT or POM, aborting...\n")
end
end
%%%%%------------------------------------%%%%%

function [vmrkfile] = ChangeDoubleResponse(vmrkfile)
    
    if(isempty(vmrkfile))
        return
    end
    
    cData = fopen(vmrkfile);
    header=string(fgetl(cData));
    while 1
        OldLine = fgetl(cData);
        if ~ischar(OldLine), break, end         % Break when there are no more lines to read
        if(contains(OldLine, 'Response,Response,R ') || contains(OldLine, 'R 1'))
            newLine = strrep(OldLine, 'Response,Response,R ', 'Response,R ');
            newLine = strrep(newLine, 'R 1', 'R  1');
        else
            newLine = OldLine;
        end
        header = [header; newLine];
    end
    fclose(cData);    
    header = header';
    
    cHeaderFile = fopen(vmrkfile, 'w+');        % overwrite content
    for line = 1:length(header)
        fprintf(cHeaderFile, strcat(header(line), '\r\n'));
    end
    fclose(cHeaderFile); %close
    
end

end
