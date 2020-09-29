function pf_emg_raw2regr_prepemg_seltrem(conf,cfg,Files)
% pf_emg_raw2regr_prepemg_seltrem is part of the prepemg chapter of
% pf_emg_raw2regr function. Specifically, it will prepare your EMG by
% calculating a TFR, plotting a powerspectrum after which you can then
% select the frequency/channel which you think will best describe the
% tremor.
% 
% Part of pf_emg_raw2regr

% � Michiel Dirkx, 2015
% $ParkFunC, version 20150703

%% Initialize
%--------------------------------------------------------------------------

nFiles    =   length(Files);
nPre      =   size(cfg.chandef,1);
nCombi    =   size(conf.prepemg.combichan.chan,1);
nCmb      =   size(conf.prepemg.cohchan.channelcmb,1);
cnt       =   1;
nPlot     =   conf.prepemg.subplot.idx(1)*conf.prepemg.subplot.idx(2);

%--------------------------------------------------------------------------

%% Seltrem
%--------------------------------------------------------------------------

for a = 1:nFiles
    
    CurFile =   Files{a};
    CurSub  =   CurFile.sub;
    CurSess =   CurFile.sess;
    CurRun  =   CurFile.run;
    CurCode =   CurFile.code;
    
    fprintf('%s\n',['Working on Subject | ' CurSub ' | session ' CurSess ' | run | ' CurRun])
    
    if ~strcmp(conf.prepemg.onlyintersel,'yes')
    
    % --- Read Events --- %
    
    event   =   ft_read_event(CurFile.mrk);
    
    vole    =   event(strcmp({event.value},conf.prepemg.sval)|strcmp({event.type},'S'));
    TRm_sam =   vole(2).sample-vole(1).sample;      % TR based of of markers
    
    volend  =   event(strcmp({event.value},'ENDLASTSCAN'));         % ENDMARKER (manually put there by me in pf_emg_farm removeoutsidemeasures)
    
    % --- Preprocess using FT --- %
    
    clear CurDat_pre
    
    firstappend =   1;
    
    for b = 1:nPre
        
        cfg_pre          = cfg.cfg_pre{b};
        cfg_pre.datafile = CurFile.dat;
        
        % --- Check Append --- %
        
        if b~=nPre && any(pf_numcmp(cfg.chandef{b+1},cfg.chandef{b}))
           append  = 0; 
        else
            append = 1;
        end
        
        % --- Check if channels are already preprocessed, then preprocess --- %
        
        if b > 1 && any(pf_numcmp(cfg.chandef{b-1},cfg.chandef{b}))
            sel     = pf_strcmp(d.label,conf.prepemg.chan(cfg.chandef{b}));
            d.label = d.label(sel);
            d.trial = cellfun(@(x) x(sel,:),d.trial,'uniformoutput',0);
            cfg_pre = rmfield(cfg_pre,'datafile');         
            d       = ft_preprocessing(cfg_pre,d);
        else
            cfg_pre.channel  = cfg.chandef{b};
            d                = ft_preprocessing(cfg_pre);
            d.label          = conf.prepemg.chan(cfg.chandef{b});
        end
        
        % --- Append datasets --- %
        
        if firstappend && append
            CurDat_pre      = d;
            firstappend   = 0;
        elseif ~firstappend && append
            CurDat_pre        =   ft_appenddata([],CurDat_pre,d);
            if ~isfield(CurDat_pre,'fsample')
                CurDat_pre.fsample = d.fsample;
            end
        end
    end
    
    % --- Combine channels if desired --- %    
    
    if strcmp(conf.prepemg.combichan.on,'yes')
        
        fprintf('\n%s','% --- COMBINING CHANNELS --- %')
        
        for b = 1:nCombi
            
            % --- Select channels --- %
            
            CurCombi    =   conf.prepemg.combichan.chan{b,1};                   % Select channels
            sel         =   pf_strcmp(CurDat_pre.label,CurCombi);
            
            CurDat      =   CurDat_pre.trial{1}(sel,:);
            CurName     =   conf.prepemg.combichan.chan{b,2};
            
            % --- Choose method -- %
            
            if strcmp(conf.prepemg.combichan.meth,'vector')
                
                combi = sqrt( CurDat(1,:).^2 + CurDat(2,:).^2 + CurDat(3,:).^2 );   % Make a vector (ray)
                CurDat_pre.label    = [CurDat_pre.label; CurName];            % Load into new structure
                CurDat_pre.trial{1} = [CurDat_pre.trial{1}; combi];
                
            elseif strcmp(conf.prepemg.combichan.meth,'pca') % uses the first principle component
                                
                [~,pscore,~,~,pexp] = pca(CurDat');           % calculate principle component analysis, rows are observations, columns variables
                fprintf('\n%s\n',['First principle component explains ' num2str(pexp(1)) '% of variance'])
                
                CurDat_pre.label    = [CurDat_pre.label; CurName];            % Load into new structure
                CurDat_pre.trial{1} = [CurDat_pre.trial{1}; pscore(:,1)'];
            end
            
            % --- Add additional info correlations --- %
                
            disp('New variable correlations:')
            corr1       =   corr(CurDat(1,:)',CurDat_pre.trial{1}(end,:)');
            disp(['- ' CurCombi{1} ' VS ' CurName ': ' num2str(corr1)])
            corr2       =   corr(CurDat(2,:)',CurDat_pre.trial{1}(end,:)');
            disp(['- ' CurCombi{2} ' VS ' CurName ': ' num2str(corr2)])
            corr3       =   corr(CurDat(3,:)',CurDat_pre.trial{1}(end,:)');
            disp(['- ' CurCombi{3} ' VS ' CurName ': ' num2str(corr3)])
        end
    end
    
    % --- Check Parameters --- %
    
    TRm_sec =   TRm_sam/CurDat_pre.fsample;
    
    if strcmp(conf.prepemg.tr,'detect')
        fprintf('%s\n','- Detecting the TR for every scan (using mean TR for last scan)')
        tr  =   nan(length(vole),1);
        for b = 1:length(vole)-1
            tr(b)   =   round( ( ( vole(b+1).sample - vole(b).sample ) / CurDat_pre.fsample ) *5000 )/5000 ;
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
        cfg_freq.toi  = CurDat_freq.time{1}(1):stp:last;     % 
    elseif strcmp(cfg_freq.toi,'timedat')               % Define a timedat
        cfg_freq.toi  = conf.prepemg.timedat:conf.prepemg.timedat:CurDat_pre.time{1}(end);
        stp     =   conf.prepemg.timedat;
    else                                                % Use specified shizzle
        stp     =   conf.fa.toi(2)-conf.fa.toi(1);
    end
    
    CurDat_freq =   ft_freqanalysis(cfg_freq,CurDat_pre);
    
    % --- Coherence Analysis --- %
    
    if strcmp(conf.prepemg.cohchan.on,'yes')
        
        % --- Select Channels --- %
        %NB: debug, wil not work when nCmb>1
        
        for b = 1:nCmb
           ncmb         =   length(conf.prepemg.cohchan.channelcmb{b,1})+length(conf.prepemg.cohchan.channelcmb{b,2});
           cmb{cnt}     =   vertcat(conf.prepemg.cohchan.channelcmb{b,1},conf.prepemg.cohchan.channelcmb{b,2});
        end
        
        sel              = pf_strcmp(CurDat_pre.label,cmb{1});
        PreCoh           = CurDat_pre;
        PreCoh.label     = CurDat_pre.label(sel);
        PreCoh.trial{1}  = CurDat_pre.trial{1}(sel,:);
        
        % --- Downsample --- %
        
        cfg_resamp.resamplefs   = 500;  
        PreCoh                  = ft_resampledata(cfg_resamp,PreCoh);
        
        % --- Divide into data segments --- %
        
        cfg_redef.length   =   60;      % !!Length of segments it will be divided into (in seconds)!!
        cfg_redef.overlap  =   0;
        
        PreCoh = ft_redefinetrial(cfg_redef,PreCoh);
        
        % --- Perform raw frequency analysis --- %
        
        cfg_coh            = cfg.cfg_coh;
        FreqCoh            = ft_freqanalysis(cfg_coh,PreCoh);
        
        % --- Perform Coherence analysis --- %
        
        for b = 1:nCmb
            actcoh      =   conf.prepemg.cohchan.channelcmb{b,1}(pf_strcmp(conf.prepemg.cohchan.channelcmb{b,1},FreqCoh.label));
            actcoh(:,2) = repmat(conf.prepemg.cohchan.channelcmb{b,2},length(actcoh),1);
            
            if b==1
                lbls = actcoh;
            else
                lbls = vertcat(lbls,actcoh);
            end
        end
        
        cfg_fc            = [];
        cfg_fc.method     = 'coh';
        cfg_fc.channelcmb = lbls;
        
        CohSpctrm          = ft_connectivityanalysis(cfg_fc,FreqCoh);
    end
    
    % --- Add scannumbers to regressor --- %
    
    fprintf('\n%s\n','- Placing scan markers for every sample')
    scanid  =   nan(length(CurDat_freq.time),1);
    cnt     =   1;
    time0   =   0; % start of time
    dat2scan    =   CurDat_freq.time(end) / mtr;
    
    % Deal with extra amount of time included by me for hanning taper%
    beginpostscan         =   CurDat_pre.time{1}(volend.sample+1);    % This is the first time point after the end of the last scanmarker in its ORIGINAL RESOLUTION (so start of postscan era in seconds)
    postscanidx           =   find(CurDat_freq.time>=beginpostscan);  % Here is an array of all the time points which match or are bigger than this post scan era (in the NEW CURDAT_FREQ RESOLUTION);
    postscanidx_first     =   postscanidx(1);                         % Ah so this is the index of the start of the postscan era. (IN THE NEW CURDAT_FREQ RESOLUTION)
    postscantime          =   CurDat_freq.time(postscanidx);          % And this would be the time point in the CurDat_freq array which indicates the start of the post-scan era (IN THE NEW CURDAT_FREQ RESOLUTION)
    postscanidx_last      =   postscanidx(end);                       % And this is the index of the end of the postscan era. (IN THE NEW CURDAT_FREQ RESOLUTION)
    
    % --- Fill in scanid --- %
     
    for b = 1:postscanidx_first-1                                           % So for 1 until the beginning of the postscan era -1 (so the last datapoint of the scan era).
        if ( round((CurDat_freq.time(b) - time0)*10000)/10000 )  > tr(cnt)
            cnt   = cnt+1;
            time0 = CurDat_freq.time(b-1);
        end
        if cnt>length(tr)
            warning('seltrem:trs',['Too much freqdata (' num2str((postscanidx_first-1)*stp/mtr) ' scans) compared to amount of TRs (' num2str(length(tr)) '). Ignoring extra data...'])
            break
        end
        scanid(b) = cnt;
    end
    
    cnt = 1; for q = 1:max(scanid); scans(q) = length(find(scanid==cnt)); cnt=cnt+1; end
    ulen           =   unique(scans);
    sel            =   ~isnan(scanid);
    scanid_nonnan  =   scanid(sel);
    
    fprintf('%s\n',['-- Placed ' num2str(scanid_nonnan(end)) ' scanmarkers. Unique scan lengths are: ' num2str(ulen) ' samples (' num2str(stp) 's)'])
    
    % --- Fill in extratime (for hanning taper) --- %
    
    scanid(postscanidx_first:postscanidx_last)   =   999;
    fprintf('%s\n',['-- Detected and denoted extra ' num2str(length(postscanidx_first:postscanidx_last)*stp) ' seconds as "extra-time for hanning taper" (code 999)'])    
    
    % --- Before ENDLASTSCANMARKER --- %
%     for b = 1:length(CurDat_freq.time)
%         if ( round((CurDat_freq.time(b) - time0)*10000)/10000 )  > tr(cnt)
%             cnt   = cnt+1;
%             time0 = CurDat_freq.time(b-1);
%         end
%         if cnt>length(tr)
%             warning('seltrem:trs',['Too much freqdata (' num2str(CurDat_freq.time(end)/mtr) ' scans) compared to amount of TRs (' num2str(length(tr)) '). Ignoring extra data...'])
%             break
%         end
%         scanid(b) = cnt;
%     end
    
      % --- OLD TR PLACEMENT --- %
%     for b = 1:length(CurDat_pre.time{1})
%         if ( cnt - (CurDat_pre.time{1}(b)/tr(cnt)) ) <= -0.000001
%             cnt = cnt+1;
%         end  
%         scanid(b) = cnt;
%     end
    
    % --- Determine start/stop of timecourse --- %
    
%     StartScan   =   ( sum(tr(1:conf.prepemg.dumscan))/stp ) + stp;            % Start of Scan in new TFR resolution
    StartScanSel =   find(scanid==conf.prepemg.dumscan+1);                      % Index of start of future regressor
    StartScan    =   StartScanSel(1);
    
%     preSS        =   ( StartScan-(conf.prepemg.prestart*TRm_sec/stp) ) + stp;  % Prestart (e.g. to correct for BOLD response) in new TFR resolution    
    preSSSel       =   find(scanid==conf.prepemg.dumscan+1-conf.prepemg.prestart); % Index of Prestart (which will be analyzed but disregarded at the very end of the mkregressor)
    preSS          =   preSSSel(1);
    
    if strcmp(conf.prepemg.onlyfa,'yes')
        if ~exist(conf.dir.onlyfa,'dir'); mkdir(conf.dir.onlyfa); end
        sname   =   fullfile(conf.dir.onlyfa,[CurSub '-' CurSess '-' CurRun '_onlyfa']);
        save(sname,'CurDat_freq','CurDat_pre','StartScan','preSS','tr','mtr','scanid');
        continue
    end
    
    else
        load(fullfile(conf.dir.onlyfa,[CurSub '-' CurSess '-' CurRun '_onlyfa']))
    end
        
    % --- Creat Powerspectrum and plot these --- %
    
    fprintf('%s\n','Plotting...')
    sel     =   cell(nPlot,1);
    psall   =   nanmean(CurDat_freq.powspctrm(:,:,round(preSS):end),3);
    
    figure
    for b = 1:nPlot
        
        CurPlot = conf.prepemg.subplot.chan{b};
        
        hh(b) = subplot(conf.prepemg.subplot.idx(1),conf.prepemg.subplot.idx(2),b);
        if ~ischar(CurPlot)
            
            % --- Selecting current channels --- %
            
            CurFreq           = CurDat_freq;
            sel{b}            = pf_strcmp(CurFreq.label,CurPlot); 
            CurFreq.label     = CurFreq.label(sel{b});
            CurFreq.powspctrm = CurFreq.powspctrm(sel{b},:,:);
            ps                = psall(sel{b},:);
            
            % --- Plotting these channels --- %
            
            nChan       =   size(CurFreq.powspctrm,1);
            col         =   distinguishable_colors(nChan);
            h           =   nan(nChan,1);
            
            for c = 1:nChan
                h(c)    =   plot(CurFreq.freq,ps(c,:),'color',col(c,:));
                hold on
            end
            set(gca,'Xtick',round(CurFreq.freq(1:2:end)*100)/100,'Xticklabel',round(CurFreq.freq(1:2:end)*100)/100);
            xlabel('Frequency (Hz)');
            ylabel('Nanmean Power (uV^2)');
            title(['Powerspectrum ' CurSub '-' CurSess '-' CurRun]);
            legend(h,CurFreq.label,'interpreter','none')
            legend('boxoff')
            
            % --- Store Data --- %
            
            if b==1
                data    =   CurFreq;
            else
                data.label      =   vertcat(data.label,CurFreq.label);
                data.powspctrm  =   vertcat(data.powspctrm,CurFreq.powspctrm);
            end
            
        elseif strcmp(CurPlot,'coh')
            
            imagesc(CohSpctrm.cohspctrm);
            sel{b}  =   [];
            
            % --- Create recognizable xlabel --- %
            
            uFreq = unique(round(CohSpctrm.freq));
            for d = 1:length(uFreq)
                iFreq      = find(round(CohSpctrm.freq)==uFreq(d));
                xtik(d)    = iFreq(1);
                xtiklab(d) = uFreq(d);
            end
            set(gca,'Xtick',xtik,'Xticklabel',xtiklab)
            
            % --- Create recognizable ylabel --- %
            
            for d = 1:length(CohSpctrm.labelcmb)
                ytik(d)      = d;
                ytiklab{d,1} = CohSpctrm.labelcmb{d,1};
            end
            set(gca,'Ytick',ytik,'Yticklabel',ytiklab);
            
            % --- Rest of graphics --- %
            
            xlabel('Frequency (Hz)','fontweight','b')
            title(['Coherence analysis (' CohSpctrm.labelcmb{1,2} ')'])
            colorbar
            
        end
    end
    
    %========Store and Save Everything=========%
    % Store coherence spectrum if performed
    if strcmp(conf.prepemg.cohchan.on,'yes')    
        data.coh    =   CohSpctrm;
    end
    % General
    data.startscan_sec  =   StartScan;
    data.startscan_sca  =   conf.prepemg.dumscan+1;
    data.prestart_sec   =   preSS;
    data.prestart_sca   =   data.startscan_sca-conf.prepemg.prestart;
    data.tr             =   tr;
    data.mtr            =   mtr;
    data.scanid         =   scanid;
    data.fs             =   CurDat_pre.fsample;
    data.meth           =   'seltremor';
    data.createdate     =   date;
    data.sub            =   CurSub;
    data.sess           =   CurSess;
    data.run            =   CurRun;
    
    if strcmp(conf.prepemg.freqana.avg,'yes')  % save only average powerspectra
        data.powspctrm = nanmean(data.powspctrm(:,:,round(data.prestart_sec):end),3);
    end
    
    savename        =   fullfile(conf.dir.prepemg,[CurSub '_' CurSess '_' CurRun '_freqana_seltremor']);
    save(savename,'data')
    %==========================================%
    
    fprintf('%s\n',['- Saved data to ' savename])
    
%     print(gcf,'-dtiff','-r200',fullfile(conf.dir.prepemg,[CurSub '_' CurSess '_' CurRun '_powerspectrum']))
%     export_fig(fullfile(conf.dir.prepemg,[CurSub '_' CurSess '_' CurRun '_powerspectrum']),'-jpg')
    saveas(gcf,fullfile(conf.dir.prepemg,[CurSub '_' CurSess '_' CurRun '_powerspectrum.jpg']),'jpg');
    fprintf('%s\n\n',['Saved figure to ' fullfile(conf.dir.prepemg,[CurSub '_' CurSess '_' CurRun '_powerspectrum'])])
    
end

% -------------------------------------------------------------------------

%% Junk
% -------------------------------------------------------------------------
%
%     
%             %SingleStorage (only one channel/frequency)
% %             data                =   CurFreq;
% %             data.label          =   data.label(CurChanI);
% %             data.freq           =   data.freq(FreqI);
% %             data.powspctrm      =   squeeze(data.powspctrm(CurChanI,FreqI,:));
%             %All storage
% %             data                =   CurDat_freq;
%             
%     
%     % --- Interactively select tremor --- %
%     
%     fprintf('%s\n',['% - Interselection for subplots ' num2str(conf.prepemg.subplot.interselidx) ' -%'])
%     fprintf('\nClick on the datapoint that you want to include in the figure.\nEnter "return" when you are done.\n')
%     brush on
%     brush green
%     keyboard
%     brush off
%     
%     % --- For all intersel subplots --- %
%     
%     for b = 1:nIntersel
%         
%         clear ps
%         subplot(hh(conf.prepemg.subplot.interselidx(b)))
%         chanidx           = sel{conf.prepemg.subplot.interselidx(b)};
%         ps                = psall(chanidx,:);
%         
%         bh      =   findobj(hh(conf.prepemg.subplot.interselidx(b)),'-property','BrushData');
%         bval    =   get(bh,'BrushData');
%         bval    =   flipud(bval); % Because everything is loaded in inverse order
%         
%         if ~iscell(bval)
%             bval = {bval};
%         end
%         
%         ChanI   =   find(cellfun(@(x) any(x),bval));  % Logical index of selected channel
%         nChanI  =   length(ChanI);
%         
%         % --- For all channels that have been selected --- %
%         
%         for c = 1:nChanI
%             
%             clear CurFreq data
%             
%             CurFreq           = CurDat_freq;
%             CurFreq.label     = CurFreq.label(chanidx);
%             CurFreq.powspctrm = CurFreq.powspctrm(chanidx,:,:);
%             
%             CurChanI =   ChanI(c);
%             FreqI    =   logical(bval{CurChanI});       % Logical index of selected frequency  
%             
%             fprintf('%s\n',['- You selected channel "' CurFreq.label{CurChanI} '" with frequency "' num2str(CurFreq.freq(FreqI)) '" Hz'])
%             text(CurFreq.freq(FreqI),ps(CurChanI,FreqI), strcat('\leftarrow',num2str(CurFreq.freq(FreqI)),' Hz'),'FontSize',10)
%             
%             FreqStr  =   num2str(CurFreq.freq(FreqI));
%             FreqStr  =   [FreqStr(1) '-' FreqStr(3:end)];
%             if length(find(FreqI))>2
%                 FreqStr = 'MULTI';
%             end
%             keyboard
%             
%             
%             
%         end
%     end





