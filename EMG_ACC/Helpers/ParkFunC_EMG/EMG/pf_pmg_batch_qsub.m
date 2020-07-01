function pf_pmg_batch_qsub(conf)
% pf_pmg_batch_qsub(conf) is the qsub extension of the pf_pmg_batch.
%
% See also pf_pmg_batch, ft_qsub

% Michiel Dirkx, 2015
% $ParkFunC, version 20150629

%--------------------------------------------------------------------------

%% Static Configuration
%--------------------------------------------------------------------------

%==========================================================================    
% --- Directories --- %
%==========================================================================

if ismac
    conf.dir.root     =   '/Users/michieldirkx/Documents/Tremor PMG';                   % Root directory ('all')
elseif isunix
    conf.dir.root     =   '/home/action/micdir/data/PMG';                   % Root directory ('all')
end

conf.dir.raw      =   fullfile(conf.dir.root,'RAW');                    % Directory containing the RAW files ('all')
conf.dir.prepraw  =   fullfile(conf.dir.root,'prepraw','Raw2Curmont');  % Directory where the files created with 'prepraw' will be stored ('prepraw')
conf.dir.plotedf  =   conf.dir.prepraw;                                 % Directory containing the files which need to be plot with plotedf ('plotedf')

conf.dir.ftsource =   conf.dir.prepraw;                                 % Directory containing files used for the FieldTrip analyses ('ftana')
conf.dir.figsave  =   fullfile(conf.dir.root,'analysis','Figures','Coherence'); % Directory where the fieldtrip analyses figures will be stored ('ftana')
conf.dir.datsave  =   fullfile(conf.dir.root,'analysis','Data');                         % Directory where the fieldtrip analyses will be stored ('ftana')

%==========================================================================    
% --- Subjects --- %
%==========================================================================

conf.sub.name    =   {'p01';'p02';'p03';'p04';'p05';'p06';'p07';'p08';'p09';'p10';
					  'p11';'p12';'p13';'p14';'p15';'p16';'p17';'p18';'p19';'p20';
                      'p21';'p22';'p23';'p24';'p25';'p26';'p27';'p28';'p29';'p30';
					  'p31';'p32';'p33';'p34';'p35';'p36';'p37';'p38';'p39';'p40';
					  'p41';'p42';'p43';'p44';'p45';'p46';'p47';'p48';'p49';'p50';
                      'p51';'p52';'p53';'p54';'p55';'p56';'p57';'p58';'p59';'p60';
                      'p61';'p62';'p63';'p64';'p65';'p66';'p67';'p68';'p69';
                      };
conf.sub.hand    =   {  'L';'R'  ;'R'  ;'L'  ;'L'  ;'L'  ;'R'  ;'R'  ;'R'  ;'L'  ;
                        'R';'L'  ;'R'  ;'R'  ;'L'  ;'R'  ;'R'  ;'L'  ;'L'  ;'R'  ;
                        'R';'R'  ;'R'  ;'R'  ;'L'  ;'L'  ;'R'  ;'L'  ;'R'  ;'R'  ;
                        'R';'L'  ;'R'  ;'R'  ;'L'  ;'R'  ;'L'  ;'L'  ;'R'  ;'R'  ;
                        'L';'L'  ;'L'  ;'L'  ;'L'  ;'R'  ;'L'  ;'R'  ;'L'  ;'L'  ;
                        'L';'L'  ;'R'  ;'R'  ;'R'  ;'R'  ;'R'  ;'R'  ;'L'  ;'L'  ;
                        'L';'L'  ;'L'  ;'L'  ;'R'  ;'R'  ;'R'  ;'R'  ;'L'  ;
                        };            % Side the patient was measured ('L'=left; 'R'=right)
conf.sub.sess	 =   {'OFF';'ON';};

% sel = [3:6 8:11 13:17 19:25 27:39 41:48]; % Christmas patients
% sel = [2 7 12 18 26 40 49:54 56:69];      % Spring patients
% sel   = [2:54 56:69];                               % All included

sel     =   [2:4];

conf.sub.name = conf.sub.name(sel);
conf.sub.hand = conf.sub.hand(sel);

%==========================================================================    
% --- Preparing raw files ('prepraw') --- %
%==========================================================================

