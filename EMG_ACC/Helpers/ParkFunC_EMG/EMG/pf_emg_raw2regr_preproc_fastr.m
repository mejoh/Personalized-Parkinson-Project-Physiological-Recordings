function pf_emg_raw2regr_preproc_fastr(conf,files)
%
% pf_emg_raw2regr_prepoc_fastr uses FASTR to remove MR artifacts from your
% raw EMG data
%
% part of pf_emg_raw2regr.m

% Michiel Dirkx, 2015
% $ParkFunC, version 20150123

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nFiles  =   length(files);

if isempty(findobj('Tag','EEGLAB'))
    eeglab
end

%--------------------------------------------------------------------------

%% Use FASTR
%--------------------------------------------------------------------------

for a = 1:nFiles
    
    CurFile =   files{a};
    
    CurSub  =   CurFile.sub;
    CurSess =   CurFile.sess;
    CurRun  =   CurFile.run;
    
    fprintf('\n%s\n',['Working on | ' CurSub ' | ' CurSess ' | ' CurRun ' | '])
    
    % --- Load BVA file --- %
    
    [rawpath,rawfile,rawext] = fileparts(CurFile.hdrfile);
    fprintf('%s\n',['- Loading file ' rawfile])
    [EEG,~] = pop_loadbv(rawpath,[rawfile rawext],[],conf.preproc.chan);
    
    % --- If prefilt --- %
     
    if strcmp(conf.preproc.filt.meth,'pre')
        fprintf('%s\n',['- Prefiltering with bandpass ' num2str(conf.preproc.filt.low) '-' num2str(conf.preproc.filt.high) ' Hz'])
        EEG =   pop_eegfiltnew(EEG,conf.preproc.filt.low,conf.preproc.filt.high);
    end
    
    % --- Employ FASTR --- %
    
    [EEG,~]     =   pop_fmrib_fastr(EEG,conf.preproc.fastr.lpf,conf.preproc.fastr.interp,conf.preproc.fastr.avgwin,...
        conf.preproc.fastr.etype,conf.preproc.fastr.strig,conf.preproc.fastr.anc,conf.preproc.fastr.trigcorr,...
        conf.preproc.fastr.vol,conf.preproc.fastr.slice,conf.preproc.fastr.prefrac,conf.preproc.fastr.exchan,...
        conf.preproc.fastr.npc);
    
    % --- If postfilt --- %
    
    if strcmp(conf.preproc.filt.meth,'post')
        fprintf('%s\n',['- Postfiltering with bandpass ' num2str(conf.preproc.filt.low) '-' num2str(conf.preproc.filt.high) ' Hz'])
        EEG =   pop_eegfiltnew(EEG,conf.preproc.filt.low,conf,preproc.filt.high);
    end
    
    % --- Export --- %
    
    if strcmp(conf.preproc.filt.meth,'pre') || strcmp(conf.preproc.filt.meth,'post')
        fname   =   fullfile(conf.dir.preproc,[CurSub '_' CurSess '_FASTR_' conf.preproc.filt.meth 'filt_' num2str(conf.preproc.filt.low) '-' num2str(conf.preproc.filt.high)]);
    else
        fname   =   fullfile(conf.dir.preproc,[CurSub '_' CurSess '_FASTR']);
    end
    
    pop_writebva(EEG,fname);
    fprintf('%s\n',['Saved to ' fname]);
    
end






