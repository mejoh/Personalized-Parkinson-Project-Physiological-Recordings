function ChangeMarkersAllSubs(Task, ProjectNr)
% Which task would you like to process? (motor / reward / rest)
% Which project would you like to process? (3022026.01 / 3024006.01)

%% ToDo
%Improve descriptions
%Improve error handling

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
settings.RawFolder  = fullfile(pfProject, ProjectNr, 'raw');   %We count the number of images in the raw folder

%Settings specific to task
if strcmp(Task, "motor")
    settings.TR         = 1;                                                                %double with TR time in seconds
    settings.ScanFolder = fullfile("ses-mri01", "0*MB6_fMRI_2.0iso_TR1000TE34", "*.IMA");        %To search the raw images, we need a path within a subject folder to the raw images of the currect scan. Note the * at the scanname (instead of numbers) and the file extension (all IMA files).
    settings.NewFolder  = fullfile(pfProject, "3022026.01", "analyses", "motor", "emg", "corrected");                 %Output folder for the new files
    settings.NumberOfEchos = 1;                                                      % Number of Echos if you do not have a multi echo sequence, use 1.
elseif strcmp(Task, "reward")
    settings.TR         = 2.24;                                                                %double with TR time in seconds
    settings.ScanFolder = fullfile("ses-mri01", "0*cmrr_3.5iso_me5_TR2240", "*.IMA");        %To search the raw images, we need a path within a subject folder to the raw images of the currect scan. Note the * at the scanname (instead of numbers) and the file extension (all IMA files).
    settings.NewFolder  = fullfile(pfProject, "3022026.01", "analyses", "reward", "emg_acc", "test");                 %Output folder for the new files
    settings.NumberOfEchos = 5;                                                      % Number of Echos if you do not have a multi echo sequence, use 1.
elseif strcmp(Task, "rest")
    settings.TR         = 0.735;                                                                %double with TR time in seconds
    settings.ScanFolder = fullfile("ses-mri01", "0*MB8_fMRI_fov210_2.4mm_ukbiobank", "*.IMA");        %To search the raw images, we need a path within a subject folder to the raw images of the currect scan. Note the * at the scanname (instead of numbers) and the file extension (all IMA files).
    settings.NewFolder  = fullfile(pfProject, "3022026.01", "analyses", "rest", "emg", "corrected");                 %Output folder for the new files
    settings.NumberOfEchos = 1;                                                      % Number of Echos if you do not have a multi echo sequence, use 1.
end

%% Execution
fprintf("Processing physiological data from %s task in project %s\n", Task, ProjectNr)

%Retrieve subjects
addpath('/home/common/matlab/spm12')
pDir = fullfile(pfProject, ProjectNr);
pBIDSDir = char(fullfile(pDir, "bids"));
Sub = spm_BIDS(pBIDSDir, 'subjects', 'task', Task)'; %Get list of subject who have done the chosen task. This will take a while (we're talking several minutes)...

%Check whether a .vmrk is present and select the last run
inputTable = rowfun(@(cSub) getFiles(pDir, Task, ProjectNr, cSub), cell2table(Sub), 'NumOutputs', 2, 'OutputVariableNames', {'Subject', 'oldFile'});
inputTable = inputTable(~ismissing(inputTable.oldFile),:); %remove subjects without folder
% inputTable = inputTable(8:11,:);            % Subset for testing
settings.EEGfolder  = table2array(rowfun(@fileparts, inputTable(:,2)));

%Check markers
logFile.LogTable = rowfun(@(cSub, oldFile) ChangeMarkersEMG(cSub, oldFile, settings), inputTable, ...
    'NumOutputs', 3, ...
    'OutputVariableNames', ["Subject", "File", "Error"]);

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
cData.Properties.VariableNames = {'MarkerNumber','MarkerType','Description','PositionInDatapoints','SizeInDataPoints', 'ChannelNumber', 'Unkown'};

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
cImaFiles = size(dir(strcat(settings.RawFolder, filesep, "sub-", cSub, filesep, settings.ScanFolder)),1);
cImaFiles = cImaFiles / settings.NumberOfEchos ;
if (size(cData, 1) == cImaFiles+1)
    warning(strcat("One pulse too many for: ", oldFile));
    cError = strcat(cError, " & One pulse too many - REMOVED LAST PULSE");
    cData(end,:)=[];
elseif (size(cData, 1) > cImaFiles)
    warning(strcat("More then one pulse too many for: ", oldFile));
    cError = strcat(cError, " & More then one pulse too many");
    return
elseif (size(cData, 1) < cImaFiles)
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
cData=removevars(cData, {'MarkerType', 'Unkown'});

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
if contains(settings.EEGfolder, '3022026.01')           % Because POM and PIT organizes emg data differently, we need different settings here
    cBase = fullfile(settings.EEGfolder(1), cFileID);
elseif contains(settings.EEGfolder, '3024006.01')
    idx = contains(settings.EEGfolder, extractBefore(cFileID, '_'));
    cBase = fullfile(settings.EEGfolder(idx), cFileID);
end
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

%This function retrieves the old Marker file for a subject
function [cSub, cFile] = getFiles(pDir, Task, ProjectNr, cSub)
%Check what to search for
switch Task
    case "rest"
        cTask = 'rest';
    case "reward" 
        cTask = 'task';
    case "motor" 
        cTask = 'task';
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
end