conf.prepraw.meth   =   {
%                            'sig2edf'; % Convert files created with signal (mat files) to EDF+ (NB: NOT WORKING YET)
                           'cremont'; % Create a specific montage
%                          'edfmerge'; % Merge multiple EDF files into a single EDF file
                         };

conf.prepraw.file   =   '/CurSub/&/CurSess/&/RAW/&/revised1/';      % File names used for prepraw (uses pf_findfile)
                     
% --- Create Montage --- %

conf.prepraw.cremont.mont   =   {
                                  'EEG 1-2'    'EEG 1-REF' 'EEG 2-REF' ;   % R-EMG
                                  'EEG 3-4'    'EEG 3-REF' 'EEG 4-REF' ;
                                  'EEG 5-6'    'EEG 5-REF' 'EEG 6-REF' ;
                                  'EEG 7-8'    'EEG 7-REF' 'EEG 8-REF' ;
                                  'EEG 9-10'   'EEG 9-REF' 'EEG 10-REF';
                                  'EEG 11-12'  'EEG 11-REF' 'EEG 12-REF';
                                  'EEG 13-14'  'EEG 13-REF' 'EEG 14-REF';
                                  
                                  'EEG 33-34'  'EEG 33-REF' 'EEG 34-REF';  % L-EMG
                                  'EEG 35-36'  'EEG 35-REF' 'EEG 36-REF';
                                  'EEG 37-38'  'EEG 37-REF' 'EEG 38-REF';
                                  'EEG 39-40'  'EEG 39-REF' 'EEG 40-REF';
                                  'EEG 41-42'  'EEG 41-REF' 'EEG 42-REF';
                                  'EEG 43-44'  'EEG 43-REF' 'EEG 44-REF';
                                  'EEG 45-46'  'EEG 45-REF' 'EEG 46-REF';
                                  
                                  'EEG 31-32'  'EEG 31-REF' 'EEG 32-REF';   % ACC
                                  'EEG 61-62'  'EEG 61-REF' 'EEG 62-REF';
                                  
                                  'EEG 63-64'  'EEG 63-REF' 'EEG 64-REF';   % ECG
                                    };           %Montage you want to build: R1C1: new name, R1C2: active electrode, R1C3: reference electrode, these will be subtracted from each other.

conf.prepraw.cremont.handchan   =   {
                                      'R' [1:7 11:12 15:17];  
                                      'L' [4:5 8:14 15:17];  
                                    };             % Indicate here the handness specicifity. Specify a new row for each hand definition. The first column indicates the hand, the right column which channels (indicated in conf.prepraw.cremont.mont) will be selected for this hand. Example: 'R' [1:7];)
conf.prepraw.cremont.montname   =   'Raw2CurMont'; % Name of montage (will be added to the new filenames, will replace RAW if this is present in the name, otherwise will add it)
conf.prepraw.cremont.plot       =   'ye';         % if yes, then it will plot the reference, active and new channel of the whole montage.

% --- MergeEDF --- %

conf.prepraw.edfmerge.addfiles  =   {
                                      '/CurSub/&/CurSess/&/RAW/&/revised11/';
                                     }; % Files, which together with conf.preproc.file, will be merged
conf.prepraw.edfmerge.addevent  =   'yes'; % If yes, then it will add up the starttimes of the addfiles events to the length of the basefile. If not, the original starttime in both files will be used.

%==========================================================================    
% --- FieldTrip Analyses --- %
%==========================================================================

% --- General --- %

conf.ft.meth    =   {
                     'freqana';     % Frequency analysis using FieldTrip
%                      'reanalyze'; % reanalyze data using data derived from 'freqana' and previously selected data as input
%                      'plot';      % Plot frequency analysed data
                    };

conf.ft.chans   =   {
                    'EEG 1-2'    'R-Deltoideus';    % 1      % Channel name (as labeled by the headbox) followed by your own name. Use a new row for every new channel, and a new column for your own name. Leave blanc ('') if original channel names used.
                    'EEG 3-4'    'R-Biceps';        % 2      
                    'EEG 5-6'    'R-Triceps';       % 3 
                    'EEG 7-8'    'R-EDC';           % 4
                    'EEG 9-10'   'R-FCR';           % 5
                    'EEG 11-12'  'R-ABP';           % 6
                    'EEG 13-14'  'R-FID1';          % 7
                    'EEG 33-34'  'L-Deltoideus';    % 8
                    'EEG 35-36'  'L-Biceps';        % 9                
                    'EEG 37-38'  'L-Triceps';       % 10
                    'EEG 39-40'  'L-EDC';           % 11
                    'EEG 41-42'  'L-FCR';           % 12
                    'EEG 43-44'  'L-ABP';           % 13
                    'EEG 45-46'  'L-FID1';          % 14
                    'EEG 31-32'  'R-ACC';           % 15
                    'EEG 61-62'  'L-ACC';           % 16
                    'EEG 63-64'  'ECG';             % 17
                    };

