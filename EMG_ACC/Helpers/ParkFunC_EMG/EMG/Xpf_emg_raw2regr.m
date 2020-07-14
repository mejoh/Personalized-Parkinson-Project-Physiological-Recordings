function pf_emg_raw2regr(conf,cfg,varargin)
% pf_emg_raw2regr(conf,cfg,varargin) is a batch like function with the 
% main goal to transform a raw EMG or Accelerometry signal into a regressor 
% describing tremor fluctuations to be used in a general linear model for 
% fMRI analyses. The input is usually EMG signal after fMRI artifact 
% reduction (e.g. FARM, for example via pf_emg_farm_ext). Specify all 
% options under configuration and run the batch. The following functions 
% can be used:
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
%
% For fMRI artifact reduction of EMG signal see pf_emg_farm_ext

% � Michiel Dirkx, 2015
% $ParkFunC, version 20150702
% Updated 20181210

%--------------------------------------------------------------------------

%% Warming Up
%--------------------------------------------------------------------------

if nargin<2
    varargin{1} =   'prepemg';
%     varargin{2} =   'mkregressor';
end

%--------------------------------------------------------------------------

%% Configuration
%--------------------------------------------------------------------------

if nargin<1
    
tic; close all; clc; 

%==========================================================================    
% --- Directories --- %
%==========================================================================

conf.dir.root      =   '/home/action/micdir/data/DRDR_MRI/EMG';             % Root directory containing EMG files

conf.dir.raw       =   fullfile(conf.dir.root,'RAW');                       % Directory containing all the RAW brainvision analyzer files
conf.dir.preproc   =   fullfile(conf.dir.root,'FARM1');                     % Directory containing files used for "prepemg" (usually after FARM)
conf.dir.prepemg   =   fullfile(conf.dir.root,'FARM1','prepemg_han2s');     % Directory where files from function "prepemg" will be stored
conf.dir.regr      =   fullfile(conf.dir.prepemg,'Regressors');             % Directory where files from function "mkregr" will be stored
conf.dir.event     =   conf.dir.preproc;                                    % Directory containing conditions, e.g. if you want to plot the conditions in mkregr

conf.dir.reanalyze.orig =   '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s/Regressors/'; % If in function "mkregr" you want to reanalyze data (so conf.mkregr.reanalyze='yes'), then the regressor files in the directory specified here will be used for peakselection

conf.dir.fmri.root    = '/home/action/micdir/data/DRDR_MRI/fMRI';               % Director containing subject folders with the fMRI scans. This is only relevant for function "mkregr" if you specify conf.mkregr.nscan='detect'. It will then search the amount of scan per subject in the subfolders (specified in conf.dir.fmri.preproc)  of this root directory to match the number of regressor datapoints. 
conf.dir.fmri.preproc = {'CurSub' 'func' 'CurSess' 'CurRun' 'preproc' 'norm'};  % Directory appended to conf.dir.fmri.root containing the subject-specific fMRI scans. In this example, if the subject is p02, session is OFF and run is resting_state it will search the amount of scans in /home/action/micdir/data/DRDR_MRI/fMRI/p02/func/OFF/resting_state/preproc/norm and use this amount to match the EMG regressor datapoint

%==========================================================================
% --- Subjects --- %
%==========================================================================

conf.sub.name   =   {
                     'p30';'p08';'p11';'p28';'p14'; %5
                     'p18';'p27';'p02';'p60';'p59'; %10
                     'p62';'p38';'p49';'p40';'p19'; %15
                     'p29';'p36';'p42';'p33';'p71'; %20
                     'p21';'p70';'p64';'p50';'p72'; %25
                     'p47';'p56';'p24';'p48';'p43'; %30
                     'p63';'p75';'p74';'p76';'p77'; %35
                     'p78';'p73';'p80';'p81';'p82'; %40
                     'p83';                         %41
                     };   

conf.sub.sess   = {
                   'SESS1';
                   'SESS2';
                   };                    % Specify the session in a cell structure (even if you have only one session)
conf.sub.run    = {
%                     'RS';
%                     'POSH';
                    'COCO';
                    };                   % Specify the run in a cell structure (even if you have only one run, e.g. resting state)

sel = 2;
sel = pf_subidx(sel,conf.sub.name);

conf.sub.name   = conf.sub.name(sel);    % Select the subjects
                        
%==========================================================================
% --- Frequency Analysis ('prepemg')--- %
%==========================================================================                   
                     
