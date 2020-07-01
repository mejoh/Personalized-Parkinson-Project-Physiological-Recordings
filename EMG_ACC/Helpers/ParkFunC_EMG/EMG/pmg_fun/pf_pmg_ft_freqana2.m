function freqana = pf_pmg_ft_freqana2(conf,files)
% pf_pmg_ft_freqana(conf,files) is part of the FieldTrip chapter of the
% pf_pmg_batch. Specifically it will perform a full frequency analysis of
% your PMG data using FieldTrip.
%
% Part of pf_pmg_batch.m

% �Michiel Dirkx, 2015
% $ParkFunC, 20150429

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nFiles      =   length(files);
nPre        =   length(conf.ft.fa.cfg.preproc);

%--------------------------------------------------------------------------

%% Preprocessing, select conditions and calculate power
%--------------------------------------------------------------------------

fprintf('\n Preprocessing and Power Calculation \n')

cnt  = 1;
cnt2 = 1;
cnt3 = 1;
flag = 0;

for a = 1:nFiles
    
    % --- File --- %
    clear path file hdr
    
    try
    
    CurFile     =   files{a};
    CurDat      =   CurFile.file;
    CurSub      =   CurFile.sub;
    CurHand     =   CurFile.hand;
    CurSess     =   CurFile.sess;
    [path,file] =   fileparts(CurDat);

    [~,hdr]     =   ReadEDF_shapkin(CurDat);
    Fs          =   unique(hdr.samplerate);
    
    fprintf('\n%s\n',['% - Working on subject "' CurSub '-' CurSess '" -%'])
    
    % --- Preprocessing --- %
    
    clear data_pre
    fprintf('\n2.1) Preprocessing \n')
    firstappend =   1;
    
    for b = 1:nPre
        
        cfg_pre          = conf.ft.fa.cfg.preproc{b};
        cfg_pre.datafile = CurDat;
        
        % --- Check Append --- %
        
        if b~=nPre && any(pf_numcmp(conf.fa.chandef{b+1},conf.fa.chandef{b}))
           append  = 0; 
        else
            append = 1;
        end
        
        % --- Check if channels are already preprocessed, then preprocess --- %
        
        if b > 1 && any(pf_numcmp(conf.fa.chandef{b-1},conf.fa.chandef{b}))
            sel     = pf_strcmp(d.label,conf.ft.chans(conf.fa.chandef{b}));
            d.label = d.label(sel);
            d.trial = cellfun(@(x) x(sel,:),d.trial,'uniformoutput',0);
            cfg_pre = rmfield(cfg_pre,'datafile');         
            d       = ft_preprocessing(cfg_pre,d);
        else
            cfg_pre.channel = conf.ft.chans(conf.fa.chandef{b});
            d               = ft_preprocessing(cfg_pre);
        end
        
        % --- Append datasets --- %
        
        if firstappend && append
            data_pre        = d;
            firstappend     = 0;
        elseif ~firstappend && append
            data_pre        =   ft_appenddata([],data_pre,d);
        end
        
    end
    
    % --- workaround fsample (doesnt save with append) --- %
    
    if ~isfield(data_pre,'fsample')
        data_pre.fsample = d.fsample;
    end
    
    
    % --- Retrieve desired conditions and cut data in nConditions --- %
    
    fprintf('\n2.2) Selecting conditions \n')
    clear data_pre_cut
    keyboard
    cond           = pf_pmg_selcond(conf,hdr.annotation,Fs);
    nCond          = length(cond.event);
    
    for b = 1:nCond
        
        % --- Retrieve condition info --- %
        
        CurCond  =  cond.event{b};
        CurStart =  cond.starttime(b);
        CurEnd   =  CurStart+cond.duration(b);
        
        % --- Select condition data --- %
        
        CurDat                =   data_pre;
        if isfield(conf.ft.fa,'prepostwin') && ~isempty(conf.ft.fa.prepostwin)
        CurDat.cfg.pf_prepost =  conf.ft.fa.prepostwin;
        CurStart              =  CurStart - (conf.ft.fa.prepostwin(1)*CurDat.fsample);
        if CurStart ==0; CurStart = 1; end
        CurEnd                =  CurEnd + (conf.ft.fa.prepostwin(2)*CurDat.fsample);
        end
        CurDat.time           =   {CurDat.time{1}(floor(CurStart):ceil(CurEnd))};   % You may want to tweak this, although it will differ from your exact marker with 1 sample at the most.
        CurDat.trial          =   {CurDat.trial{1}(:,floor(CurStart):ceil(CurEnd))};
        CurDat.sampleinfo     =   [1 length(CurDat.time{1})];
        
        % --- Load into new data structure, cut if desired --- %
        
        if strcmp(conf.ft.fa.cfg.trialdef.on,'yes') 
           lenTr = CurDat.time{1}(end)-CurDat.time{1}(1);
           nTr   = round(lenTr/conf.ft.fa.cfg.trialdef.trl);
           trl   = nan(nTr,3);
           onset = 1;
           plus  = conf.ft.fa.cfg.trialdef.trl*CurDat.fsample;
           for c = 1:nTr
               trl(c,:)   =   [onset onset+plus-1 0];
               onset      =   onset+plus;
           end
           cfg_redefine.trl = trl;
           data_pre_cut.(CurCond)  =   ft_redefinetrial(cfg_redefine,CurDat);
           
           % --- Check for nans, if present disregard --- %
           
           if any(any(isnan(data_pre_cut.(CurCond).trial{end})))
               data_pre_cut.(CurCond).trial       = data_pre_cut.(CurCond).trial(1:end-1);
               data_pre_cut.(CurCond).time        = data_pre_cut.(CurCond).time(1:end-1);
               data_pre_cut.(CurCond).sampleinfo  = data_pre_cut.(CurCond).sampleinfo(1:end-1,:);
           end
        else
           data_pre_cut.(CurCond)  =   CurDat;
        end
        
        % --- Perform temporal correlation with each other if desired --- %
        
        if strcmp(conf.ft.fa.cfg.corrchans.on,'yes')
            nCorr   =   size(conf.ft.fa.cfg.corrchans.which,1);
            
            % --- For all correlations --- %
            
            for c = 1:nCorr
                
                CurCorr = conf.ft.fa.cfg.corrchans.which(c,:);
                
                % --- Retrieve channels and indices --- %
                
                CurComp = CurCorr{1};
                iComp   = find(pf_strcmp(CurDat.label,CurComp));
                nComp   = length(iComp);
                
                CurRef  = CurCorr{2};
                iRef    = pf_strcmp(CurDat.label,CurRef);
                ref     = CurDat.trial{1}(iRef,:);
                
                % --- Correlate for every channel --- %
                
                for d = 1:nComp
                   act      =   CurDat.trial{1}(iComp(d),:);
                   [cor,p]  =   corr(act',ref');
                   corstrc(cnt3,:) =   {CurDat.label(iComp(d)) CurDat.label(iRef) cor p}; 
                   cnt3 = cnt3+1;
                end
                data_pre_cut.(CurCond).tempcorr  =   corstrc; 
            end
        end
    end
    
    fn  =   fieldnames(data_pre_cut);
    nFn =   length(fn);
    
    % --- Perform frequency analysis over all conditions --- %
   
    fprintf('\n2.3) Calculating Power Spectra \n')
    clear data_freq
    cfg = conf.ft.fa.cfg.freq;
    
    for c = 1:nFn
        CurFn   =   fn{c};
        CurDat  =   data_pre_cut.(CurFn);
        
        % --- cfg.toi is based on data length, deal with it here --- %
        
        if isfield(conf.ft.fa.cfg.freq,'toi')
            if strcmp(conf.ft.fa.cfg.freq.toi,'orig')
                last    =   CurDat.time{1}(end);
                stp     =   CurDat.time{1}(2)-CurDat.time{1}(1);    
                cfg.toi = CurDat.time{1}(1):stp:last;
            else
                cfg.toi = conf.ft.fa.cfg.freq.toi;
            end
            
        end
        
        % --- If tempcorr was performed, cut it here and paste later on ---%
        
        if isfield(CurDat,'tempcorr')
            tempcorr = CurDat.tempcorr;
            CurDat   = rmfield(CurDat,'tempcorr');
            flag     = 1;
        end
        
        % --- Frequency analaysis --- %
        
        data_freq.(CurFn) = ft_freqanalysis(cfg, CurDat); % Combining   
        
        % --- Perform Coherence Analysis if desired --- %
        
        if strcmp(conf.ft.fa.cohana.on,'yes')
            nCoh    =   size(conf.ft.fa.cohana.cfg.channelcmb,1);
            
            for d = 1:nCoh
                actcoh      =   conf.ft.fa.cohana.cfg.channelcmb{d,1}(pf_strcmp(conf.ft.fa.cohana.cfg.channelcmb{d,1},data_freq.(CurFn).label));
                actcoh(:,2) = repmat(conf.ft.fa.cohana.cfg.channelcmb{d,2},length(actcoh),1);
               
                if d==1
                   lbls = actcoh;
                else
                   lbls = vertcat(lbls,actcoh);
                end
            end
            cfg_coh.method     =  conf.ft.fa.cohana.cfg.method;
            cfg_coh.channelcmb =  lbls;
            
            data_freq.(CurFn).cohana  = ft_connectivityanalysis(cfg_coh,data_freq.(CurFn));
        end
        
        % --- Paste tempcorr if desired -- %
        
        if flag
            data_freq.(CurFn).tempcorr = tempcorr;
            flag = 0;
        end
            
        % --- Avereage if desired --%
        
        if strcmp(conf.ft.fa.avgfreq,'yes')
            meanps    =   nanmean(data_freq.(CurFn).powspctrm,3);
            stdps     =   nanstd(data_freq.(CurFn).powspctrm,0,3);
            covps     =   stdps./meanps;
            data_freq.(CurFn).powspctrm  = meanps;
            data_freq.(CurFn).cfg.method = 'mtmconvol_postavg';
            data_freq.(CurFn).powspctrm_std   = stdps;
            data_freq.(CurFn).powspctrm_covps = covps;
        end
        
            % --- New dataformat 20150616 --- %
            
            freqdat{cnt,1}      = data_freq.(CurFn);
            freqdat{cnt,1}.sub  = CurSub;
            freqdat{cnt,1}.sess = CurSess;
            freqdat{cnt,1}.cond = CurFn;
            freqdat{cnt,1}.hand = CurHand;
            cnt                 = cnt+1;
    end  
    
    % --- If something went wrong --- %
    
    catch err
        errmsg{cnt2}  =   ['Skipping subject "' CurSub '-' CurSess '". Error: ' err.message];
        warning('PFpmg:powspct',errmsg{cnt2})
		cnt2          = cnt2+1;
    end
