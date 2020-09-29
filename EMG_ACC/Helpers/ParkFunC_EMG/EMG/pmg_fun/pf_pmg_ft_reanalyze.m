function pf_pmg_ft_reanalyze(conf,freqana)
% pf_pmg_ft_reanalyze(conf,Files) reanalyses data. That is, it uses a peak
% selection input (specified by the user) to reload that data and perform
% this peakselection on a frequency analysis dataset specfied in freqana.
% For this, it is necessary you have a 'freqana' dataset and a 'peaksel'
% dataset. The freqana dataset is leading, that is it will select all the
% peaks for the data in freqana thereby selecting data from peaksel. 
%
% Practical example: let's say you manually did a peak selection on a
% freqana dataset which was bandpass filtered at 2-40 Hz. Later on you
% decide that you should have taken a band-pass filter of 1-40 Hz. In this
% case, do the freqana again (specify in conf.ft.meth) for the required
% subjects, enter the input 'peaksel' file which indicates the manual peak
% selection you previously did and run this script again. You can choose to
% plot the figures or not.
%
% Part of pf_pmg_batch.m

% © Michiel Dirkx, 2015
% $ParkFunC, version 20150609

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

inp   =   load(conf.ft.reanalyze.input);
fn    =   fieldnames(inp);
inp   =   inp.(fn{1});

data_freq = freqana;
cnt   =   1;

%--------------------------------------------------------------------------

%% Loop
%--------------------------------------------------------------------------

Sub      =   unique(cellfun(@(x) x.sub,freqana,'uniformoutput',0));
nSub     =   length(Sub);

for a = 1:nSub
    
    clear CurDat
    
    CurSub    =   Sub{a};
    subcode   =   str2double(CurSub(2:end));
    
    sel       =   cellfun(@(x) strcmp(x.sub,CurSub),freqana);
    SubDat    =   freqana(sel);
    
    Sess       =   unique(cellfun(@(x) x.sess,SubDat,'uniformoutput',0));
    nSess      =   length(Sess);
    
    for b = 1:nSess
        
        CurSess   =   Sess{b};
        sesscode  =   pf_pmg_sesscode(CurSess);
        
        sel       =   cellfun(@(x) strcmp(x.sess,CurSess),SubDat);
        SessDat   =   SubDat(sel);
        
        Cond      =   unique(cellfun(@(x) x.cond,SessDat,'uniformoutput',0));
        nCond     =   length(Cond);
        
        h       =   figure;
        row     =   2;
        col     =   nCond/row;
        plotidx =   [1 3 5 2 4 6];
        
        for c = 1:nCond
            
            CurCond   =   Cond{c};
            condcode  =   pf_pmg_condcode(CurCond);
            
            sel       =   cellfun(@(x) strcmp(x.cond,CurCond),SessDat);
            CondDat   =   SessDat{sel};
        
            Chan      =   CondDat.label;
            nChan     =   length(Chan);
            
            colo    =   hsv(nChan);
            
            for d = 1:nChan
               
               CurChan  =   pf_pmg_channame(Chan(d),conf.ft.chans);
               chancode =   pf_pmg_chancode(CurChan);
               
               Chan{d}  =   CurChan{1};
         
               % --- Now we need the input to match the data --- %
               
               CurDat   =   CondDat;

               if strcmp(CurDat.cfg.method,'mtmconvol')
                    CurDat.power     =   CurDat.powspctrm;
                    CurDat.powspctrm =   nanmean(CurDat.powspctrm,3);
               end
               
               clear type
               sel    = inp(:,1) == subcode & inp(:,2) == sesscode & inp(:,3) == condcode & inp(:,4) == chancode; 
               type   = inp(sel,5);
               
               if isempty(type)
                   disp(['- Could not find selected peak for "' CurSub '-' CurSess ' ' CurCond ' ' CurChan{1} '". Skipping...'])
                   continue
               else
                   nType = length(type);
                   
                   subplot(row,col,c)
                   hh(d) = plot(CurDat.freq,CurDat.powspctrm(d,:),'color',colo(d,:));
                   hold on
                   for e = 1:nType
                       
                       typecode = type(e);
                       sel      = inp(:,1) == subcode & inp(:,2) == sesscode & inp(:,3) == condcode & inp(:,4) == chancode & inp(:,5) == typecode;
                       freqinp  = inp(sel,6);
                       if length(freqinp)>1
                           freqinp = freqinp(1);
                           disp('found multiple frequencies on selection');
                           keyboard
                       end
                       
                       iFreq    =   round(CurDat.freq*10)/10 == round(freqinp*10)/10;
                       freq     =   CurDat.freq(iFreq);
                       
                       % --- Ah, so know we know the idx of the powspctrm, lets plot --- %
                       
                       plot(freq,CurDat.powspctrm(d,iFreq),'*','MarkerSize',10);
                       text(freq,CurDat.powspctrm(d,iFreq),strcat('\leftarrow',num2str(freq),' Hz'),'FontSize',10)
                       
                       % --- And calculate additional items --- %
                       
                       power     =   CurDat.powspctrm(d,iFreq);
                       powerSTD  =   nanstd(CurDat.power(d,iFreq,:));
                       powerCOV  =   powerSTD/power;
                       powerMIN  =   min(CurDat.power(d,iFreq,:));
                       powerMAX  =   max(CurDat.power(d,iFreq,:));
                       powerNDAT =   size(CurDat.power,3);
                       
                       %================ And store everything ================%
                       %[subcode sesscode condcode chancode typecode freq power powerSTD powerCOV powerMIN powerMAX powerNDAT]
                       %[1           2       3         4       5       6    7      8        9        10       11         12  ]
                       peaksel(cnt,:)  =   [subcode sesscode condcode chancode typecode freq power powerSTD powerCOV powerMIN powerMAX powerNDAT];
                       %======================================================%
                       cnt = cnt+1;
                   end
               end
            end
            set(gca,'Xtick',unique(round(CurDat.freq)),'Xticklabel',unique(round(CurDat.freq)))
            title([CurSub '-' CurSess '-' CurCond],'fontweight','b','fontsize',11,'interpreter','none');
            xlabel('Frequency (Hz)','fontweight','b')
            ylabel('Power (uV^2)','fontweight','b')
            legend(hh,Chan,'Location','NorthEast')
            legend('boxoff')
            xlim([CurDat.freq(1)-0.25 CurDat.freq(end)+0.25])
        end
        
        % --- Save if specified --- %
        if strcmp(conf.ft.reanalyze.savefig,'yes')
            savedir = fullfile(conf.dir.figsave,conf.ft.reanalyze.savefigfolder);
            if ~exist(savedir,'dir'); mkdir(savedir); end
            
            savename = [CurSub '-' CurSess '_' conf.ft.reanalyze.savefigname];
            print(h,conf.fa.reanalyze.figext,conf.fa.reanalyze.figres,fullfile(savedir,savename));
            fprintf('%s\n',['- Printed figure to ' fullfile(savedir,savename)])
        end
    end
    
    if a == 20
        close all
    end
end

%--------------------------------------------------------------------------

%% Save peaksel
%--------------------------------------------------------------------------

if ~exist(conf.dir.datsave,'dir'); mkdir(conf.dir.datsave); end
savename = fullfile(conf.dir.datsave,conf.ft.reanalyze.savename);
save(savename,'peaksel');