conf.prepemg.datfile  = '/CurSub/&/CurSess/&/CurRun/&/FARM.dat/';   % Data file name of preprocessed data (uses pf_findfile)
conf.prepemg.mrkfile  = '/CurSub/&/CurSess/&/CurRun/&/FARM.vmrk/';  % Marker file name of preprocessed data (uses pf_findfile)  
conf.prepemg.hdrfile  = '/CurSub/&/CurSess/&/CurRun/&/FARM.vhdr/';  % Hdr file name of preprocessed data (uses pf_findfile)

conf.prepemg.precut   = 'no';     % If yes, it will cut out the data before the first volume marker. If you leave this as no, it should already be cut away        
conf.prepemg.sval     = 'V';      % Scan value in your marker file (usually 'V' after FARM);
conf.prepemg.tr       = 0.859;    % Choose a fixed TR (repetition time) or enter 'detect' if you want the script to detect this
conf.prepemg.dumscan  = 5;        % Dummyscans (Start of regressor will be at conf.prepemg.dumscan+1)
conf.prepemg.prestart = 3;        % Scans before the start of your first scan (conf.prepemg.dumscan+1) you want to select (for example to account for the hanning taper, BOLD response etc). This data will be processed all the way, and only disregarded at the end of all analyses
conf.prepemg.timedat  = 0.001;    % The resolution of the time-frequency representation in seconds (can be used for cfg.cfg_freq.toi)
conf.prepemg.chan     = {'MA-Biceps'  ; %1
                         'MA-Triceps' ; %2
                         'MA-EDC'     ; %3
                         'MA-FCR'     ; %4
                         'MA-ABP'     ; %5
                         'LA-EDC'     ; %6
                         'LA-FCR'     ; %7
                         'MA-TIBIAL'  ; %8
                         'HEART'      ; %9
                         'RESP'       ; %10
                         'ACC_Z'      ; %11
                         'ACC_Y'      ; %12
                         'ACC_X'      ; %13
                         }; % All channels present in your dataset, give them a name here.

% --- Plotting options --- %

conf.prepemg.subplot.idx           = [1,2];    % Every analysis yields one figure, choose the subplot here ([r,c])
conf.prepemg.subplot.chan          = {
                                       conf.prepemg.chan(1:8);
                                      [conf.prepemg.chan(11:13);'ACC-PC1'];
                                     };       % Choose here the channels you want to plot in the subplots (these need to match the amount of subplots in conf.prepemg.subplot.idx). NB1: it will first check for a single string, you can specify these strings; 'coh': will plot the freshly performed coherence analysis                     
                     
% --- Optional: combine channels if desired --- %

conf.prepemg.combichan.on   = 'yes';    % If you want to combine channels, specify 'yes'
conf.prepemg.combichan.chan = {
                                conf.prepemg.chan(11:13) 'ACC-PC1';
                               };       % Choose the sets of channels you want to combine (for every row another set of channels, in the left column the channel names (as in conf.prepemg.chan) in the right column the new name)
conf.prepemg.combichan.meth = 'pca';    % Choose method of combining ('vector': will make a vector out of a triaxial signal (x^2+y^2+z^2)^0.5 | 'pca': performs principal component analysis and will take first principle component)                           

% --- Optional: perform coherence analysis if desired --- %

conf.prepemg.cohchan.on         =  'yes';    % Cohere channels (specify 'yes')
conf.prepemg.cohchan.channelcmb =  {
                                    conf.prepemg.chan(1:5) conf.prepemg.combichan.chan(1,2);
                                    };       % Channels you want to performe a coherence analysis over. In the left column specify the channels (multiple) which you want to cohere with the channel on the right column (one). It will detect the presense of these channels in the freqana data and only select those which are present.

