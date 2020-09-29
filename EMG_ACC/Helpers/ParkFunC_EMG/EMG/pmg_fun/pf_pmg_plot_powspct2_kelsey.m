function pf_pmg_plot_powspct2_kelsey(conf,freqana,uSub)
% pf_pmg_plot_powspct2(conf,freqana,uSub) is part of the FieldTrip chapter
% of the pf_pmg_batch. Specifically, it will plot frequency analyzed data
% (using FieldTrip) in a power spectrum. 
%
% This is the second version which was created after I adapted a new way to
% store the freqana data (cell rather than multi-level structure). This is
% especially more efficient when plotting averaged data. 
%
% This script now has become incredibly advanced, with many possible
% exceptions which makes it a very flexible script (i.e. you can
% plot/average data in many ways), however, also pretty hard to read/write.
%
% Part of pf_pmg_batch

% � Michiel Dirkx, 2015
% $ParkFunC, version 20150624
% Made suitable for the reemergent project of Kelsey, 20180915

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nF           =   length(uSub);

sub_freqana  =   cellfun(@(x) x.sub,freqana,'uniformoutput',0);
iSub         =   pf_strcmp(sub_freqana,uSub); % NB: if a subject was specified but is not present in the data structure than this will not be shown when averaged!!!!!!!
freqana      =   freqana(iSub);
breakflag    =   0;
interselflag =   0;
lim          =   'ylim';

% if strcmp(conf.fa.fig.avgcond.on,'yes')
    avgcond   =   conf.fa.fig.avgcond.which(:,1);
    nAvg      =   length(avgcond);
    condflags =   nan(nAvg,1);
% end
    
    
%--------------------------------------------------------------------------

%% Plotting
%--------------------------------------------------------------------------

