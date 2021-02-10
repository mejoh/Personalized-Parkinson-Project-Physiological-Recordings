function pf_emg_raw2regr_mkregr(conf)
% pf_emg_raw2regr_mkregr(conf) is part of the pf_emg_raw2regr function.
% Specifically, it is the last part of the pipeline and thus it will create
% a regressor suitable for your GLM in fMRI. To this extent, it needs data 
% from the 'prepemg' part of pf_emg_raw2regr. This function is usually
% called upon by the GUI: pf_emg_raw2regr_mkregressor_gui. Alternatively,
% when reanalyzing data it can be called upon from the main script:
% pf_emg_raw2regr.
% 
% See also pf_emg_raw2regr.

% � Michiel Dirkx, 2015
% $ParkFunC
% Updated: 20181103

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

if isfield(conf.mkregr,'data') % If the gui was not used
    conf.sub.name   =   {conf.mkregr.data.sub};
    conf.sub.sess   =   {conf.mkregr.data.sess};
    conf.sub.run    =   {conf.mkregr.data.run}; 
end

nSub    =   length(conf.sub.name);
nSess   =   length(conf.sub.sess);
nRun    =   length(conf.sub.run);
nMeth   =   length(conf.mkregr.meth);

Files   =   cell(nSub*nSess*nRun,1);
cnt     =   1;
add     =   0;

%--------------------------------------------------------------------------

%% Retrieve all fullfiles
%--------------------------------------------------------------------------

fprintf('%s\n\n','1) Retrieving all file information')

for a = 1:nSub
    CurSub  =   conf.sub.name{a};
    for b = 1:nSess
        CurSess =   conf.sub.sess{b};
        for c = 1:nRun
            CurRun =   conf.sub.run{c};
            
            if ~isfield(conf.mkregr,'data') % If the gui was not used
                file   =   pf_findfile(conf.dir.prepemg,conf.mkregr.file,'conf',conf,'CurSub',a,'CurSess',b,'CurRun',c,'msgM',0);
            else
                file   =   'GUI_dataset';
            end
            
            if strcmp(conf.mkregr.nscan,'detect')
                for d = 1:length(conf.dir.fmri.preproc)
                    sc  =   conf.dir.fmri.preproc{d};
                    switch sc
                        case 'CurSub'
                            sc  =   CurSub;
                        case 'CurSess'
                            sc  =   CurSess;
                        case 'CurRun'
                            sc  =   CurRun;
                    end
                    if d == 1
                        scandir =   pf_findfile(conf.dir.fmri.root,sc,'fullfile');
                    else
                        scandir =   pf_findfile(scandir,sc,'fullfile');
                    end
                end
                nScan   =   length(pf_findfile(scandir,conf.mkregr.scanname));
            else
                nScan   =   conf.mkregr.nscan;
            end
                        
                %==========Files==========%
                if iscell(file)
                    for d = 1:length(file)
                        Files{cnt,1}.dat   =   fullfile(conf.dir.prepemg,file{d});
                        Files{cnt,1}.sub   =   CurSub;
                        Files{cnt,1}.sess  =   CurSess;
                        Files{cnt,1}.run   =   CurRun;
                        Files{cnt,1}.code  =   [a;b;c];
                        Files{cnt,1}.nscan =   nScan;
                        fprintf('%s\n',['- Added ' file{d}])
                        cnt     =   cnt+1;
                    end
                else
                    Files{cnt,1}.dat   =   fullfile(conf.dir.prepemg,file);
                    Files{cnt,1}.sub   =   CurSub;
                    Files{cnt,1}.sess  =   CurSess;
                    Files{cnt,1}.run   =   CurRun;
                    Files{cnt,1}.code  =   [a;b;c];
                    Files{cnt,1}.nscan =   nScan;
                    fprintf('%s\n',['- Added ' file])
                    cnt     =   cnt+1;
                end                
                %=========================%
        end
    end
end

nFiles  =   length(Files);

if strcmp(conf.mkregr.zscore,'yes')
    savedir =    fullfile(conf.dir.regr,'ZSCORED');
else
    savedir =    fullfile(conf.dir.regr,'NOTZSCORED');
end

if ~exist(savedir,'dir'); mkdir(savedir); end

%--------------------------------------------------------------------------

%% Create regressors
%--------------------------------------------------------------------------

fprintf('\n%s\n\n','% --- Creating regressor(s) --- %')

