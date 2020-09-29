function pf_pmg_ft_timetopeak(conf,freqana)
% pf_pmg_ft_timetopeak(conf,freqana) is part of the FieldTrip ana (ftana)
% chapter of the pf_pmg_batch. Specifically, it will use frequency analyzed
% data (freqana, mtmconvol) and calculate for each subject the time when
% meanTFR[after posturing] equals meanTFR[-3 -1]
%
%
% See also pf_pmg_batch

% (C) Michiel Dirkx, 2018
% $ParkFunC, version 20180602

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nSub    =   length(conf.sub.name);
nSess   =   length(conf.sub.sess);
nCond   =   length(conf.ft.ttp.cond);
% nFrags  =   length(conf.ft.ttp.fragments);
cnt     =   1;
if strcmp(conf.ft.ttp.freqs.meth,'peaksel')
    peaksel = load(conf.ft.ttp.freqs.peakselfile);
    fn      = fieldnames(peaksel);
    peaksel = peaksel.(fn{1});
else
    disp('Only peaksel method has been implemented yet, entering debug...')
    keyboard
end

%--------------------------------------------------------------------------

%% Loop around
%--------------------------------------------------------------------------

for a = 1:nSub
    
    CurSub   =   conf.sub.name{a};
    subcode  =   str2double(CurSub(2:end));
    
%     CurHand  =   conf.sub.hand{a};
%     chansel  =   strcmp(conf.ft.ttp.channels(:,1),CurHand);
%     chans    =   conf.ft.ttp.channels{chansel,2};
%     nChan    =   length(chans);
    
    for n = 1:nSess
        
        CurSess  =   conf.sub.sess{n};
        sesscode =   pf_pmg_sesscode(CurSess);
        
        for b = 1:nCond
            
            CurCond   =   conf.ft.ttp.cond;
            condcode  =   pf_pmg_condcode(CurCond{1});
            
            % --- Deal with Average Condition if applicable --- %
            
            if strcmp(conf.ft.ttp.avgcond.on,'yes') && any(strcmp(conf.ft.ttp.avgcond.which(:,1),CurCond))
                iAvg      =   strcmp(conf.ft.ttp.avgcond.which(:,1),CurCond);
                CurConds  =   conf.ft.ttp.avgcond.which{iAvg,2};
                firstflag =   0;
                
                for c = 1:length(CurConds)
                    
                    sel         =   cellfun(@(x) strcmp(x.sub,CurSub) && strcmp(x.sess,CurSess) && strcmp(x.cond,CurConds{c}),freqana);
                    if ~isempty(find(sel, 1))
                        CurDat      =   freqana{sel};
                    elseif c == 1
                        firstflag = 1;
                        warning('ft:fragments',['Could not find freqdata of ' CurSub '-' CurSess '-' CurConds{c} '. Skipping...']);
                        continue
                    else
                        continue
                    end
                    
                    if c == 1  || firstflag   % Store for condition averaging
                        storage                    = CurDat;
                        storage.powspctrm(:,:,:,1) = storage.powspctrm;
                        storage.cond               = CurCond;
                    else
                        sStorage    =   size(storage.powspctrm); % If sampling are not equal
                        sPowspctrm  =   size(CurDat.powspctrm);
                        if sStorage(3)>sPowspctrm(3)
                            diff    =   sStorage(3)-sPowspctrm(3);
                            CurDat.powspctrm(:,:,sPowspctrm(3)+1:sPowspctrm(3)+diff) = nan(sPowspctrm(1),sPowspctrm(2),diff);
                        elseif sPowspctrm(3)>sStorage(3)
                            diff    =   sPowspctrm(3)-sStorage(3);
                            if length(sStorage)>3 && sStorage(4)>1
                                storage.powspctrm(:,:,sStorage(3)+1:sStorage(3)+diff,:) = nan(sStorage(1),sStorage(2),diff,sStorage(4));
                            else
                                storage.powspctrm(:,:,sStorage(3)+1:sStorage(3)+diff) = nan(sStorage(1),sStorage(2),diff);
                            end
                            storage.time    =   CurDat.time;
                        end
                        storage.powspctrm(:,:,:,c) = CurDat.powspctrm;
                    end
                end
            else % If not average condition
                sel         =   cellfun(@(x) strcmp(x.sub,CurSub) && strcmp(x.sess,CurSess) && strcmp(x.cond,CurCond),freqana);
            end
            
            CurDat.powspctrm = nanmean(storage.powspctrm,4);
            
            % --- Match Peaksel --- %
            
            subcode  =   str2double(CurSub(2:end));
            sesscode =   pf_pmg_sesscode(CurSess);
            condcode =   pf_pmg_condcode(CurCond{1});
            
            sel      =   peaksel(:,1) == subcode & peaksel(:,2)==sesscode & peaksel(:,3)==condcode;
            peaks    =   peaksel(sel,:);
            
            uChan    =   unique(peaks(:,4));
            nChan    =   length(uChan);
            %Loop through channels, get right tfr information per selected
            %peak.            
            
            %[1         2        3      4      5       6        7      8         9       10     11     12  ]
            %[Sub   Session Condition Channel Type Frequency Power PowerSTD PowerCOV PowerMIN PowerMAX nDAT]
            
            for c = 1:nChan
                
                chancode =   uChan(c);
                if chancode==18
                    CurChan = [11 12];
                elseif chancode==19
                    CurChan = [4 5];
                else
                    CurChan = chancode;
                end
                ChanStr =   conf.ft.chans(CurChan,1);
                
                sel     =   peaks(:,4)==chancode;
                CurFreq =   peaks(sel,6);
                CurType =   peaks(sel,5);
                
