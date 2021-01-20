 function EMGACC_runcluster(Task)
% Task = 'motor' / 'reward' / 'rest';                 % From which task do you want to process data

% Dependencies
% Settings
% SETTINGS pf_emg_raw2regr.m & pf_emg_farm.m
% Directories
% Subjects
% Frequency Analysis ('prepemg')
% Frequency Analysis OPTIONAL
% Make Regressor ('mkregressor')
% FieldTrip Configuration
% File info 
% Preprocessing and slice triggers
% Additional methods
% Call functions
% Final step: select peak frequency and channel, create regressor

%% EMGACC_runcluster
% Run FARM and Frequency analysis on cluster, after those peak frequency
% and channel selection should be done. See end of this script.

%% Dependencies
addpath('/home/common/matlab/spm12')
addpath('/home/common/matlab/fieldtrip')
addpath('/home/common/matlab/fieldtrip/qsub')
ft_defaults
%addpath(genpath('/project/3022026.01/scripts/Physio/eeglab14_0_0b'))
%addpath(genpath('/project/3022026.01/scripts/Physio/Personalized-Parkinson-Project-Physiological-Recordings'))
addpath(genpath('/home/sysneu/marjoh/scripts/eeglab14_0_0b'))
addpath(genpath('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Physiological-Recordings'))
%% Settings

%Select what to do
% NOTE: It is required to run FARM before anything else, even processing of
% ACC only. This is because FARM calls eeglab-functions that puts the data
% into a specific format.
conf.todo.Farm               = false; %Do you want to run Farm
conf.todo.Frequency_analysis = true; %Do you want to run frequency analysis
conf.todo.prepemg            = true; %When doing frequency analysis, do you want to prepair emg using: pf_emg_raw2regr_prepemg
conf.todo.mkregressor        = false; %When doing frequency analysis, do you want to make a regressor using: pf_emg_raw2regr_mkregr
conf.todo.ACC                = true; %Do you want analyse the Accelerometer

%Task Settings:
cluster_outputdir = fullfile('/project/3022026.01/analyses/EMG', Task, 'clusteroutput');
processing_dir = fullfile('/project/3022026.01/analyses/EMG', Task, 'processing');
if strcmp(Task,'reward')   
    TR          = 2.24;     % TR
    NSlices     = 32;       % Number of slices
    pScan = '^sub-.*task-reward_acq-ME.*nii.gz$';      % Directory containing raw .IMAs
elseif strcmp(Task,'motor')
    TR          = 1;  
    MB          = 6;
    NSlices     = 72 / MB;   
    pScan = '^sub-.*task-motor_acq-MB6.*nii.gz$';
elseif strcmp(Task,'rest')
    TR          = 0.735;  
    MB          = 8;
    NSlices     = 64 / MB;     
    pScan = '^sub-.*task-rest_acq-MB8.*nii.gz$';
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETTINGS pf_emg_raw2regr.m & pf_emg_farm.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Specify all options under configuration and run the batch. The following
% functions can be used:
%   - 'prepemg': will perform preprocessing and frequency analysis on your
%   data using FieldTrip. This data is then stored in a .mat file, which
%   can be used formaking a regressor using:
%   -  'mkregressor': wil create regressors based on data analyzed with
%   'prepemg'. To do so, you must first interactively select the tremor
%   frequency. This selection and subsequent creation of regressor must be
%   done via the GUI: pf_emg_raw2regr_mkregressor_gui. If you have already
%   done so but you want to reanalyze data (and use previous peak
%   selection) you can also specify options here, the first option being:
%   conf.mkregr.reanalyze='yes'.