for a = 1:nF
    
    CurSub   =   uSub{a};
    nPlot    =   length(conf.fa.fig.plot);
    
    % --- For every Figure --- %
    
    for b = 1:nPlot
        
        CurPlot   =  conf.fa.fig.plot{b};
        [row,col] =  size(CurPlot);
        
        cntC      =  1;
        cntR      =  1;
        cnt		  =  1;
        figPS     =  cell(row,col);
        figP      =  cell(row,col);
        figF      =  cell(row,col);
        tits      =  cell(row,col);
        chans     =  cell(row,col);
        hh        =  nan(row,col);
        
        q = figure;
        
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
                        CurCond =   CurField{2};
                    end
                    
                    % --- Average over subjects if applicable --- %
                    
                    if strcmp(conf.fa.fig.avg.on,'yes')
                        
                        % --- Deal with handedness --- %
                        
                        nHand    =   size(conf.fa.fig.avg.chancombi,1);
                        cnthand  =   1;
                        
                        for d = 1:nHand
                            
                            CurHand  =   conf.fa.fig.avg.chancombi{d,1};
                            sel      =   cellfun(@(x) strcmp(x.hand,CurHand) && strcmp(x.sess,CurField{1}) && strcmp(x.cond,CurCond),freqana);
                            
                            % --- Store and get right chanorder --- %
                            
                            if any(sel)
                                data              =   freqana(sel);
                                oldorder          =   data{1}.label;
                                neworder          =   conf.fa.fig.avg.chancombi{d,2}';
                                newidx            =   pf_find(oldorder,neworder);
                                
                                if strcmp(data{1}.cfg.method,'mtmconvol')
                                    if cnthand>1
                                        allpowspctrm    = vertcat(allpowspctrm,cellfun(@(x) x.powspctrm(newidx,:,:),data,'uniformoutput',0));
                                    else
                                        allpowspctrm    = cellfun(@(x) x.powspctrm(newidx,:,:),data,'uniformoutput',0);  % In which case you need the time dimension
                                        CurDat          = data{1};       % Example (template) dataset
                                    end
                                else
                                    if cnthand>1
                                        allpowspctrm    = vertcat(allpowspctrm,cellfun(@(x) x.powspctrm(newidx,:),data,'uniformoutput',0));
                                    else
                                        allpowspctrm    = cellfun(@(x) x.powspctrm(newidx,:),data,'uniformoutput',0);
                                        CurDat          = data{1};       % Example (template) dataset
                                    end
                                end
                                cnthand  =   cnthand+1;
                            end
                        end
                        
                        % --- Perform averaging --- %
                        
                        nChan        =  size(allpowspctrm{1},1);
                        nFreq        =  size(allpowspctrm{1},2);
                        
                        if strcmp(CurDat.cfg.method,'mtmconvol')
                            nTime    =  size(allpowspctrm{1},3);
                            mat      =  nan(nChan,nFreq,nTime);
                            for d = 1:nChan
                                mat                 = cell2mat(cellfun(@(x) x(d,:,:),allpowspctrm,'uniformoutput',0));
                                avgpowspctrm(d,:,:) = nanmean(mat,1);
                                stdpowspctrm(d,:,:) = nanstd(mat,1);
                            end
                        else
                            mat      =  nan(nChan,nFreq);
                            for d = 1:nChan
                                mat               = cell2mat(cellfun(@(x) x(d,:),allpowspctrm,'uniformoutput',0));
                                avgpowspctrm(d,:) = mean(mat,1);
                                stdpowspctrm(d,:) = std(mat,1);
                            end
                        end
                        
                        % --- Build CurDat --- %
                        
                        %                CurDat               = rmfield(CurDat,{'sub';'hand'});
                        CurDat.powspctrm     = avgpowspctrm;
                        CurDat.powspctrm_std = stdpowspctrm;
                        
                        
                    else % --- If not average --- %
                        sel         =   cellfun(@(x) strcmp(x.sub,CurSub) && strcmp(x.sess,CurField{1}) && strcmp(x.cond,CurCond),freqana);
                        if ~any(sel)
                            warning('powspct:sel',['File for "' CurSub '-' CurField{1} '-' CurCond '" could not be found']);
                            breakflag = 1;
                            continue
                        end
                        CurDat      =   freqana{sel};
                        
                        
                    end
                    
                    % --- Store for condition averaging --- %
                    
                    if storeflag && storecnt==1
                        storage      =   CurDat;
                        storage.cond =   CurField{2};
                        storecnt     =   storecnt+1;
                        if strcmp(CurDat.cfg.method,'mtmconvol')
                            storage.powspctrm = nanmean(storage.powspctrm,3);
                        end
                    elseif storeflag
                        if strcmp(CurDat.cfg.method,'mtmconvol')
                            CurDat.powspctrm                  =   nanmean(CurDat.powspctrm,3);
                        end   
                        storage.powspctrm(:,:,storecnt)   =   CurDat.powspctrm;
                        storecnt                          =   storecnt+1;                       
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
                    CurDat.powspctrm = mean(CurDat.powspctrm,3);
                    storeflag = 0;
                elseif strcmp(CurDat.cfg.method,'mtmconvol')
%                     disp('probably needs debugging'); keyboard;
                    CurDat.power     =   CurDat.powspctrm;
                    CurDat.powspctrm =   nanmean(CurDat.powspctrm,3);
                end
                
                % --- Select Data Channels --- %              
                
                [~,numI]     =   pf_strcmp(conf.fa.fig.chan{1},CurDat.label); % Get numerical index                
                chanlabels   =   CurDat.label(numI);                        % Original channel name, R/L selection
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
                    chanlabels      =   chanlabels(CurField{3});                 % Original channel name, plot selection
