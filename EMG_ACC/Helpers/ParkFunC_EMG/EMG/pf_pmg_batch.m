function pf_pmg_batch(conf,varargin)
% pf_pmg_batch(conf,varargin) is a batch like function to process and
% analyze PMG data, that is EMG + Accelerometer data. Specify any of the
% following options (as varargin)
%   - 'prepraw': process your raw data in order to make it ready for
%                analyses (e.g. change the montage, resample etc).
%                Following options can be specified in conf.prepraw.meth:
%                - 'cremont': create a new montage of the channel.
%                - 'edfmerge': merge EDF+ files into one EDF+ file.
%   - 'ftana'  : Perform frequency analysis using FieldTrip.
%                Following options can be specified in conf.ft.meth:
%                - 'freqana': frequency analyze a dataset using FieldTrip
%                - 'plot': plot this freqana data in various ways and (if
%                          specified) interactively select data. 
%                - 'reanalyze': reanalyze freqana data using a previous
%                          peak selection performed with 'plot'. This is
%                          useful if you performed a peakselection on
%                          freqana data, but later decide that the freqana
%                          was performed incorrectly (for instance you want 
%                          a different preprocessing. With this function, 
%                          you can perform the peakselection which was done
%                          before on a different freqana dataset.
%   - 'utilities': Various utilities. 
%                Following options can be specified in conf.utilities.meth:
%                - 'convpeaksel': convert peakselection (peaksel) data into
%                               a different (Heidi/Rick friendly) matrix 
%                               structure.
%                - 'plotedf': simply plot the data stored in a EDF+ file

% Michiel Dirkx, 2015
% $ParkFunC, version 20150609

%--------------------------------------------------------------------------

%% Warming Up
%--------------------------------------------------------------------------

if nargin < 2
%   varargin{1} =   'prepraw';     % Prepare raw datafiles (e.g. channel selection, or monopolor>dipolar)  (NB: not FT preprocessing)
  varargin{1} =   'ftana';       % FieldTrip frequency analysis 
%   varargin{1} =   'utilities';   % Several Utilities useful for other functions in this batch
end
    
%--------------------------------------------------------------------------

%% Configuration
%--------------------------------------------------------------------------    

if nargin < 1
    
tic; clc; close all;

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
conf.dir.figsave  =   fullfile(conf.dir.root,'analysis','Figures','POSTPD','POSHvsRest_OFFON_powspct_5_peakfinder2SD_mancheck_edc-fcr-separate'); % Directory where the fieldtrip analyses figures will be stored ('ftana')
conf.dir.datsave  =   fullfile(conf.dir.root,'analysis','Data','POSTPD');                         % Directory where the fieldtrip analyses will be stored ('ftana')

%==========================================================================    
% --- Subjects --- %
%==========================================================================

conf.sub.name    =   {'p01';'p02';'p03';'p04';'p05';'p06';'p07';'p08';'p09';'p10';
					  'p11';'p12';'p13';'p14';'p15';'p16';'p17';'p18';'p19';'p20';
                      'p21';'p22';'p23';'p24';'p25';'p26';'p27';'p28';'p29';'p30';
					  'p31';'p32';'p33';'p34';'p35';'p36';'p37';'p38';'p39';'p40';
					  'p41';'p42';'p43';'p44';'p45';'p46';'p47';'p48';'p49';'p50';
                      'p51';'p52';'p53';'p54';'p55';'p56';'p57';'p58';'p59';'p60';
                      'p61';'p62';'p63';'p64';'p65';'p66';'p67';'p68';'p69';'p70';
                      'p71';'p72';'p73';'p74';'p75';'p76';'p77';'p78';'p79';'p80';
                      'p81';'p82';'p83';
                      };
conf.sub.hand    =   {  'L';'R'  ;'R'  ;'L'  ;'L'  ;'L'  ;'R'  ;'R'  ;'R'  ;'L'  ;
                        'R';'L'  ;'R'  ;'R'  ;'L'  ;'R'  ;'R'  ;'L'  ;'L'  ;'R'  ;
                        'R';'R'  ;'R'  ;'R'  ;'L'  ;'L'  ;'R'  ;'L'  ;'R'  ;'R'  ;
                        'R';'L'  ;'R'  ;'R'  ;'L'  ;'R'  ;'L'  ;'L'  ;'R'  ;'R'  ;
                        'L';'L'  ;'L'  ;'L'  ;'L'  ;'R'  ;'L'  ;'R'  ;'L'  ;'L'  ;
                        'L';'L'  ;'R'  ;'R'  ;'R'  ;'R'  ;'R'  ;'R'  ;'L'  ;'L'  ;
                        'L';'L'  ;'L'  ;'L'  ;'R'  ;'R'  ;'R'  ;'R'  ;'L'  ;'R'  ;
                        'L';'L'  ;'R'  ;'R'  ;'L'  ;'R'  ;'R'  ;'R'  ;'R'  ;'R'  ;
                        'R';'L'  ;'L'  ;
                        };            % Side the patient was measured ('L'=left; 'R'=right)
conf.sub.sess	 =   {'OFF';};

%--- New Group Clustering (cluster group 7) --- %

% sel = [4,5,7,8,12,16,17,18,19,20,21,22,25,27,28,29,30,31,33,34,35,36,37,38,39,40,42,45,46,47,49,50,57,59,60,61,63,64,66,68,70,72,74,76,77,78,79,80]; % 1 (reem)
% sel = [3,9,11,13,14,15,32,41,48,62,67]; % 2  (pure postural)
% sel = [3,4,5,7,8,9,11,12,13,14,15,16,17,18,19,20,21,22,25,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,45,46,47,48,49,50,57,59,60,61,62,63,64,66,67,68,70,72,74,76,77,78,79,80]; %all

%--- DRDR-MRI-RS --- %

sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83 ... 
         18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % ALL - confirmed doubts     

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

conf.prepraw.file   =   '/CurSub/&/CurSess/&/RAW/&/revised1a_merged/';      % File names used for prepraw (uses pf_findfile)
                     
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
conf.prepraw.cremont.plot       =   'no';         % if yes, then it will plot the reference, active and new channel of the whole montage.

% --- MergeEDF --- %

conf.prepraw.edfmerge.addfiles  =   {
                                      '/CurSub/&/CurSess/&/RAW1/&/revised1a/';
                                     }; % Files, which together with conf.preproc.file, will be merged
conf.prepraw.edfmerge.addevent  =   'no'; % If yes, then it will add up the starttimes of the addfiles events to the length of the basefile. If not, the original starttime in both files will be used.

%==========================================================================    
% --- FieldTrip Analyses ('ftana') --- %
%==========================================================================

% --- General --- %

conf.ft.meth    =   {
                     'freqana';     % Frequency analysis using FieldTrip
%                      'reanalyze';     % reanalyze data using data derived from 'freqana' and previously selected data as input
%                      'reanalyze2';    % Same as reanalyze, but now the peaksel file is leading (unlike the reanalyze where freqana is leading), uses same configuration as reanalyze
%                      'fragmentana'; % Function to analyze seperate fragments of conditions analyzed with 'freqana'. Useful for the POSTPD FigureClassification purpose.
%                      'timetopeak';  % Function to calculate when meanTFR[after posturing)>=meanTFR[-1 -3]
%                      'plot';      % Plot frequency analysed data (including fragmentana).
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
conf.ft.savefile   =   'freqana_acc-fcr-edc_3-80_OFFON_restposh_preproc3_mtmfft_freq3_20151211.mat';
% conf.ft.savefile   =   'freqana_acc-fcr-edc_purepost_OFFON_restposhcoco_preproc3_mtmfft_freq3_20151211.mat';
% conf.ft.savefile   =   'freqana_acc-fcr-edc_3-32and34-67and69-80_OFFON_postweight_preproc3_mtmfft_freq3_20160130.mat'; % Name it will be saved to (if conf.ft.save='yes') or will be loaded from (if conf.ft.load='yes')
% conf.ft.savefile   = 'freqana_acc-fcr-edc_3-80_ON_posh_preproc4_mtmconvol_freq4_20151211.mat';
% conf.ft.savefile   = 'freqana_acc-fcr-edc_3-80_OFF_posh_preproc4_mtmconvol_freq4_20151201.mat';
% conf.ft.savefile   =   'freqana_acc-fcr-edc_allbutreemergent_OFFON_postweight_preproc4_mtmconvol_freq4_20160726.mat';
% conf.ft.savefile   =   'freqana_acc-fcr-edc_reemergent_OFF_rest_preproc4_mtmconvol_freq4_20170709.mat';
conf.ft.load       =   'no';                
          
% --- Frequency Analysis --- %                

conf.ft.save       =   'yes';                                             % Save the frequency analyzed data
conf.ft.saveasmat  =   'no';            %OUTDATED, always no              % If yes, then the freqana data will be saved as a matrix instead of a structure (backwards compatiblity function, in principle this should always be no!!).

conf.ft.fa.cond    =  {                             % Conditions you want to include
%                        'EntrL' 
%                        'EntrM' 
%                        'IntentL' 
%                        'IntentM' 
                       'POSH1' 
                       'POSH2' 
%                        'POST1' 
%                        'POST2' 
%                        'POSW1' 
%                        'POSW2' 
                       'Rest1' 
                       'Rest2' 
                       'Rest3' 
%                        'RestCOG1' 
%                        'RestCOG2' 
%                        'RestCOG3' 
%                        'RestmoL1'     
%                        'RestmoL2'    
%                        'RestmoL3' 
%                        'RestmoM1' 
%                        'RestmoM2' 
%                        'RestmoM3'
%                        'Weight'
                                 };                              

%Preproc% 
conf.ft.fa.prepostwin  = [0 0]; % Pre and post window (in seconds) before and after the start/stop of your conditions                           

conf.fa.chandef =   {
%                       1:14;  % Channel 1:14 is EMG %% NB: at the moment you can only do multiple rounds of preprocessing (lets say bp>rectify>hp) with one SET of channels
%                       1:14;  % second round of preprocessing
%                       1:14;  % third round of preprocessing    
%                       11:12;
%                       11:12;
%                       11:12;
%                       16; % Channel 15:16 are ACC
                        [4:5 11:12];
                        [4:5 11:12];
                        [4:5 11:12];
                        15:16;
%                       17;    % Channel 17 is ECG
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
conf.ft.fa.cfg.preproc{4}.bpfreq        = [2 40];

% conf.ft.fa.cfg.preproc{5}               = [];
% conf.ft.fa.cfg.preproc{5}.continuous    = 'yes';
% conf.ft.fa.cfg.preproc{5}.demean        = 'yes';        
% conf.ft.fa.cfg.preproc{5}.detrend       = 'yes'; 

                        
%FreqAna%
conf.ft.fa.cfg.freq.method              = 'mtmconvol'; % Choose a method ('mtmfft' or 'mtmconvol')
conf.ft.fa.cfg.freq.output              = 'pow';       % Output ('pow' is powerspectrum; 'fourier': bare frequency domain)
% conf.ft.fa.cfg.freq.foilim              = [1 16]; % frequency range you are interested in NB can I use foilim with this taper??
conf.ft.fa.cfg.freq.foi                 = 1:0.5:16;
conf.ft.fa.cfg.freq.taper               = 'hanning';   % Taper ('dpss': multitaper; 'Hanning': single taper
nFoi                                    = length(conf.ft.fa.cfg.freq.foi); 
% conf.ft.fa.cfg.freq.tapsmofrq           = 0.1;
% conf.ft.fa.cfg.freq.toi                 = [10 20 30 40 50 60];
conf.ft.fa.cfg.freq.toi                 = 'all';   % times on which the analysis window should be centered (in seconds). Define 'orig' to use the original timepoints (every sample).
% conf.ft.fa.cfg.freq.tapsmofrq           = repmat(0.5,1,nFoi);   % Smoothing
conf.ft.fa.cfg.freq.t_ftimwin           = repmat(2,1,nFoi);     % vector 1 x nFoi, length of time window (in seconds)
conf.ft.fa.avgfreq                      = 'no';        % If you specify this as yes, it will only save the average time spectrum and not the whole TFR (only applies for 'mtmconvol')

%Optional1:redefinetrial%
conf.ft.fa.cfg.trialdef.on              = 'no';    % If you want to cut the data into nTrials you can specify this option as 'yes'. Below you can specify in which datasegments you want to cut them.
conf.ft.fa.cfg.trialdef.trl             = 5;       % Specify here the length of the new datasegments (i.e. if you specify 10 then the data will be cut in segments of 10s)

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

conf.ft.reanalyze.input                 = '/home/action/micdir/data/PMG/analysis/Data/POSTPD/peaksel_OFFON_restVSposh_sub3-54and56-80_peakfinder2SD_mancheck.mat'; % Fullfile of the peak selection datafile
conf.ft.reanalyze.savename              = 'peaksel_OFFON_restVSposh_allbutreemergent_peakfinder2SD_mancheck_reanalyze';                                                            % The new peaksel data will be saved with this name
conf.ft.reanalyze.time                  = [15 999]; % Timeframe you want to use (specify [0 999] if you want to include all datapoints or, for example, [15 999] if you want to include all data from +15s until the end)
% conf.ft.reanalyze.input                 =  '/home/action/micdir/data/PMG/analysis/powspct_dat/Ana_seltremor-move_Rest-CoCo-MoCo_first_total.mat';
% conf.ft.reanalyze.savename              = 'peaksel_3-6_8-11_13-17_19-25_27-39_41-48_bp1-40';
conf.ft.reanalyze.savefig               = 'no';         % Save the figures (NB: DOES NOT WORK FOR REANALYZE2  YET)
conf.ft.reanalyze.savefigfolder         = 'tmp_reanalyze';         % Name of the folder, will be made within the conf.dir.figsave folder (for proper name see help me within figures folder)
conf.ft.reanalyze.savefigname           = 'tmp'; % Name will be pasted after CurSub-CurSess
conf.fa.reanalyze.figext                = '-dtiff';      % Extension format of saved figure (e.g. '-dtiff'; see print)
conf.fa.reanalyze.figres                = '-r800';       % Resolution of saved figure (e.g. '-r100'; see print)
                                      
                                      
% --- Fragmentana --- %

conf.ft.fragana.cond                    = {'POSH'};   % Choose the conditions in freqana that you want to perform fragementana on
conf.ft.fragana.avgcond.on              = 'yes';      % If you specified an average condition, indicate here yes.
conf.ft.fragana.avgcond.which           = {
                                            'POSH' {'POSH1' 'POSH2'};
%                                             'Rest' {'Rest1' 'Rest2' 'Rest3'};
                                          };          % Then if you have specified an average condition in conf.ft.freqana.cond, specify which conditions in freqana should be averaged for this new condition (so {POSH {POSH1 POSH2};} means you have a new condition POSH, which is the average of POSH1 and POSH2

conf.ft.freqana.freqs.meth              = 'peaksel';  % Choose which frequencies of the TFR you want to use this for ('peaksel': means it will load the peaksel file in conf.ft.freqana.freqs.peakselfile to use selected peaks there)
conf.ft.freqana.freqs.peakselfile       = 'peaksel_neurologyrevision_OFFON_restVSposh_all_peakfinder2SD_mancheck_redone.mat';  % Peaksel file. Make sure you have one selected peak per specified condition. 
conf.ft.fragana.fragments               = {
                                            [-3 -1];
                                            [ 1  3];
%                                            [30 999];
%                                            [-5 0];
%                                            [0 1];
%                                            [0 5];
%                                            [1 2];
%                                            [1 3];
%                                            [1 5];
%                                            [2 3];
%                                            [0 999];
%                                            [2 999];
%                                            [5 999];
                                           };          % The fragments of the conditions you want to analyze (in seconds). 
conf.ft.fragana.startcond               = 10;          % If during freqana you defined conf.ft.fa.prepostwin other than [0 0], you can define the relative timepoint with respect to conf.ft.fragana.fragments here.                                       
% conf.ft.fragana.startcond               = 0;          % If during freqana you defined conf.ft.fa.prepostwin other than [0 0], you can define the relative timepoint with respect to conf.ft.fragana.fragments here.                                       
conf.ft.fragana.savefile                = 'fragmentana_neurologyrevision_all_-3--1_1-3.mat'; % name of the savefile

% --- TimeToPeak --- %

conf.ft.ttp.cond                    = {'POSH'};   % Choose the conditions in freqana that you want to perform fragementana on
conf.ft.ttp.avgcond.on              = 'yes';      % If you specified an average condition, indicate here yes.
conf.ft.ttp.avgcond.which           = {
                                            'POSH' {'POSH1' 'POSH2'};
                                       };          % Then if you have specified an average condition in conf.ft.freqana.cond, specify which conditions in freqana should be averaged for this new condition (so {POSH {POSH1 POSH2};} means you have a new condition POSH, which is the average of POSH1 and POSH2

conf.ft.ttp.freqs.meth              = 'peaksel';  % Choose which frequencies of the TFR you want to use this for ('peaksel': means it will load the peaksel file in conf.ft.freqana.freqs.peakselfile to use selected peaks there)
conf.ft.ttp.freqs.peakselfile       = 'peaksel_OFF_restVSposhVSpostVSweight_merged.mat';
conf.ft.ttp.startcond               = 10;
conf.ft.ttp.savefile                = 'timetopeak_neurologycomment_reem_-3--1_singleval.mat'; % name of the savefile

%==============%
% --- Plot --- %
%==============%

% --- General --- %

conf.fa.fig.meth            = {
%                                'powspct'; % Plots powerspectrum
                               'tfr'; % Plots (all) the TFR's of mtmconvol analyzed data in imagesc manner
%                                'coh'    % Simpel plot of coherence analysis 
                              };           % Choose what to display of the frequency analysis performed ('subpowspect': plot the power spectra of individual subjects (see pf_pmg_plot_powspct); 'avgpowspct': plot powerspectrum averaged over subjects; )
                           

conf.fa.fig.chan            = {
                                 'R' conf.ft.chans([4:5 15]); % Enter the channel names you want to plot (you can use conf.ft.chans for this), if you specified a coherence analysis it will look for the channels in the left column. Adjust for handedness by specifying every row the hand 'R' or 'L' followed by the channel names (e.g. {'R' conf.ft.chans(4:5);'L' conf.ft.chans(11:12);}
                                 'L' conf.ft.chans([11:12 16]);
                              };   
                          
% Then here specify the layout of your figure. Use one cell per figure.
% Then organise the subplots by specify nCells for nSubplots, with
% the index of each cell corresponding to the index of each subplot. Within
% each cell (i.e. suplot), describe what you want to plot like this, R1:
% session, R2: condition, R3: index of channels described in
% conf.fa.fig.chan. If you average a condition, give it your own name here
% which corresponds with the first column of conf.fa.fig.avgcond.which. If
% you want multiple condition in one subplot then use R4,R5,R6 in the same
% way you used R1,R2,R3 for your other condition. Make sure that for every
% new condition you specify 3 extra columns (session,condition,channel). 
% If you want to average several channels in one subplot, use 999 as the 
% first channel index followed by the channels that need to be averaged.                           
                          
% conf.fa.fig.plot{1}         = {
%                                {'OFF','POSH',[3],'OFF','RestCOG1',[3]} {'OFF','POSH',[999 1:2],'OFF','RestCOG1',[999 1:2]};
%                                }; % POSHvsRest_powspct_5_peakfinder2SD_mancheck_edc-fcravg

% conf.fa.fig.plot{1}         = {
%                                {'OFF','POSH',[3],'OFF','Rest',[3]} {'OFF','POSH',[1],'OFF','Rest',[1]};
%                                }; % OFF_POSHvsRest_powspct_5_peakfinder2SD_mancheck_edc

% conf.fa.fig.plot{2}         = {
%                                {'OFF','POSH',[3],'OFF','Rest',[3]} {'OFF','POSH',[2],'OFF','Rest',[2]};
%                                }; % OFF_POSHvsRest_powspct_5_peakfinder2SD_mancheck_fcr
% 
% conf.fa.fig.plot{3}         = {
%                                {'ON','POSH',[3],'ON','Rest',[3]} {'ON','POSH',[1],'ON','Rest',[1]};
%                                }; % ON_POSHvsRest_powspct_5_peakfinder2SD_mancheck_edc                           
%                            
%                            
% conf.fa.fig.plot{4}         = {
%                                {'ON','POSH',[3],'ON','Rest',[3]} {'ON','POSH',[2],'ON','Rest',[2]};
%                                }; % ON_POSHvsRest_powspct_5_peakfinder2SD_mancheck_fcr

% 
% conf.fa.fig.plot{1}         = {
%                                {'OFF','POST',[3],'OFF','Weight',[3]} {'OFF','POST',[999 1:2],'OFF','Weight',[999 1:2]};
%                                }; % Powspct POSTvsWEIGHT

% conf.fa.fig.plot{2}         = {
%                                {'ON','POST',[3],'ON','Weight',[3]} {'ON','POST',[999 1:2],'ON','Weight',[999 1:2]};
%                                }; % POSTvsWeight_powspct_5_peakfinder2SD_mancheck_edc-fcravg

%                            
% conf.fa.fig.plot{1}         =  {
%                                 {'OFF','POSH',1} {'OFF','POSH',2} {'OFF','POSH',3}
%                                }; % figure classification     multi-TFR
                           
% conf.fa.fig.plot{1}         = {
%                                {'OFF','POST1',1} {'OFF','POST1',2} {'OFF','POST1',3}; 
%                                {'OFF','POST2',1} {'OFF','POST2',2} {'OFF','POST2',3}; 
%                                }; %POSH_tfr / POST_tfr
conf.fa.fig.plot{1}           = {
                                 {'OFF','POSH',3} {'OFF','POSH',[999 1:2]} 
                                 }; % POSH_tfr_1_peakfinder2SD_mancheck_edc-fcravg, figure classification singletfr

% conf.fa.fig.plot{1}           = {
%                                  {'OFF','POST',3}         {'OFF','Weight',3}; 
%                                  {'OFF','POST',[999 1:2]} {'OFF','Weight',[999 1:2]}; 
%                                 };  % POST and WEIGHT AVG single-tfr-at-trem/post-frequency

conf.fa.fig.avg.on            = 'no';       % Choose yes if you want a figure which is averaged over all subjects ('no' or 'yes') (ONLY IMPLEMENTED FOR 'powspct')
conf.fa.fig.avg.chancombi     = {                                           % NB: THIS ONLY APPLIES TO POWSPCT FIGURES, NOT TO COHERENCE ANALYSES, FOR COHERENCE ANALYSIS THE ORDER IS PRESPECIFIED AND IT WILL ONLY WORK IF YOU USE ALL CHANNELS
                                  'R' conf.ft.chans([4:5 15]);
                                  'L' conf.ft.chans([11:12 16]);
                                };            % When you average, you can deal with handedness of patients here. specify a cell with nHand rows. For each row you specify the handedness in the first column and in the second column the channels to include. Do this for both hands and match the order of channels in the second column

conf.fa.fig.avgcond.on        = 'yes';      % Choose yes if you want to average over CONDITIONS FOR EVERY SUBJECT (ONLY IMPLEMENTED FOR 'powspct')
conf.fa.fig.avgcond.which     = {
                                  'Rest' {'Rest1' 'Rest2' 'Rest3'};
                                  'POSH' {'POSH1' 'POSH2'};
                                  'POST' {'POST1' 'POST2'};
                                 }; % Specify a new row for every average, specify in each column (variable length) which condition you want to combine. The first column should indicate your code, for instance if you had POSH1 and POSH2 then {'POSH' 'POSH1' 'POSH2'}
                            
conf.fa.fig.backcol           = [1 1 1];  % Set the background color of your figures (RGB, e.g. [1 1 1] is defualt white)
conf.fa.fig.xlim              = [];          % caChoose your x-axis, leave empty for default
conf.fa.fig.ylim              = [];             % Choose your y-axis, leave empty for default
conf.fa.fig.ax				  = '';	    % Apply axes of subplots to the other subplots in the figure (see pf_adjustax). Leave '' for default.
conf.fa.fig.col               = 'hsv';        % Choose color spectrum (e.g. hot, hsv, prism etc.)
conf.fa.fig.logtransform      = 'no';         % logtransform your figures??

conf.fa.fig.save              = 'no';           % Choose if you want to save your figures
conf.fa.fig.savename          = {
                                   'OFF_POSHvsRest_powspct_5_peakfinder2SD_mancheck_edc';
                                   'ON_POSHvsRest_powspct_5_peakfinder2SD_mancheck_edc';
                                   'OFF_POSHvsRest_powspct_5_peakfinder2SD_mancheck_fcr';
                                   'ON_POSHvsRest_powspct_5_peakfinder2SD_mancheck_fcr';
                                 }; % For every plot (conf.fa.fig.plot), text will be placed after CurSub_CurHand (e.g. p01_R
% conf.fa.fig.savename          = {'ON_POSTPD_powspct_RESTvsPOSH_mtmfft_peakfinder2SD_avgposh_avgchan';}; % For every plot (conf.fa.fig.plot), text will be placed after CurSub_CurHand (e.g. p01_R
conf.fa.fig.saveext           = '-dtiff';       % Extension format of saved figure (e.g. '-dtiff'; see print)
conf.fa.fig.saveres           = '-r800';        % Resolution of saved figure (e.g. '-r100'; see print)

% --- PowSpct ('powspct') --- %

conf.fa.fig.pow.graph  = 'plot';       % Choose method of displaing the powerspcetrum ('plot': simple 2D plot; 'contourf': contourf plot)

conf.fa.fig.pow.peaksel.onoff     = 'off';       % Choose if you wa nt to perform a peak selection ('on')
conf.fa.fig.pow.peaksel.peakdef   = 'mansingle';      % Choose the peak definition ('mansingle': manual selection of one peak per channel; 'peakfinder': use peakfinder to automatically select peaks)
conf.fa.fig.pow.peaksel.mancheck =  'yes';      % If you chose conf.fa.fig.pow.peaksel.peakdef   = 'peakfinder', specify if you want to manually select the real ones after automatic peak detection ('yes')
conf.fa.fig.peaksel.savefile  = 'peaksel_neurologyrevision_OFFON_restVSposh_50-end_peakfinder2SD_mancheck_redone'; % Filename of the file where data retrieved from peaksel will be saved to
% conf.fa.fig.peaksel.savefile    =   'tmp';

% --- Coherence plot 'coh' --- %
% NB: A lot of the new plotting functions not yet implemented
conf.fa.fig.coh.graph         = 'contourf';   % Coohse the way you want to plot the coherence spectrum ('plot': simple plot; 'contourf': contourf plot)

% --- TFR --- %

conf.fa.fig.tfr.graph          = 'plot';       % Choose method, ('plot': is an extremly complicated script for plotting TFR's of peak selected data; 'imagesc': uses imagesc to 3D plot your TFR's (preferable)
conf.fa.fig.tfr.peaksel.on     = 'yes';        % If yes it will use conf.fa.fig.tfr.peaksel.file to only plot the frequencies selected in this file. (only for 'plot')
conf.fa.fig.tfr.peaksel.file   = '/home/action/micdir/data/PMG/analysis/Data/POSTPD/peaksel_OFFON_restVSposhVSpostVSweight_merged.mat'; % Fullfile of the peakselection file (only if conf.fa.fig.tfr.peaksel.on ='yes')
conf.fa.fig.tfr.peaksel.avgsub = 'yes';        % if yes then average all subjects.

%==========================================================================    
% --- Additional Utilities ('utilities') --- %
%==========================================================================

conf.util.meth     =    {
%                          'convertpeaksel';  % Utility to convert the matrix data of peaksel into a Heidi friendly version %NB: MAvsLA is a dirty selection which I have to implement nicely still
%                          'convertpeaksel2';
                         'plotedf';         % Utility to simply plot data stored in a EDF+ file
%                         'classificationplot_postpd'; % Utility to make a plot of delta-frequency (rest vs reemergent) VS tremor decrease, see Evernote FigureClassification
                        };
                    
% --- ConvertPeaksel --- %

conf.util.convert.input               = '/home/action/micdir/data/PMG/analysis/Data/MIRROR/peaksel_OFF_peakfinder2SD_mancheck_p42_redoneOFF.mat'; % peaksel file that needs to be converted
conf.util.convert.savename            = 'tmp.mat';

% --- Plot EDF --- %

conf.util.plotedf.file   =   '/CurSub/&/CurSess/&/Raw2CurMont/&/revised1/';      % File name of the raw dataset (in conf.dir.plotedf) which needs to be plotted (uses pf_findfile)
conf.util.plotedf.chans   =   {
%                           'EEG 1-2'    'R-Deltoideus';    % 1      % Channel name you want to plot (as labeled by the headbox) followed by your own name (used for title of the plot. Use a new row for every new channel, and a new column for your own name. Leave blanc ('') if original channel names used.
%                           'EEG 3-4'    'R-Biceps';        % 2      
%                           'EEG 5-6'    'R-Triceps';       % 3 
%                           'EEG 7-8'    'R-EDC';           % 4
%                           'EEG 9-10'   'R-FCR';           % 5
%                           'EEG 11-12'  'R-ABP';           % 6
%                           'EEG 13-14'  'R-FID1';          % 7
%                           'EEG 33-34'  'L-Deltoideus';    % 8
%                           'EEG 35-36'  'L-Biceps';        % 9                
%                           'EEG 37-38'  'L-Triceps';       % 10
%                           'EEG 39-40'  'L-EDC';           % 11
%                           'EEG 41-42'  'L-FCR';           % 12
%                           'EEG 43-44'  'L-ABP';           % 13
%                           'EEG 45-46'  'L-FID1';          % 14
                          'EEG 31-32'  'R-ACC';           % 15
                          'EEG 61-62'  'L-ACC';           % 16
%                           'EEG 63-64'  'ECG';             % 17
                        };

conf.util.plotedf.rsp     =  1;                    % Amount of subplots in each row                    

% --- classificationplot postpd --- %

conf.util.class.channel      = {
                                  'R' [15];
                                  'L' [16];
                                }; % Channel you want to use (only 1 possible, use the channelcode as noted in the evernote decoding file)
conf.util.class.peaksel      = '/home/action/micdir/data/PMG/analysis/Data/POSTPD/peaksel_restVSposh_sub3-80_peakfinder2SD_mancheck_removedmultipeak_redone19subs.mat'; % Necessary to retrieve frequencies of rest vs reemergent tremor
conf.util.class.fragmentana  = '/home/action/micdir/data/PMG/analysis/Data/POSTPD/fragmentana_reemergentANDpure_number1';
conf.util.class.fragments    = {[-5 0] [1 2]}; % Analyzed fragments in fragmentana you want to use for defining the drop in power (e.g. {[-5 0] [2 5]} means you will subtract the value from fragment [2 5] of of fragment [-5 0])
conf.util.class.fragmentval  = {
                                 'meanTFR';   % Will plot differences in meanTFR
%                                  'maxTFR';    % Will plot differences in maxTFR
%                                  'last-first';  % Will plot differences between last sample of fragment 1 and first sample of fragment2
%                                    'meanTFR-first';
                                }; % Choose the value of the fragment you want to use ('meanTFR': use meanTFR of fragments)

conf.util.class.stdcrit      =  'off';  % Will assign value 0 if differences in meanTFR are < std of first fragment, value 1 if differences are > std
                            
end

%--------------------------------------------------------------------------

%% Preparing RAW
%--------------------------------------------------------------------------

H = strfind(varargin,'prepraw');
if ~isempty ([H{:}])
     pf_pmg_prepraw(conf);
end

%--------------------------------------------------------------------------

%% Frequency Analysis
%--------------------------------------------------------------------------

H = strfind(varargin,'ftana');
if ~isempty ([H{:}])
    pf_pmg_ft(conf);
end

%--------------------------------------------------------------------------

%% Additional utilities
%--------------------------------------------------------------------------

H = strfind(varargin,'utilities');
if ~isempty ([H{:}])
    pf_pmg_utilities(conf);
end

%--------------------------------------------------------------------------

%% Cooling Down
%--------------------------------------------------------------------------

T   =   toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T/60) ' minutes!!'])

%--------------------------------------------------------------------------



