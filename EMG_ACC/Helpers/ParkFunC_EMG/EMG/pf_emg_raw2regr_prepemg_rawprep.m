function pf_emg_raw2regr_prepemg_rawprep(conf,cfg,Files)
%
% create TFR and select tremor
%

% © Michiel Dirkx, 2015
% $ParkFunC

%% Initialize
%--------------------------------------------------------------------------

nFiles  =   length(Files);

%--------------------------------------------------------------------------

%% Prep preprocessed EMG data
%--------------------------------------------------------------------------

for a = 1:nFiles
    
    CurFile =   Files{a};
    CurSub  =   CurFile.sub;
    CurSess =   CurFile.sess;
    CurRun  =   CurFile.run;
    
    fprintf('\n%s\n',['Working on | ' CurSub '-' CurSess ' |'])
    
    % --- Read Events --- %
    
    event   =   ft_read_event(CurFile.mrk);
    
    vole    =   event(strcmp({event.value},conf.prepemg.sval));
    TRm_sam =   vole(2).sample-vole(1).sample;      % TR based of of markers
    
    % --- Preprocess using FT --- %
    
    cfg_pre         =   cfg.cfg_pre;
    cfg_pre.dataset =   CurFile.dat;
    
    CurDat_pre  =   ft_preprocessing(cfg_pre);
    
    % --- Check Parameters --- %
    
    TRm_sec =   TRm_sam/CurDat_pre.fsample;
    
    if strcmp(conf.prepemg.tr,'detect')
        fprintf('%s\n','- Detecting the TR for every scan (using mean TR for last scan)')
        tr  =   nan(length(vole),1);
        for b = 1:length(vole)-1
            tr(b)   =   ( vole(b+1).sample - vole(b).sample ) / CurDat_pre.fsample;
        end
        mtr   =   nanmean(tr);
        stdtr =   nanstd(tr);
        fprintf('%s\n',['- Mean tr: ' num2str(mtr) ' sec (std = ' num2str(stdtr) 'sec)'])
        tr(end) = mtr;
    else
        if TRm_sec~=conf.prepemg.tr; warning('prepemg:tr',['Specified TR (' num2str(conf.prepemg.tr) ') does not match marker TR (' num2str(TRm_sec) '). Continueing with specified one...']); end
        for b = 1:length(vole)
            tr(b)   =   conf.prepemg.tr;
        end
        mtr   =   conf.prepemg.tr;
        stdtr =   0;
    end
    
    % --- Cut if necessary --- %
    
    if strcmp(conf.prepemg.precut,'yes')
        CurDat_pre.trial        =   {CurDat_pre.trial{1}(:,vole(1).sample:round(vole(end).sample+tr(end)*CurDat_pre.fsample))};
        timebar                 =   0:(1/CurDat_pre.fsample):(length(CurDat_pre.trial{1})/CurDat_pre.fsample);
        CurDat_pre.time         =   {timebar(1:end-1)};
        CurDat_pre.sampleinfo   =   [1 length(CurDat_pre.trial{1})];
    end
    
    % --- Add scannumbers to regressor --- %
    
    fprintf('\n%s\n','- Placing scan markers for every sample')
    scanid  =   nan(length(CurDat_pre.time{1}),1);
    cnt     =   1;
    time0   =   CurDat_pre.time{1}(1);
    stp     =   CurDat_pre.time{1}(2)-CurDat_pre.time{1}(1);
    
    for b = 1:length(CurDat_pre.time{1})
        if ( CurDat_pre.time{1}(b) - time0 ) >= tr(cnt)
            cnt   = cnt+1;
            time0 = CurDat_pre.time{1}(b);
        end
        scanid(b) = cnt;
    end
    
%     for b = 1:length(CurDat_pre.time{1})
%         if ( cnt - (CurDat_pre.time{1}(b)/tr(cnt)) ) <= -0.000001
%             cnt = cnt+1;
%         end  
%         scanid(b) = cnt;
%     end
    
    cnt = 1; for q = 1:max(scanid); scans(q) = length(find(scanid==cnt)); cnt=cnt+1; end
    ulen    =   unique(scans);
    
    fprintf('%s\n',['-- Placed ' num2str(scanid(end)) ' scanmarkers. Unique scan lengths are: ' num2str(ulen) ' samples (' num2str(stp) 's)'])
    
    % --- Determine start/stop of timecourse --- %
    
    StartScan   =   ( sum(tr(1:conf.prepemg.dumscan))/stp ) + stp;   % Start of Scan in new TFR resolution
    preSS       =   ( StartScan-(conf.prepemg.prestart*TRm_sec/stp) ) + stp;  % Prestart (e.g. to correct for BOLD response) in new TFR resolution    
    
    % --- Final conversion --- %
    
    CurDat_pre.time  =   CurDat_pre.time{1};
    CurDat_pre.trial =   CurDat_pre.trial{1};
    
    %========Store and Save Everything=========%
    data                =   CurDat_pre;
    data.chanI          =   conf.prepemg.rawprep.chan;
    data.startscan_sec  =   StartScan;
    data.startscan_sca  =   conf.prepemg.dumscan+1;
    data.prestart_sec   =   preSS;
    data.prestart_sca   =   data.startscan_sca-conf.prepemg.prestart;
    data.tr             =   tr;
    data.mtr            =   mtr;
    data.scanid         =   scanid;
    data.fs             =   CurDat_pre.fsample;
    
    savename        =   fullfile(conf.dir.prepemg,[CurSub '_' CurSess '_rawprep']);
    save(savename,'data')
    %==========================================%
    
    fprintf('%s\n\n',['Saved data to ' savename])
end




