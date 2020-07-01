function pf_pmg_plot_powspct(conf,data_freq,uSub)
% 
% pf_pmg_plot is a function to plot powerspectra data calculated with
% pf_pmg_freqana. Use the configuration structure (conf.fa.fig) to specify
% how you want to plot it. You can specify the following functions:
%       - conf.fa.fig.plot: cell structure containing MxN cells indicating
%                           the subplots of this figure. Use {1},{2}...{n}
%                           to specify multiple figures.
%       - conf.fa.fig.ax: option to define the Y-limits of your plots.
%                         leave '' for default, for other options see
%                         pf_adjustax
%       - conf.fa.fig.col: string defining color spectrum you want to use 
%                          (e.g. 'hsv', 'hot' etc.)
%       - conf.fa.fig.intersel: options for interactively selecting data
%                               from the plot (see pf_pmg_seltremorUI).
%                               Specify intersel.exe as 'yes' and
%                               intersel.filename as the filename for you
%                               savings.
%       - conf.fa.fig.save: specify 'yes' if you want to save the figure
%       - conf.fa.fig.savename: specify a cell containing strings for your 
%                               figure(s)
%       - conf.fa.fig.saveext: extension of the saved figure, (see print)
%       - conf.fa.fig.saveres: resolution of the saved figure (see print)
%

% NB: this function has been replaced for pf_pmg_plot_powspct2! 

% © Michiel Dirkx, 2014
% $ParkFunC

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nF        =   length(uSub);
Hands     =   nan(nF,1);
cntAVG    =   1;      % Counter for averaging
pflag     =   0;      % plot flag
intersel  =   [];      

%--------------------------------------------------------------------------

%% Plotting
%--------------------------------------------------------------------------

for a = 1:nF
    
    CurSub   =   uSub{a};
    CurHand  =   conf.sub.hand{strcmp(conf.sub.name,CurSub)};
    
    if strcmp(CurHand,'L')
        Hands(a) =   0;
    elseif strcmp(CurHand,'R')
        Hands(a) =   1;
    end
    
    CurData  =   data_freq.(CurSub);
    
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
        
        if ~strcmp(conf.fa.fig.avg,'yes')
            q = figure;
        end
        
        % --- For Every Subplot --- %
        
        for c = 1:(row*col)
            
            % --- Read Current Data --- %
            
            CurFields   =   CurPlot{cntR,cntC};
            
            % --- Select data depending on fields --- %
            
            nSp         =   length(CurFields);
            CurDat      =   CurData;
            tit         =   [CurSub '_' CurHand];
            
            for d = 1:nSp;
                CurDat  =   CurDat.(CurFields{d});
                tit     =   [tit '-' CurFields{d}];
            end
            
            if strcmp(CurDat.cfg.method,'mtmconvol')
                CurDat.power     =   CurDat.powspctrm;
                CurDat.powspctrm =   nanmean(CurDat.powspctrm,3);
            end
            
            % --- Select Channels --- %
            
            if ~strcmpi(conf.fa.fig.chan,'all')
                sel              = pf_strcmp(CurDat.label,conf.fa.fig.chan);
                CurDat.label     = CurDat.label(sel);
                CurDat.powspctrm = CurDat.powspctrm(sel,:);
            else
                H =  strfind(CurDat.label,'EDF Annotations');
                if ~isempty([H{:}])
                    idx = find(cellfun(@isempty,H)==1);
                    CurDat.label = CurDat.label(idx);
                    CurDat.powspctrm = CurDat.powspctrm(idx,:);
                end
            end
%             keyboard
            chnames = pf_pmg_channame(CurDat.label,conf.ft.chans);
