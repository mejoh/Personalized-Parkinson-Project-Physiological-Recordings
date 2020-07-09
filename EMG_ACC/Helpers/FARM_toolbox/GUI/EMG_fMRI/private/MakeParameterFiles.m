function [ result, message ] = MakeParameterFiles( studyDir, ppid )
%MakeParameterFiles: This function will create missing parameter files.
%   The parameter file hold some relevant MR parameters that are normally automatically
%   extracted from the native Philips PAR-file in the raw/parrec directory. 
%   Parameter files should reside in each individual 'task' subdirectory.

    message = [];
    result = false;
    try
        created_count = 0;
        existing_count = 0;
        ruwDir=fullfile(studyDir, 'ruw', ppid);
        fid=fopen(fullfile(ruwDir, 'files.txt'));
        if fid==-1
            message = [ 'Couldn''t open files.txt in ' ruwDir ];
            return;
        end
        
        while ~feof(fid)
            line=fgetl(fid);

            if strncmpi(line,'REC',3) % || strncmpi(line,'DTI',3)

                parts=regexp(line,'[^\s]*','match');

                recfilename=parts{4};
                [ dummy, basename ] = fileparts(recfilename);
                par_path = fullfile(ruwDir, 'parrec', [basename, '.PAR']); % TODO: should actually check for exact filename (linux will be case sensitive)

                task=parts{3};

                destDir=fullfile(studyDir, 'pp', ppid, task);
                parameter_path = fullfile(destDir, 'parameters');

                if ~isdir(destDir);mkdir(destDir);end
                if ~exist(fullfile(destDir,'parameters'),'file') 
                    [ parameters, message ] = build_parameters_file(par_path, parameter_path);
                    if isempty(parameters)
                        return;
                    else
                        fprintf('Created parameter file for (%s,%s): %s\n',ppid,task,parameter_path);
                        created_count = created_count+1;
                    end
                else
                    existing_count = existing_count+1;
                end
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
        
        message = sprintf('%d existing and %d new', existing_count, created_count);
        result = true;
        
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        % getReport(ME) %only works with R2007+ in combination with catch ME
        errordlg(['Something went wrong: ', ME.message ])
        message = ME.message;
    end
end

