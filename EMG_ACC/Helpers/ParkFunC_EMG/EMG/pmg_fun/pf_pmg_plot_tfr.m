function pf_pmg_plot_tfr(conf,freqana,uSub)
% pf_pmg_plot_tfr(conf,freqana,uSub) is part of the plot subparagraph which
% is part of the 'ftana' paragraph of the pf_pmg_batch. Specifically, this
% function will plot time-frequency representations of frequency analyzed
% data.

% I had to implement both a imagesc function as well as a simple plot
% function. Because of the differences in both plots I decided to make
% seperate loops for this.

% �Michiel Dirkx, 2014
% $ParkFunC, version 20151910

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

% --- Select subjects --- %

nSub         =   length(uSub);

sub_freqana  =   cellfun(@(x) x.sub,freqana,'uniformoutput',0);
iSub         =   pf_strcmp(sub_freqana,uSub); % NB: if a subject was specified but is not present in the data structure than this will not be shown when averaged!!!!!!!
freqana      =   freqana(iSub);
breakflag    =   0;

% --- Check peaksel option --- %

if strcmp(conf.fa.fig.tfr.peaksel.on,'yes')
    peaksel = load(conf.fa.fig.tfr.peaksel.file);
    fn      = fieldnames(peaksel);
    peaksel = peaksel.(fn{1});
end

% if strcmp(conf.fa.fig.avgcond.on,'yes')
    avgcond   =   conf.fa.fig.avgcond.which(:,1);
    nAvg      =   length(avgcond);
    condflags =   nan(nAvg,1);
% end

%--------------------------------------------------------------------------

%% Plot 3D (imagesc) plots
%--------------------------------------------------------------------------

%=========================================================================%
if strcmp(conf.fa.fig.tfr.graph,'imagesc')
%=========================================================================%    
    
    for a = 1:nSub
        
        % --- Select Subject data --- %
        
        CurSub   =   uSub{a};
        nPlot    =   length(conf.fa.fig.plot);
        
        for b = 1:nPlot
            
            % --- Select predefined plot--- %
            
            CurPlot   =  conf.fa.fig.plot{b};
            [row,col] =  size(CurPlot);
            hh        =  nan(row,col);
            cntR      =  1;
            cntC      =  1;
            
            q = figure;
            
            for c = 1:(row*col)
                
                CurFields   =   CurPlot{cntR,cntC};
                
                % --- Deal with Condition Average --- %
                
                selcond       =   strcmp(avgcond,CurFields{2});
                if any(selcond)
                    AvgCnt    =   length(conf.fa.fig.avgcond.which{selcond,2});
                    storeflag =   1;
                    storage   =   cell(AvgCnt,1);
                    CurAvg    =   conf.fa.fig.avgcond.which{selcond,2};
                    storecnt  =   1;
                else
                    AvgCnt = 1;
                    storeflag =   0;
                end
              
                for e = 1:AvgCnt
                    
                    % --- Get right current condition --- %
                    
                    if storeflag
                        CurCond =   CurAvg{e};
                    else
                        CurCond =   CurFields{2};
                    end
                    
                    if strcmp(conf.fa.fig.avg.on,'yes')
                        
                        % --- Deal with handedness --- %
                        
                        nHand    =   size(conf.fa.fig.avg.chancombi,1);
                        cnthand  =   1;
                        
                        for d = 1:nHand
                            
                            CurHand  =   conf.fa.fig.avg.chancombi{d,1};
                            sel      =   cellfun(@(x) strcmp(x.hand,CurHand) && strcmp(x.sess,CurFields{1}) && strcmp(x.cond,CurCond),freqana);
                            
                            % --- Store and get right chanorder --- %
                            
                            if any(sel)
                                data              =   freqana(sel);
                                oldorder          =   data{1}.label;
                                neworder          =   conf.fa.fig.avg.chancombi{d,2}';
                                newidx            =   pf_find(oldorder,neworder);
                                
                                
                                if cnthand>1
                                    allpowspctrm    = vertcat(allpowspctrm,cellfun(@(x) x.powspctrm(newidx,:,:),data,'uniformoutput',0));
                                else
                                    allpowspctrm    = cellfun(@(x) x.powspctrm(newidx,:,:),data,'uniformoutput',0);  % In which case you need the time dimension
                                    CurDat          = data{1};       % Example (template) dataset
                                    CurDat.label    = CurDat.label(newidx);
                                end
                                
                                cnthand  =   cnthand+1;
                            end
                        end
                        
                        % --- Perform averaging --- %
                        
                        nChan        =  size(allpowspctrm{1},1);
                        nFreq        =  size(allpowspctrm{1},2);
                        
                        minTime  =  min(cellfun(@(x) size(x,3),allpowspctrm));
                        maxTime  =  max(cellfun(@(x) size(x,3),allpowspctrm));
                        nTime    =  maxTime;
                        
                        if strcmp(conf.fa.fig.logtransform,'yes')
                             allpowspctrm = cellfun(@reallog,allpowspctrm,'uniformoutput',0);
                        end
                        
                        mat      =  nan(nChan,nFreq,nTime,length(allpowspctrm));
                        for d = 1:length(allpowspctrm)
                            CurPowspctrm                       =   allpowspctrm{d};
                            mat(:,:,1:size(CurPowspctrm,3),d)  =   CurPowspctrm; 
                        end
                        
                        avgpowspctrm        = nanmean(mat,4);
