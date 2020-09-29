function pf_pmg_ft_fragmentana(conf,freqana)
% pf_pmg_ft_fragmentana(conf,freqana) is part of the FieldTrip ana (ftana)
% chapter of the pf_pmg_batch. Specifically, it will use frequency analyzed
% data (freqana, mtmconvol) and perform analyses on specified fragments of 
% your specified conditions (which have to be present in freqana of course). 
% Of these specified fragments, it will return:
%       -   mean of TFR
%       -   STD of TFR
%       -   COV of TFR
%       -   Min of TFR
%       -   Max of TFR
%       -   nDat of TFR
%       -   firstdat of TFR
%       -   lastdat of TFR
%
% See also pf_pmg_batch

% (C) Michiel Dirkx, 2015
% $ParkFunC, version 20151104

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nSub    =   length(conf.sub.name);
nSess   =   length(conf.sub.sess);
nCond   =   length(conf.ft.fragana.cond);
nFrags  =   length(conf.ft.fragana.fragments);
cnt     =   1;
if strcmp(conf.ft.freqana.freqs.meth,'peaksel')
    peaksel = load(conf.ft.freqana.freqs.peakselfile);
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
%     chansel  =   strcmp(conf.ft.fragana.channels(:,1),CurHand);
%     chans    =   conf.ft.fragana.channels{chansel,2};
%     nChan    =   length(chans);
    
    for n = 1:nSess
        
        CurSess  =   conf.sub.sess{n};
        sesscode =   pf_pmg_sesscode(CurSess);
        
        for b = 1:nCond
            
            CurCond   =   conf.ft.fragana.cond;
            condcode  =   pf_pmg_condcode(CurCond{1});
            
            % --- Deal with Average Condition if applicable --- %
            
            if strcmp(conf.ft.fragana.avgcond.on,'yes') && any(strcmp(conf.ft.fragana.avgcond.which(:,1),CurCond))
                iAvg      =   strcmp(conf.ft.fragana.avgcond.which(:,1),CurCond);
                CurConds  =   conf.ft.fragana.avgcond.which{iAvg,2};
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
                iTime0  =   pf_closestto(storage.time,storage.time(1)+conf.ft.fragana.startcond); % correct for pre/post window
                time0   =   storage.time(iTime0);

                for d= 1:nFrags
                    
                   CurFrag          =   conf.ft.fragana.fragments{d};
                   selfrag          =   CurFrag==999;
                   CurFrag(selfrag) =   storage.time(end);
                   
                   timeMin  =   pf_closestto(storage.time,time0+CurFrag(1)); % Index of minimal timepoint
                   timeMax  =   pf_closestto(storage.time,time0+CurFrag(2)); % Index of maximal timepoint
                   
                   % --- Relevant values in fragment --- %
                   
                   meanTFR  =   nanmean(avgTFR(timeMin:timeMax));
                   stdTFR   =   nanstd(avgTFR(timeMin:timeMax));
                   covTFR   =   meanTFR/stdTFR;
                   minTFR   =   min(avgTFR(timeMin:timeMax));
                   maxTFR   =   max(avgTFR(timeMin:timeMax));
                   nDat     =   length(timeMin:timeMax);
                   nDatS    =   nDat / (1/(storage.time(2)-storage.time(1)));
                   firstdat =   avgTFR(timeMin);
                   lastdat  =   avgTFR(timeMax);
                   
                   % [1     2             3       4      5      6        7        8          9        10         11       12        13      14         15       16         17             18            ]
                   % [Sub   Session  Condition Channel Type  timemin   timemax   Freq     meanTFR     stdTFR    covTFR   minTFR   maxTFR   nDatTFR     nDatS     firstvalTFR    lastvalTFR     ]
                   %===============STORAGE OF FRAGMENTANA=================%
                   fragments(cnt,:) = [subcode sesscode condcode chancode CurType  CurFrag(1) CurFrag(2)  CurDat.freq(iFreq) meanTFR stdTFR covTFR minTFR maxTFR nDat nDatS firstdat lastdat];
                   cnt              = cnt+1;
                   %======================================================%
                   
%                    % [1     2             3       4      5      6        7        8          9        10            11       12        13      14         15       16         17             18            ]
%                    % [Sub   Session  Condition Channel Type  timemin   timemax   Freqmin    FreqMax   meanTFR     stdTFR    covTFR   minTFR   maxTFR   nDatTFR     nDatS     firstvalTFR    lastvalTFR     ]
%                    %===============STORAGE OF FRAGMENTANA=================%
%                    fragments(cnt,:) = [subcode sesscode condcode chancode CurType  CurFrag(1) CurFrag(2)  CurDat.freq(iMin) CurDat.freq(iMax) meanTFR stdTFR covTFR minTFR maxTFR nDat nDatS firstdat lastdat];
%                    cnt              = cnt+1;
%                    %======================================================%
                     
                end 
            end
        end
    end
end

%--------------------------------------------------------------------------

%% Save file
%--------------------------------------------------------------------------

savename = fullfile(conf.dir.datsave,conf.ft.fragana.savefile);
save(savename,'fragments');
fprintf('%s\n',['Saved fragments to ' savename])