conf.ft.file       =   '/CurSub/&/CurSess/&/Raw2CurMont/&/revised1/';      % File names (uses pf_findfile located in conf.dir.ftsource)
conf.ft.savefile   =   'freqana_powspct_mtmconvol-10s_sub2-6_rest-coco-moco.mat';                    % Name it will be saved to (if conf.ft.save='yes') or will be loaded from (if conf.ft.load='yes')
conf.ft.load       =   'no';                
                   
% --- Frequency Analysis --- %                

conf.ft.save       =   'yes';                                             % Save the frequency analyzed data
conf.ft.saveasmat  =   'no';                                              % If yes, then the freqana data will be saved as a matrix instead of a structure (backwards compatiblity function, in principle this should always be yes).

conf.ft.fa.cond    =  {                             % Conditions you want to include
%                        'EntrL' 
%                        'EntrM' 
%                        'IntentL' 
%                        'IntentM' 
%                        'POSH1' 
%                        'POSH2' 
%                        'POST1' 
%                        'POST2' 
%                        'POSW1' 
%                        'POSW2' 
                       'Rest1' 
                       'Rest2' 
                       'Rest3' 
                       'RestCOG1' 
                       'RestCOG2' 
                       'RestCOG3' 
                       'RestmoL1'     
                       'RestmoL2'    
                       'RestmoL3' 
                       'RestmoM1' 
                       'RestmoM2' 
                       'RestmoM3'
                                 };      
conf.ft.fa.prepostwin  = [0 0]; % Pre and post window (in seconds) before and after the start/stop of your conditions                           
                             
%Preproc% 
conf.fa.chandef =   {
                      1:14;  % Channel 1:14 is EMG %% NB: at the moment you can only do multiple rounds of preprocessing (lets say bp>rectify>hp) with one SET of channels
                      1:14;  % second round of preprocessing
                      1:14;  % third round of preprocessing
                      15:16; % Channel 15:16 are ACC
                      17;    % Channel 17 is ECG
                    };       % Define the different preprocessing for the channels here. For every row define the channel name and then the structure index defined in conf.fa.cfg.preproc{i}. The different processed channels will be appended later on.

conf.ft.fa.cfg.preproc{1}               = [];           % For every set of channels (nRows in conf.fa.chandef) you must here define the preprocessing methods 
conf.ft.fa.cfg.preproc{1}.continuous    = 'yes';
conf.ft.fa.cfg.preproc{1}.demean        = 'yes';        
conf.ft.fa.cfg.preproc{1}.detrend       = 'yes';
conf.ft.fa.cfg.preproc{1}.bpfilter      = 'yes';
conf.ft.fa.cfg.preproc{1}.bpfreq        = [20 200];
conf.ft.fa.cfg.preproc{2}.continuous    = 'yes';
conf.ft.fa.cfg.preproc{2}.rectify       = 'yes';
conf.ft.fa.cfg.preproc{3}.continuous    = 'yes';
conf.ft.fa.cfg.preproc{3}.hpfilter      = 'yes';
conf.ft.fa.cfg.preproc{3}.hpfreq        = 2;

conf.ft.fa.cfg.preproc{4}               = [];
conf.ft.fa.cfg.preproc{4}.continuous    = 'yes';
conf.ft.fa.cfg.preproc{4}.bpfilter      = 'yes';
conf.ft.fa.cfg.preproc{4}.bpfreq        = [1 40];

conf.ft.fa.cfg.preproc{5}               = [];
conf.ft.fa.cfg.preproc{5}.continuous    = 'yes';
conf.ft.fa.cfg.preproc{5}.demean        = 'yes';        
conf.ft.fa.cfg.preproc{5}.detrend       = 'yes';

