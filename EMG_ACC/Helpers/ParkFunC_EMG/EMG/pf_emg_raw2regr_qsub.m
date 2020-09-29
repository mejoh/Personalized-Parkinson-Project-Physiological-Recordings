function pf_emg_raw2regr_qsub
%
% qsub application of the pf_emg_raw2regr function

% Michiel Dirkx
% $ParkFunC, 20150124

%% Confiugration

% --- Directories --- %

if ismac
    conf.dir.root    =   '/Users/michieldirkx/Dropbox/OFFON_relaunched/EMG/';   % Root Directory    
elseif ispc
    conf.dir.root   =   'H:\action\micdir\data\EMG\Cohort 2 - relaunched';
%     conf.dir.root   =   'D:\Dropbox\OFFON_relaunched\EMG';
elseif isunix
    conf.dir.root   =   '/home/action/micdir/data/EMG/Cohort 2 - relaunched';
end

conf.dir.raw     =   fullfile(conf.dir.root,'RAW');                         % Directory containing all the RAW BVA files
conf.dir.preproc =   fullfile(conf.dir.root,'FASTR');                        % Directory containing the preprocessed data (e.g. after FARM correction)
conf.dir.prepemg =   fullfile(conf.dir.preproc,'prepemg');                     % Directory containing the data and figures of 'prepemg'
conf.dir.onlyfa  =   fullfile(conf.dir.prepemg,'onlyfa');
conf.dir.regr    =   fullfile(conf.dir.preproc,'regressors');                  % Directory containing the regressors and figures
    
% --- Subjects --- %

conf.sub.name   =  {'p07';'p10';'p17';'p18';'p28'; %C2a: Good first round (clinical)
                    'p31';'p37';'p39';'p41';
                    'p26';'p29';'p32';'p38';'p11';
                    'p33';                         %C2a: Bad first round
                    
                    'S07';'S14';'S18';'S29';'S31'; %C2b: good first round
                    'S41';'S44';'S46';'S66';'S70';
                    'S12';'S24';'S38';'S47';'S50'; %C2b: bad first round
                    'S53';'S54';'S56';'S59';
                    };

conf.sub.sess   = {'OF';};                   % Specify the session in a cell structure (even if you have only one session)
conf.sub.run    = {'RS';};

% sel             = [16 17 18 20 ...
%                    21 22 23 24 25 ...
%                    26 27 28 29    ...
%                    31 32 33 34];                    
sel = 22;
conf.sub.name   = conf.sub.name(sel);     % Select the subjects

% --- Preprocess --- %

conf.preproc.meth     =   {'fastr'};                     % Choose method of preprocessing ('farm' or 'fastr')

conf.preproc.datfile  =   '/CurSub/&/CurSess/&/.eeg/';   % Choose name of your file (uses pf_findfile)
conf.preproc.mrkfile  =   '/CurSub/&/CurSess/&/.vmrk/';  % Marker file (uses pf_findfile)
conf.preproc.hdrfile  =   '/CurSub/&/CurSess/&/.vhdr/';  % Header file (uses pf_findfile)

