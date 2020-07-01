function pf_pmg_prepraw_edfmerge(conf,files)
% pf_pmg_prepraw_mergebroken(conf) is part of the preprocessing part of the 
% pf_pmg_batch function. Specifically, this function will combine EDF files.
% This can be useful, as sometimes EDF files belonging to the same session
% belong to each other (e.g. when the subject had to take a toilet break).
% this assumes that the amount of channels in all files are equal and,
% moreover, have the same montage.
%
% Part of pf_pmg_ana.m

% Michiel Dirkx, 2015
% $ParkFunC, version 20150406

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nFiles = length(files);

%--------------------------------------------------------------------------

%% Loop over files and merge
%--------------------------------------------------------------------------

for a = 1:nFiles
   
    CurFile          =   files{a};
    CurSub           =   CurFile.sub;
    CurSess          =   CurFile.sess;
    [~,basefile,ext] =   fileparts(CurFile.file);
    
    fprintf('\n%s\n',['Working on ' CurSub '-' CurSess]);
    fprintf('%s\n',['- Basefile: "' basefile ext '"']);
    
    % --- Load Basefile --- %
    
    [d,h]   =   ReadEDF_shapkin(CurFile.file);
    nAddon  =   length(CurFile.addon);
    
    % --- Load and concatenate addons --- %
    
    for b = 1:nAddon
       CurAdd         =   CurFile.addon{b};
       [~,addfile,ex] =   fileparts(CurFile.addon{b});   
       fprintf('%s',['-- Concatenate addon ' num2str(b) ': "' addfile ex '"...']);
       
       [dadd,hadd]    =   ReadEDF_shapkin(CurFile.addon{b});
       
       if length(d) ~= length(dadd)
           error('pmgpreproc:merge','Amount of channels from basefile does not match this addon');
       end
       
       % --- Concatenate Addon: data --- %
       
       d        =   cellfun(@vertcat,d,dadd,'UniformOutput',0);
       
       % --- Concatenate Addon: header --- %
       
       if strcmp(conf.prepraw.edfmerge.addevent,'yes')
           hadd.annotation.starttime = hadd.annotation.starttime+h.records;
       end
       
       h.length               =   h.length + hadd.length;
       h.records              =   h.records + hadd.records;
       h.annotation.event     =   horzcat(h.annotation.event,hadd.annotation.event);
       h.annotation.duration  =   vertcat(h.annotation.duration,hadd.annotation.duration);
       h.annotation.data      =   horzcat(h.annotation.data,hadd.annotation.data);
       h.annotation.starttime =   vertcat(h.annotation.starttime,hadd.annotation.starttime);
       fprintf('%s\n','done.')
       
    end
    
    % --- Check Fs consistency, adjust if necessary --- %
    
    uFs =   unique(h.samplerate);
    
    if uFs > 2
       fprintf('%s\n','- Cannot handle multiple samplerates, resampling data with lowest Fs...')
       refFs =   max(h.samplerate);
       iFs   =   find(h.samplerate~=refFs);
       for c = 1:length(iFs)
           CurDat                       =   resample(d{iFs(c)},refFs,h.samplerate(iFs(c)));
           d{iFs(c)}                    =   CurDat;
           fprintf('%s\n',['-- Resampled channel ' num2str(iFs(c)) ' with Fs=' num2str(h.samplerate(iFs(c))) ' Hz to ' num2str(refFs) ' Hz' ]);
           h.samplerate(iFs(c))    =   refFs;
       end   
    end
    
    % === Save === %
    keyboard
    savename    =  fullfile(fileparts(CurFile.file),[basefile '_merged' ext]);
    SaveEDF_shapkin(savename,d,h);
    
    fprintf('%s\n',['Saved merged file as "' basefile '_merged' ext '"'])
    
end





