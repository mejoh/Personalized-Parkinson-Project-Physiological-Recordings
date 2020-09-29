function pf_pmg_plot_coh(conf,freqana,uSub)
% pf_pmg_plot_coh(conf,freqana,uSub) is part of the FieldTrip chapter,
% section plotting of the pf_pmg_batch. Specifically, it will perform a
% simple plot of the coherence analysis that has previously been performed
% with pf_pmg_ft_freqana.
%
% Part of pf_pmg_batch.m

% Michiel Dirkx, 2015
% $ParkFunC, version 20150620

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nF        =   length(uSub);
Hands     =   nan(nF,1);
pflag     =   0;      % plot fl    

iSub      =   cellfun(@(x) any(pf_strcmp(uSub,x.sub)),freqana);
freqana   =   freqana(iSub);
lim       =   'ylim';

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
        hh        =  nan(row,col);
     
        q = figure;
        
        % --- For Every Subplot --- %
        
        for c = 1:(row*col)
            
            % --- Read Current Data --- %
            
            CurFields   =   CurPlot{cntR,cntC};
            
            % --- Check if average or per subject --- %
            
            if strcmp(conf.fa.fig.avg.on,'yes')
               
               % --- Deal with handedness --- %
                
               selR = cellfun(@(x) strcmp(x.hand,'R') && strcmp(x.sess,CurFields{1}) && strcmp(x.cond,CurFields{2}),freqana);  
               if any(selR) 
                    sel{1}       =  selR;
               end
               selL = cellfun(@(x) strcmp(x.hand,'L') && strcmp(x.sess,CurFields{1}) && strcmp(x.cond,CurFields{2}),freqana);
               if any(selL)
                    sel{2}      =  selL;
                    chanconv    =  [3:9 1:2]; % NEW CHANNEL INDEX TO MATCH RIGHT HANDED SUBJECTS