%                         stdpowspctrm        = nanstd(mat,4);
                        
                        avgpowspctrm        = avgpowspctrm(:,:,1:minTime);


                        % --- Build CurDat --- %
                        
                        CurDat.powspctrm     = avgpowspctrm;
%                         CurDat.powspctrm_std = stdpowspctrm;
                        
                    else % --- If not average --- %
                        sel         =   cellfun(@(x) strcmp(x.sub,CurSub) && strcmp(x.sess,CurFields{1}) && strcmp(x.cond,CurCond),freqana);
                        if ~any(sel)
                            warning('powspct:sel',['File for "' CurSub '-' CurFields{1} '-' CurCond '" could not be found']);
                            breakflag = 1;
                            continue
                        end
                        CurDat      =   freqana{sel};
                        CurHand     =   CurDat.hand;
                        
                    end
                    
                    % --- Store for condition averaging --- %
                    
                    if storeflag && storecnt==1
                        storage            =   CurDat;
                        storage.powspctrm(:,:,:,1)  = storage.powspctrm;
                        storage.cond       =   CurFields{2};
                        storecnt           =   storecnt+1;
                    elseif storeflag
                        sStorage    =   size(storage.powspctrm); % If sampling are not equal
                        sPowspctrm  =   size(CurDat.powspctrm);
                        if sStorage(3)>sPowspctrm(3)
                            diff    =   sStorage(3)-sPowspctrm(3);
                            CurDat.powspctrm(:,:,sPowspctrm(3)+1:sPowspctrm(3)+diff) = nan(sPowspctrm(1),sPowspctrm(2),diff);
                        elseif sPowspctrm(3)>sStorage(3)
                            diff    =   sPowspctrm(3)-sStorage(3);
                            storage.powspctrm(:,:,sStorage(3)+1:sStorage(3)+diff) = nan(sStorage(1),sStorage(2),diff);
                            storage.time    =   CurDat.time;
                        end
                        storage.powspctrm(:,:,:,storecnt)   =   CurDat.powspctrm;
                        storecnt                            =   storecnt+1;
                    end
                    
                end
                
                
                % --- Check if condition was found --- %
                
                if breakflag && storecnt==1
                    breakflag = 0;
                    cfcnt     =   cfcnt+3;
                    continue
                end
                
                % --- Average over stored conditions if applicable --- %
                
                if storeflag
                    CurDat           = storage;
                    CurDat.powspctrm = mean(CurDat.powspctrm,4);
                    storeflag = 0;
                end
                
                % --- Select Data Channels --- %
                
                if ~strcmp (conf.fa.fig.avg.on,'yes')
                    iHand        =   pf_strcmp(conf.fa.fig.chan(:,1),CurHand);  % only applicable if not subject averaged.
                    [~,numI]     =   pf_strcmp(conf.fa.fig.chan{iHand,2}',CurDat.label); % Get numerical index                
                    chanlabels   =   CurDat.label(numI);                        % Original channel name, R/L selection
                else
                    chanlabels   =   CurDat.label;
                end
                
                if CurFields{3}(1) == 999 % If channel average
                    chinchan      =   pf_pmg_channame(chanlabels(CurField{3}(2:end)),conf.ft.chans);         % Original channel name, plot selection
                    for d = 1:length(chinchan)
                        if d==1
                            chanlabels = chinchan(d);
                        else
                            chanlabels{1} = [chanlabels{1} '&' chinchan{d}];
                        end
                    end
                else
                    chanlabels      =   chanlabels(CurFields{3});                 % Original channel name, plot selection
                    chanlabels      =   pf_pmg_channame(chanlabels,conf.ft.chans); % Replace first column for trivial name
                end
                
                if strcmp(conf.fa.fig.avg.on,'yes')
                    chanlabels = regexprep(chanlabels,'R-','MA-');
                    chanlabels = regexprep(chanlabels,'L-','LA-');
                    powspctrm  = CurDat.powspctrm;
                    CurSub     = 'avgsub';
                else
                    powspctrm  =   CurDat.powspctrm(numI,:,:); % R/L selection
                end
                
                if CurFields{3}(1) == 999 % If channel average
                    powspctrm       =   powspctrm(CurFields{3}(2:end),:); % Plot selection
                    powspctrm       =   mean(powspctrm,1);               % mean of channels
                else
                    powspctrm       =   powspctrm(CurFields{3},:,:); % Plot selection
                end
                nChan           =   length(chanlabels);
                h               =   nan(nChan,1);
                
                % --- TMP: take 0-30s (same as rickfig) --- %
                
                maxdat  =   max(max(squeeze(powspctrm)));
%                 mindat  =   min(min(squeeze(powspctrm)));
% 
%                 
%                 timezero = CurDat.time-CurDat.time(1);
%                 i30s     = pf_closestto(timezero,30);
%                 CurDat.time = CurDat.time(1:i30s);
%                 powspctrm   = powspctrm(:,:,1:i30s);
                        
                % --- Plot Data --- %
%                 keyboard;[mindat maxdat*0.15]
                subplot(row,col,c)
                imagesc(flipud(squeeze(powspctrm)),[0 maxdat]); %Flip because otherwise top will be first frequency
                colorbar
                axis square
                
                % --- Create recognizable ylabel --- %
                
                uFreq = unique(round(CurDat.freq));
                for d = 1:length(uFreq)
                    ytik(d)    = pf_closestto(CurDat.freq,uFreq(d));
                    ytiklab(d) = uFreq(d);
                end
                set(gca,'Ytick',ytik,'Yticklabel',fliplr(ytiklab))
                
                % --- Create recognizable xlabel --- %
                
                uTime = unique(round(CurDat.time));
                cnt   = 1;
                for d = 1:length(uTime)
                    if ~mod(d,10) || d==1
                        xtik(cnt)    = pf_closestto(CurDat.time,uTime(d));
                        xtiklab(cnt) = uTime(d);
                        cnt = cnt+1;
                    end
                end
                set(gca,'Xtick',xtik,'Xticklabel',xtiklab)
                
                % --- Rest of graphics --- %
                
                xlabel('Time (s)','fontweight','b')
                ylabel('Frequency (Hz)','fontweight','b')
                colorbar
                tit = [CurSub '-' CurDat.sess ' ' CurDat.cond ' ' chanlabels];
                title(tit,'interpreter','none')
                
                % --- Prepare for next round --- %
                
                cntC = cntC+1;
                if c == col
                    cntC = 1;
                    cntR = cntR + 1;
                end
                
            end
            
            % --- Save Figure if specified --- %
            
            if strcmpi(conf.fa.fig.save,'yes')
                savedir  = conf.dir.figsave;
                savename = [CurSub '-' CurHand '_' conf.fa.fig.savename{b}];
                if ~exist(savedir,'dir'); mkdir(savedir); end
                print(q,conf.fa.fig.saveext,conf.fa.fig.saveres,fullfile(savedir,savename))
                fprintf('%s\n',['Saved figure to ' fullfile(savedir,savename)])
            end
            
        end
        if strcmp(conf.fa.fig.avg.on,'yes') % if average over subjects, break now
            break
        end
    end
end

%--------------------------------------------------------------------------

%% Plot 2D ('plot')
%--------------------------------------------------------------------------

breakflag = 0;
poopcnt   = 1;

%=========================================================================%
if strcmp(conf.fa.fig.tfr.graph,'plot')
%=========================================================================%    

% --- Check if conditions need be averaged --- %

if strcmp(conf.fa.fig.avgcond.on,'yes')
    avgcond   =   conf.fa.fig.avgcond.which(:,1);
    nAvg      =   length(avgcond);
    condflags =   nan(nAvg,1);
end

peakstorage         =   cell(100,size(conf.fa.fig.plot{1},1)*size(conf.fa.fig.plot{1},2));
storagecnt      =    1;

for a = 1:nSub
    
    CurSub   =   uSub{a};
    nPlot    =   length(conf.fa.fig.plot);
    
    % --- For every Figure --- %
    
    for b = 1:nPlot
        
        CurPlot   =  conf.fa.fig.plot{b};
        [row,col] =  size(CurPlot);
        
        cntC      =  1;
        cntR      =  1;
        cnt		  =  1;
        
        if ~strcmp(conf.fa.fig.tfr.peaksel.avgsub,'yes')
            q = figure;
        end
        
        % --- For Every Subplot --- %
        
        for c = 1:(row*col)
            
            % --- Read Current Data --- %
            
            CurFields   =   CurPlot{cntR,cntC};
            nDraw       =   length(CurFields)/3;
            cfcnt       =   1;
            colocnt     =   0;
            coloCNT     =   1;
            firstlabel  =   0;
            drawn       =   0;
            
            for f = 1:nDraw
                
                CurField    =   CurFields(cfcnt:cfcnt+2);
                
                % --- Deal with Condition Average --- %
                
                selcond       =   strcmp(avgcond,CurField{2});
                storecnt      =   1;
                if any(selcond)
                    AvgCnt    =   length(conf.fa.fig.avgcond.which{selcond,2});
                    storeflag =   1;
                    storage   =   cell(AvgCnt,1);
                    CurAvg    =   conf.fa.fig.avgcond.which{selcond,2};
                else
                    AvgCnt = 1;
                    storeflag =   0;
                end
                
                for e = 1:AvgCnt
                    
                    % --- Get right current condition --- %
                    
                    if storeflag
                        CurCond =   CurAvg{e};
                    else
                        CurCond =   CurField{2};
                    end
                    
                    % --- Average over subjects if applicable --- %
                    
                    if strcmp(conf.fa.fig.avg.on,'yes')
                        
                        % --- Deal with handedness --- %
                        
                        nHand    =   size(conf.fa.fig.avg.chancombi,1);
                        cnthand  =   1;
                        
                        for d = 1:nHand
                            
                            CurHand  =   conf.fa.fig.avg.chancombi{d,1};
                            sel      =   cellfun(@(x) strcmp(x.hand,CurHand) && strcmp(x.sess,CurFields{1}) && strcmp(x.cond,CurCond),freqana);
                            
                            % --- Store and get right chanorder --- %
                            
                            if any(sel)
                                data              =   freqana(sel);
                                oldorder          =   data{1}.label;
                                neworder          =   conf.fa.fig.avg.chancombi{d,2}';
                                newidx            =   pf_find(oldorder,neworder);
                                
                                if cnthand>1
                                    allpowspctrm    = vertcat(allpowspctrm,cellfun(@(x) x.powspctrm(newidx,:,:),data,'uniformoutput',0));
                                else
                                    allpowspctrm    = cellfun(@(x) x.powspctrm(newidx,:,:),data,'uniformoutput',0);  % In which case you need the time dimension
                                    CurDat          = data{1};       % Example (template) dataset
                                    CurDat.label    = CurDat.label(newidx); % NB: here I set the new labels as indexed by conf.fa.fig.avg.chancombi (see above). Note that this corresponds to the FIRST HAND
                                end
                                
                                cnthand  =   cnthand+1;
                            end
                        end
                        
                        % --- Perform averaging --- %
                        
                        nChan        =  size(allpowspctrm{1},1);
                        nFreq        =  size(allpowspctrm{1},2);
                        
                        minTime  =  min(cellfun(@(x) size(x,3),allpowspctrm));
                        maxTime  =  max(cellfun(@(x) size(x,3),allpowspctrm));
                        nTime    =  maxTime;
                        
                        mat      =  nan(nChan,nFreq,nTime,length(allpowspctrm));
                        for d = 1:length(allpowspctrm)
                            CurPowspctrm                       =   allpowspctrm{d};
                            mat(:,:,1:size(CurPowspctrm,3),d)  =   CurPowspctrm; 
                        end
                        
                        avgpowspctrm        = nanmean(mat,4);
%                         stdpowspctrm        = nanstd(mat,4);
                        
                        avgpowspctrm        = avgpowspctrm(:,:,1:minTime); % only do minimum

                        % --- Build CurDat --- %
                        
                        CurDat.powspctrm     = avgpowspctrm;
%                         CurDat.powspctrm_std = stdpowspctrm;
                        
                    else % --- If not average --- %
                        sel         =   cellfun(@(x) strcmp(x.sub,CurSub) && strcmp(x.sess,CurField{1}) && strcmp(x.cond,CurCond),freqana);
                        if ~any(sel)
                            warning('powspct:sel',['File for "' CurSub '-' CurField{1} '-' CurCond '" could not be found']);
                            breakflag = 1;
                            continue
                        end
                        CurDat      =   freqana{sel};
                        CurHand     =   CurDat.hand;
                        
                    end
                    
                    % --- Store for condition averaging --- %
                    
                    if storeflag && storecnt==1
                        storage            =   CurDat;
                        storage.powspctrm(:,:,:,1)  = storage.powspctrm;  
                        storage.cond       =   CurField{2};
                        storecnt           =   storecnt+1;
                    elseif storeflag
                        sStorage    =   size(storage.powspctrm); % If sampling are not equal
                        sPowspctrm  =   size(CurDat.powspctrm);
                        if sStorage(3)>sPowspctrm(3)
                            diff    =   sStorage(3)-sPowspctrm(3);
                            CurDat.powspctrm(:,:,sPowspctrm(3)+1:sPowspctrm(3)+diff) = nan(sPowspctrm(1),sPowspctrm(2),diff);
                        elseif sPowspctrm(3)>sStorage(3)
                            diff    =   sPowspctrm(3)-sStorage(3);
                            storage.powspctrm(:,:,sStorage(3)+1:sStorage(3)+diff) = nan(sStorage(1),sStorage(2),diff);
                            storage.time    =   CurDat.time;
                        end
                        storage.powspctrm(:,:,:,storecnt)   =   CurDat.powspctrm;
                        storecnt                            =   storecnt+1;
                    end
                    
                end
                
                % --- Check if condition was found --- %
                
                if breakflag && storecnt==1
                    breakflag = 0;
                    cfcnt     =   cfcnt+3;
                    continue
                end
                
                % --- Average over stored conditions if applicable --- %
                
                if storeflag
                    CurDat           = storage;
                    CurDat.powspctrm = nanmean(CurDat.powspctrm,4);
                    storeflag = 0;
                end
                
                 % --- Select Data Channels --- %
                
                if ~strcmp (conf.fa.fig.avg.on,'yes')
                    iHand        =   pf_strcmp(conf.fa.fig.chan(:,1),CurHand);  % only applicable if not subject averaged.
                    [~,numI]     =   pf_strcmp(conf.fa.fig.chan{iHand,2}',CurDat.label); % Get numerical index                
                    chanlabels   =   CurDat.label(numI);                        % Original channel name, R/L selection
                else
                    chanlabels   =   CurDat.label;              %NBNBNB: What happens here?? A workaround for conf.fa.fig.chan... this is not right.
                end
                
                if CurFields{3}(1) == 999 % If channel average
                    chinchan      =   pf_pmg_channame(chanlabels(CurField{3}(2:end)),conf.ft.chans);         % Original channel name, plot selection
                    for d = 1:length(chinchan)
                        if d==1
                            chanlabels = chinchan(d);
                        else
                            chanlabels{1} = [chanlabels{1} '&' chinchan{d}];
                        end
                    end
                else
                    chanlabels      =   chanlabels(CurFields{3});                 % Original channel name, plot selection
                    chanlabels      =   pf_pmg_channame(chanlabels,conf.ft.chans); % Replace first column for trivial name
                end
                
                if strcmp(conf.fa.fig.avg.on,'yes')
                    chanlabels = regexprep(chanlabels,'R-','MA-');
                    chanlabels = regexprep(chanlabels,'L-','LA-');
                    powspctrm  = CurDat.powspctrm;
                    CurSub     = 'AvgSub';
                else
                    powspctrm  =   CurDat.powspctrm(numI,:,:); % R/L selection
                end
                
                if CurFields{3}(1) == 999 % If channel average
                    powspctrm       =   powspctrm(CurFields{3}(2:end),:,:); % Plot selection
                    powspctrm       =   mean(powspctrm,1);               % mean of channels
                else
                    powspctrm       =   powspctrm(CurFields{3},:,:); % Plot selection
                end
                nChan           =   length(chanlabels);
                h               =   nan(nChan,1);
                                                
                % --- Check peaksel --- %
                
                if strcmp(conf.fa.fig.tfr.peaksel.on,'yes')
                    %[1           2        3      4      5       6        7      8         9       10     11      12 ]
                    %[Subject Session Condition Channel Type Frequency Power PowerSTD PowerCOV PowerMIN PowerMAX nDAT]
                    subcode     =   str2double(CurSub(2:end));
                        
                    sesscode    =   pf_pmg_sesscode(CurDat.sess);
                    condcode    =   pf_pmg_condcode(CurDat.cond); % for df>1.5 groups
                    
                    % --- For fig1 column 1 (to get singletfr at rest tremor frequency)--- %
                    
%                     condcode    =   24; %RestAVG, for the df<1.5 groups
                     
%                     if subcode ~=9      % 9 doesnt have 24, so workaround to take 25 and later on manually set it
%                         condcode    =   24;
%                     else
%                         condcode    =   25;
%                     end
                     
                    % --- end --- %
                    
                    chancode    =   pf_pmg_chancode(chanlabels);
                    
                    sel  =  peaksel(:,1)==subcode & peaksel(:,2)==sesscode & peaksel(:,3)==condcode & peaksel(:,4)==chancode;
                    
                    if ~any(sel)
                        disp(['-Did not find a selected peak for ' CurSub '-' CurDat.sess '-' CurDat.cond ' ' cell2str(chanlabels)]);
                        cfcnt   =   cfcnt+3;
                        if f == nDraw
                            cntC = cntC+1;
                            cnt  = cnt+1;
                            if ~mod(c,col)
                                cntC = 1;
                                cntR = cntR + 1;
                            end
                        end
                        continue % to following condition
                    else
                        peakdat =   peaksel(sel,:);
                        nDat    =   size(peakdat,1);
                    end
                end
                
                % --- Plot --- %
                
                nChan           =   length(chanlabels);
                coloCNT         =   1;
                if ~strcmp(conf.fa.fig.tfr.peaksel.avgsub,'yes')
                    subplot(row,col,c);
                end
                fStr            =   cell(1,1);
                
                for d = 1:nChan
                    
                    CurData      = squeeze(powspctrm(d,:,:));
                    CurChan      = chanlabels(d);
                    
                    % --- Select Right Frequencies if peaksel --- %
                    
                    if strcmp(conf.fa.fig.tfr.peaksel.on,'yes')
                        fcnt    =   1;
                        for e = 1:nDat
%                             if chancode==15 || chancode==16
%                                 thispeak = 8.4; %OFF
% %                                 thispeak = 8.8; OLD ON
%                             elseif chancode==18 || chancode==19
%                                 thispeak = 8.8; %OFF
% %                                 thispeak = 9; OLD ON
%                             end
%                             if subcode ~=9 % for fig1 column1
                                thispeak = peakdat(e,6);
                                poop(poopcnt) = thispeak;
                                poopcnt = poopcnt+1;
                                disp(['Subject ' CurSub ': ' num2str(thispeak) ' Hz'])
%                             else %for fig1 column1
%                                 thispeak = 4.5; % for fig1 column1
%                             end %for fig1 column1
                            PB       = 1.5;
                            minpeak  = thispeak-PB; %Protected band
                            maxpeak  = thispeak+PB;
                            iMin     = pf_closestto(CurDat.freq,minpeak);
                            iMax     = pf_closestto(CurDat.freq,maxpeak);
                            if any(iMin)
                                colocnt = colocnt+1;
                                colo    = hsv(colocnt);
                                %==============PLOTTING===============%
                                CurDataq = mean(CurData(iMin:iMax,:));
                                
                                %==== Log transform ====%
                                CurDataq = CurDataq(~isnan(CurDataq));                                
                                CurDataq = log(CurDataq);
%                                 CurDataq = zscore(CurDataq);
                                %=======================%
                                
                                if ~strcmp(conf.fa.fig.tfr.peaksel.avgsub,'yes')
                                    h(coloCNT)  = plot(CurDat.time,CurDataq,'color',colo(coloCNT,:));
                                    hold on
%                                     fStr{coloCNT} = num2str(CurDat.freq(fIdx(fcnt)));
                                    fStr{coloCNT} = [num2str(CurDat.freq(iMin)) '-' num2str(CurDat.freq(iMax))];
                                    coloCNT       = coloCNT+1;
                                else
                                    peakstorage{storagecnt,c}    = CurDataq;
                                    if c == row*col
                                        storagecnt = storagecnt+1;
                                    end
                                end
                                %=====================================%
                            else
                                warning('peaksel:fidx','Freqana/peaksel mismatch');
                                keyboard
                            end
                        end
                        
                    end
                end
                
                if ~strcmp(conf.fa.fig.tfr.peaksel.avgsub,'yes')
                
                    drawn = 1;  % To indicate something was plotted at least.
                    
                    % --- Change tit/chanlabels when more conditions in one plot --- %
                    
                    if nDraw>1 && ~firstlabel
                        if ~strcmp(conf.fa.fig.avg.on,'yes')
                            tit  =   ['PowSpct: ' CurDat.sub '-' CurDat.hand '_' CurDat.sess ' ' CurDat.cond];
                        else
                            tit  =   ['PowSpct: AvgSub_' CurDat.sess ' ' CurDat.cond];
                        end
                        lab  =   pf_horzcatcell(chanlabels,[' ' CurDat.cond]);
                        hcf  =   h;
                        legend(hcf,lab);
                        legend('boxoff')
                        firstlabel = 1;
                    elseif nDraw>1 && firstlabel
                        tit  =   [tit 'vs' CurDat.cond];
                        hcf  =   vertcat(hcf,h);
                        
                        labb =   pf_horzcatcell(chanlabels,[' ' CurDat.cond]);
                        lab  =   vertcat(lab,labb);
                        legend(hcf,lab);
                        legend('boxoff')
                    elseif nDraw==1
                        if ~strcmp(conf.fa.fig.avg.on,'yes')
                            tit  =   ['PowSpct: ' CurDat.sub '-' CurDat.hand '_' CurDat.sess ' ' CurDat.cond];
                        else
                            tit  =   ['PowSpct: AvgSub_' CurDat.sess ' ' CurDat.cond];
                        end
                        for d = 1:length(fStr)
                            lab(d) = pf_horzcatcell(chanlabels,[' ' fStr{d}]);
                        end
                        legend(h,lab)
                        legend('boxoff')
                    end
                    
                    % --- Set all the graphics --- %
                    
                    % set(gca,'Xtick',length(CurData)/512,'Xticklabel',length(CurData)/512)
                    title(tit,'fontweight','b','fontsize',11,'interpreter','none');
                    xlabel('Time (s)','fontweight','b')
                    ylabel('Power (uV^2)','fontweight','b')
                    pf_verline(CurDat.time(1)+10)
                    if isempty(conf.fa.fig.xlim)
                        xlim([CurDat.time(1) CurDat.time(end)])
                    else
                        xlim(conf.fa.fig.xlim)
                    end
                    if ~isempty(conf.fa.fig.ylim)
                        ylim(conf.fa.fig.ylim)
                    end
                    %                 whitebg(conf.fa.fig.backcol);
                    
                    % --- Prepare for next round --- %
                    
                end
                
                cntC = cntC+1;
                cnt	 = cnt+1;
                
                if ~mod(c,col)
                    cntC = 1;
                    cntR = cntR + 1;
                end
                
                
            end
        end
        
        if strcmpi(conf.fa.fig.save,'yes') && ~strcmp(conf.fa.fig.tfr.peaksel.avgsub,'yes')
            savedir  = conf.dir.figsave;
            savename = [CurSub '-' CurHand '_' conf.fa.fig.savename{b}];
            if ~exist(savedir,'dir'); mkdir(savedir); end
            print(q,conf.fa.fig.saveext,conf.fa.fig.saveres,fullfile(savedir,savename))
            fprintf('%s\n',['Saved figure to ' fullfile(savedir,savename)])
        end
         
    end
    
end

% --- Now create average figure if this was the plan all along --- %
disp('If you want to save figures as eps: (1) use matlab2015a (2) set custom renderer after first subplot (3) set custom renderer after second subplot (4) save before exiting script')
keyboard
disp(['- Used protected band of ' num2str(PB) ' Hz'])

if strcmp(conf.fa.fig.tfr.peaksel.avgsub,'yes')

    CurSub        = 'avgsub';
    sel           = cellfun(@isempty,peakstorage(:,1));
    peakstorage   = peakstorage(~sel,:);
    
    CurPlot   =  conf.fa.fig.plot{b};
    [row,col] =  size(CurPlot);
    channels  =  {'ACC';'EDC&FCR'};
    arbitrary_idx = [1 2];
%     cntC      =  1;
%     cntR      =  1;
%     cnt		  =  1;    
    q = figure;
    keyboard
    for c = 1:(row*col)
        
        % --- Read Current Data --- %
        
        CurFields   =   CurPlot{c};
        CurDat      =   peakstorage(:,arbitrary_idx(c));
        minT        =   min(cellfun(@(x) length(x),CurDat));
        maxT        =   max(cellfun(@(x) length(x),CurDat));
        
        timewin     =   [5*512 50*512];     % Because posh starts 10 before onset and we want -5 until 30 relative to onset;
        if minT<timewin(2)
            timewin(2) = minT;
        end
        time        =   ( timewin(1):1:timewin(2) ) / 512;
        CurDat      =   cellfun(@(x) x(:,timewin(1):timewin(2)),CurDat,'uniformoutput',0);
        
        AvgDat      =   mean(cell2mat(CurDat));
        StdDat      =   std(cell2mat(CurDat));
        SemDat      =   StdDat/sqrt(nSub);
        
        % -- Create error patch --- %
        
%         xvector     =   1:1:length(AvgDat);
%         x           =   [xvector fliplr(xvector)];
        x           =   [time fliplr(time)];
        y           =   [AvgDat+SemDat fliplr(AvgDat-SemDat)];
        
        % --- And plot the bitches --- %
        
        keyboard
        subplot(row,col,c)
        hpatch = patch(x,y,'b');
        hold on
%         set(hpatch,'EdgeColor','b','FaceColor',[0.7294    0.8314    0.9569]);
        set(hpatch,'EdgeColor','b','FaceColor',[0.85    0.85    0.85]);
%         set(hpatch,'EdgeColor','k','FaceColor',[0.85    0.85    0.85]);
        plot(time,AvgDat,'color','b','linewidth',2);
        
        title(['TFR AvgSub-' CurFields{1} ' ' CurFields{2} ' ' channels{c}])
        xlabel('Time (s)');ylabel('Power (ln(uV^2))')
        set(gca,'xtick',5:1:50,'xticklabel',-5:1:40)
        pf_verline(10,'linewidth',2,'color','r')
        axis square
        
%         cntC = cntC+1;
%         cnt	 = cnt+1;
%         keyboard
%         if ~mod(c,col)
%             cntC = 1;
%             cntR = cntR + 1;
%         end
        
    end
    
    if strcmpi(conf.fa.fig.save,'yes')
        savedir  = conf.dir.figsave;
        savename = ['AvgSub_' conf.fa.fig.savename{b}];
        if ~exist(savedir,'dir'); mkdir(savedir); end
        print(q,conf.fa.fig.saveext,conf.fa.fig.saveres,fullfile(savedir,savename))
        fprintf('%s\n',['Saved figure to ' fullfile(savedir,savename)])
    end
    
    
end

end

%==========================================================================