%--------------------------------------------------------------------------
%% Directories
%--------------------------------------------------------------------------
%REGR
conf.dir.root      =   fullfile('/project/3022026.01/analyses/EMG', Task);
conf.dir.ParkFunc  =   '/project/3022026.01/scripts/Physio/Personalized-Parkinson-Project-Physiological-Recordings/EMG_ACC/Helpers/ParkFunC_EMG';     % Directory containing Park_Func
conf.dir.Farm      =   '/project/3022026.01/scripts/Physio/Personalized-Parkinson-Project-Physiological-Recordings/EMG_ACC/Helpers/FARM_toolbox';          % Directory containing Farm
conf.dir.eeglab    =   '/project/3022026.01/scripts/Physio/eeglab14_0_0b'; % Directory containing EEGLAB
conf.dir.SPM       =   fullfile('home', 'common', 'matlab', 'spm12');       % Directory containing SPM
conf.dir.Fieldtrip =   fullfile('home', 'common', 'matlab', 'fieldtrip');   % Directory containing Fieldtrip
conf.dir.preproc   =   fullfile(conf.dir.root, 'processing', 'FARM');                     % Directory containing files used for "prepemg" (usually after FARM)
conf.dir.prepemg   =   fullfile(conf.dir.root, 'processing', 'prepemg');                  % Directory where files from function "prepemg" will be stored
conf.dir.auc       =   fullfile(conf.dir.root, 'auc');                      % Directory for aucs
conf.dir.regr      =   fullfile(conf.dir.prepemg,'Regressors');             % Directory where files from function "mkregr" will be stored
conf.dir.event     =   conf.dir.preproc;                                    % Directory containing conditions, e.g. if you want to plot the conditions in mkregr
% conf.dir.raw       =   fullfile(conf.dir.root,'data');                    % Directory containing all the RAW brainvision analyzer files
conf.dir.reanalyze.orig =  fullfile(conf.dir.regr,'ZSCORED'); % If in function "mkregr" you want to reanalyze data (so conf.mkregr.reanalyze='yes'), then the regressor files in the directory specified here will be used for peakselection
%conf.dir.fmri.root    = '/home/action/micdir/data/DRDR_MRI/fMRI';               % Director containing subject folders with the fMRI scans. This is only relevant for function "mkregr" if you specify conf.mkregr.nscan='detect'. It will then search the amount of scan per subject in the subfolders (specified in conf.dir.fmri.preproc)  of this root directory to match the number of regressor datapoints.
%conf.dir.fmri.preproc = {'CurSub' 'func' 'CurSess' 'CurRun' 'preproc' 'norm'};  % Directory appended to conf.dir.fmri.root containing the subject-specific fMRI scans. In this example, if the subject is p02, session is OFF and run is resting_state it will search the amount of scans in /home/action/micdir/data/DRDR_MRI/fMRI/p02/func/OFF/resting_state/preproc/norm and use this amount to match the EMG regressor datapoint

%FARM
conf.dir.save    =   fullfile(conf.dir.root, 'processing', 'FARM');
conf.dir.work    =   fullfile(conf.dir.root, 'processing', 'FARM', 'work');
conf.dir.preworkdel  = 'yes';           % Delete work directory beforehand (if present)
conf.dir.postworkdel = 'yes';           % Delete work directory afterwards

%--------------------------------------------------------------------------
%% Subjects
%--------------------------------------------------------------------------
%Retrieve subjects
pDir = fullfile('/project', '3022026.01', 'pep');
pBIDSDir = char(fullfile(pDir, 'bids'));
Sub = cellstr(spm_select('List', fullfile(pBIDSDir), 'dir', '^sub-POM.*'));
Sel = true(numel(Sub),1);

%Exclude subjects without task data
for n = 1:numel(Sub)
    Sessions = cellstr(spm_select('FPList', fullfile(pBIDSDir, Sub{n}), 'dir', 'ses-Visit[0-9]'));
    TaskData_fmri = cellstr(spm_select('List', fullfile(Sessions, 'func'), ['.*task-', Task, '_acq-MB6.*.nii.gz']));
    TaskData_beh  = cellstr(spm_select('List', fullfile(Sessions, 'beh'), ['.*task-', Task, '_acq-MB6.*.tsv']));
    if isempty(TaskData_fmri{1}) || isempty(TaskData_beh{1})
        Sel(n) = false;
        fprintf('Skipping %s without fmri or without beh data for task \n', Sub{n})
    end
end

