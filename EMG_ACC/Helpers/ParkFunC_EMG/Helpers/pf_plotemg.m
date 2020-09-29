function pf_plotemg
%
%
%
%

%% Configuration

% --- Directories --- %

conf.dir.root       =   '/home/action/micdir/data/EMG/Cohort 2/EMG_results (orig; pre; final)/Regressor unconvolve';
conf.dir.save       =   fullfile(conf.dir.root,'OFFON plots');

% --- Subjects --- %

conf.sub.name       = {'p07'   ;'p10'   ;'p17'   ;'p26'   ;'p28';     % Cohort 2 (TRS>=2)
                       'p31'   ;'p32'   ;'p37'   ;'p39'   ;'p41';
                       'S07'   ;'S14'   ;'S18'   ;'S24'   ;'S31';
                       'S41'   ;'S44'   ;'S46'   ;'S47'   ;'S50';
                       'S56'   ;'S70'   ;};
                   
% sel = 1:19;
% conf.sub.name = conf.sub.name(sel);
                   
% --- File properties --- %

conf.file.name      =   '/CurSub/&/_RS_OFFON_Regr_Log_deriv1_unconvolved.mat/';

%% Plot everything

if ~exist(conf.dir.save,'dir'); mkdir(conf.dir.save); end
nSub    =   length(conf.sub.name);

for a = 1:nSub
    
    CurSub  =   conf.sub.name{a};
    CurFile =   pf_findfile(conf.dir.root,conf.file.name,'conf',conf,'CurSub',a);
    
    Q = load(fullfile(conf.dir.root,CurFile));
    
    fn  =   fieldnames(Q);
    emg =   Q.(fn{1});
    
    figure
    plot(emg);
    xlabel('time (scans)'); ylabel('Signal (dy/dx)'); title(CurFile,'interpreter','none');
    pf_verline(length(emg)/2,'color','r','linewidth',1)
    
    saveas(gcf,[fullfile(conf.dir.save,CurFile(1:end-4)) '.jpg'],'jpg');
end
    
    
    
    
    