%FreqAna%
conf.ft.fa.cfg.freq.method              = 'mtmconvol'; % Choose a method ('mtmfft' or 'mtmconvol')
conf.ft.fa.cfg.freq.output              = 'pow';       % Output ('pow' is powerspectrum; 'fourier': bare frequency domain)
conf.ft.fa.cfg.freq.foi                 = 1:0.1:16; % frequency range you are interested in NB can I use foilim with this taper??
conf.ft.fa.cfg.freq.taper               = 'hanning';   % Taper ('dpss': multitaper; 'Hanning': single taper
nFoi                                    = length(conf.ft.fa.cfg.freq.foi); 
% conf.ft.fa.cfg.freq.tapsmofrq           = 0.1;
conf.ft.fa.cfg.freq.toi                 = [10 20 30 40 50 60];
% conf.ft.fa.cfg.freq.toi                 = 'orig';   % times on which the analysis window should be centered (in seconds). Define 'orig' to use the original timepoints (every sample).
% conf.ft.fa.cfg.freq.tapsmofrq           = repmat(0.5,1,nFoi);   % Smoothing
conf.ft.fa.cfg.freq.t_ftimwin           = repmat(10,1,nFoi);     % vector 1 x nFoi, length of time window (in seconds)
conf.ft.fa.avgfreq                      = 'no';        % If you specify this as yes, it will only save the average time spectrum and not the whole TFR (only applies for 'mtmconvol')

%Optional1:redefinetrial%
conf.ft.fa.cfg.trialdef.on              = 'no';    % If you want to cut the data into nTrials you can specify this option as 'yes'. Below you can specify in which datasegments you want to cut them.
conf.ft.fa.cfg.trialdef.trl             = 10;       % Specify here the length of the new datasegments (i.e. if you specify 10 then the data will be cut in segments of 10s)

%Optional2:tempcorrelationchans%
conf.ft.fa.cfg.corrchans.on             = 'no';     % If you want to correlate channels in the temporal domain with each other you can specify 'yes' here 
conf.ft.fa.cfg.corrchans.which          = {
                                           conf.ft.chans(1:7) conf.ft.chans(15); 
                                           conf.ft.chans(8:14) conf.ft.chans(16);
                                           };       % Specify here which channels you want to correlate with each other. For each row specify in the first column the channels (multiple) which will be correlated with the channel (one channel) in the second column)

%Optional3:coherenceanalysis%               % For this, you need to adjust the settings of the frequency analysis accordingly
conf.ft.fa.cohana.on                    = 'no'; % If specified yes, it will perform a coherence analysis
conf.ft.fa.cohana.cfg.method            = 'coh'; % Specify 'coh' for coherence analysis
conf.ft.fa.cohana.cfg.channelcmb        = {
                                           conf.ft.chans(1:7)' conf.ft.chans(15);
                                           conf.ft.chans(8:14)' conf.ft.chans(16);  
                                          }; % Channels you want to performe a coherence analysis over. In the left column specify the channels (multiple) which you want to cohere with the channel on the right column (one). It will detect the presense of these channels in the freqana data and only select those which are present.
                                       
% --- Reanalyze --- %

conf.ft.reanalyze.input                 = '/home/action/micdir/data/PMG/analysis/Data/peaksel_coco_rest_acc_newmaycombined.mat'; % Fullfile of the peak selection datafile
conf.ft.reanalyze.savename              = 'peaksel_2_7_12_18_26_40_49-54_56-69';                                                            % The new peaksel data will be saved with this name
% conf.ft.reanalyze.input                 =  '/home/action/micdir/data/PMG/analysis/powspct_dat/Ana_seltremor-move_Rest-CoCo-MoCo_first_total.mat';
% conf.ft.reanalyze.savename              = 'peaksel_3-6_8-11_13-17_19-25_27-39_41-48_bp1-40';
conf.ft.reanalyze.savefig               = 'yes';         % Save the figures
conf.ft.reanalyze.savefigname           = {'REST';'COCO'}; % Name will be pasted after CurSub-CurSess
conf.fa.reanalyze.figext                = '-dtiff';      % Extension format of saved figure (e.g. '-dtiff'; see print)
conf.fa.reanalyze.figres                = '-r800';       % Resolution of saved figure (e.g. '-r100'; see print)

%==============%
% --- Plot --- %
%==============%

% --- General --- %

