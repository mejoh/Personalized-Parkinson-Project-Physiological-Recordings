function pf_concatTS(conf)
%
% concatenate time courses (UNDER CONSTRUCTION)
%
%

% Michiel Dirkx, 2014
% $ParkFunC

%% Configuration

if nargin < 1

clear all; close all; clc

% --- Directories --- %

conf.dir.root       =   '/home/action/micdir/data/DRDR_MRI/EMG/FARM1/prepemg_han2s_coh-dpss/Regressors/broadband_PB1Hz/ZSCORED';
conf.dir.save       =   fullfile(conf.dir.root,'OFFON_concat');

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

sel =   [30 08 11 28 27 42 50 72 75 74 73 78 81 83 ... 
         18 02 60 59 38 49 40 19 29 36 33 71 21 70 64 56 48 43 76 77]; % ALL - confirmed doubts     

sel = pf_subidx(sel,conf.sub.name);

conf.sub.name   =   conf.sub.name(sel);
conf.sub.hand   =   conf.sub.hand(sel);
conf.sub.sess1  =   conf.sub.sess1(sel);

% --- File --- %

conf.file.name      =   {
                         {'OFF','OFF','/CurSub/&/RS_MA-/&/log.mat/&/SESS1/','/CurSub/&/RS_MA-/&/log.mat/&/SESS2/'};
                         {'ON','ON','/CurSub/&/RS_MA-/&/log.mat/&/SESS1/','/CurSub/&/RS_MA-/&/log.mat/&/SESS2/'};
                         };
conf.file.type      =   'deriv1_unconvolved';  %Type of regressor (usually 'deriv1_unconvolved')                     

end

%% Initiate loop parameters

nSub    =   length(conf.sub.name);
nFile   =   length(conf.file.name);

%% Loop

fprintf('%s\n\n','% ---------------- Concatenating Time Series ---------------- %')

for a = 1:nSub
    
    clear TC drLog
    CurSub      =   conf.sub.name{a};
    
    for b = 1:nFile
        
        clear names R
        if ~iscell(conf.file.name{b})
            CurFile     =   pf_findfile(conf.dir.root,conf.file.name{b},'conf',conf,'CurSub',a);
        else
            CurSess1    =   conf.sub.sess1{a};
            if strcmp(conf.file.name{b}{2},CurSess1)
                CurFile     =   pf_findfile(conf.dir.root,conf.file.name{b}{3},'conf',conf,'CurSub',a);
            else
                CurFile     =   pf_findfile(conf.dir.root,conf.file.name{b}{4},'conf',conf,'CurSub',a);
            end
        end
        
        disp(['- loading ' CurFile])
        
        % --- Load file --- %
        
        load(fullfile(conf.dir.root,CurFile))
        
        idx = strcmp(names,conf.file.type);
        CurTC    =   R(:,idx);
        
        % --- Store TC --- %
        
        if b == 1 
            TC  =   CurTC;
        else
            TC  =   vertcat(TC,CurTC);
        end
        
    end
    
    % --- Save concatenated file --- %
    
    drLog     =   TC;
    figure; plot(drLog); title(CurFile,'interpreter','none')
    
    if ~exist(conf.dir.save,'dir'); mkdir(conf.dir.save); end
    save(fullfile(conf.dir.save,[CurSub '_RS_OFFON_Regr_Log_deriv1_unconvolved.mat']),'drLog')
    
    fprintf('%s\n\n','-- These time courses have now been concatenated and saved')
    
end

        
        
        
        
        