%             chnames = CurDat.label;

            % --- Plot Data --- %
            
            if ~strcmp(conf.fa.fig.avg,'yes')
                
                hh(cntR,cntC) = subplot(row,col,c);
                nChan         =	length(CurDat.label);
                colo          =	eval([conf.fa.fig.col '(nChan)']);
                pflag         = 1;
                
                clear h
                for i = 1:nChan
                    h(i)	= plot(CurDat.freq,CurDat.powspctrm(i,:),'col',colo(i,:));
                    hold on
                end
                
                set(gca,'Xtick',unique(round(CurDat.freq)),'Xticklabel',unique(round(CurDat.freq)))
                title(tit,'fontweight','b','fontsize',11,'interpreter','none');
                xlabel('Frequency (Hz)','fontweight','b')
                ylabel('Power (uV^2)','fontweight','b')
                legend(h,chnames,'Location','NorthEast')
                legend('boxoff')
                xlim([CurDat.freq(1)-0.25 CurDat.freq(end)+0.25])
                whitebg(conf.fa.fig.backcol);
                
                if strcmp(conf.fa.fig.reportcorr,'yes')
                   keyboard 
                end
                
            end
            
            % --- Store figure data --- %
            
            figPS{cntR,cntC}   =   CurDat.powspctrm;    % Store figure data
            figF{cntR,cntC}    =   CurDat.freq;
            tits{cntR,cntC}    =   tit;
            chans{cntR,cntC}   =   chnames;
            
            if isfield(CurDat,'power')
                figP{cntR,cntC} =  CurDat.power;
            end
            
            % --- Prepare for next round --- %
            
            cntC = cntC+1;
            cnt	 = cnt+1;
            
            if c == col
                cntC = 1;
                cntR = cntR + 1;
            end
        end
        
        % --- Store everything for averaging --- %
        
        if strcmp(conf.fa.fig.avg,'yes')
            chansA{cntAVG,b} = chans;
            figPSA{cntAVG,b} = figPS;
            figPA{cntAVG,b} = figP;
            figFA{cntAVG,b} = figF;
            if b==nPlot
                cntAVG = cntAVG+1;
            end
        end
        
        % --- Additional Figure Adjustments --- %
        
        if ~strcmp(conf.fa.fig.avg,'yes')
            pf_adjustax(hh,conf.fa.fig.ax)
        end
        
        % --- Interactively select channel/frequence if desired --- %
        
        %[Sub Session Condition Channel Type Frequency Power PowerSTD PowerCOV]
        
        if strcmpi(conf.fa.fig.peaksel.onoff,'on')
            
            is      = pf_pmg_seltremorUI(hh,tits,chans,figPS,figP,figF,CurHand,conf.ft.chans(:,2),conf.fa.fig.peaksel.meth);
            is      = [repmat(str2double(CurSub(2:end)),size(is,1),1) is];            
            
            % --- Select data needed if sel is auto --- %
            
            subcode =   CurSub(2:end);
            
            % --- Store the data --- %
            
            intersel = vertcat(intersel,is);
            
            % --- Save after every figure --- %
            savedir  = conf.dir.datsave;
            if ~exist(savedir,'dir'); mkdir(savedir); end
            save(fullfile(savedir,conf.fa.fig.peaksel.savefile),'intersel')
            fprintf('%s\n',['Saved data to ' fullfile(savedir,conf.fa.fig.peaksel.savefile)])
        end
        
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
end
    
    
%--------------------------------------------------------------------------

%% Average if specified
%--------------------------------------------------------------------------

Hands   =   logical(Hands);
nPlot   =   length(conf.fa.fig.plot);

if ~isempty(conf.fa.fig.plotcombi)
    nPlot = size(conf.fa.fig.plotcombi,1);
end