%Exclude subjects without without vmrk/eeg/vhdr file
for n = 1:numel(Sub)
    vmrk    = cellstr(spm_select('List', conf.dir.root, [Sub{n}, '.*task-', Task, '.*_eeg.vmrk$']));
    eeg     = cellstr(spm_select('List', conf.dir.root, [Sub{n}, '.*task-', Task, '.*_eeg.eeg$']));
    vhdr    = cellstr(spm_select('List', conf.dir.root, [Sub{n}, '.*task-', Task, '.*_eeg.vhdr$']));
    if isempty(vmrk{1}) || isempty(eeg{1}) || isempty(vhdr{1})
        Sel(n) = false;
        fprintf('Skipping %s with no vmrk/eeg/vhdr files \n', Sub{n})
    end
end

Sub = Sub(Sel);
%Sub = {Sub{1} Sub{2} Sub{3} Sub{4}};    % Subset for testing purposes only
%Sub = Sub(2);
FARMjobs = cell(numel(Sub),1);
FREQjobs = cell(numel(Sub),1);
%conf.sub.sess   = {'_';};             % Specify the session in a cell structure (even if you have only one session)
conf.sub.run    = {Task;};         % Specify the run in a cell structure (even if you have only one run, e.g. resting state)

for n = 1:numel(Sub)
conf.sub.name   = Sub(n);
Sessions = cellstr(spm_select('FPList', fullfile(pBIDSDir, conf.sub.name), 'dir', 'ses-Visit[0-9]'));
    for i = 1:numel(Sessions)
    [~, conf.sub.sess, ~] = fileparts(Sessions{i});
    conf.sub.sess = cellstr(conf.sub.sess);
    Channels = spm_select('FPList', fullfile(pBIDSDir, conf.sub.name{1}, conf.sub.sess{1}, 'eeg'), ['^sub.*' Task '_channels.tsv$']);
    txtChannels = tdfread(Channels);
    nChannels = size(txtChannels.name, 1);
    if nChannels == 9
        emgChannels = 1:4;
        accChannels = 7:9;
    elseif nChannels == 10
        emgChannels = 1:5;
        accChannels = 8:10;
    else
        fprintf('sub-%s has abnormal amount of channels: %i, skipping...\n', conf.sub.name{1}, nChannels)
        continue
    end

%--------------------------------------------------------------------------
%% Frequency Analysis ('prepemg')
%--------------------------------------------------------------------------
    conf.prepemg.datfile  = '/CurSub/&/CurSess/&/CurRun/&/FARM.dat/';   % Data file name of preprocessed data (uses pf_findfile)
    conf.prepemg.mrkfile  = '/CurSub/&/CurSess/&/CurRun/&/FARM.vmrk/';  % Marker file name of preprocessed data (uses pf_findfile)
    conf.prepemg.hdrfile  = '/CurSub/&/CurSess/&/CurRun/&/FARM.vhdr/';  % Hdr file name of preprocessed data (uses pf_findfile)
    conf.prepemg.precut   = 'no';     % If yes, it will cut out the data before the first volume marker. If you leave this as no, it should already be cut away
    conf.prepemg.sval     = 'V';      % Scan value in your marker file (usually 'V' after FARM);
    conf.prepemg.tr       = TR;    % Choose a fixed TR (repetition time) or enter 'detect' if you want the script to detect this
    conf.prepemg.dumscan  = 5;        % Dummyscans (Start of regressor will be at conf.prepemg.dumscan+1)
    conf.prepemg.prestart = 3;        % Scans before the start of your first scan (conf.prepemg.dumscan+1) you want to select (for example to account for the hanning taper, BOLD response etc). This data will be processed all the way, and only disregarded at the end of all analyses
    conf.prepemg.timedat  = 0.001;   % The resolution of the time-frequency representation in seconds (can be used for cfg.cfg_freq.toi)
    if nChannels == 9
        conf.prepemg.chan     = {'right_extensor';  %1
        'right_flexor';    %2
        'left_extensor';   %3
        'left_flexor';     %4
        'hr';              %9 (5)
        'resp';            %10 (6)
        'acc_x';           %11 (7)
        'acc_y';           %12 (8)
        'acc_z' ;          %13 (9)
        }; % All channels present in your dataset, give them a name here.
    elseif nChannels == 10
        conf.prepemg.chan     = {'right_extensor';  %1
        'right_flexor';    %2
        'left_extensor';   %3
        'left_flexor';     %4
        'most_affected_leg'; %5     <<< May be unused, despite existence of channel in eeg file!
        'hr';              %9 (6)
        'resp';            %10 (7)
        'acc_x';           %11 (8)
        'acc_y';           %12 (9)
        'acc_z' ;          %13 (10)
        }; % All channels present in your dataset, give them a name here. 
    end