conf.fa.fig.meth            = {
                               'powspct';
%                                'tfr'; % Written long time ago, probably needs some debugging
%                                'coh'    % Simpel plot of coherence analysis
                               };           % Choose what to display of the frequency analysis performed ('subpowspect': plot the power spectra of individual subjects (see pf_pmg_plot_powspct); 'avgpowspct': plot powerspectrum averaged over subjects; )
                           

conf.fa.fig.chan            = conf.ft.chans(15:16); % Enter the channel names you want to plot (you can use conf.ft.chans for this), if you specified a coherence analysis it will look for the channels in the left column
conf.fa.fig.plot{1}         = {
                               {'OFF','Rest1'} {'OFF','Rest2'} {'OFF','Rest3'};             % Choose the subplots for one figure. Specify a cell containing MxN cells containing the field names of the data you want to plot.
                               {'ON','Rest1'} {'ON','Rest2'} {'ON','Rest3'} ;
                               };
conf.fa.fig.plot{2}         = {
                               {'OFF','RestCOG1'} {'OFF','RestCOG2'} {'OFF','RestCOG3'};
                               {'ON','RestCOG1'} {'ON','RestCOG2'} {'ON','RestCOG3'} ;
                               };
conf.fa.fig.plot{3}         = {
                               {'OFF','RestmoL1'} {'OFF','RestmoL2'} {'OFF','RestmoL3'};
                               {'ON','RestmoL1'} {'ON','RestmoL2'} {'ON','RestmoL3'} ;
                              };
conf.fa.fig.plot{4}         = {
                               {'OFF','RestmoM1'} {'OFF','RestmoM2'} {'OFF','RestmoM3'};
                               {'ON','RestmoM1'} {'ON','RestmoM2'} {'ON','RestmoM3'} ;
                              };                          
% conf.fa.fig.plot{4}         = {
%                                {'OFF','EntrM'} {'OFF','EntrL'};
%                                {'ON','EntrM'}  {'ON','EntrL'}    
%                                };
% conf.fa.fig.plot{5}         = {
%                                {'OFF','EntrM'} {'OFF','EntrL'};
%                                {'ON','EntrM'}  {'ON','EntrL'}    
%                                };                           


conf.fa.fig.avg.on            = 'ye';       % Choose yes if you want a figure which is averaged over all subjects ('no' or 'yes')
conf.fa.fig.avg.chancombi     = {
                                  'R' conf.ft.chans([1:7  11:12 15 16]);
                                  'L' conf.ft.chans([8:14 4:5   16 15]);
                                };            % When you average, you can deal with handedness of patients here. specify a cell with nHand rows. For each row you specify the handedness in the first column and in the second column the channels to include. Do this for both hands and match the order of channels in the second column

conf.fa.fig.backcol           = [0.2 0.2 0.2];    % Set the background color of your figures (RGB, e.g. [1 1 1] is defualt white)
conf.fa.fig.ax				  = '';	      	% Choose how you want to build your figure axis (see pf_adjustax), leave '' if default
conf.fa.fig.col               = 'prism';      % Choose color spectrum (e.g. hot, hsv, prism etc.)