if strcmp(conf.fa.fig.avg,'yes')
    
    for a = 1:nPlot
        
        CurNan    = isnan(conf.fa.fig.plotcombi(a,:));
        CurIdx    = conf.fa.fig.plotcombi(a,~CurNan);
        
        CurPlots  = conf.fa.fig.plot(CurIdx);
        nPlots    = length(CurPlots);
        colo      =	eval([conf.fa.fig.col '(2*nPlots)']);
        cntcol    =  1;
        
        q   =   figure;
        
        for b = 1:nPlots
            
            CurPlot   = CurPlots{b};
            [row,col] = size(CurPlot);
            
            cntC      =  1;
            cntR      =  1;
            cnt		  =  1;
            
            %=============sel==========%
            CurChans    =   chansA(:,CurIdx(b));
            CurPS       =   figPSA(:,CurIdx(b));
            CurP        =   figPA(:,CurIdx(b));
            CurF        =   figFA(:,CurIdx(b));
            %==========================%
            
            coll       = colo(cntcol:cntcol+1,:);
            
            for c = 1:(row*col)
                
                % --- Prepare current subplot --- %
                
                CurFields   =   CurPlot{cntR,cntC};
                nSp         =   length(CurFields);
                tit         =   'Allsub';
                
                for d = 1:nSp
                    tit     =   [tit '-' CurFields{d}];
                end
                
                leg{c,cntcol}   = [tit ' Most-Affected'];
                leg{c,cntcol+1} = [tit ' Least-Affected'];
                
                % --- Read channels for subplot --- %
                
                spChans =   CurChans{1}{cntR,cntC};
                spPS    =   cellfun(@(x) x{cntR,cntC},CurPS,'uniformoutput',0);
                spP     =   cellfun(@(x) x{cntR,cntC,:},CurP,'uniformoutput',0);
                spF     =   mean(cell2mat(cellfun(@(x) x{cntR,cntC},CurF,'uniformoutput',0)));
                for d = 1:length(spChans)
                    % --- Get channel data --- %
                    spChan   =   spChans{d};
                    spps     =   cellfun(@(x) x(d,:),spPS,'uniformoutput',0);
                    spp      =   cellfun(@(x) x(d,:,:),spP,'uniformoutput',0);
                    % --- Squeeze and transpose power vectors --- %
                    spp      =   cellfun(@squeeze,spp,'uniformoutput',0);
                    spp      =   cellfun(@transpose,spp,'uniformoutput',0);  % powerXfreqeuncy
                    
                    if d == 1
                        MA   = cell2mat(spps(Hands));       % When right handed
                        MAp  = spp(Hands);
                        LA   = cell2mat(spps(~Hands));
                        LAp  = spp(~Hands);
                    elseif d == 2
                        MA  = [MA;cell2mat(spps(~Hands))];
                        MAp = [MAp;spp(~Hands)];
                        LA  = [LA;cell2mat(spps(Hands))];
                        LAp = [LAp;spp(Hands)];
                    end
                end
                
                % --- Retrieve STD of Powers --- %
                
                MAm    = cell2mat(cellfun(@nanmean,MAp,'uniformoutput',0));
                MAmm   = mean(MAm);
                MAmsd  = std(MAm);
                MAmcov = MAmsd./MAmm;
                MAmse   = MAmsd/sqrt(size(MAm,1));
                MAmci   = 1.96*MAmse;
                
                LAm    = cell2mat(cellfun(@nanmean,LAp,'uniformoutput',0));
                LAmm   = mean(LAm);
                LAmsd  = std(LAm);
                LAmcov = LAmsd./LAmm;
                LAmse   = LAmsd/sqrt(size(LAm,1));
                LAmci   = 1.96*LAmse;
                
                % --- Make error patch --- %
                
                MAx    = [spF fliplr(spF)];
                MAy    = [MAmm+MAmse fliplr(MAmm-MAmse)];
                LAx    = [spF fliplr(spF)];
                LAy    = [LAmm+LAmse fliplr(LAmm-LAmse)];
                
                % --- Plot --- %
                
                subplot(row,col,c)
                hpatch = patch(MAx,MAy,coll(1,:)); % the errorpatch
                set(hpatch,'EdgeColor','none'); % remove the edge
                set(hpatch,'FaceAlpha',0.5); % and change the
                hold on;
                hline(c,cntcol) = plot(spF,MAmm,'color',coll(1,:)); % central line
                
                hpatch = patch(LAx,LAy,coll(2,:)); % the errorpatch
                set(hpatch,'EdgeColor','none'); % remove the edge
                set(hpatch,'FaceAlpha',0.5); % and change the
                hline(c,cntcol+1) = plot(spF,LAmm,'color',coll(2,:)); % central line
                
                %--- Figure adjustments --- %
                if nPlots==b
                legend(hline(c,:),leg(c,:));
                legend('boxoff')
                end
                set(gca,'Xtick',spF(1:2:end),'Xticklabel',round(spF(1:2:end)))
                title(tit,'fontweight','b','fontsize',11,'interpreter','none');
                xlabel('Frequency (Hz)','fontweight','b')
                ylabel('Power (uV?)','fontweight','b')
                xlim([spF(1)-0.25 spF(end)+0.25])
                
                % --- Prepare for next round --- %
                
                cntC = cntC+1;
                cnt	 = cnt+1;
                
                if c == col
                    cntC = 1;
                    cntR = cntR + 1;
                end
            end
            
            cntcol = cntcol+2;
            
        end
        
        % --- Save figure if specified --- %
        
        if strcmpi(conf.fa.fig.save,'yes')
            savedir  = conf.dir.save.faplot;
            savename = ['AvgSub_' conf.fa.fig.savename{a}];
            if ~exist(savedir,'dir'); mkdir(savedir); end
            maxfig(q,1);
            print(q,conf.fa.fig.saveext,conf.fa.fig.saveres,fullfile(savedir,savename))
            fprintf('%s\n',['Saved figure to ' fullfile(savedir,savename)])
        end
        
    end
end

%==========================================================================
