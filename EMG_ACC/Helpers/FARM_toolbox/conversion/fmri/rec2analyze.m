function [ outfile, message ] = rec2analyze( sourcepath, parfile, destpath, destprefix, outputformat )
%REC2ANALYZE Converts Philips PAR/REC files to Analyze or Nifti format
%   The conversion is implemented by r2agui (http://r2agui.sourceforge.net/),
%   so make sure that the r2agui package is installed on your computer and 
%   added to the matlab path.
%   This function is a replacement for the rec2analyze.pl Perl script, which 
%   depends on a perl interpreter and a Unix-like shell.
%
%   sourcepath      Should be the directory containing the par/rec files
%                   This can be an empty string in case parfile contains a complete path.
%   parfile         Name of the PAR or REC file, including extension. 
%                   The path will be ignored if sourcepath is not empty.
%   destpath        Location for the output file(s)
%   destprefix      The name or name-prefix of the output file(s).
%                   When the output consists of more than one file then the name will be 
%                   padded with a dash and a 4-digit image sequence number.
%   outputformat    Should be 1 (nifti) or 2 (analyze)
%
%   Note that multiple files will be created when a multi-volume (4D) is used with r2agui.
%   The outfile return value will contain a list with all paths of the created files.
%   An asterisk before the filename indicated something went wrong during the file move operation.
%
%   TODO:   Image orientation is probably not correct... Must update header info at some point.
%   TODO:   Return outfile{} containing two columns: one for the header and 
%           one for the image files (in case the output format is Analyze).
%   TODO:   Add an optional parameter to specify output format (r2agui also supports nifti)
%
% 2009-08-14, Paul Groot

outfile = [];
if nargout>=2
    message = [];
end
if nargin<5
    outputformat = 2; % default to analyze format
end

[pathstr, parname, ext] = fileparts(parfile);
% copy source path from parfile if it is only defined in parfile
if (isempty(sourcepath) && ~isempty(pathstr))
    sourcepath = pathstr; 
end
% change extension to par in case a rec file was specified
if strcmp(ext,'.rec')
    ext = '.par';
elseif strcmpi(ext,'.REC') || isempty(ext)
    ext = '.PAR';
end
% set header filename extension
if outputformat==2
    hdrext = '.hdr';
end
% complete par-path
parfile = fullfile(sourcepath,[parname,ext]);

if true
    % Create a new nii or img/hdr file using dcm2nii from MRIcroN.
    % This is currently preferred over r2agui because we would like to write
    % mulit-volume series as a single 4D file.
    % Unfortunately we cannot specify the name of the new file explicitly, so we will
    % have to guess the names of the output and move them.

    % dcm2nii <options> <sourcenames>
    % OPTIONS:
    % -a Anonymize [remove identifying information]: Y,N = Y
    % -b load settings from specified inifile, e.g. '-b C:\set\t1.ini'  
    % -c Collapse input folders: Y,N = N
    % -d Date in filename [filename.dcm -> 20061230122032.nii]: Y,N = Y
    % -e events (series/acq) in filename [filename.dcm -> s002a003.nii]: Y,N = Y
    % -f Source filename [e.g. filename.par -> filename.nii]: Y,N = Y
    % -g gzip output, filename.nii.gz [ignored if '-n n']: Y,N = Y
    % -i ID  in filename [filename.dcm -> johndoe.nii]: Y,N = Y
    % -n output .nii file [if no, create .hdr/.img pair]: Y,N = Y
    % -o Output Directory, e.g. 'C:\TEMP' (if unspecified, source directory is used)
    % -p Protocol in filename [filename.dcm -> TFE_T1.nii]: Y,N = Y
    % -r Reorient image to nearest orthogonal: Y,N 
    % -s SPM2/Analyze not SPM5/NIfTI [ignored if '-n y']: Y,N = N
    % -v Convert every PAR file in the directory: Y,N = Y
    %   You can also set defaults by editing dcm2nii.ini
    if outputformat==1 % nifti
        formatArg = '-n y ';
    else % img/hdr, spm5
        formatArg = '-n n -s n ';
    end
    mypath = '/usr/local/bin'; %fileparts(mfilename('fullpath'));
    if ispc
        dcm2nii = 'dcm2nii.exe';
    else
        dcm2nii = 'dcm2nii';
    end
    cmd = [fullfile(mypath,dcm2nii), ' -a n -d n -e n -g n -i n -p n -r n -v n -f y ', formatArg,' -o ', destpath, ' ', parfile ];
    disp(['Running system command: ', cmd ])
    [status msg] = system(cmd);
    if status==0
        basename = parname;
        if outputformat==1
            ext = '.nii';
        else
            ext = '.img';
        end
        newoutfile = fullfile(destpath, [destprefix ext]);
        % move the image file
        [status, msg] = movefile(fullfile(destpath, [basename ext]), newoutfile);
        if status==1 && outputformat==2
            % move the header file in case we converted to hdr/img
            [status, msg] = movefile(fullfile(destpath, [basename hdrext]), fullfile(destpath, [destprefix hdrext]));
        end
        if status==0
            msg = [ 'An error ocurred while moving the new Analyze files to the destination: ', msg ];
            outfile{1} = ['*' newoutfile]; % mark as incomplete
        else
            outfile{1} = newoutfile;
        end
    end
else
    % Convert PAR/REC to analyse/nifti by using r2agui
    % Note that the current version (28/1/2009) doesn't support converting multi-volume into a single file.
    if exist('convert_r2a','file')~=2
        msg = 'r2agui is not installed or not included in the your path. Install from: http://r2agui.sourceforge.net/';
    else
        options.subaan=0;           % do not create subdirs for output
        options.usealtfolder=0;     %~isempty(destpath);
        options.altfolder=[];
        options.prefix=[];          % 
        options.usefullprefix=0;    % not important beacause we will rename the output anyway
        options.pathpar=sourcepath;
        options.angulation=0;       % only effective for nifti though
        options.rescale=1;          % store intensity scale as found in PAR file (assumed equall for all slices). Yields DV values.
        options.outputformat=outputformat;     % 1=nifti, 2 = analyze;
        
        filelist{1} = [parname ext];      % convert only one file

        sep = filesep;
        if (options.pathpar(end)~=sep) && ~(options.pathpar(end)=='/' && ispc)
            options.pathpar(end+1) = sep;
        end

        outfile=convert_r2a(filelist,options);

        if isempty(outfile)
            msg = 'PAR/REC to Analyze (hdr/img) conversion failed!';
        else
            % move the files to their destination
            nFiles = length(outfile);
            for iFile=1:nFiles
                % split the full path of the new Analyze img file
                [sourcepath, basename, ext ] = fileparts(outfile{iFile});
                % assemble the complete path for the final location
                if nFiles==1
                    outbase = destprefix;
                else
                    outbase = sprintf('%s-%04d',destprefix,iFile);
                end
                newoutfile = fullfile(destpath, [outbase ext]);
                % move the image file
                [status, msg] = movefile(fullfile(sourcepath, [basename ext]), newoutfile);
                if status==1 && outputformat==2
                    % move the header file in case we converted to hdr/img
                    if sum(isstrprop(ext, 'upper'))==3
                        hdrext = upper(hdrext);
                    end
                    [status, msg] = movefile(fullfile(sourcepath, [basename hdrext]), fullfile(destpath, [outbase hdrext]));
                end
                if status==0
                    msg = [ 'An error ocurred while moving the new Analyze files to the destination: ', msg ];
                    outfile{iFile} = ['*' outfile{iFile}]; % mark as incomplete
                else
                    outfile{iFile} = newoutfile;
                end
            end
        end
    end
end

if nargout>=2
    message = msg;
end
if ~isempty(msg)
    disp(msg)
end