%                     chanlabels      =   pf_pmg_channame(chanlabels,conf.ft.chans); % Replace first column for trivial name
                end
                                
                powspctrm       =   CurDat.powspctrm(numI,:); % R/L selection
                if CurFields{3}(1) == 999 % If channel average
                    powspctrm       =   powspctrm(CurField{3}(2:end),:); % Plot selection
                    powspctrm       =   mean(powspctrm,1);               % mean of channels
                else
                    powspctrm       =   powspctrm(CurField{3},:); % Plot selection
                end
                nChan           =   length(chanlabels);
                h               =   nan(nChan,1);
                
                % --- Plot Data --- %
                
                colocnt =   colocnt+nChan;                       % Create unique colors depending on nDraw
                colo    =   distinguishable_colors(colocnt);
                
                hh(cntR,cntC) = subplot(row,col,c);
                
                if strcmp(conf.fa.fig.pow.graph,'plot')
                    
                    for d = 1:nChan
                        CurData      = powspctrm(d,:);
                        h(d)         = plot(CurDat.freq,CurData,'color',colo(coloCNT,:));
                        hold on
                        coloCNT      = coloCNT+1;
                    end
                    drawn = 1;  % To indicate something was plotted at least.
                    
                    % --- Change tit/chanlabels when more conditions in one plot --- %
                    
                    if nDraw>1 && ~firstlabel
                        if ~strcmp(conf.fa.fig.avg.on,'yes')
                            tit  =   ['PowSpct: ' CurDat.sub '-' CurDat.sess ' ' CurDat.cond];
                        else
                            tit  =   ['PowSpct: AvgSub_' CurDat.sess ' ' CurDat.cond];
                        end
                        lab  =   pf_horzcatcell(chanlabels,[' ' CurDat.cond]);
                        hcf  =   h;
                        legend(hcf,lab,'interpreter','none');
                        legend('boxoff')
                        firstlabel = 1;
                    elseif nDraw>1 && firstlabel
                        tit  =   [tit 'vs' CurDat.cond];
                        hcf  =   vertcat(hcf,h);
                        
                        labb =   pf_horzcatcell(chanlabels,[' ' CurDat.cond]);
                        lab  =   vertcat(lab,labb);
                        legend(hcf,lab,'interpreter','none');
                        legend('boxoff')
                    elseif nDraw==1
                        if ~strcmp(conf.fa.fig.avg.on,'yes')
                            tit  =   ['PowSpct: ' CurDat.sub '-' CurDat.sess ' ' CurDat.cond];
                        else
                            tit  =   ['PowSpct: AvgSub_' CurDat.sess ' ' CurDat.cond];
                        end
                        legend(h,chanlabels,'interpreter','none')
                        legend('boxoff')
                        lab         =  chanlabels;
                    end
                    
                    % --- Set all the graphics --- %
                    
                    set(gca,'Xtick',unique(round(CurDat.freq)),'Xticklabel',unique(round(CurDat.freq)))
                    title(tit,'fontweight','b','fontsize',11,'interpreter','none');
                    xlabel('Frequency (Hz)','fontweight','b')
                    ylabel('Power (uV^2)','fontweight','b')
                    if isempty(conf.fa.fig.xlim)
                        xlim([CurDat.freq(1)-0.25 CurDat.freq(end)+0.25])
                    else
                        xlim(conf.fa.fig.xlim)
                    end
                    if ~isempty(conf.fa.fig.ylim)
                        ylim(conf.fa.fig.ylim)
                    end
                    whitebg(conf.fa.fig.backcol);
                    
                    % --- Store figure data --- %
                    
                    if ~firstlabel % If this is the first draw of the subplot 
                        figPS{cntR,cntC}   =   powspctrm;    % Store figure data
                    else           % If there was a draw before
                        figPS{cntR,cntC}   =   vertcat(figPS{cntR,cntC},powspctrm);    % Store figure data
                    end
                    figF{cntR,cntC}    =   CurDat.freq;
                    tits{cntR,cntC}    =   tit;
                    chans{cntR,cntC}   =   lab;
                    