for a = 1:nFiles
    
    % --- Load current fileset --- %
    
    CurFile  =   Files{a};
    CurSub   =   CurFile.sub;
    CurSess  =   CurFile.sess;
    CurRun   =   CurFile.run;
    CurScans =   CurFile.nscan;
    
    if ~isfield(conf.mkregr,'data') % If the gui was not used
        dat     =   load(CurFile.dat);
        fn      =   fieldnames(dat);
        dat     =   dat.(fn{1});
        if strcmp(conf.mkregr.reanalyze,'yes')
            if strcmp(conf.mkregr.reanalyzemeth,'regressor')
                namefile    =   pf_findfile(conf.dir.reanalyze.orig,['/' CurSub '/&/' CurSess '/&/' CurRun '/&/acc_/&/log.mat/']); % when based on regressors
                namesep     =   strfind(namefile,'_');
                sjannel     =   namefile(namesep(1)+1:namesep(2)-1);
                if strcmp(sjannel,'ACC')
                    sjannel     =   namefile(namesep(1)+1:namesep(3)-1);
                    cntns       =   1;
                else
                    cntns       =   0;
                end
                sjansel     =   cellfun(@any,strfind(dat.label,sjannel));
                dat.label   =   dat.label(sjansel);
                
                frek        =   namefile(namesep(2+cntns)+1:namesep(3+cntns)-1);
                frek1       =   str2double([frek(1) '.' frek(3)]);
                frek1I      =   pf_closestto(dat.freq,frek1);
                frek2       =   str2double([frek(5) '.' frek(7)]);
                frek2I      =   pf_closestto(dat.freq,frek2);
            elseif strcmp(conf.mkregr.reanalyzemeth,'ps_save')
                
                namefile    =   pf_findfile(conf.dir.reanalyze.orig,['/' CurSub '/&/' CurSess '/&/' CurRun '/&/ps-save/'],'fullfile'); %when based on PS_save 
                rean        =   load(namefile);
                frek1       =   rean.data.freq; %Protected bandwidth of 1 Hz (broadband)
                frek1I      =   pf_closestto(dat.freq,frek1);
                frek2       =   rean.data.freq; %Protected bandwidth of 1 Hz (broadband)
                frek2I      =   pf_closestto(dat.freq,frek2);
                
                sjansel     =   cellfun(@any,strfind(dat.label,rean.data.chan));
                dat.label   =   dat.label(sjansel);
                
            end
            
            dat.freq    =   dat.freq(frek1I:frek2I);
            dat.powspctrm = dat.powspctrm(sjansel,frek1I:frek2I,:);
            dat.powspctrm = squeeze(mean(dat.powspctrm,2));
            
            CurFreqstr = [num2str(frek1) '-' num2str(frek2)];
            nFreq      = 1;
        elseif strcmp(conf.mkregr.automatic,'yes')    
            % define peak frequency and channel 
            tosearch.powspctrm = dat.powspctrm(conf.mkregr.automaticchans,find(dat.freq>conf.mkregr.automaticfreqwin(1) & dat.freq<conf.mkregr.automaticfreqwin(2)),:);
            tosearch.freq = dat.freq(dat.freq>conf.mkregr.automaticfreqwin(1) & dat.freq < conf.mkregr.automaticfreqwin(2));
            orig.freq = dat.freq;
            mean_powspctrm =   nanmean(tosearch.powspctrm,3);
            [r,c] = find(mean_powspctrm == max(mean_powspctrm(:)));

            %plot powerspectrum for visual checking
            figure('units','normalized','outerposition',[0 0 1 0.5]);
            subplot(1,4,1)
            hold on
            for i=1:length(conf.mkregr.automaticchans)
            plot(tosearch.freq,nanmean(squeeze(tosearch.powspctrm(i,:,:)),2))
            end
            plot(tosearch.freq(c),max(mean_powspctrm(:)),'or','LineWidth',5 )
            hold off
            legend(dat.label(conf.mkregr.automaticchans))
            ylabel('Power');xlabel('Frequency');

            subplot(1,4,2:4)
            imagesc(dat.time/conf.prepemg.tr,dat.freq,squeeze(dat.powspctrm(conf.mkregr.automaticchans(r),:,:)));
            caxis([0 max(mean_powspctrm(:))*1.5]); %adjust colorscale to 1.5 * max power in average powerspectrum
            ax = gca; ax.YDir = 'normal'; % change y-axis increasing bottom to top
            ylabel('Frequency (Hz)');xlabel('Time (scans)');
            colorbar;
                      
            savename = [CurSub '-' CurSess '-' CurRun '-selected-' dat.label{conf.mkregr.automaticchans(r)}];
            suptitle(savename);
            if ~exist(conf.mkregr.automaticdir,'dir'); mkdir(conf.mkregr.automaticdir);end
            saveas(gcf,fullfile(conf.mkregr.automaticdir,savename),'jpg');

            % select corresponding powerpectrum info
            dat.label = dat.label(conf.mkregr.automaticchans(r));
            nFreq = 1;
            dat.freq = dat.freq(find(dat.freq == tosearch.freq(c)));
            dat.freqlab = num2str(dat.freq);
            CurFreqstr= dat.freqlab;
            dat.powspctrm = squeeze(dat.powspctrm(conf.mkregr.automaticchans(r),find(orig.freq == tosearch.freq(c)),:));

        else
            nFreq      = length(dat.freq);
        end

        
    else
        dat =   conf.mkregr.data;
        CurFreqstr= dat.freqlab;
        nFreq   =   1;
    end
    
    CurChan =   dat.label{1};
    
    for i = 1:nFreq
        
        dummy   =   dat.startscan_sca-dat.prestart_sca;                     % Extra pre-data before the start of scans (dummy scans excluded)
        
        fprintf('%s\n',['Working on ' CurSub '-' CurSess '-' CurRun ' ' CurChan ' (' CurFreqstr ' Hz)' ])
        
        % --- Get Current data --- %
        
        lastscan    =   dat.startscan_sca+CurScans-1;                       % Based on the amount of dummyscans and scans found in the folder
        scansel     =   dat.scanid>=dat.prestart_sca & ( dat.scanid<=lastscan | dat.scanid==999 );   % Choose only the scans of conf.prepemg.dummy+1-prestart:lastscan + extratime (code 999), the prestart will be removed after convolution (in pf_emg_hrfregr)

        if isfield(dat,'freqI')     % Backwards compatibility
            rawregr     =   squeeze(dat.powspctrm(dat.chanI,dat.freqI,scansel));
        else
            if strcmp(dat.meth,'broadband')
                rawregr     =   dat.powspctrm(dat.chanI,scansel)';
            else
                if size(dat.powspctrm,1) == nFreq
                    rawregr     =   dat.powspctrm(i,scansel)';
                else
                    rawregr     =   dat.powspctrm(scansel,i);
                end
            end
        end
        
        rawscanid   =   dat.scanid(scansel);
        rawtime     =   dat.time(scansel);
        
        rawr        =   [rawregr rawscanid rawtime'];
        
        % --- Get rid of nans --- %
        
        iNan = isnan(rawr(:,1));
        if iNan(1)==1; error('The first value is a nan, the script cant handle this'); end
        
        rawr        =   rawr(~iNan,:);
        
        % --- Retrieve conditions if desired --- %
        
        if strcmp(conf.mkregr.plotcond,'yes')
            evefile             =   pf_findfile(conf.dir.event,conf.mkregr.evefile,'conf',conf,'CurSub',CurFile.code(1),'CurSess',CurFile.code(2),'CurRun',CurFile.code(3),'fullfile');
            [onset,offset,~]    =   pf_fmri_creacond(evefile,dat.startscan_sca-1,conf.mkregr.mrk,dat.fs,dat.mtr);
        end
        
        % --- Make all types of regressors --- %
        
        for  b = 1:nMeth
            
            CurMeth =   conf.mkregr.meth{b};
            
            switch CurMeth
                case  'power'
                    rin                   =   rawr;
                    rin                   =   pf_zscore(conf,rin,CurMeth);
                    [R,names,r_origres]   =   pf_emg_hrfregr(conf,rin,dat.tr,dummy,CurScans,dat.startscan_sca-1);
                case  'amplitude'
                    rin                   =   rawr;
                    rin(:,1)              =   sqrt(rin(:,1));
                    rin                   =   pf_zscore(conf,rin,CurMeth);
                    [R,names,r_origres]   =   pf_emg_hrfregr(conf,rin,dat.tr,dummy,CurScans,dat.startscan_sca-1);
                case  'log'
                    rin                   =   rawr;
                    rin(:,1)              =   log10(rin(:,1));
                    rin                   =   pf_zscore(conf,rin,CurMeth);
                    [R,names,r_origres]   =   pf_emg_hrfregr(conf,rin,dat.tr,dummy,CurScans,dat.startscan_sca-1);
            end
            
            % --- Plot the regressors --- %
            
            figure('units','normalized','outerposition',[0 0 1 1])
            if strcmp(conf.mkregr.plotscanlines,'yes')
                subplot(3,1,1)
                add = 1;
                uScan   =   unique(r_origres(:,2));
                nScan   =   length(uScan);
                plot(r_origres(:,3),r_origres(:,1));
                axis([r_origres(1,3) r_origres(end,3) min(r_origres(:,1)) max(r_origres(:,1)) ])
                ylimit  = ylim;
                for c = 1:nScan
                    ScanSel = find(r_origres(:,2)==uScan(c));
                    xtik(c) = r_origres(ScanSel(1),3);
                    if ~mod(c,5) || c ==1
                        pf_verline(r_origres(ScanSel(1),3),'color',[1 1 1]);
                        text(r_origres(ScanSel(1),3),ylimit(2)*0.9,num2str(c));
                    end
                end
                set(gca,'xtick',xtik,'xticklabel',{})
                title([CurSub '-' CurSess '-' CurRun ' ' CurChan ' (' CurFreqstr ' Hz) ' CurMeth ' Orignial temporal resolution' ])
                xlabel('time (seconds)'); ylabel(CurMeth);
            end
            
            cnt =   1;
            for c = 1:size(R,2)/2
                subplot(2+add,1,c+add)
                h(1) = plot(R(:,cnt));
                hold on
                h(2) = plot(R(:,cnt+1),'r');
                title([CurSub '-' CurSess '-' CurRun ' ' CurChan ' (' CurFreqstr ' Hz) ' CurMeth])
                xlabel('scans'); ylabel(CurMeth);
                legend(h,names(cnt:cnt+1),'interpreter','none');
                legend('boxoff')
                xlim([0 length(R(:,cnt))])
                if c==1 && add==1
                    ylim(ylimit)
                end
                cnt = cnt+2;
                if strcmp(conf.mkregr.plotcond,'yes')
                    Y   =   get(gca,'ylim');
                    Yf  =   1;            % Factor for making bigger/smaller
                    for d = 1:length(onset)
                        CurStart = onset(d);
                        CurEnd   = offset(d);
                                            P   =   patch([CurStart CurEnd CurEnd CurStart],[min(Y)*Yf min(Y)*Yf max(Y)*Yf max(Y)*Yf],'k');
                                            set(P,'EdgeColor','none','FaceAlpha',0.3)
                    end
                end
            end
            
            % --- Save all the data --- %
            
            if strcmp(conf.mkregr.save,'yes')
                if strcmp(CurSess,'OF')
                    addsess = 'F';
                else
                    addsess = '';
                end
                if ~isfield(conf.mkregr,'data')
                    if strcmp(conf.mkregr.automatic,'yes')
                        savename    =   [CurSub '-' CurSess addsess '-' CurRun '_' CurChan '_' CurFreqstr(1) 'Hz_regressors_' CurMeth];
                    else
                        savename    =   [CurSub '-' CurSess addsess '-' CurRun '_' CurChan '_' CurFreqstr(1) '-' CurFreqstr(3) 'Hz_regressors_' CurMeth];
                    end
                else
                    dot         =   strfind(CurFreqstr,'.');
                    bar         =   strfind(CurFreqstr,'-');
                    try
                        if length(dot)<2
                            if bar==2
                                savename    =   [CurSub '-' CurSess addsess '-' CurRun '_' CurChan '_' CurFreqstr(1) 'c' num2str(0) '-' CurFreqstr(dot-1) 'c' CurFreqstr(dot+1)  'Hz_regressors_' CurMeth];
                            else
                                savename    =   [CurSub '-' CurSess addsess '-' CurRun '_' CurChan '_' CurFreqstr(dot-1) 'c' CurFreqstr(dot+1)  '-' CurFreqstr(bar+1) 'c' CurFreqstr(bar+3)  'Hz_regressors_' CurMeth];
                            end
                        else
                            savename    =   [CurSub '-' CurSess addsess '-' CurRun '_' CurChan '_' CurFreqstr(1) 'c' CurFreqstr(3) '-' CurFreqstr(dot(2)-1) 'c' CurFreqstr(dot(2)+1)  'Hz_regressors_' CurMeth];
                        end
                    catch
                        savename    =   [CurSub '-' CurSess addsess '-' CurRun '_' CurChan '_' CurFreqstr(1) 'c' CurFreqstr(3)  'Hz_regressors_' CurMeth];
                    end
                end
                saveas(gcf,fullfile(savedir,savename),'jpg');
                save(fullfile(savedir,savename),'R','names')
                fprintf('%s\n',['-- Saved to ' fullfile(savedir,savename)])
            end
        end
    end
end

end

%--------------------------------------------------------------------------

%% Helpers
%--------------------------------------------------------------------------

function rin = pf_zscore(conf,rin,CurMeth)

% --- apply z-score if desired --- %

uScan   =   unique(rin(:,2));
nScan   =   length(uScan);

% --- And plot this --- %

figure('units','normalized','outerposition',[0 0 1 1])
if strcmp(conf.mkregr.zscore,'yes')
    subplot(2,1,1)
    plot(rin(:,3),rin(:,1));
    xlabel('Time (s)');ylabel(['Power (' CurMeth ')']);title([CurMeth ' regressor (original resolution)']);   
    rin(:,1) =   zscore(rin(:,1));
    subplot(2,1,2)
    plot(rin(:,3),rin(:,1));
    xlabel('Time (s)');ylabel(['Zscored Power (' CurMeth ')']);title(['Zscored ' CurMeth ' regressor (original resolution)']);
else
    subplot(1,1,1)
    plot(rin(:,3),rin(:,1));
    xlabel('Time (s)');ylabel(['Power (' CurMeth ')']);title([CurMeth ' regressor (original resolution)']);
end
rin     =   rin;
end



