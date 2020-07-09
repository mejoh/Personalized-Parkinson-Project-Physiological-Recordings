function [ result, message ] = batch_parrec_to_analyze(study,pp,studyDir,outputformat)
% batch_parrec_to_analyze will convert all parrec file in files.txt
% to analyze (img/hdr) format by calling rec2analyze for each raw MR file.
% outputformat: 1 for Nifty output format (spm5), 2 for Analyze (spm2)
% 
% 2009-08-17, Paul

if nargin<3
    studyDir = fullfile(regexprep(pwd, '(^.*)(Onderzoek.*)', '$1'), 'Onderzoek/Lopend_onderzoek', 'fMRI', study);
    disp(['using study directory: ' studyDir])
end
if nargin<4
    outputformat = 1;
    disp('Converting PAR/REC to nifti ')
end

message = [];
result = false;
create_count = 0;
exist_count = 0;

ruwDir=fullfile(studyDir, 'ruw', pp);
fid=fopen(fullfile(ruwDir, 'files.txt'));
if fid==-1
    message = ['Couldn''t open files.txt in' ruwDir];
    return;
end

h = waitbar(0,'Converting PAR/REC to analyze/nifti...');
waitbar_pos = 0;

while ~feof(fid)
    line=fgetl(fid);

    if strncmpi(line,'t1',2)
        outputbasename = 't1';
        subdir = [];
    elseif strncmpi(line,'REC',3)
        outputbasename = '4D';
        subdir = 'fmri';
    else
        outputbasename = [];
    end
    if ~isempty(outputbasename)

        parts=regexp(line,'[^\s]*','match');
        recfilename=parts{4};
        task=parts{3};

        destDir=fullfile(studyDir, 'pp', pp, task);
        if ~isempty(subdir);destDir=fullfile(destDir,subdir);end
        if ~isdir(destDir);mkdir(destDir);end
        if outputformat==1
            bOutputExists = exist(fullfile(destDir,[outputbasename '.nii']),'file');
        else
            bOutputExists = exist(fullfile(destDir,[outputbasename '.hdr']),'file') && exist(fullfile(destDir,[outputbasename '.img']),'file');
        end
        if ~bOutputExists
            [filelist, message] = rec2analyze(fullfile(ruwDir, 'parrec', []), recfilename, destDir, outputbasename, outputformat);
            if ~isempty(filelist)
                create_count = create_count+1;
            else
                result = false;
                return;
            end
        else
            exist_count = exist_count+1;
        end
        waitbar_pos = waitbar_pos + 0.5*(1-waitbar_pos); % yes I know... at this point is is not clear how many will follow ;(
        waitbar(waitbar_pos);
    end

    % 
    % survey        6201	survey		6201_1_1.REC	xx          xx
    % REC           6201 	tremor1		6201_3_1.REC	EEG_90.TRC	tremor1
    % t1            6201 	t1          6201_7_1.REC	xx          xx
    % REC           6201 	tremor2		6201_6_1.REC	EEG_92.TRC	tremor2
    % DTI           6201 	DTI         6201_8_1.REC	xx          xx
    % emgprescan	6201	outsidetest	EEG_89.TRC      xx          xx

end
fclose(fid);
waitbar(1);
if create_count>0 && exist_count>0
    message = sprintf('Converted %d PAR/REC files (%d already converted)\n',create_count,exist_count);
elseif create_count>0
    message = sprintf('Converted %d PAR/REC files\n',create_count);
elseif exist_count>0
    message = sprintf('%d PAR/REC files already converted\n',exist_count);
else
    message = 'No PAR/REC data defined';
end
close(h); % close waitbar
result = true;
