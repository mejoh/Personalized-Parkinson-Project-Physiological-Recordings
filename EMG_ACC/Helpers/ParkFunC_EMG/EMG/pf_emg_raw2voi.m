function pf_emg_raw2voi(conf)
% pf_emg_raw2roi is part of the EMG section of the ParkFunC toolbox.
% Specifically, it will transform the raw EMG signal into a regressor
% useable as a VOI for DCM. This if you want to use the muscle as a node in
% your DCM network.
%
% (C) Michiel Dirkx, 2018
% $ParkFunc toolbox, version 20180822

%--------------------------------------------------------------------------

%% Configuration
%--------------------------------------------------------------------------

if nargin<1

tic; clear all; clc;    
    
%==========================================================================    
% --- Directories --- %
%==========================================================================

conf.dir.root    =   '/home/action/micdir/data/DRDR_MRI/EMG/FARM1'; % root directory
conf.dir.save    =   '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/muscle_vois'; % where muscle vois will be stored
conf.dir.refmusc =   '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s_coh-dpss/Regressors/broadband_PB1Hz/ZSCORED'; %directory with reference to which muscle to use

conf.dir.preworkdel  = 'yes';       % Delete work directory beforehand (if present)
conf.dir.postworkdel = 'yes';        % Delete work directory afterwards

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
conf.sub.hand   =   {
                     'R'  ;'R'  ;'R'  ;'L'  ;'R'  ;
                     'L'  ;'R'  ;'R'  ;'L'  ;'L'  ;
                     'L'  ;'L'  ;'L'  ;'R'  ;'L'  ;
                     'L'  ;'R'  ;'L'  ;'R'  ;'L'  ;
                     'L'  ;'R'  ;'L'  ;'L'  ;'L'  ;
                     'L'  ;'R'  ;'R'  ;'R'  ;'L'  ;
                     'L'  ;'L'  ;'R'  ;'R'  ;'R'  ;
                     'R'  ;'R'  ;'R'  ;'R'  ;'L'  ;
                     'L'  ;
                     };                 
conf.sub.sess1  =   {
                     'OFF';'OFF';'ON' ;'OFF';'OFF';
                     'OFF';'ON' ;'OFF';'ON' ;'OFF';
                     'ON' ;'ON' ;'ON' ;'OFF';'OFF';
                     'ON' ;'OFF';'OFF';'ON' ;'ON' ;
                     'OFF';'OFF';'ON' ;'ON' ;'ON' ;
                     'OFF';'ON' ;'ON' ;'OFF';'ON' ; 
                     'OFF';'ON' ;'OFF';'ON' ;'OFF';
                     'ON' ;'ON' ;'OFF';'ON' ;'ON' ;
                     'OFF';
                     }; % Define if first session was OFF (placebo) or ON (madopar)


% sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83]; % DOPARESISTANT - confirmed doubts (14, 62, 47, 80, 82)
% sel =   [18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % DOPARESPONSIVE - confirmed doubts (24)
%      
sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83 ... 
         18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % ALL - confirmed doubts     
% 
% sel =   [30 08 11 28 27 42 50 72 75 74 78 81 83 ... 
%          18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % MINUS p73

% sel = 30;
sel = pf_subidx(sel,conf.sub.name);

conf.sub.name   =   conf.sub.name(sel);
conf.sub.hand   =   conf.sub.hand(sel);
conf.sub.sess1  =   conf.sub.sess1(sel);

%==========================================================================
% --- Parameters --- %
%==========================================================================

conf.file.name          =   '/FARM/&/.vhdr/';      % .vhdr file of the BVA EMG file(uses pf_findfile)
conf.file.mrkname       =   '/FARM/&/.vmrk/';      % .vmrk file of the BVA EMG file(uses pf_findfile)
conf.prepemg.chan       = {'MA-Biceps'  ; %1
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
                           }; % All channels apparent in your dataset, give them a name here.                
conf.file.scanpar       =   [0.859;11;nan];                             % Scan parameters: TR / nSlices / nScans (enter nan for nScans if you want to automatically detect this)
conf.file.etype         =   'R  1';                                     % Scan marker (EEG.event.type)
conf.file.sess          =  {
                            {'OFF','OFF','SESS1','SESS2'};
%                             {'ON','ON','SESS1','SESS2'};
                            };                                          % Session you want to use
conf.file.run    = {
                   'RS';
%                    'COCO';
%                    'POSH';
                    };                        

conf.file.exampvoi  =  '/home/action/micdir/data/DRDR_MRI/fMRI/analysis/M43_ICA-AROMAnonaggr_spmthrsh0c25_FARM1_han2s_EMG-log_broadband_retroicor18r-exclsub/RS/VOIs/Mask_P=1-none/OFF/VOI_p08_L-OP4_Mask_P1_1.mat'; % This will be used as template voi                      
conf.file.scandum   = 5; %1:conf.file.scandum wil be disregarded


end

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

fprintf('\n%s\n\n','% -------------- Initializing -------------- %')

nSub     =   length(conf.sub.name);
nSess    =   length(conf.file.sess);
nRun     =   length(conf.file.run);
Files    =   cell(nSub*nSess*nRun,1);
nFiles   =   length(Files);
cnt      =   1;

workmain =   fullfile(conf.dir.root,'work');
if ~exist(workmain,'dir');      mkdir(workmain);      end
if ~exist(conf.dir.save,'dir'); mkdir(conf.dir.save); end

if isempty(findobj('Tag','EEGLAB'))
    eeglab
end

%--------------------------------------------------------------------------

%% Retrieve all fullfiles, initializing workdir
%--------------------------------------------------------------------------

fprintf('\n%s\n\n','% -------------- Retrieving all fullfiles -------------- %')

for a = 1:nSub
    CurSub  =   conf.sub.name{a};
    for b = 1:nSess
        if strcmp(conf.sub.sess1{a},conf.file.sess{b}(2))
            CurSess    =   conf.file.sess{b}{3};
        else
            CurSess    =   conf.file.sess{b}{4};
        end
        for c = 1:nRun
            CurRun     =   conf.file.run{c};
            CurFile    =   pf_findfile(conf.dir.root,[conf.file.name '/&/' CurSub '/&/' CurSess '/&/' CurRun '/']);
            workdir    =   fullfile(workmain,[CurSub '_' CurSess '_' CurRun]);
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

%--------------------------------------------------------------------------

%%  Creating Muscle VOIs
%--------------------------------------------------------------------------

fprintf('\n%s\n','% -------------- Creating Muscle VOIs -------------- %')
detscan  =   0;

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
    
    fprintf('\n%s\n',['Working on Subject | ' CurSub ' | Session | ' CurSess ' | Run | ' CurRun ' | ']);
    
    % --- Determine which channel to be loaded --- %
    
    reffile = pf_findfile(conf.dir.refmusc,['/' CurSub '/&/' CurSess '/&/' CurRun '/&/power.mat/&/MA-/']);
    refmusc = reffile(14:19);
    iChan   = find(strcmp(conf.prepemg.chan,refmusc));
    disp(['- Using ' refmusc])
    
    % --- Load data --- %
    
    [EEG,~]         = pop_loadbv(rawpath,[rawfile rawext],[],iChan);
    
    mrkfile         = pf_findfile(conf.dir.root,[conf.file.mrkname '/&/' CurSub '/&/' CurSess '/&/' CurRun '/'],'fullfile');
    event           = ft_read_event(mrkfile);
    
    % --- select only values at onset of scan --- %
    
    mrks      =   [{event.value}]';
    iScan     =   strcmp(mrks,'V');
    scaneve   =   event(iScan); 
    scantimes =   [scaneve.sample]'; 
    scanregr  =   EEG.data(scantimes);
    
    % --- convolve regressor --- %
    
    spm('Defaults','fmri');
    hrfOrig = spm_hrf(conf.file.scanpar(1));                     % get HRF for TR

    % --- Convolve HRF*EMG --- %

    cr    = conv(scanregr, hrfOrig);        % convolve data with HRF
    cr    = cr(1:end-length(hrfOrig)+1);    % get rid of last datapoints (equal to length of HRF)
    cr    = detrend(cr,'constant');         % detrend to remove linear trend
    
    % --- Remove dummys --- %
    
    scanregr  =   scanregr(conf.file.scandum+1:end);
    cr        =   cr(conf.file.scandum+1:end);
    
    % --- plot and save figure --- %
    
    h=figure;
    plot(scanregr);
    hold on
    plot(cr,'r');
    legend('unconvolved EMG','convolved EMG')
    legend('boxoff')
    title([CurSub '-' CurSess '-' CurRun ' ' refmusc])
    
    if ~exist([conf.dir.save '/fig'],'dir'); mkdir([conf.dir.save '/fig']); end
    saveas(h,fullfile(conf.dir.save,'fig',[CurSub '-' CurSess '-' CurRun '-' refmusc '.png']));
    
    % --- create VOI and save --- %
    
    voi          = load(conf.file.exampvoi);
    voi.Y        = cr';
    voi.xY.name  = refmusc;
    voi.xY.u     = cr';
    voi.xY       = rmfield(voi.xY,'xyz');
    voi.xY       = rmfield(voi.xY,'str');
    voi.xY       = rmfield(voi.xY,'spec');
    voi.xY       = rmfield(voi.xY,'XYZmm');
    voi.xY       = rmfield(voi.xY,'X0');
    voi.xY       = rmfield(voi.xY,'y');
    voi.xY       = rmfield(voi.xY,'v');
    voi.xY       = rmfield(voi.xY,'s');
    
    Y            = voi.Y;
    xY           = voi.xY;
    
    save(fullfile(conf.dir.save,['VOI_' CurSub '_' CurSess '_' refmusc '_P1_1.mat']),'Y','xY');
    disp(['- Saved muscle voi to ' fullfile(conf.dir.save,['VOI_' CurSub '_' CurSess '_' refmusc '_P1_1.mat'])])
    
    % --- USE THIS WHEN MISSING SCANMARKER --- %

%     q         = EEG.event(60);               % replace this with random event (to get started)
%     q.latency = EEG.event(55).latency+4295;  % replace the indices with prescan event
%     q.urevent = 999;                         % leave this
%     EEG.event = [EEG.event(1:55) q EEG.event(56:end)]; %replace with prescan event and postscan event
%     EEGalt.event = EEG.event;
    
end