%                 % --- OLD, when we used to average --- %
%                 PB      =   [CurFreq-1.5 CurFreq+1.5]; % Protected bandwidth, to account for both reemergent and rest tremor
%                 
%                 iMin    =   pf_closestto(CurDat.freq,PB(1)); % Freq - PB, idx
%                 iMax    =   pf_closestto(CurDat.freq,PB(2)); % Freq + PB, idx
                if length(CurFreq)>1
                    keyboard
                end
                iFreq = pf_closestto(CurDat.freq,CurFreq);
                
                % --- Rest --- %

                iChan   =   pf_strcmp(CurDat.label,ChanStr);
                
                avgTFR  =   squeeze(mean(CurDat.powspctrm(iChan,iFreq,:),1)); % Ah, so this is the average TFR for the tremor frequency
%                 avgTFR  =   squeeze(mean(CurDat.powspctrm(iChan,iMin:iMax,:),2)); % Ah, so this is the average TFR for the tremor frequency
                iTime0  =   pf_closestto(storage.time,storage.time(1)+conf.ft.ttp.startcond); % correct for pre/post window
                time0   =   storage.time(iTime0);
                
%                 keyboard
                
                % --- Calculate mTFR [-1 -3] --- %
                
                timeMin      =   pf_closestto(storage.time,time0+-3); % Index of minimal timepoint
                timeMax      =   pf_closestto(storage.time,time0+-1); % Index of maximal timepoint
                
                meanTFR_pre  =   nanmean(avgTFR(timeMin:timeMax));
%                 stdTFR_pre   =   nanstd(avgTFR(timeMin:timeMax));
%                 covTFR_pre   =   meanTFR_pre/stdTFR_pre;
%                 minTFR_pre   =   min(avgTFR(timeMin:timeMax));
%                 maxTFR_pre   =   max(avgTFR(timeMin:timeMax));
%                 nDat_pre     =   length(timeMin:timeMax);
%                 nDatS_pre    =   nDat_pre / (1/(storage.time(2)-storage.time(1)));
%                 firstdat_pre =   avgTFR(timeMin);
%                 lastdat_pre  =   avgTFR(timeMax);
                
                % --- determine time to peak --- %
%                 keyboard
                
                % --- OLD single val --- %
                
%                 timeMin_post  =   pf_closestto(storage.time,time0+1);   % onset after start posturing
%                 sel           =   find(avgTFR>=meanTFR_pre);            % fully re-emerged
%                 sel2          =   find(sel>=timeMin_post);              % after posturing
%                 if isempty(sel2)
%                    ttp_abs       =   storage.time(end);
%                    ttp_index     =   pf_closestto(storage.time,ttp_abs);   % onset after start posturing
%                 else
%                    ttp_index     =   sel(sel2(1));                         % select first index of sel
%                    ttp_abs       =   storage.time(ttp_index);   
%                 end
%                 timetopeak    =   ttp_abs-time0;
%                 meanTFR_post  =   avgTFR(ttp_index);
                
                %--- OLD 2s window --- %