% --- Optional: only save averaged power spectrum (if you don't need regressors, this will save space) --- %
                                
conf.prepemg.freqana.avg        = 'no';
                                
%==========================================================================
% --- Make Regressor ('mkregressor') --- %
%==========================================================================

conf.mkregr.reanalyze = 'yes';                          % Choose if you want to reanalyze previously selected data. If not, then use the GUI: pf_emg_raw2regr_mkregressor_gui
conf.mkregr.reanalyzemeth = {
                             'regressor';
                             'ps_save';
                             };                         % Method for re-analyzing the data ('regressor': create regressors; 'ps_save': only save average power spectrum)
conf.mkregr.file      = '/CurSub/&/CurSess/&/freqana/'; % Name of prepemg data (uses pf_findfile)
conf.mkregr.nscan     = 'detect';                       % Amount of scans your regressor should contain ('detect' to detect the amount in conf.dir.fmri.preproc)
conf.mkregr.scanname  = '|w*';                          % search criterium for images (only if conf.mkregr.nscan = 'detect'; uses pf_findfile)
conf.mkregr.sample    = 1;                              % Samplenr of every scan which will be used to represent the tremor during scan (if you used slice time correction, use the reference slice timing here)
conf.mkregr.zscore    = 'yes';                          % If yes, than the data will first be z-normalized
conf.mkregr.meth      = {'power';'amplitude';'log'};    % Choose methods for regressors ('power': simple power; 'amplitude': sqrt(pow); 'log': log10 transformed)
conf.mkregr.trans     = {'deriv1'};                     % In addition to regressors specified in conf.mkregr.meth, specify here transformation of made regressors ('deriv1': first temporal derivative)
conf.mkregr.save      = 'yes';                          % Save regressors/figures

% --- Optional: plot condition as grey bar --- %

conf.mkregr.plotcond  = 'no';                                   % If you want to plot the condition (will use the same )
conf.mkregr.evefile   = '/CurSub/&/CurSess/&/CurRun/&/.vmrk/';   % Event file stored in conf.dir.event (if you want to plot the conditions
conf.mkregr.mrk.scan  = 'R  1';                                  % Scan marker (if you want to plot events)
conf.mkregr.mrk.onset = 'S 11';                                  % Onset marker (if you want to plot events)
conf.mkregr.mrk.offset= 'S 12';                                  % Offset marker (if you want to plot events)                                     

% --- Optional: plot scan lines --- %

conf.mkregr.plotscanlines = 'no';                       % If yes then it will plot the scanlines in the original resolution.

%=========================================================================%
%======================== FieldTrip Configuration ========================%
%=========================================================================%
% Options specified here correspond to the options specified for FieldTrip
% fucntions. Therefor, check the info of FieldTrip for options possible:
% ft_preprocessing for cfg_pre, ft_freqanalysis for cfg_freq

% --- Preprocessing (ft_preprocessing) --- %

cfg.chandef =   {
                      1:8;   % First round of preprocessingfor channel 1:8 (in my case EMG after FARM) 
                      1:8;   % Second round of preprocessing for channel 1:8 (in my case EMG after FARM)
                      11:13; % First round of preprocessing for channel 11:13 (in my case raw accelerometry)
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
cfg.cfg_freq.foi        = 2:0.5:8;                   % Frequency range you are interested in (usually 2:0.5:8, make sure you at least include 3-8 Hz)   
nFoi                    = length(cfg.cfg_freq.foi);  % Number of frequencies
cfg.cfg_freq.t_ftimwin  = repmat(2,1,nFoi);          % Wavelet length (seconds; 1 wavelet per frequency). For practical reasons usually take 2 second (which will contain enough time to detect tremor frequency)
cfg.cfg_freq.toi        = 'timedat';                 % Temporal resolution of you time-frequency representation (resolution in seconds) ('orig': original resolution; 'timedat': one step specified under conf.prepemg.timedat;)
cfg.cfg_freq.pad        = 'maxperlen';               % Padding (use 'maxperlen' for default)

% --- Coherence Analysis ('ft_connectivityanalsis') --- %

cfg.cfg_coh.output    = 'fourier';        % Frequency analysis previous to coherence analysis
cfg.cfg_coh.method    = 'mtmfft';         % Coherence analysis method ('mtmfft' for simple coherence)
cfg.cfg_coh.foi       = 2:0.5:8;          % Frequency range (usually same as cfg_freq.foi)
cfg.cfg_coh.tapsmofrq = 0.5;

end

%--------------------------------------------------------------------------

%% Frequency analysis ('prepemg')
%--------------------------------------------------------------------------

H = strfind(varargin,'prepemg');
if ~isempty([H{:}])
    pf_emg_raw2regr_prepemg(conf,cfg);
end

%--------------------------------------------------------------------------

%% Create regressor of frequency analyzed data ('mkregressor')
%--------------------------------------------------------------------------

H = strfind(varargin,'mkregressor');
if ~isempty([H{:}])
    pf_emg_raw2regr_mkregr(conf);
end

%--------------------------------------------------------------------------

%% Cooling Down
%--------------------------------------------------------------------------

T   =   toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T/60) ' minutes!!'])

%--------------------------------------------------------------------------






