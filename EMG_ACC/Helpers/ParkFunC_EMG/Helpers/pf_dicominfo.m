function pf_dicominfo(path,speed)
% pf_dicominfo(path,speed) will analyze the dicom headers of the dicom files
% located in path. If no path is specified it will use the current
% directory. Speed indicates the fastness of this analysis, if nothing is
% specified it will go 'fast'. This means it will use the name of the files
% to analyze rather than read all the headers.

% ©Michiel Dirkx, 2015
% $ParkFunC, 20150601

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

tic

if nargin<1
    clc
    path = cd;
end

if nargin<2
    speed = 'fast';
end

ima      =   pf_findfile(path,'*.IMA|','fullfile');
nFiles   =   length(ima);
protold  =   '';
serieold =   999;

cnt      =   1;

%--------------------------------------------------------------------------

%% Get all the dicom info
%--------------------------------------------------------------------------

fprintf('\n')

for a = 1:nFiles
    
    CurFile =   ima{a};
    
    % --- Read DICOM header --- %
    
    hdr     =   dicominfo(CurFile);
    prot    =   hdr.ProtocolName;
    
    
    if strcmp(speed,'accurate')
        seq     =   hdr.SeriesNumber;
    elseif strcmp(speed,'fast')
        iDot    =   strfind(CurFile,'.');
        seqdot  =   iDot(3);
        seq     =   str2num(CurFile(seqdot+1:seqdot+4));
    end
    
    if serieold ~= seq
        date = [hdr.AcquisitionDate(7:8) '-' hdr.AcquisitionDate(5:6) '-' hdr.AcquisitionDate(1:4)];
        time = [hdr.AcquisitionTime(1:2) ':' hdr.AcquisitionTime(3:4)];
        fprintf('%s\n',['Sequence ' num2str(seq) ': "' prot '" start at '  date ' ' time ])
        cnt = cnt+1;
    end
    
    protold  =   prot; 
    serieold =   seq;
    
end

%--------------------------------------------------------------------------

%% Cooling down
%--------------------------------------------------------------------------

T = toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T/60) ' minutes!!'])