%                 dur      =  storage.time(end)-storage.time(iTime0+1);
%                 n2s      =  floor(dur/2);
%                 n2sCNT   =  1; % start 1second after stretching
%                 
%                 for d = 1:n2s
%                     
%                     timeMin_post  =   pf_closestto(storage.time,time0+n2sCNT); % Index of minimal timepoint
%                     timeMax_post  =   pf_closestto(storage.time,time0+n2sCNT+2); % Index of maximal timepoint
%                     
%                     meanTFR_post  =   nanmean(avgTFR(timeMin_post:timeMax_post));
% %                     stdTFR_post   =   nanstd(avgTFR(timeMin_post:timeMax_post));
% %                     covTFR_post   =   meanTFR_post/stdTFR_post;
% %                     minTFR_post   =   min(avgTFR(timeMin_post:timeMax_post));
% %                     maxTFR_post   =   max(avgTFR(timeMin_post:timeMax_post));
% %                     nDat_post     =   length(timeMin_post:timeMax_post);
% %                     nDatS_post    =   nDat / (1/(storage.time(2)-storage.time(1)));
% %                     firstdat_post =   avgTFR(timeMin_post);
% %                     lastdat_post  =   avgTFR(timeMax_post);
%                     
%                     if meanTFR_post >= meanTFR_pre || d==n2s
%                         timetopeak = n2sCNT;
%                         break
%                     end
%                     n2sCNT = n2sCNT+2;
%                 end
                

                timeMin_post  = pf_closestto(storage.time,time0+1);   % onset after start posturing
                n2s           = length(avgTFR(timeMin_post:end));
                win2s         = pf_closestto(storage.time,time0+2)-pf_closestto(storage.time,time0);
                                
                n2sCNT        = 1; % start 1second after stretching
                
                for d = 1:n2s
                    
                    try
                        meanTFR_post  =   nanmean(avgTFR(timeMin_post:timeMin_post+win2s));
                    catch
                        meanTFR_post  =   nanmean(avgTFR(timeMin_post:end));
                    end
                    
                    if meanTFR_post >= meanTFR_pre || d==n2s
                        timetopeak = storage.time(timeMin_post) - storage.time(pf_closestto(storage.time,time0));
                        timeMax_post = timeMin_post+win2s;
                        break
                    end
                    timeMin_post = timeMin_post+1;
                end

                ff = figure;
                plot(avgTFR)
                pf_verline([timeMin timeMax]);
                try
                    pf_verline([timeMin_post timeMax_post],'color','r');
                catch
                    keyboard
                end
%                 pf_verline(ttp_index,'color','r');
                title([CurSub '-' CurSess '-' pf_pmg_chancode2name(chancode) ' TimeToPeak = ' num2str(timetopeak)]);
                disp([[CurSub '-' CurSess '-' pf_pmg_chancode2name(chancode) ' TimeToPeak = ' num2str(timetopeak)]]);
                     
                %             [1     2             3       4         5      6        7            8              9       ] 
                %             [Sub   Session  Condition Channel    Type    Freq     meanTFR_pre  meanTFR_post  timetopeak ]
                %===============STORAGE OF TIMETOPEAK=================%
                ttps(cnt,:) = [subcode sesscode condcode chancode CurType CurDat.freq(iFreq) meanTFR_pre meanTFR_post timetopeak ];
                cnt              = cnt+1;
                %======================================================%
                
                print(ff,'-dtiff','-r400',['/home/action/micdir/data/PMG/analysis/Figures/POSTPD/TTP/singleval/' CurSub '-' CurSess '-' pf_pmg_chancode2name(chancode)])
                
            end
        end
    end
end

%--------------------------------------------------------------------------

%% Save file
%--------------------------------------------------------------------------

savename = fullfile(conf.dir.datsave,conf.ft.ttp.savefile);
save(savename,'ttps');
fprintf('%s\n',['Saved ttps to ' savename])





