function pf_emg_raw2regr_prepemg_bb(conf,cfg,Files)
%
% create TFR and averages this
%

% © Michiel Dirkx, 2015
% $ParkFunC

%% Initialize
%--------------------------------------------------------------------------

nFiles  =   length(Files);

%--------------------------------------------------------------------------

%% Seltrem
%--------------------------------------------------------------------------

for a = 1:nFiles
    
    CurFile =   Files{a};
    CurSub  =   CurFile.sub;
    CurSess =   CurFile.sess;
    CurRun  =   CurFile.run;
    
    fprintf('%s\n',['Working on | ' CurSub '-' CurSess ' | ' CurRun ' | '])
    
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
        CurDat_pre.trial        =   {CurDat_pre.trial{1}(:,vole(1).sample:vole(end).sample+tr(end)*CurDat_pre.fsample)};
        timebar                 =   0:(1/CurDat_pre.fsample):(length(CurDat_pre.trial{1})/CurDat_pre.fsample);
        CurDat_pre.time         =   {timebar(1:end-1)};
        CurDat_pre.sampleinfo   =   [1 length(CurDat_pre.trial{1})];
    end
    
    % --- Frequency Analysis using FT --- %
    
    cfg_freq    =   cfg.cfg_freq;
    
    if strcmp(cfg_freq.toi,'orig')
        last    =   CurDat_freq.time{1}(end);                  % Keep original resolution (only use this with low Fs)
        stp     =   CurDat_freq.time{1}(2)-CurDat_freq.time{1}(1);
        cfg_freq.toi  = CurDat_freq.time{1}(1):stp:last;
    elseif strcmp(cfg_freq.toi,'timedat')               % Define a timedat
        cfg_freq.toi  = conf.prepemg.timedat:conf.prepemg.timedat:CurDat_pre.time{1}(end);
        stp     =   conf.prepemg.timedat;
    else                                                % Use specified shizzle
        stp     =   conf.fa.toi(2)-conf.fa.toi(1);
    end
    
    CurDat_freq =   ft_freqanalysis(cfg_freq,CurDat_pre);
    
    % --- Average this braodband signal --- %
    
    CurDat_freq     = ft_selectdata(cfg.cfg_freqbb,CurDat_freq);
    
    % --- Add scannumbers to regressor --- %
    
    fprintf('\n%s\n','- Placing scan markers for every sample')
    scanid  =   nan(length(CurDat_freq.time),1);
    cnt     =   1;
    time0   =   CurDat_freq.time(1);
    
    for b = 1:length(CurDat_freq.time)
        if ( CurDat_freq.time(b) - time0 ) >= tr(cnt)
            cnt   = cnt+1;
            time0 = CurDat_freq.time(b);
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
    ulen     =   unique(scans);
    
    fprintf('%s\n',['-- Placed ' num2str(scanid(end)) ' scanmarkers. Unique scan lengths are: ' num2str(ulen) ' samples (' num2str(stp) 's)'])
    
    % --- Determine start/stop of timecourse --- %
    
    StartScan   =   ( (conf.prepemg.tr)*(conf.prepemg.dumscan)/stp ) + stp;   % Start of Scan in new TFR resolution
    preSS       =   ( StartScan-(conf.prepemg.prestart*TRm_sec/stp) ) + stp;  % Prestart (e.g. to correct for BOLD response) in new TFR resolution    
    
    %========Store and Save Everything=========%
    data                =   CurDat_freq;
    data.chanI          =   conf.prepemg.rawprep.chan;
    data.startscan_sec  =   StartScan;
    data.startscan_sca  =   conf.prepemg.dumscan+1;
    data.prestart_sec   =   preSS;
    data.prestart_sca   =   data.startscan_sca-conf.prepemg.prestart;
    data.tr             =   tr;
    data.mtr            =   mtr;
    data.scanid         =   scanid;
    data.meth           =   'broadband';
    data.fs             =   CurDat_pre.fsample;
    
    savename        =   fullfile(conf.dir.prepemg,[CurSub '_' CurSess '_' CurRun '_broadband']);
    save(savename,'data')
    %==========================================%
    
    fprintf('%s\n\n',['Saved data to ' savename])
end




