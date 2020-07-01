function pf_emg_raw2regr(conf,cfg,varargin)
% pf_emg_raw2regr(conf,cfg,varargin) is a batch like function with the main
% goal to transform a raw EMG signal into a regressor describing tremor
% fluctuations to be used in a general linear model for fMRI analyses. The
% input is usually EMG signal after fMRI artifact reduction. The following
% functions can be used:
% 
%
% For fMRI artifact reduction of EMG signal see pf_emg_farm_ext

% � Michiel Dirkx, 2015
% $ParkFunC

%--------------------------------------------------------------------------

%% Warming Up
%--------------------------------------------------------------------------

if nargin<2
%         varargin{1}    =   'preproc';
        varargin{1} =   'prepemg';
%     varargin{1} =   'mkregressor';
end

%--------------------------------------------------------------------------

%% Configuration
%--------------------------------------------------------------------------

tic

if nargin<1
    
close all; clc; 
%NB: this configuration is incomplete, see EMG_batch_DRDR_patients for a
%recent batch
%==========================================================================    
% --- Directories --- %
%==========================================================================

if ismac
    conf.dir.root    =   '/Users/michieldirkx/Dropbox/OFFON_relaunched/EMG/';   % Root Directory    
elseif ispc
    conf.dir.root   =   'H:\action\micdir\data\EMG\Cohort 2 - relaunched';
%     conf.dir.root   =   'D:\Dropbox\OFFON_relaunched\EMG';
elseif isunix
    conf.dir.root   =   '/home/action/micdir/data/EMG/Cohort 2 - relaunched';
end

conf.dir.raw     =   fullfile(conf.dir.root,'RAW');                         % Directory containing all the RAW BVA files
conf.dir.preproc =   fullfile(conf.dir.root,'FARM');                        % Directory containing the preprocessed data (e.g. after FARM correction)
conf.dir.prepemg =   fullfile(conf.dir.preproc,'prepemg');                     % Directory containing the data and figures of 'prepemg'

conf.dir.onlyfa  =   fullfile(conf.dir.prepemg,'onlyfa');
conf.dir.regr    =   fullfile(conf.dir.preproc,'regressors');                  % Directory containing the regressors and figures

conf.dir.fmri.root    = '/home/action/micdir/data/DRDR_MRI/fMRI';           % fMRI root directory (containing all subject folders)
conf.dir.fmri.preproc = {'CurSub' 'func' 'CurSess' 'CurRun' 'preproc' 'norm'};                        % Preproc folder for detecting amount of scans

%==========================================================================
% --- Subjects --- %
%==========================================================================

conf.sub.name   =  {'p07';'p10';'p17';'p18';'p28'; %C2a: Good first round (clinical)
                    'p31';'p37';'p39';'p41';
                    'p26';'p29';'p32';'p38';'p11';
                    'p33';                         %C2a: Bad first round
                    
                    'S07';'S14';'S18';'S29';'S31'; %C2b: good first round
                    'S41';'S44';'S46';'S66';'S70';
                    'S12';'S24';'S38';'S47';'S50'; %C2b: bad first round
                    'S53';'S54';'S56';'S59';'S34';
                    };

conf.sub.sess   = {'OF';'ON'};                   % Specify the session in a cell structure (even if you have only one session)
conf.sub.run    = {'RS';};

sel             = [35];                    

conf.sub.name   = conf.sub.name(sel);     % Select the subjects

%==========================================================================
% --- Preprocess --- %
%==========================================================================

conf.preproc.meth     =   {
                           'fastr';
                           'combifile'; % This will combine two Brainvision files (useful for combining Accelerometer and EMG signal)
                           };                     % Choose method of preprocessing ('farm' or 'fastr')

% --- FARM/FASTR --- %                       
                       
conf.preproc.datfile  =   '/CurSub/&/CurSess/&/.eeg/';   % Choose name of your file (uses pf_findfile)
conf.preproc.mrkfile  =   '/CurSub/&/CurSess/&/.vmrk/';  % Marker file (uses pf_findfile)
conf.preproc.hdrfile  =   '/CurSub/&/CurSess/&/.vhdr/';  % Header file (uses pf_findfile)

conf.preproc.chan      =  1:2;                        % Channels you want to include
conf.preproc.channame  = {'Biceps (MA)'        ;'Triceps (MA)'    ; % NOT IMPLEMENTED YET
                          'Ext. digitorum (MA)';'Flex. carpi (MA)';
                          'Abd. pollicis (MA)' ;'Ext. digitorum (LA)';
                          'Flex. carpi (LA)';};                      
                      