%--------------------------------------------------------------------------
%% Frequency Analysis OPTIONAL
%--------------------------------------------------------------------------
% --- Plotting options --- %
    conf.prepemg.subplot.idx           = [1,2];    % Every analysis yields one figure, choose the subplot here ([r,c])
    conf.prepemg.subplot.chan          = { conf.prepemg.chan(emgChannels);
        [conf.prepemg.chan(accChannels);'acc-pc1'];
        };        % Choose here the channels you want to plot in the subplots (these need to match the amount of subplots in conf.prepemg.subplot.idx). NB1: it will first check for a single string, you can specify these strings; 'coh': will plot the freshly performed coherence analysis

% --- Optional: combine channels if desired --- %
    conf.prepemg.combichan.on   = 'yes';                                % If you want to combine channels, specify 'yes'
    conf.prepemg.combichan.chan = {conf.prepemg.chan(accChannels) 'acc-pc1';};  % Choose the sets of channels you want to combine (for every row another set of channels, in the left column the channel names (as in conf.prepemg.chan) in the right column the new name)
    conf.prepemg.combichan.meth = 'pca';                                % Choose method of combining ('vector': will make a vector out of a triaxial signal (x^2+y^2+z^2)^0.5 | 'pca': performs principal component analysis and will take first principle component)

% --- Optional: perform coherence analysis if desired --- %
    conf.prepemg.cohchan.on         =  'yes';    % Cohere channels (specify 'yes')
    conf.prepemg.cohchan.channelcmb =  {
        conf.prepemg.chan(1:4) conf.prepemg.combichan.chan(1,2);
        };       % Channels you want to performe a coherence analysis over. In the left column specify the channels (multiple) which you want to cohere with the channel on the right column (one). It will detect the presense of these channels in the freqana data and only select those which are present.

