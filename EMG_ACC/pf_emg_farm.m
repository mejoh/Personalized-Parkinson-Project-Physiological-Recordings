function pf_emg_farm(subjects, conf)
% Function written by van der Meer for MR-correction of EMG signals.
% See also van der Meer et al, 2010, clin. neurophyisology.

% Made suitable for ParkFunC toolbox by Michiel Dirkx, 2014
% Configured by Jitse Amelink for Personalized Parkinson Project, fall 2019
% $ParkFunC
tic;
sel   = 1; %COPIED FROM SETTINGS, NOT SURE WHY IT IS THERE AT ALL
conf.sub.name   = conf.sub.name(sel); %COPIED FROM SETTINGS, NOT SURE WHY IT IS THERE AT ALL

%% ------------------------------------------------------------------------
% Add packages
%--------------------------------------------------------------------------
if isempty(which('ft_defaults')) %check if fieldtrip is installed
    addpath(path.Fieldtrip); %Add fieldtrip
    ft_defaults
end
addpath(path.SPM); %Add SPM12
addpath(fullfile(path.Fieldtrip, 'qsub'));
addpath(genpath(path.ParkFunc));  %Add ParkFunc
addpath(conf.dir.eeglab); eeglab; %Add eeglab
addpath(genpath(conf.dir.Farm)); %Add FARM

%% ------------------------------------------------------------------------
% Initialize
%--------------------------------------------------------------------------
fprintf('\n%s\n\n','% -------------- Initializing -------------- %')

nSub     =   length(conf.sub.name);
nSess    =   length(conf.sub.sess);
nRun     =   length(conf.sub.run);
Files    =   cell(nSub*nSess*nRun,1);
nFiles   =   length(Files);
cnt      =   1;

workmain =   fullfile(conf.dir.work);
if ~exist(workmain,'dir');      mkdir(workmain);      end
if ~exist(conf.dir.save,'dir'); mkdir(conf.dir.save); end

%% ------------------------------------------------------------------------
% Retrieve all fullfiles, initializing workdir
%--------------------------------------------------------------------------
fprintf('\n%s\n\n','% -------------- Retrieving all fullfiles -------------- %')

for a = 1:nSub
    CurSub  =   conf.sub.name{a};
    for b = 1:nSess
        CurSess    =   conf.sub.sess{b};
        for c = 1:nRun
            CurRun     =   conf.sub.run{c};
            CurFile    =   pf_findfile(conf.dir.root,conf.file.name,'conf',conf,'CurSub',a,'CurSess',b,'CurRun',c);
            % Comment is changed because unable to run the pf_findfile function
            % with the task name, I could not identify why. Error in line 139
            % of the pf_findfiles script 'Undefined function 'minus' for input
            % arguments of type 'cell'. In name = [name(1:iStr-1))
            % name(iStr+end)];
            %             cFile =  strcat(CurSub, CurSess, CurRun);
            %             CurFile = fullfile(conf.dir.root, cFile);
            workdir    =   fullfile(conf.dir.work,[CurSub '_' CurSess '_' CurRun]);
            %             if ~exist(workdir,'dir');
            %                 mkdir(workdir);
            %             elseif exist(workdir,'dir') && strcmp(conf.dir.preworkdel,'yes')
            %                 rmdir([workdir '/'],'s')
            %                 mkdir(workdir);
            %             end
            % Changed because of Error using exist, the first input to exist must be a string scalar or character vector
            
            if ~exist(workdir,'dir');
                mkdir(workdir);
            elseif exist(workdir,'dir') && strcmp(conf.dir.preworkdel,'yes')
                rmdir([workdir '/'],'s')
                mkdir(workdir);
            end
            
            %=============================FILES===============================%
            Files{cnt,1}.raw  =  fullfile(conf.dir.root,CurFile);
            Files{cnt,1}.work =  workdir;
            Files{cnt,1}.sub  =  CurSub;
            Files{cnt,1}.sess =  CurSess;
            Files{cnt,1}.run  =  CurRun;
            %=================================================================%
            fprintf('%s\n',['- Added "' CurFile '"'])
            cnt =   cnt+1;
        end
    end