conf.preproc.filt.meth     =  'pre';    % Choose 'pre' or 'post' if you want to filter with a bandpass filter before MR correcting or after MR correcting
conf.preproc.filt.low      =   30;      % Lower cutoff of bp filter
conf.preproc.filt.high     =   250;     % Higher cutoff of bp filter

conf.preproc.fastr.lpf      =   0;    % FASTR: low-pass filter
conf.preproc.fastr.interp   =   10;   % FASTR: interpolation factor
conf.preproc.fastr.avgwin   =   12;   % FASTR: average artifacts in sliding window
conf.preproc.fastr.etype    = 'R  1'; % FASTR: event type of slice or volume
conf.preproc.fastr.strig    =   0;    % FASTR: 0 for Volume triggers, 1 for slice triggers
conf.preproc.fastr.anc      =   0;    % FASTR: 1 for ANC, 0 for no ANC
conf.preproc.fastr.trigcorr =   0;    % FASTR: 1 to correct for missing triggers, 0 to not correct
conf.preproc.fastr.vol      =   [];   % FASTR: needed if trigcorr = 1, otherwise []
conf.preproc.fastr.slice    =   [];   % FASTR: same but then for slices, otherwise []
conf.preproc.fastr.prefrac  =   0.03; % FASTR: delay of actual artifact compared to trigger, default 0.03
conf.preproc.fastr.exchan   =  [1 2];   % FASTR: channels to exclude from OBS (usually EMG...)
conf.preproc.fastr.npc      = 'auto'; % FASTR: number of principal components (default 'auto')            

% --- Combifile --- %

% conf.preproc.datfile  =   '/CurSub/&/CurSess/&/.eeg/';   % Choose name of your file (uses pf_findfile)
% conf.preproc.mrkfile  =   '/CurSub/&/CurSess/&/.vmrk/';  % Marker file (uses pf_findfile)

conf.preproc.hdrfile  =   {                                             % Specify here the files you want to combine (first column indicates folder within the root directory, second column the search criterium; start a new row for every additional file)
                           'FARM'   '/CurSub/&/CurSess/&/CurRun/&/.vhdr/';
                           'RAW'   '/CurSub/&/CurSess/&/CurRun/&/.vhdr/';
                            };  % Header file (uses pf_findfile)

conf.preproc.chans    =    {             % Channels (every row corresponds to conf.preproc.hdrfile)
                            1:7;
                            11:13;
                            };
conf.preproc.save     =   fullfile(conf.dir.root,'COMBIFARM');
                        
%==========================================================================
% --- Prepemg --- %
%==========================================================================

conf.prepemg.meth     = {'seltremor';};

conf.prepemg.datfile  = '/CurSub/&/CurSess/&/.dat/';   % Data file name of preprocessed data (uses pf_findfile)
conf.prepemg.mrkfile  = '/CurSub/&/CurSess/&/.vmrk/';  % Marker file name of preprocessed data (uses pf_findfile)  
conf.prepemg.hdrfile  = '/CurSub/&/CurSess/&/.vhdr/';  % Hdr file name of preprocessed data (uses pf_findfile)

conf.prepemg.precut   = 'yes';    % If yes, it will cut out the data before the first volume marker. If you leave this as no, it should already be cut away        
conf.prepemg.sval     = 'R  1';      % Scan value in your marker file (usually 'V' after FARM);
conf.prepemg.tr       = 1.82;   % Either 'detect' to base it off of the marker, or fill out a TR
conf.prepemg.dumscan  = 30;       % Dummyscans
conf.prepemg.prestart = 5;        % Scans before the start of your first scan (conf.prepemg.dumscan+1) you want to select (for example to account for the hanning taper, BOLD response etc). This data will be processed all the way, and only disregarded at the end of all analyses
conf.prepemg.timedat  = 0.0002;     % The resolution of the TFR in seconds (can be used for cfg.cfg_freq.toi)
conf.prepemg.chan     = {'Flexor';'Extensor'};
conf.prepemg.rawprep.chan     =  3;       % Only for Rawprep/broadband, for seltrem it is intersel

conf.prepemg.onlyfa   = 'no';     % If yes, it will only perform frequency analyspis and not intersel (useful for qsub)
conf.prepemg.onlyintersel = 'no';  % If yes, it will load FA data and only perform intersel

%==========================================================================
% --- Make Regressor --- %
%==========================================================================

