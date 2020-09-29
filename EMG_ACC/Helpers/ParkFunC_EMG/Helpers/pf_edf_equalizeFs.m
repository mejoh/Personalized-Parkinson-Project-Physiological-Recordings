function pf_edf_equalizeFs(rootdir,fname,varargin)
% pf_edf_equalizeFs(rootdir,fname,varargin) will equalize the Fs in EDF
% files.
% varargin can be another (reference) file, or the sampling frequency you
% want to up to. Choose 'upsample' or 'downsample' as varargin.
% specify as varargin:
%   'upmethod': 'conservative' (uses upsample), 'interp'  
%                (uses interp1), 'resample' (uses resampling). 
%
% NOTE: DOWNSAMPLING DOES only work for method 'resample'.
%
%% Defaults
%--------------------------------------------------------------------------

subdir     =   '';         % Default subdirectory
subsubdir  =   '';         % Default subsubdirectory
method     =   'upsample'; % Default upsample
meth       =   'resample'; % Default resampling option
save       =   'no';       % Default save option

%--------------------------------------------------------------------------

%% Deal with varargin
%--------------------------------------------------------------------------

for b = 1:length(varargin)
if mod(b,2) == 1
switch varargin{b}
case 'sbdir'
    subdir     =   varargin{b+1};      % subdir if applicable
case 'sbsbdir'
    subsubdir  =   varargin{b+1};      % Subsub dir if applicable
case 'save'                         
    save       =   1;                  % save files
case 'methodUp'
    meth       =   varargin{b+1};      % resampling method
case 'method'
    method     =   varargin{b+1};      % resampling method
end
end
end

%--------------------------------------------------------------------------

%% Initiate Parameters
%--------------------------------------------------------------------------

nSub    =   length(subdir);
nSubsub =   length(subsubdir);
cnt     =   1;

%--------------------------------------------------------------------------

%% Collect all files
%--------------------------------------------------------------------------

fprintf('1) Collecting all files \n')

for b = 1:nSub
    CurSub = pf_findfile(rootdir,subdir{b},'msgN',0,'fullfile');
    for b = 1:nSubsub
        CurSess		= subsubdir{b};
        CurDir		= pf_findfile(CurSub,CurSess,'fullfile','msgN',0);
        CurFile		= pf_findfile(CurDir,fname,'intersel');
        Files{cnt}	= fullfile(CurDir,CurFile);
        cnt			= cnt + 1;
        fprintf(' - Added: %s\n',CurFile)
    end
end

nFiles	=	length(Files);

%--------------------------------------------------------------------------

%% Resampling files
%--------------------------------------------------------------------------

fprintf('\n 2) Resampling all files \n')

for a = 1:nFiles
    
    % --- Read File --- %
    
    clear dat hdr
    
    CurFile    = Files{a};
    [path,name]= fileparts(CurFile);
    fprintf(' - Working on %s\n',name)
    
    [dat,hdr]   =   read_edf(CurFile);
    
    % --- Get Fs info --- %
    
    uFs         =   unique(hdr.samplerate); % Unique samplerates
    minFs       =   min(uFs);               % lowest Fs
    maxFs       =   max(uFs);               % highest Fs
    
    % --- Downsample or Upsample --- %
    
    switch method
        case 'upsample'
            sel =   uFs~=maxFs;
            wFs =   uFs(sel);   % Fs that need to be upsampled
            target = maxFs;     % target Fs
        case 'downsample'
            sel =   uFs~=minFs;
            wFs =   uFs(sel);   % Fs that need to be downsmapled
            target = minFs;     % target Fs
    end
    
    % --- Actual resampling of selected channels --- %
    
    for b = 1:length(wFs)
        
        % --- Find channels corresponding to CurFs --- %
        
        CurFs   =   wFs(b);
        iChan   =   find(hdr.samplerate~=target);
        
        % --- Determine multiplication factor --- %
        
        factor  =   target/CurFs;
        
        for c = 1:length(iChan);
            
            % --- Resampling data --- %
            
            if strcmp(meth,'interp')
                dat{iChan(c)}    =   interp(dat{iChan(c)},factor);
            elseif strcmp(meth,'conservative')
                dat{iChan(c)}    =   upsample(dat{iChan(c)},factor);
            elseif strcmp(meth,'resample')
                dat{iChan(c)}    =   resample(dat{iChan(c)},target,CurFs);
            end
            
            % --- Adjust Fs in HDR --- %
            
            hdr.samplerate(iChan(c)) =   target;
            
        end
        
        fprintf('%s\n',[' -- Resampled ' num2str(length(iChan)) ' channels with Fs=' num2str(CurFs) ' Hz to ' num2str(target) ' Hz.'])
        
    end
    
    % === Save resampled EDF+ (Hdr+dat) === %
    
    if save == 1
        savedir = fullfile(path,'equalFs');
        if ~exist(savedir,'dir'); mkdir(savedir); end
        cd(savedir)
        copyfile(CurFile,savedir);
        save_edf([name '_resampled2Fs=' num2str(target) '.edf'],dat,hdr)
    end
    
    fprintf('%s\n',['--- Saved "' name '_resampled2Fs=' num2str(target) '.edf"'])
    
end

%==========================================================================
