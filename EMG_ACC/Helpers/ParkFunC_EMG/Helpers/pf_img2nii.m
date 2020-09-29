function pf_img2nii(hdrfile,path,zip)
%
% pf_img2.nii(hdrfile) convert your .img + .hdr file to one .nii file. Specify
% the name(s) of your hdrfile(s) in hdrfile. If all these files are located
% in the same directory, you can specify this directory in path. Otherwise
% use the fullfile name for all your hdrfiles and don't specify path.
% Additionally, you can choose to zip these files, by specifying zip as 1.
% Default is no zip.
%
% This scripts uses pf_findfile in its search for files, so you can use
% wildcards (see pf_findfile.m)
%
% Examples: img2nii('p10.hdr','C:\data')
%           img2nii('/p10/&/.hdr/','C:\data')
%           img2nii({'p10.hdr';'p12.hdr'},'C:\data')
%           img2nii({'C:\data\p10.hdr';'C:\old\p12.hdr'})

% See also Tools for NIfTI and ANALYZE image, pf_findfile.m

% © Michiel Dirkx, 2014
% contact: michieldirkx@gmail.com
% $ParkFunC

%% Configuration

tic

if nargin < 1
    
    hdrfile = {'/p10/&/.hdr/';'/p17/&/.hdr/';'/p26/&/.hdr/';'/p28/&/.hdr/';'/p31/&/.hdr/';'/p32/&/.hdr/';'/p37/&/.hdr/';             % Can use pf_findfile
               '/p39/&/.hdr/';'/p41/&/.hdr/';'/S07/&/.hdr/';'/S14/&/.hdr/';'/S18/&/.hdr/';'/S24/&/.hdr/';'/S31/&/.hdr/';
               '/S34/&/.hdr/';'/S38/&/.hdr/';'/S41/&/.hdr/';'/S44/&/.hdr/';'/S46/&/.hdr/';'/S47/&/.hdr/';'/S50/&/.hdr/';
               '/S53/&/.hdr/';'/S56/&/.hdr/';'/S60/&/.hdr/';'/S70/&/.hdr/'}; 
end

if nargin < 2
    path = '';
end

if nargin < 3
    zip  =  0;
end

%% Initialize parameters

nF  =   length(hdrfile);

%% Convert all files

for a = 1:nF
    try      CurFile   =   pf_findfile(path,hdrfile{a}); 
    catch;   CurFile   =   pf_findfile(path,hdrfile);  %#ok<*CTCH>
    end
    
    % --- Load HDR file as nii --- %
    try nii     =   load_nii(fullfile(path,CurFile)); end; %#ok<*TRYNC>
    
    % --- Save the nii file --- %
    try save_nii(nii,[CurFile '.nii']); end;
    
    if zip == 1  && ~isempty(CurFile)
    system(['gzip ' fullfile(path,CurFile(1:end-4)) '.nii']);
    disp(['Converted ' CurFile ' to ' CurFile '.nii.gz'])
    elseif ~isempty(CurFile)
    disp(['Converted ' CurFile ' to ' CurFile '.nii'])
    end
end

%% Benchmark

T = toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T) ' seconds!!'])
    