%                     if isfield(CurDat,'power')
%                         disp('debug me'); keyboard;
%                         % This probably needs to be implemented in the same
%                         % way the powspctrm (see above) was implemented.
%                         figP{cntR,cntC} =  CurDat.power;
%                         if ~firstlabel % If this is the first draw of the subplot 
%                             figPS{cntR,cntC}   =   powspctrm;    % Store figure data
%                         else           % If there was a draw before
%                             figPS{cntR,cntC}   =   vertcat(figPS{cntR,cntC},powspctrm);    % Store figure data
%                         end
%                     end
                    
                elseif strcmp(conf.fa.fig.pow.graph,'contourf')
                    
                    contourf(powspctrm);
                    
                    % --- Create recognizable xlabel --- %
                    
                    uFreq = unique(round(CurDat.freq));
                    for d = 1:length(uFreq)
                        iFreq      = find(round(CurDat.freq)==uFreq(d));
                        xtik(d)    = iFreq(1);
                        xtiklab(d) = uFreq(d);
                    end
                    set(gca,'Xtick',xtik,'Xticklabel',xtiklab)
                    
                    % --- Create recognizable ylabel --- %
                    
                    ytik    = 1:1:length(chanlabels);
                    ytiklab = chanlabels;
                    set(gca,'Ytick',ytik,'Yticklabel',ytiklab);
                    
                    % --- Set X and Y axes if specified --- %
                    
                    if ~isempty(conf.fa.fig.xlim)
                        xlim(xtik(conf.fa.fig.xlim))
                    end
                    if ~isempty(conf.fa.fig.ylim)
                        ylim(ytik(conf.fa.fig.ylim))
                    end
                    
                    % --- Rest of graphics --- %
                    
                    title(tit,'fontweight','b','fontsize',11,'interpreter','none');
                    xlabel('Frequency (Hz)','fontweight','b')
                    caxis([min(min(powspctrm)) max(max(powspctrm))]); % NB: make a caxis adjustment for pf_adjustax
                    whitebg(conf.fa.fig.backcol);
                    
                    if c==(row*col)
                        colorbar
                        lim = 'clim';
                    end
                    
                end
                cfcnt   =   cfcnt+3;
            end
            
            % --- Prepare for next round --- %
            
            cntC = cntC+1;
            cnt	 = cnt+1;
            
            if ~mod(c,col)
                cntC = 1;
                cntR = cntR + 1;
            end
        end
        
        % --- If this loop wasn't skipped --- %
        
        if drawn
            
            % --- Additional Figure Adjustments --- %
            
            pf_adjustax(hh,conf.fa.fig.ax,lim)
            
            % --- Peak selection --- %
            keyboard
            if strcmp(conf.fa.fig.pow.peaksel.onoff,'on') && ~strcmp(conf.fa.fig.pow.graph,'contourf')
               is      = pf_pmg_seltremorUI_kelsey(hh,tits,chans,figPS,figP,figF,conf.ft.chans(:,2),conf.fa.fig.pow.peaksel.peakdef,conf.fa.fig.pow.peaksel.mancheck);
               is      = [repmat(str2double(CurSub),size(is,1),1) is]; % Add subject number
               
               % --- Select data needed if sel is auto --- %
               
               subcode =   CurSub;
               
               % --- Store the data --- %
               
               if ~interselflag 
                  intersel = is; 
                  interselflag = 1;
               else
                  intersel = vertcat(intersel,is);
               end
               
               % --- Save after every figure --- %
               savedir  = conf.dir.datsave;
               if ~exist(savedir,'dir'); mkdir(savedir); end
               save(fullfile(savedir,conf.fa.fig.peaksel.savefile),'intersel')
               fprintf('%s\n',['Saved data to ' fullfile(savedir,conf.fa.fig.peaksel.savefile)])
               
            end
            
            % --- Save Figure if specified --- %
            
            if strcmpi(conf.fa.fig.save,'yes')
                savedir  = conf.dir.figsave;
                savename = [CurSub '_' conf.fa.fig.savename{b}];
                if ~exist(savedir,'dir'); mkdir(savedir); end
                print(q,conf.fa.fig.saveext,conf.fa.fig.saveres,fullfile(savedir,savename))
                fprintf('%s\n',['Saved figure to ' fullfile(savedir,savename)])
            end
            
        end
        breakflag = 0;
    end
    
    if strcmp(conf.fa.fig.avg.on,'yes')
        break
    end
        
end
    
    
%--------------------------------------------------------------------------