% --- Optional: only save averaged power spectrum (if you don't need regressors, this will save space) --- %
    conf.prepemg.freqana.avg        = 'no';

% --- Optional: calculate area under the curve for the highest peak in the ACC spectrum (FWHM) --- %
    conf.auc.auto                   = 'no';
    conf.auc.chan                   = {accChannels - 2}; %JS edit. Defines accelerometry channels for the analysis AUC dataset (HR and RESP are removed at this point).
    conf.auc.filter                 = [3.4 6.6]; %filter (two numbers required!) for peak selection. Most tremor peaks fall between 3.4 and 6.6 Hz, so recommended to leave as is.
    conf.auc.us_factor              = 20; %upsample factor for power spectrum for AUC. Recommended: 20.
    conf.auc.manual                 = 'no'; %selects peak within manual range and channel only (specify below)
    conf.auc.manual_chan            = 7; %make sure selected channel falls in range auc.chan
    conf.auc.manual_range           = 5 ; %Can give range (two numbers) or one value.
% Values should be same as stepsize of
% foi (see cfg.fft_auc). Normally 0.2 Hz
% In case of one value, the algorithm selects the closest peak.

%--------------------------------------------------------------------------
%% Make Regressor ('mkregressor')
%--------------------------------------------------------------------------
    conf.mkregr.reanalyze = 'no';   % Choose if you want to reanalyze previously selected data. If not, then use the GUI: pf_emg_raw2regr_mkregressor_gui
    conf.mkregr.reanalyzemeth = {  'regressor';
    %                              'ps_save';
        }; % Method for re-analyzing the data ('regressor': create regressors; 'ps_save': only save average power spectrum)
    conf.mkregr.automatic = 'yes';
    conf.mkregr.automaticfreqwin = [1.99,13.1];
    conf.mkregr.automaticdir = fullfile(conf.dir.root, 'automaticdir');
    conf.mkregr.file      = '/CurSub/&/CurSess/&/freqana/'; % Name of prepemg data (uses pf_findfile)
    conf.mkregr.scanname  = '|w*';                          % search criterium for images (only if conf.mkregr.nscan = 'detect'; uses pf_findfile)
    conf.mkregr.sample    = 1;                              % Samplenr of every scan which will be used to represent the tremor during scan (if you used slice time correction, use the reference slice timing here)
    conf.mkregr.zscore    = 'yes';                          % If yes, than the data will first be z-normalized
    conf.mkregr.meth      = {'power';'amplitude';'log'};    % Choose methods for regressors ('power': simple power; 'amplitude': sqrt(pow); 'log': log10 transformed)
    conf.mkregr.trans     = {'deriv1'};                     % In addition to regressors specified in conf.mkregr.meth, specify here transformation of made regressors ('deriv1': first temporal derivative)
    conf.mkregr.save      = 'yes';                          % Save regressors/figures

%Choose channels based on acc vs emg and most affected side. THIS IS VERY
%SPEFIC TO DONDERS AND OUR STUDY
    if conf.todo.ACC
        conf.mkregr.automaticchans = accChannels - 2;
    else
        EventsJson = spm_select('FPList', fullfile(pBIDSDir, conf.sub.name, conf.sub.sess, 'beh'), ['.*_task-', Task '.*events.json']);
        EventsJson = fileread(EventsJson);
        EventsJson = jsondecode(EventsJson);
        AffectedSide = EventsJson.RespondingHand.Value;
        if strcmp(AffectedSide, 'Left')
            conf.mkregr.automaticchans = 3:4;
        elseif strcmp(AffectedSide,'Right')
            conf.mkregr.automaticchans=1:2;
        end
    end

%--------------------------------------------------------------------------
%% Make Regressor OPTIONAL
%--------------------------------------------------------------------------
% --- Optional: plot condition as grey bar --- %
    conf.mkregr.plotcond  = 'no';                                   % If you want to plot the condition (will use the same )
    conf.mkregr.evefile   = '/CurSub/&/CurSess/&/CurRun/&/.vmrk/';   % Event file stored in conf.dir.event (if you want to plot the conditions
    conf.mkregr.mrk.scan  = 'R  1';                                  % Scan marker (if you want to plot events)
    conf.mkregr.mrk.onset = 'S 11';                                  % Onset marker (if you want to plot events)
    conf.mkregr.mrk.offset= 'S 12';                                  % Offset marker (if you want to plot events)

% --- Optional: plot scan lines --- %
    conf.mkregr.plotscanlines = 'no';                       % If yes then it will plot the scanlines in the original resolution.

%--------------------------------------------------------------------------
%%  FieldTrip Configuration
%--------------------------------------------------------------------------
% Options specified here correspond to the options specified for FieldTrip
% fucntions. Therefore, check the info of FieldTrip for options possible:
% ft_preprocessing for cfg_pre, ft_freqanalysis for cfg_freq
% --- Preprocessing (ft_preprocessing) --- %
    cfg.chandef =   {
        emgChannels;   % First round of preprocessingfor channel 1:4 (in my case EMG after FARM)
        emgChannels;   % Second round of preprocessing for channel 1:4 (in my case EMG after FARM)
        accChannels; % First round of preprocessing for channel 7:9 (in my case raw accelerometry)
        };       % Define the different preprocessing for the channels here. For every row define the channels defined in conf.prepemg.chan and define the preprocessing in the options below. The different processed channels will be appended later on.

    cfg.cfg_pre{1}             =   [];       % For every set of channels (nRows in cfg.chandef) you must here define the preprocessing methods. E.g. in this case cfg.cfg_pre{1} corresponds to channels 1:8 (first round), cfg.cfg_pre{3} to channels 11:13
    cfg.cfg_pre{1}.continuous  =   'yes';    % Load all data, select later
    cfg.cfg_pre{1}.detrend     =   'yes';    % Detrend data
    cfg.cfg_pre{1}.demean      =   'yes';    % Demean data
    cfg.cfg_pre{1}.rectify	   =   'yes';    % Rectify for tremor bursts
    cfg.cfg_pre{2}.hpfilter	   =   'yes';    % Second round: high-pass filter to remove low-frequency drifts
    cfg.cfg_pre{2}.hpfreq	   =       2;    % HP frequency
    cfg.cfg_pre{2}.hpfilttype  = 'firws';    % HP filter type, 'but' often crashes
    cfg.cfg_pre{3}.continuous  =   'yes';    % Load all data, select later
    cfg.cfg_pre{3}.detrend	   =   'yes';    % Detrend data
    cfg.cfg_pre{3}.demean	   =   'yes';    % Demean data
    cfg.cfg_pre{3}.bpfilter	   =   'yes';    % Bandpass filter
    cfg.cfg_pre{3}.bpfreq	   =   [1 40];   % Bandpass filter frequency
    cfg.cfg_pre{3}.bpfiltord   =   1;        % Bandpass filter order
    cfg.cfg_pre{3}.bpfilttype  =   'but';    % Bandpass filter type ('but'=butterworth)

% --- Frequency analysis (ft_freqanalysis) --- %
    cfg.cfg_freq.method     = 'mtmconvol';               % Select method (choose 'mtmconvol' for regressor)
    cfg.cfg_freq.output     = 'pow';                     % Select output ('pow'=power)
    cfg.cfg_freq.taper      = 'hanning';                 % Windowing ('hanning'=hanning taper)
    cfg.cfg_freq.foi        = 2:0.5:13;                   % Frequency range you are interested in (usually 2:0.5:8, make sure you at least include 3-8 Hz)
    nFoi                    = length(cfg.cfg_freq.foi);  % Number of frequencies
    cfg.cfg_freq.t_ftimwin  = repmat(2,1,nFoi);          % Wavelet length (seconds; 1 wavelet per frequency). For practical reasons usually take 2 second (which will contain enough time to detect tremor frequency)
    cfg.cfg_freq.toi        = 'timedat';                 % Temporal resolution of you time-frequency representation (resolution in seconds) ('orig': original resolution; 'timedat': one step specified under conf.prepemg.timedat;)
    cfg.cfg_freq.pad        = 'maxperlen';               % Padding (use 'maxperlen' for default)

% --- AUC analysis --- %
    cfg.fft_auc{1}.length      =    5; %segmentation settings. specify length of windows in seconds
    cfg.fft_auc{1}.overlap     =    0; %Overlap between segments, should be zero in case of resting analysis
    resolution_foi = 1/cfg.fft_auc{1}.length; % Freq resolution depends on the length of the time window (1/T).
    cfg.fft_auc{2}.method      =       'mtmfft'; %FFT settings.
    cfg.fft_auc{2}.foi         =       2:resolution_foi:8; % define frequency window. Step size is dependent on segment lenghts, so only change first and last value.
    cfg.fft_auc{2}.taper       =       'hanning'; %Hanning seems to work better than dpss.
    cfg.fft_auc{2}.keeptrials  =       'no';
% cfg.fft_auc{2}.tapsmofrq   = 0.4; % only necessary for dpss analysis. Not recommended
% cfg.fft_auc{2}.t_ftimwin   = ones(length(cfg_fft.foi),1)*5; %not necessary
% cfg.fft_auc{2}.toi         = 'all'; %not necessary

% --- Coherence Analysis ('ft_connectivityanalsis') --- %
    cfg.cfg_coh.output    = 'fourier';        % Frequency analysis previous to coherence analysis
    cfg.cfg_coh.method    = 'mtmfft';         % Coherence analysis method ('mtmfft' for simple coherence)
    cfg.cfg_coh.foi       = 2:0.5:13;          % Frequency range (usually same as cfg_freq.foi)
    cfg.cfg_coh.tapsmofrq = 0.5;

%--------------------------------------------------------------------------
%%  File info 
%--------------------------------------------------------------------------
    conf.file.name          =   '/CurSub/&/CurSess/&/CurRun/&/.vhdr/';         %%%%%%%%%%%%%%%%%%%%%%%%%%%% .vhdr file of the BVA EMG file(uses pf_findfile)
    conf.file.nchan         =   nChannels;                                             % total amount of channels in original file
    conf.file.chan          =   emgChannels;                                           % Channels you want to analyze. EMG
    conf.file.scanpar       =   [TR;NSlices;nan];                                 % Scan parameters: TR / nSlices / nScans (enter nan for nScans if you want to automatically detect this)
    conf.file.etype         =   'R  1';                                        % Scan marker (EEG.event.type)

%--------------------------------------------------------------------------
%%  Preprocessing and slice triggers
%--------------------------------------------------------------------------
    conf.preproc.mkbipol    =   'no';       % If yes, then it will make bipolar out of monopolar channels
    conf.slt.plot           =   'no';       % Plot the slicetrigger check (no for qsub)

%--------------------------------------------------------------------------
%%  Additional methods
%--------------------------------------------------------------------------
    conf.meth.volcor  =   'yes';   % volume correction
    conf.meth.cluster =   'yes';   % Cluster correction
    conf.meth.pca     =   'yes';   % do PCA
    conf.meth.lp      =   'yes';   % Do lowpass filtering
    conf.meth.hp      =   'yes';   % do highpass filtering
    conf.meth.anc     =   'yes';   % do ANC


%% Call functions
    startdir = pwd;
    cd(cluster_outputdir)
    if isempty(pf_findfile(fullfile(processing_dir,'FARM'),['/' conf.sub.name{1} '/&/' Task '/'])) && conf.todo.Farm
    %Check number of scans
        dImg = fullfile(pBIDSDir, conf.sub.name, conf.sub.sess, 'func');
        fpImg = spm_select('FPList', dImg, pScan);
        nScan = size(spm_vol(fpImg(size(fpImg,1),:)),1);    % Takes the last run only
        conf.mkregr.nscan = nScan - conf.prepemg.dumscan;
    
        fprintf(['\n --- Submitting FARM-job for subject ' conf.sub.name{1} ' ---\n']);
        FARMjobs{n} = qsubfeval('pf_emg_farm', conf.sub.name, conf,'memreq', 4*1024^3,'timreq',1*60*60);  % Run on cluster ;
    elseif isempty(pf_findfile(fullfile(processing_dir,'prepemg'),['/' conf.sub.name{1} '/&/' Task '/'])) && conf.todo.Frequency_analysis
    %Check number of scans
        dImg = fullfile(pBIDSDir, conf.sub.name, conf.sub.sess, 'func');
        fpImg = spm_select('FPList', dImg, pScan);
        nScan = size(spm_vol(fpImg(size(fpImg,1),:)),1);    % Takes the last run only
        conf.mkregr.nscan = nScan - conf.prepemg.dumscan;
    
        fprintf(['\n --- Submitting frequency analysis-job for subject ' conf.sub.name{1} ' ---\n']);
        FREQjobs{n} = qsubfeval('pf_emg_raw2regr', conf, cfg, 'memreq',8*1024^3,'timreq',1*60*60);  % Run on cluster
    else
        fprintf(['\n --- FARM and frequency analysis already done for ' conf.sub.name{1} ' or not selected as task ---\n']);
    end
    end
end

jobs = [FARMjobs FREQjobs];

% Save clusterjobs
if ~isempty(jobs)
    task.jobs = jobs;
    task.submittime = datestr(clock);
    task.mfile = mfilename;
    task.mfiletext = fileread([task.mfile '.m']);
    save([cluster_outputdir '/jobs_' task.mfile  '_' datestr(clock) '.mat'],'task');
end

fprintf(['\n --- Done ---\n']);

cd(startdir)

%% Final step: select peak frequency and channel, create regressor
% Use pf_emg_raw2regr_mkregressor_gui in matlab2014a with paths:
% scriptdir = '/project/3011164.01/TEMP/Scripts/EMG-ACC/';
% addpath(fullfile(scriptdir,'ParkFunC_EMG','EMG'));
% addpath(fullfile(scriptdir,'ParkFunC_EMG','Helpers'));
% addpath('/home/common/matlab/spm12');
% spm fmri

end