%                     chanconv    = 1:9;
               end
               
               % --- Get average spectrum for channel subsets --- %
               
               for i = 1:length(sel)
                  AllDat       =  freqana(sel{i});
                  AllCoh       =  cellfun(@(x) x.cohana,AllDat);
                  
                  AllCohspctrm =  {AllCoh.cohspctrm};
                  if i>1
                      AllCohspctrm = cellfun(@(x) x(chanconv,:),AllCohspctrm,'uniformoutput',0);
                  end
               
                  nChan        =  size(AllDat{1}.cohana.labelcmb,1);
                  nFreq        =  length(AllCoh(1).freq);
                  CohSpctrm    =  nan(nChan,nFreq);
                  
                  for d = 1:nChan
                      AllChan            = cell2mat(cellfun(@(x) x(d,:),AllCohspctrm,'uniformoutput',0)');
                      
                      % --- Calculate and store average after i>1 --- %
                      
                      if i>1
                        CohSpctrm(d,:)       = mean(AllChan,1);
                        CohSpctrm_std(d,:)   = std(AllChan,1);
                        
                        storespctrm(d,:)     = mean([storespctrm(d,:);CohSpctrm(d,:)]);
                        storespctrm_std(d,:) = mean([storespctrm_std(d,:);CohSpctrm_std(d,:)]);
                      else
                        CohSpctrm(d,:)     = mean(AllChan,1);
                        CohSpctrm_std(d,:) = std(AllChan,1);
                      end
                  end
                  
                  if i==1 
                     storespctrm     = CohSpctrm;
                     storespctrm_std = CohSpctrm_std;
                     basechans       = AllCoh(1).labelcmb;
                  end
               end
               
               CurCoh                =  AllCoh(1);
               CurCoh.labelcmb       =  basechans;
               CurCoh.cohspctrm      =  storespctrm;
               CurCoh.cohspctrm_std  =  storespctrm_std;
               tit                   =  ['Coher: AvgSub' '_' AllDat{1}.sess ' ' AllDat{1}.cond];
            else
               sel         =   cellfun(@(x) strcmp(x.sub,CurSub) && strcmp(x.sess,CurFields{1}) && strcmp(x.cond,CurFields{2}),freqana);
               CurDat      =   freqana{sel};
               CurCoh      =   CurDat.cohana;
               tit         =   ['Coher: ' CurDat.sub '-' CurDat.hand '_' CurDat.sess ' ' CurDat.cond];
            end
         
            
            % --- Select Data Channels --- %
            
            iChan           =   pf_strcmp(CurCoh.labelcmb(:,1),conf.fa.fig.chan);
            chanlabels      =   CurCoh.labelcmb(iChan,:);                       % Original channel name
            chanlabels(:,1) =   pf_pmg_channame(chanlabels(:,1),conf.ft.chans); % Replace first column for trivial name
            chanlabels(:,2) =   pf_pmg_channame(chanlabels(:,2),conf.ft.chans); % Replace second column
            cohspctrm       =   CurCoh.cohspctrm(iChan,:);
            nChan           =   length(chanlabels);
            h               =   nan(nChan,1);
            
            % --- Plot Data --- %
            
            colo =   eval([conf.fa.fig.col '(nChan)']);
            
            hh(cntR,cntC) = subplot(row,col,c);
            
            if strcmp(conf.fa.fig.coh.graph,'plot')
            
                for d = 1:nChan
                    CurChan{d,1} = [chanlabels{d,1} ' vs ' chanlabels{d,2}];
                    CurData      = cohspctrm(d,:);
                    h(d)         = plot(CurCoh.freq,CurData,'color',colo(d,:));
                    hold on
                end
                
                set(gca,'Xtick',unique(round(CurCoh.freq)),'Xticklabel',unique(round(CurCoh.freq)))
                title(tit,'fontweight','b','fontsize',11,'interpreter','none');
                xlabel('Frequency (Hz)','fontweight','b')
                ylabel('Power (uV^2)','fontweight','b')
                legend(h,CurChan,'Location','BestOutside')
                legend('boxoff')
                if isempty(conf.fa.fig.xlim)
                    xlim([CurDat.freq(1)-0.25 CurDat.freq(end)+0.25])
                else
                    xlim(conf.fa.fig.xlim)
                end
                if ~isempty(conf.fa.fig.ylim)
                    ylim(conf.fa.fig.ylim)
                end
                whitebg(conf.fa.fig.backcol);
            
            elseif strcmp(conf.fa.fig.coh.graph,'contourf')
                
                h = contourf(cohspctrm);
                
                % --- Create recognizable xlabel --- %
                
                uFreq = unique(round(CurCoh.freq));
                for d = 1:length(uFreq)
                    iFreq      = find(round(CurCoh.freq)==uFreq(d));
                    xtik(d)    = iFreq(1);
                    xtiklab(d) = uFreq(d);
                end
                set(gca,'Xtick',xtik,'Xticklabel',xtiklab)
                
                % --- Create recognizable ylabel --- %
                
                for d = 1:length(chanlabels)
                    ytik(d)      = d;
                    if strcmp(chanlabels{d,1}(1),'R')
                        aff = 'MA';
                    else
                        aff = 'LA';
                    end
                    ytiklab{d,1} = [aff ': ' chanlabels{d,1}(3:end) ' vs ' chanlabels{d,2}(3:end)];
                end
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
                caxis([min(min(cohspctrm)) max(max(cohspctrm))])
                whitebg(conf.fa.fig.backcol);
                
%                 if c==(row*col)
                    colorbar
                    lim = 'clim';
%                 end
               
            end
            
            % --- Prepare for next round --- %
            
            cntC = cntC+1;
            cnt	 = cnt+1;
            
            if c == col
                cntC = 1;
                cntR = cntR + 1;
            end
        end
        
        % --- Additional Figure Adjustments --- %
        
        pf_adjustax(hh,conf.fa.fig.ax,lim)
        
        % --- Save Figure if specified --- %
        
        if strcmpi(conf.fa.fig.save,'yes') && pflag
            savedir  = conf.dir.figsave;
            savename = [CurSub '-' CurHand '_' conf.fa.fig.savename{b}];
            if ~exist(savedir,'dir'); mkdir(savedir); end
%             maxfig(q,1);
            print(q,conf.fa.fig.saveext,conf.fa.fig.saveres,fullfile(savedir,savename))
%             imwrite(q,fullfile(savedir,savename),'tiff')
            fprintf('%s\n',['Saved figure to ' fullfile(savedir,savename)])
        end 
    end
    
    if strcmp(conf.fa.fig.avg.on,'yes')
        break
    end
        
end
    
    
%--------------------------------------------------------------------------
