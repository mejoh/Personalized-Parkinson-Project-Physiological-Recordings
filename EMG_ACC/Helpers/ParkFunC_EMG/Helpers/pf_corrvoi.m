function pf_corrvoi 
%
%
%
%

%% Configuration

% --- Directories --- %

conf.dir.root   =   '/home/action/micdir/data/fMRI/Cohort_2/analysis/model_OFFON_origmethod41r/RS/VOIs/Mask_P=1-none';
% conf.dir.root   =   '/home/action/micdir/data/fMRI/Cohort_1/First level - regressor GLM + VOI time courses/VOIs/Mask_P=1-none';

% --- Subjects --- %

conf.sub.name      =  {
                       'p06'   ;'p08'   ;'p10'   ;'p11'   ;'p13';     % Cohort 1                            % Include all your subjects, then choose which one you want to select
                       'p14'   ;'p15'   ;'p16'   ;'p18'   ;'p20';     
                       'p21'   ;'p22'   ;'p23'   ;'p26'   ;'p27';         
                       'p28'   ;'p30'   ;'p41'   ;'p47'   ;             
                       'p07'   ;'p10'   ;'p17'   ;'p26'   ;'p28';     % Cohort 2 (TRS>=2)
                       'p31'   ;'p32'   ;'p37'   ;'p39'   ;'p41';
                       'S07'   ;'S14'   ;'S18'   ;'S24'   ;'S31';
                       'S41'   ;'S44'   ;'S46'   ;'S47'   ;'S50';
                       'S56'   ;'S70'   ; 
                      };                  

% sel = [1:4 6:15 17:19]; % C1
sel = 20:41; % C2

conf.sub.name = conf.sub.name(sel);

% --- VOI Correlation --- %

conf.voicorr.name   =   {
                         '/CurSub/&/GPi/&/.mat/&/VOI/';
                         '/CurSub/&/GPe/&/.mat/&/VOI/';
                         }; % Name (pf_findfile search criteria) of the VOI you want to correlate with each other (currently only 2)
                     
%--------------------------------------------------------------------------
                     
%% Retrieve all fullfiles
%--------------------------------------------------------------------------

nSub    =   length(conf.sub.name);
nVoi    =   length(conf.voicorr.name);
cor     =   nan(nSub,1);

for a = 1:nSub
    
   CurSub   =   conf.sub.name{a};
   Files    =   cell(nVoi,1);
   
   for b = 1:nVoi
       CurVoi   =   conf.voicorr.name{b};
       voi      =   pf_findfile(conf.dir.root,CurVoi,'conf',conf,'CurSub',a,'fullfile');
       tc       =   load(voi);
       tc       =   tc.Y;
       
       %=====FILES====%
       Files{b,1}.voi =   tc;
       %==============%
   end
   cor(a)   =   corr(Files{1,1}.voi,tc);
    
end

avgcor      =   mean(cor);
stdcor      =   std(cor);

disp(['Mean correlation is ' num2str(avgcor)])
disp(['- STD: ' num2str(stdcor)])

figure
pf_boxplot(cor,1,'avg','mean');
xlim([0 4])

%--------------------------------------------------------------------------














                     