conf.preproc.chan      =  1:2;                        % Channels you want to include
conf.preproc.channame  = {'Biceps (MA)'        ;'Triceps (MA)'    ;
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

% --- Prepemg --- %

conf.prepemg.meth     = {'seltremor';};

conf.prepemg.datfile  = '/CurSub/&/CurSess/&/.dat/';   % Data file name of preprocessed data (uses pf_findfile)
conf.prepemg.mrkfile  = '/CurSub/&/CurSess/&/.vmrk/';  % Marker file name of preprocessed data (uses pf_findfile)  
conf.prepemg.hdrfile  = '/CurSub/&/CurSess/&/.vhdr/';  % Hdr file name of preprocessed data (uses pf_findfile)

conf.prepemg.precut   = 'yes';    % If yes, it will cut out the data before the first volume marker. If you leave this as no, it should already be cut away        
conf.prepemg.sval     = 'R  1';      % Scan value in your marker file (usually 'V' after FARM);
conf.prepemg.tr       = 1.82;   % It will automatically detect this, but just as a check
conf.prepemg.dumscan  = 30;       % Dummyscans
conf.prepemg.prestart = 5;        % Scans before the start of your first scan (conf.prepemg.dumscan+1) you want to select (for example to account for the hanning taper, BOLD response etc). This data will be processed all the way, and only disregarded at the end of all analyses
conf.prepemg.timedat  = 0.0002;     % The resolution of the TFR in seconds (can be used for cfg.cfg_freq.toi)
conf.prepemg.chan     = {'Flexor';'Extensor'};
conf.prepemg.rawprep.chan     =  3;       % Only for Rawprep/broadband, for seltrem it is intersel

conf.prepemg.onlyfa   = 'yes';     % If yes, it will only perform frequency analysis and not intersel (useful for qsub)
conf.prepemg.onlyintersel = 'no';  % If yes, it will load FA data and only perform intersel


% --- Make Regressor --- %

conf.mkregr.file      = '/CurSub/&/CurSess/&/freqana/'; % Name of prepemg data
conf.mkregr.nscan     = 270;                            % Amount of scans your regressor should contain
conf.mkregr.sample    = 1;                              % Samplenr of every scan which will be used to represent the tremor during scan (if you used slice time correction, use the reference slice timing here)
conf.mkregr.zscore    = 'yes';                          % If yes, than the data will first be z-normalized
conf.mkregr.meth      = {'power';'amplitude';'log'};    % Choose methods for regressors ('power': simple power; 'amplitude': sqrt(pow); 'log': log10 transformed)
conf.mkregr.trans     = {'deriv1'};                     % Transformation of made regressors
conf.mkregr.save      = 'yes';                          % Save regressors/figures

conf.mkregr.plotcond  = 'no';                          % If you want to plot the condition (will use the same )
conf.mkregr.evefile   = '/CurSub/&/CurSess/&/M.vmrk/';   % Event file (if you want to plot the conditions
conf.mkregr.mrk.scan  = 'R  1';                         % Onset marker (if you want to plot events)
conf.mkregr.mrk.onset = 'S 11';                         % Onset marker (if you want to plot events)
conf.mkregr.mrk.offset= 'S 12';                         % Offset marker (if you want to plot events)                         

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

%--------------------------------------------------------------------------

%% Create individual batches
%--------------------------------------------------------------------------       

nSub        =   length(conf.sub.name);
nSess       =   length(conf.sub.sess);
nRun        =   length(conf.sub.run);
bch_conf    =   cell(nSub*nSess*nRun,1);
cnt         =   1;

cfg.sub.name    =   conf.sub.name;
% cfg.sub.hand    =   conf.sub.hand;
cfg.sub.sess    =   conf.sub.sess;
cfg.sub.run     =   conf.sub.run;

for a = 1:nSub
    conf.sub.name   =   cfg.sub.name(a);
%     conf.sub.hand   =   cfg.sub.hand(a);
    for b = 1:nSess
        conf.sub.sess = cfg.sub.sess(b);
        for c = 1:nRun
            conf.sub.run = cfg.sub.run(c);
            bch_conf{cnt}     =   conf;
            cnt = cnt+1;
        end
    end
end

%--------------------------------------------------------------------------       

%% Run the batch
%--------------------------------------------------------------------------       

% --- Run the batch using qsubcellfun --- %

pwd     =   cd;

logdir  =   '/home/action/micdir/Torque-log/C2b_FASTR_EMG_onlyfa_tr182';

if ~exist(logdir,'dir'); mkdir(logdir); end

cd(logdir)

for i = 1:length(bch_conf)
    
    qsubfeval('pf_emg_raw2regr',bch_conf{i},cfg,'prepemg','timreq',20*60,'memreq',12288*1000*1000,'memoverhead',12288*1000*1000);

end

cd(pwd)

%       varargin{1}    =   'preproc';
    %     varargin{1} =   'prepemg';
%     varargin{2} =   'mkregressor';