conf.mkregr.file      = '/CurSub/&/CurSess/&/freqana/'; % Name of prepemg data
conf.mkregr.nscan     = 'detect';                       % Amount of scans your regressor should contain ('detect' to detect the amount in conf.dir.fmri.preproc)
conf.mkregr.sample    = 430;                              % Samplenr of every scan which will be used to represent the tremor during scan (if you used slice time correction, use the reference slice timing here)
conf.mkregr.zscore    = 'yes';                          % If yes, than the data will first be z-normalized
conf.mkregr.meth      = {'power';'amplitude';'log'};    % Choose methods for regressors ('power': simple power; 'amplitude': sqrt(pow); 'log': log10 transformed)
conf.mkregr.trans     = {'deriv1'};                     % Transformation of made regressors
conf.mkregr.save      = 'yes';                          % Save regressors/figures

conf.mkregr.plotcond  = 'no';                          % If you want to plot the condition (will use the same )
conf.mkregr.evefile   = '/CurSub/&/CurSess/&/M.vmrk/';   % Event file (if you want to plot the conditions
conf.mkregr.mrk.scan  = 'R  1';                         % Onset marker (if you want to plot events)
conf.mkregr.mrk.onset = 'S 11';                         % Onset marker (if you want to plot events)
conf.mkregr.mrk.offset= 'S 12';                         % Offset marker (if you want to plot events)                         

conf.mkregr.scanname  = '|w*';                       % search criterium for images (only if conf.mkregr.nscan = 'detect');

%=========================================================================%
%======================== FieldTrip Configuration ========================%
%=========================================================================%

% --- Preprocessing --- %

cfg.cfg_pre     =   [];
cfg.cfg_pre.continuous  =   'yes'; % Load all data, select later
cfg.cfg_pre.hpfilter	=	'no';  % High-pass filter, usually done during FARM
cfg.cfg_pre.hpfreq		=	20;    % HPF frequency
cfg.cfg_pre.rectify		=	'yes';  % Rectify for tremor burst and to regain low frequencies
cfg.cfg_pre.bpfilter    =   'no';  % BP filter, usually used for hilbert
cfg.cfg_pre.bpfreq      =   20;     % BPF frequecy
cfg.cfg_pre.hilbert     =   'no';   % Hilbert PS (for PS of envelope, I think its the same as rectify)  

% --- Frequency Analysis --- %

cfg.cfg_freq.method   = 'mtmconvol';          % Select method (choose 'mtmconvol')
cfg.cfg_freq.output   = 'pow';                % power  
cfg.cfg_freq.taper    = 'hanning';            % Windowing (because cut-off frequency), (Choose 'hanning' for low frequency)
cfg.cfg_freq.foi      =  1:0.5:20;            % frequency range you are interested in (usually 1:0.5:20, make sure you at least include 3-8 Hz)   
nFoi                  =  length(cfg.cfg_freq.foi);
cfg.cfg_freq.t_ftimwin  = repmat(1.82,1,nFoi);    % Wavelet length (seconds; 1 wavelet per frequency). This is important also for your NaN in the hanning taper (which is 0.5*this)
cfg.cfg_freq.tapsmofrq  = repmat(0.5,1,nFoi);     % Frequency smoothing (Choose 0.5 Hz, that is, if your frequency range is in steps of 0.5 Hz)
cfg.cfg_freq.toi        = 'timedat';                   % timeline the TFR (resolution in seconds)
cfg.cfg_freq.pad        = 'maxperlen';                % Padding (use 'maxperlen')
cfg.cfg_freq.keeptrials = 'no';                       % Delete trials
cfg.cfg_freq.keeptapers = 'no';               
%Broadband%
cfg.cfg_freqbb.avgoverfreq = 'yes';
cfg.cfg_freqbb.foilim      = [20 200];            % Frequencies you want to average

end

%--------------------------------------------------------------------------

%% Preprocessing of EMG (removing MR artifacts)
%--------------------------------------------------------------------------

H = strfind(varargin,'preproc');
if ~isempty([H{:}])
    pf_emg_raw2regr_preproc(conf);
end

%--------------------------------------------------------------------------

%% FT: Create TFR and plot mean PS
%--------------------------------------------------------------------------

H = strfind(varargin,'prepemg');
if ~isempty([H{:}])
    pf_emg_raw2regr_prepemg(conf,cfg);
end

%--------------------------------------------------------------------------

%% Create regressor of frequency analyzed data
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