end

fprintf('\nDone.\n')


% --- Show error messages --- %

if exist('errmsg','var')
    fprintf('The following errors were saved: \n')
	fprintf('- %s\n',errmsg{:})
end

% --- Save analyzed data --- %

if strcmp(conf.ft.save,'yes')
    fprintf('\n2.4) Saving processed data...\n')
    savedir =   fullfile(conf.dir.datsave,'freqana');
    
    if ~exist(savedir,'dir'); mkdir(savedir); end
    
    if strcmp(conf.ft.saveasmat,'yes')
        mat =   pf_pmg_ft_struc2mat(data_freq);
        save(fullfile(savedir,conf.ft.savefile),'mat')
    else
%         save(fullfile(savedir,conf.ft.savefile),'data_freq')
        save(fullfile(savedir,conf.ft.savefile),'freqdat'); % Changed dataformat 20150616
    end
    
    [~,msgid] =   lastwarn;
    if any(strfind(msgid,'sizeTooBigForMATFile'))
        fprintf('Warning detected. Now trying to save the file for "-v7.3". \nGet a coffee, this may take a while...');
        if strcmp(conf.ft.saveasmat,'yes')
            save(fullfile(savedir,conf.ft.savefile),'mat','-v7.3')
        else
            save(fullfile(savedir,conf.ft.savefile),'freqdat','-v7.3')
        end
    end
    fprintf('\n%s\n',['- Analysed data was saved to ' fullfile(savedir,conf.ft.savefile)])
end

% --- Return freqana --- %

freqana = freqdat;