end

%% ------------------------------------------------------------------------
%  FARM correction
%--------------------------------------------------------------------------
fprintf('\n%s\n','% -------------- Performing FARM correction -------------- %')
homer    =   pwd;
detscan  =   0;
Files{:};

for a = 1:nFiles
    
    clear EEG o d sl m mrk ve prebound postbound exevents
    
    CurFile   =  Files{a};
    if ~exist(CurFile.work,'dir');
        mkdir(CurFile.work);
    elseif exist(CurFile.work,'dir') && strcmp(conf.dir.preworkdel,'yes')
        rmdir([CurFile.work '/'],'s')
        mkdir(CurFile.work);
    end
    
    CurSub    =  CurFile.sub;
    CurSess   =  CurFile.sess;
    CurRun    =  CurFile.run;
    [rawpath,rawfile,rawext]  =  fileparts(CurFile.raw);
    
    fprintf('\n%s\n',['Working on Sujbect | ' CurSub ' | Session | ' CurSess ' | Run | ' CurRun ' | ']);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% START LOADING
    [EEG,~]         = pop_loadbv(rawpath,[rawfile rawext],[],conf.file.chan);
    
    % --- Load channels which need not be processed with FARM --- %
    chans           = 1:1:conf.file.nchan;
    iAlt            = find(~pf_numcmp(chans,conf.file.chan));
    [EEGalt,~]      = pop_loadbv(rawpath,[rawfile rawext],[],iAlt)    
    
    % --- Detect amount of scans --- %
    if isnan(conf.file.scanpar(3)) || detscan==1
        mrk     =   EEG.event(strcmp({EEG.event.type},conf.file.etype));
        nScans  =   length(mrk);
        conf.file.scanpar(3) = nScans;
        fprintf('%s\n',['- Detected ' num2str(nScans) ' scan markers'])
        detscan =   1;
    end
    
    cd(CurFile.work);
    nChans    =  length(conf.file.chan);
    
    if ~exist(strcat(workdir,'/emg_added_slicetriggers.mat'),'file')
        if strcmp(conf.preproc.mkbipol,'yes')
            EEG=emg_make_bipolar(EEG);
        end
        maxvals=max(abs(EEG.data(1:nChans,:)),[],2);
        trigchannel = find(maxvals==max(maxvals));       % add slice-triggers.
        if length(trigchannel)>1                         % If the maximum is in both channels (like with the EMG of C2b)
            trigchannel = 1;
        end
        EEG=emg_add_slicetriggers(EEG,trigchannel,conf);
        save(strcat(workdir,'/emg_added_slicetriggers.mat'),'EEG');
    else
        load(strcat(workdir,'/emg_added_slicetriggers.mat'));
    end
    %%
    % --- Rest of Analysis --- %
    ve=EEG.event(strcmp({EEG.event.type},'V'));
    Tr=mean(([ve(2:end).latency]-[ve(1:end-1).latency])/EEG.srate);
    if ~sum(abs(([ve(2:end).latency]-[ve(1:end-1).latency])/EEG.srate-conf.file.scanpar(1))>0.1)
        %JS: this if-loop checks relative length of difference/time/space
        %between markers, and if relative difference bigger than 0.1,
        %it skips rest of analysis.
        
        % reject (possibly!) extragenous data.
        % re-do muscle names from files.txt file.
        % samples that is 1 [s] before 1st V
        % smaples that is 1+Tr [s] after last V
        % estimate Tr.
        
        if ~exist(strcat(workdir,'/emg_added_slicetriggers_revised.mat'),'file')
            % --- Cut out part of the end and part of the beginning --- %
            omit_begin=ve(1).latency-3*EEG.srate;
            if omit_begin<2
                omit_begin=2;
            end
            omit_end=ve(end).latency+round((3+Tr)*EEG.srate);
            if omit_end>(size(EEG.data,2)-1)
                omit_end=size(EEG.data,2)-1;
            end
            % --- Remove events outside the boundary to prevent crash in eeg_eegrej --- %
            lats        =   [EEG.event.latency]';
            prebound    =   lats<=omit_begin;
            postbound   =   lats>=omit_end;
            exevents    =   logical(prebound+postbound);
            EEG.event   =   EEG.event(~exevents);
            
            % --- Reject Data --- %
            EEG = eeg_eegrej( EEG, [1 omit_begin;omit_end size(EEG.data,2)]);
            save (strcat(workdir,'/emg_added_slicetriggers_revised.mat'), 'EEG');
        else
            load (strcat(workdir,'/emg_added_slicetriggers_revised.mat'));
        end
        
        % --- Additional Slice timing --- %
        
        if exist(strcat(workdir,'/state_after_slicetiming.mat'),'file')
            disp('skipping the slice-timing (already done) !!');
            disp('to re-do, delete state_after_slicetiming.mat');
            load (strcat(workdir,'/state_after_slicetiming.mat'));
        else
            % == Convert to double == %
            EEG.data    =   double(EEG.data);
            % ======================= %
            [o d sl m]=init(EEG,conf);
            
            
            
            % --- High-pass filter --- %
            if strcmp(conf.meth.hp,'yes')
                d=filter_lowfrequency(d,o);     % Comment '%' to not perform highpass filtering
            end
            sl=pick_other_templates(sl,o);
            
            % calculate needed adjustments.
            tmp=mean(abs(EEG.data(nChans,:)),2);
            trigchannel=find(tmp==max(tmp));
            disp('starting slicetiming, using third workflow (incl. phaseshifting)');
            [sl o]=do_new_slicetiming3(d,sl,o,m,trigchannel);
            save state_after_slicetiming.mat d sl m o     %%%%%%%%%%%%%% How can you save this into the accurate dir?
        end
        
        if strcmp(conf.meth.volcor,'yes')
            if exist(strcat(workdir,'/state_after_volume_correction.mat'),'file')
                disp('skipping volume-correction (already done)');
                disp('to re-do, delete state_after_volume_correction.mat');
                load (strcat(workdir,'/state_after_volume_correction.mat'));
            else
                disp('starting volume correction..');
                d=do_volume_correction(d,sl,o,m);
                save state_after_volume_correction.mat d sl m o %%%%%%%%%%%%%% How can you save this into the accurate dir?
                
            end
        end
        
        % --- Cluster the artifacts into most-resembling sub-groups --- %
        if strcmp(conf.meth.cluster,'yes')
            if ~exist(strcat(workdir,'/state_after_clustering.mat'),'file')
                disp('starting clustering...');
                sl=do_clustering(d,sl,o,m);
                save state_after_clustering.mat d sl m o
            else
                disp('skipping volume-correction (already done)');
                disp('to re-do, delete state_after_volume_correction.mat');
                load(strcat(workdir,'/state_after_clustering.mat'))
            end
        end
        
        % --- Upsample (cluster&align), do pca, and downsample. --- %
        if strcmp(conf.meth.pca,'yes')
            if ~exist(strcat(workdir,'/state_after_pca.mat'),'file')
                disp(['starting pca, using ' num2str(o.pca.usr_max_components) ' PCA components...']);
                [d sl m]=do_pca(d,sl,o,m);
                save(['state_after_pca.mat'],'d','sl','m','o');
            else
                disp('skipping PCA (already done)');
                disp('to re-do, delete state_after_pca.mat');
                load(strcat(workdir,'/state_after_pca.mat'))
            end
        end
        if strcmp(conf.meth.lp,'yes')
            d=filter_high(d,o);% ZET DIT UIT OM HPfilt UIT TE ZETTEN!!!
        end
        
        % 2010-05-12: seems that anc field was added later, but is not defined under all circumstances
        if strcmp(conf.meth.anc,'yes')
            if ~isfield(o,'anc')
                o.anc = 1;
            end
            if o.anc==1
                disp('starting ANC analysis...');
                d=do_anc(d,o,m,sl);
            end
            d=filter_low(d,o);
        end
        
        load (strcat(workdir,'/emg_added_slicetriggers_revised.mat'))
        EEG.data=d.clean';
        EEG.emgcorroptions=o;
        
        if strcmp(conf.meth.pca,'yes')
            % do_pca also returns, if you ask for it, the samples at where segments
            % start and end! -- see if there's bursts there too.
            for sc=1:numel(m.beginsegmarker)
                EEG.event(end+1).type='b_seg';
                EEG.event(end).latency=m.beginsegmarker(sc);
                EEG.event(end).duration=1;
                EEG.event(end+1).type='e_seg';
                EEG.event(end).latency=m.endsegmarker(sc);
                EEG.event(end).duration=1;
            end
        end
        
        % --- Remove outside measurments and slice triggers --- %
        
        EEG    =emg_remove_outsidemeasurementdata(EEG, 'V');
        EEGalt =emg_remove_outsidemeasurementdata(EEGalt,conf.file.etype);
        
        EEG=emg_remove_slicetriggers(EEG);
        try
            EEG=emg_add_modeltriggers(EEG);
        catch;end
        try
            add_events;
        end
        
        % --- DONE, save --- %
        
        save emg_corrected.mat
        fprintf('\n%s\n','Correction procedure completed!');
        
        % --- Add non-processed channels to processed channels --- %
        
        EEG.nbchan   = EEG.nbchan+EEGalt.nbchan;
        
        %added by JSA to solve vertcat issues.
        if length(EEG.data) > length(EEGalt.data)
            diff_data = length(EEG.data) - length(EEGalt.data);
            warning('\n Warning: length of EEG.data is %s datapoints longer than EEGalt.data \n', num2str(diff_data))
            if diff_data < 20
                EEG.data     = EEG.data(:,1:end-diff_data);
                EEG.data     = vertcat(EEG.data,EEGalt.data);
                fprintf ('\n EEG.data has successfully been concatenated. Extra datapoints have been removed. \n')
            else
                error('Difference is too big (>20), EEG.data and EEGalt.data cannot be concatenated. \n')
            end
            
        elseif length(EEGalt.data) > length(EEG.data)
            diff_data = length(EEGalt.data) - length(EEG.data);
            warning('Length of EEGalt.data is %s datapoints longer than EEG.data', num2str(diff_data))
            if diff_data < 20
                EEGalt.data = EEGalt.data(:,1:end-diff_data);
                EEG.data     = vertcat(EEG.data,EEGalt.data);
                fprintf ('\n EEG.data has successfully been concatenated. Extra datapoints in EEGalt.data have been removed. \n')
            else
                error('Difference is too big (>20), EEG.data and EEGalt.data cannot be concatenated. \n')
            end
        else
            EEG.data     = vertcat(EEG.data,EEGalt.data);
        end
        %end added by JSA
        
        %        EEG.data     = vertcat(EEG.data,EEGalt.data);
        EEG.chanlocs = [EEG.chanlocs EEGalt.chanlocs];
        
        % --- Export --- %
        fname   =   char(strcat(conf.dir.save, '/',subjects, '___task1_FARM'));
        pop_writebva(EEG,fname);
        fprintf('%s\n',['Saved to ' fname]);
        
        % --- delete workdir --- %
        
        try
            cd(homer)
        catch
            cd /home/control/tespee
        end
        
        if strcmp(conf.dir.preworkdel,'yes')
            rmdir(CurFile.work,'s');
        end
        
    else
        latenc = [ve.latency];
        trs    = latenc(2:end)-latenc(1:end-1);
        uTr    = unique(trs);
        incTr  = uTr<(5000*Tr) | uTr>(5000*Tr);
        iIncor = find(trs==uTr(incTr));
        disp(['Unique TRs: ' num2str(uTr)])
        warning(['(Some of the) scanmarkers do not match your specified TR (probably scan number: '  num2str(iIncor+2) '-' num2str(iIncor+1) ' )']);
        
    end
    
end

%--------------------------------------------------------------------------

%% Benchmark
%--------------------------------------------------------------------------

t=toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(t/60) ' minutes!!'])