conf.fa.fig.save              = 'no';         % Choose if you want to save your figures
conf.fa.fig.savename          = {'EMG_COCO_mtmconvol_han10s-cent10s';'EMG_REST_mtmconvol_han10s-cent10s';}; % For every plot (conf.fa.fig.plot), text will be placed after CurSub_CurHand (e.g. p01_R
conf.fa.fig.saveext           = '-dtiff';     % Extension format of saved figure (e.g. '-dtiff'; see print)
conf.fa.fig.saveres           = '-r800';      % Resolution of saved figure (e.g. '-r100'; see print)

% --- PowSpct --- %

conf.fa.fig.pow.graph         = 'plot';       % Choose method of displaing the powerspcetrum ('plot': simple 2D plot)

conf.fa.fig.pow.peaksel.onoff     = 'off';       % Choose if you want to perform a peak selection ('on')
conf.fa.fig.pow.peaksel.peakdef   = 'single';      % Choose the peak definition ('single': only a single peak; 'auc': area under the curve)
conf.fa.fig.pow.peaksel.aucdef    = 'div2';     % If you chose 'auc' for conf.fa.fig.peaksel.peakdef, indicate what the method is for this ('div2': AUC of the curve defined by peak +- powerpeak/2)

conf.fa.fig.peaksel.savefile  = 'peaksel_coco_rest_acc_addsubs'; % Filename of the file where data retrieved from peaksel will be saved to

% --- Coherence plot 'coh' --- %

%NOTETOSELF: implement a nice way to match channels between left and right
%handed subject, now there is a situation specific indexcode which will
%only work if you performed freqana on all available channels.

conf.fa.fig.coh.graph         = 'contourf';   % Coohse the way you want to plot the coherence spectrum ('plot': simple plot; 'contourf': contourf plot)

%==========================================================================    
% --- Additional Utilities --- %
%==========================================================================

conf.util.meth     =    {
%                          'convertpeaksel';  % Utility to convert the matrix data of peaksel into a Heidi friendly version
                         'plotedf';         % Utility to simply plot data stored in a EDF+ file
                        };
                    
% --- ConvertPeaksel --- %

% conf.util.convert.meth                = 'heidiknowsbest';  % Method of conversion ('heidiknowsbest': convert into heidi friendly format)
conf.util.convert.input               = '/home/action/micdir/data/PMG/analysis/Data/peaksel_reanalyze_christmasspringcombi_bp2-40.mat'; % peaksel file that needs to be converted
% conf.ft.convert.input               = '/home/action/micdir/data/PMG/analysis/powspct_dat/peaksel_2_7_12_18_26_40_49-54_56-69_bp1-40.mat';
conf.util.convert.savename            = 'peaksel_spring_bp2-40_convert_MAhand.mat';

% --- Plot EDF --- %

conf.util.plotedf.file   =   '/CurSub/&/CurSess/&/Raw2CurMont/&/revised1/';      % File name of the raw dataset (in conf.dir.plotedf) which needs to be plotted (uses pf_findfile)
conf.util.plotedf.chans   =   {
                          'EEG 1-2'    'R-Deltoideus';    % 1      % Channel name you want to plot (as labeled by the headbox) followed by your own name (used for title of the plot. Use a new row for every new channel, and a new column for your own name. Leave blanc ('') if original channel names used.
                          'EEG 3-4'    'R-Biceps';        % 2      
                          'EEG 5-6'    'R-Triceps';       % 3 
                          'EEG 7-8'    'R-EDC';           % 4
                          'EEG 9-10'   'R-FCR';           % 5
                          'EEG 11-12'  'R-ABP';           % 6
                          'EEG 13-14'  'R-FID1';          % 7
                          'EEG 33-34'  'L-Deltoideus';    % 8
                          'EEG 35-36'  'L-Biceps';        % 9                
                          'EEG 37-38'  'L-Triceps';       % 10
                          'EEG 39-40'  'L-EDC';           % 11
                          'EEG 41-42'  'L-FCR';           % 12
                          'EEG 43-44'  'L-ABP';           % 13
                          'EEG 45-46'  'L-FID1';          % 14
                          'EEG 31-32'  'R-ACC';           % 15
                          'EEG 61-62'  'L-ACC';           % 16
                          'EEG 63-64'  'ECG';             % 17
                        };

conf.util.plotedf.rsp     =  2;                    % Amount of subplots in each row     

%--------------------------------------------------------------------------

%% Create dynamic configurations 
%--------------------------------------------------------------------------

nSub     =  length(conf.sub.name);
bch_conf =  cell(nSub,1);  
cnt      =  1;

for a = 1:nSub
   
   cfg             = conf;
   cfg.sub.name    = cfg.sub.name(a); 
   cfg.sub.hand    = cfg.sub.hand(a); 
   CurSub          = conf.sub.name{a};
   cfg.ft.savefile = ['freqana_mtmconvol-dat10s-win2s_' CurSub '.mat'];
   fprintf('%s\n',['Creating batch for ' CurSub]);
   
   bch_conf{cnt} = cfg;
   cnt           = cnt+1;
   
end

%--------------------------------------------------------------------------       

%% Run the batch
%--------------------------------------------------------------------------       

% --- Run the batch using qsubcellfun --- %

pwd     =   cd;

logdir  =   '/home/action/micdir/Torque-log/PMG/freqana_mtmconvol10s';

if ~exist(logdir,'dir'); mkdir(logdir); end

cd(logdir)

for i = 1:length(bch_conf)
    
    qsubfeval('pf_pmg_batch',bch_conf{i},'ftana','timreq',0.25*60*60,'memreq',12288*1000*1000,'diary','always');
    
end

cd(pwd)

%--------------------------------------------------------------------------       





