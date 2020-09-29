function pf_copyfiles(files,origdir,destdir,varargin)
% 
% pf_copyfiles(files,origdir,destdir,varargin) is an extended version of
% the original matlab function copyfile. The advantage is that you can
% copy files from 1 or 2 subdirectories, and do that for all of those in a
% nice loop. This is particularly useful if you have files in multiple
% subfolders which need to be copied to one directory, this script will
% loop through them. Specify:
%       -   Files:   files you want to copy according to pf_findfile criteria
%                    (e.g. {'/*/.jpg/'})
%       -   origdir: original root directory of your files (e.g. {'C:\'})
%       -   destdir: destination directory of your files (e.g. {'C:\dest\'}
%
% You can specify the following varargin, preceded by the following code:
%       -   'suborig':    subfolder(s) of your root directory according to
%                         pf_findfile criteria (e.g. {'/S05/';'/EMG_/*/'}
%       -   'subsuborig:  subfolder of your original subfolder (see suborig)
%       -   'subdest':    subfolder of your destination directory according
%                         to pf_findfile criteria (see suborig).
%       -   'subsubdest': subfolder of destination subfolder.
%
% NB: if you specify mulitple subdest folders, they need to have the exact
% same amount as the total of suborig folers. Every suborig folder will
% then be copied to the subdest folder in ascending order.
%
% Example: 
% pf_copyfiles({'/*/.jpg/'},{'C:\'},{'C:\dest'},'suborig',{'/p01/&/EMG';'/p01/&/EMG'})  

% © Michiel Dirkx, 2014
% contact: michieldirkx@gmail.com
% $ParkFunC

%% Warming Up

if nargin < 1
    tic
    files       =   {''};
end

if nargin < 2
%     origdir     =   {'/home/action/micdir/data/fMRI/Cohort_1/DCM Models/SPM12b/TremorDCM_OFFON_C2'};
    origdir =   {'/home/action/micdir/data/fMRI/Cohort_1/DCM Models/SPM12b/TremorDCM_OFF_C1C2_GPe-and-GPi-and-STNhidden';};
end

if nargin < 3
%     destdir     =   {'/home/action/micdir/data/fMRI/Cohort_1/DCM Models/SPM12b/TremorDCM_OFFON_C2/Model Illustrations'};
    destdir     =   {'/home/action/micdir/data/fMRI/Cohort_1/DCM Models/SPM12b/TremorDCM_OFF_C1C2_GPe-and-GPi-and-STNhidden';};
end

if nargin < 4 
    varargin{1} =   'suborig';
    varargin{2} =   {'|1_*'  ;'|2_*'  ;'|3_*'  ;'|4_*'  ;'|5_*'  ;'|6_*'  ;'|7_*'  ;'|8_*'  ;'|9_*'  ;'|10_*' ;'|11_*' ;'|12_*' ;'|13_*' ;'|14_*' ;
                     '|15_*' ;'|16_*' ;'|17_*' ;'|18_*' ;'|19_*' ;'|20_*' ;'|21_*' ;'|22_*' ;'|23_*' ;'|24_*' ;'|25_*' ;'|26_*' ;'|27_*' ;'|28_*' ;
                     '|29_*' ;'|30_*' ;'|31_*' ;'|32_*' ;'|33_*' ;'|34_*' ;'|35_*' ;'|36_*' ;'|37_*' ;'|38_*' ;'|39_*' ;'|40_*' ;'|41_*' ;'|42_*' ;
                     '|43_*' ;'|44_*' ;'|45_*' ;'|46_*' ;'|47_*' ;'|48_*' ;'|49_*' ;'|50_*' ;'|51_*' ;'|52_*' ;'|53_*' ;'|54_*' ;'|55_*' ;'|56_*' ;
                     '|57_*' ;'|58_*' ;'|59_*' ;'|60_*' ;'|61_*' ;'|62_*' ;'|63_*' ;'|64_*' ;'|65_*' ;'|66_*' ;'|67_*' ;'|68_*' ;'|69_*' ;'|70_*' ;
                     '|71_*' ;'|72_*' ;'|73_*' ;'|74_*' ;'|75_*' ;'|76_*' ;'|77_*' ;'|78_*' ;'|79_*' ;'|80_*' ;'|81_*' ;'|82_*' ;'|83_*' ;'|84_*' ;
                     '|85_*' ;'|86_*' ;'|87_*' ;'|88_*' ;'|89_*' ;'|90_*' ;'|91_*' ;'|92_*' ;'|93_*' ;'|94_*' ;'|95_*' ;'|96_*' ;'|97_*' ;'|98_*' ;
                     '|99_*' ;'|100_*';'|101_*';'|102_*';'|103_*';'|104_*';'|105_*';'|106_*';'|107_*';'|108_*';'|109_*';'|110_*';'|111_*';'|112_*';
                     '|113_*';'|114_*';'|115_*';'|116_*';'|117_*';'|118_*';'|119_*';'|120_*';'|121_*';'|122_*';'|123_*';'|124_*';'|125_*';'|126_*';
                     '|127_*';'|128_*';'|129_*';'|130_*';};  
    varargin{2} =   varargin{2}(13:14);
    varargin{3} =   'subsuborig';
    varargin{4} =   {'|12c2*'};
    varargin{5} =   'subdest';
    varargin{6} =   {'|1_*'  ;'|2_*'  ;'|3_*'  ;'|4_*'  ;'|5_*'  ;'|6_*'  ;'|7_*'  ;'|8_*'  ;'|9_*'  ;'|10_*' ;'|11_*' ;'|12_*' ;'|13_*' ;'|14_*' ;
                     '|15_*' ;'|16_*' ;'|17_*' ;'|18_*' ;'|19_*' ;'|20_*' ;'|21_*' ;'|22_*' ;'|23_*' ;'|24_*' ;'|25_*' ;'|26_*' ;'|27_*' ;'|28_*' ;
                     '|29_*' ;'|30_*' ;'|31_*' ;'|32_*' ;'|33_*' ;'|34_*' ;'|35_*' ;'|36_*' ;'|37_*' ;'|38_*' ;'|39_*' ;'|40_*' ;'|41_*' ;'|42_*' ;
                     '|43_*' ;'|44_*' ;'|45_*' ;'|46_*' ;'|47_*' ;'|48_*' ;'|49_*' ;'|50_*' ;'|51_*' ;'|52_*' ;'|53_*' ;'|54_*' ;'|55_*' ;'|56_*' ;
                     '|57_*' ;'|58_*' ;'|59_*' ;'|60_*' ;'|61_*' ;'|62_*' ;'|63_*' ;'|64_*' ;'|65_*' ;'|66_*' ;'|67_*' ;'|68_*' ;'|69_*' ;'|70_*' ;
                     '|71_*' ;'|72_*' ;'|73_*' ;'|74_*' ;'|75_*' ;'|76_*' ;'|77_*' ;'|78_*' ;'|79_*' ;'|80_*' ;'|81_*' ;'|82_*' ;'|83_*' ;'|84_*' ;
                     '|85_*' ;'|86_*' ;'|87_*' ;'|88_*' ;'|89_*' ;'|90_*' ;'|91_*' ;'|92_*' ;'|93_*' ;'|94_*' ;'|95_*' ;'|96_*' ;'|97_*' ;'|98_*' ;
                     '|99_*' ;'|100_*';'|101_*';'|102_*';'|103_*';'|104_*';'|105_*';'|106_*';'|107_*';'|108_*';'|109_*';'|110_*';'|111_*';'|112_*';
                     '|113_*';'|114_*';'|115_*';'|116_*';'|117_*';'|118_*';'|119_*';'|120_*';'|121_*';'|122_*';'|123_*';'|124_*';'|125_*';'|126_*';
                     '|127_*';'|128_*';'|129_*';'|130_*';  
                     };
    varargin{6} =   varargin{6}(13:14);
    varargin{7} =   'subsubdest';
    varargin{8} =   {'/13c1c2-/*/'};
%     varargin{7} =   'newname';
%     varargin{8} =   '15c1c2-Deriv1_ParamMod_stoch_Mask';   
end

%% Configuration

% --- Directory Settings --- %

conf.dir.orig      =   origdir;
conf.dir.dest      =   destdir;

% --- File Settings ---%

conf.file.name     =   files;

% --- Varargin Configuration --- %                 

for a = 1:length(varargin)
if mod(a,2) == 1;    
switch varargin{a}
    case 'suborig'
        conf.dir.suborig     =   varargin{a+1};
    case 'subsuborig'
        conf.dir.subsuborig  =   varargin{a+1};
    case 'subdest'
        conf.dir.subdest     =   varargin{a+1};
    case 'subsubdest'
        conf.dir.subsubdest  =   varargin{a+1};
    case 'newname'
        conf.file.newname    =   varargin{a+1};
end
end
end

%% Initialize Parameters

                                                                         nOrig  =   length(conf.dir.orig);       
                                                                         nFiles =   length(conf.file.name);
if isfield(conf.dir,'suborig');    else conf.dir.suborig    = {''}; end; nOSub  =   length(conf.dir.suborig);
if isfield(conf.dir,'subsuborig'); else conf.dir.subsuborig = {''}; end; nOSubs =   length(conf.dir.subsuborig); 
if isfield(conf.dir,'subdest');    else conf.dir.subdest    = {''}; end; 
if isfield(conf.dir,'subsubdest'); else conf.dir.subsubdest = {''}; end; 

%% Loop through all Files/(sub)directories

% --- Loop through all the Original Directories --- %

for a = 1:nOrig
    
    % --- Root Orig/Dest --- %
    
    CurOrig  =   conf.dir.orig{a};  % Root Orig
    
    CurDest  =   conf.dir.dest{a};  % Root Dest
    
    for b = 1:nOSub
        
        % --- Sub Orig/Dest --- %
        
        CurOSub   =   pf_findfile(CurOrig,conf.dir.suborig{b},'fullfile');          % SubOrig
        
        try
            CurDSub   =   pf_findfile(CurDest,conf.dir.subdest{b},'msgN',0,'fullfile'); % SubDest
        catch
            CurDSub   =   pf_findfile(CurDest,conf.dir.subdest{1},'msgN',0,'fullfile'); % SubDest
        end
        
        for c = 1:nOSubs
            
            % --- SubSub Orig/Dest --- %
            
            CurOSubs    =   pf_findfile(CurOSub,conf.dir.subsuborig{c},'msgN',0,'fullfile');  %SubSubOrig
            
            try
                CurDSubs    =   pf_findfile(CurDSub,conf.dir.subsubdest{c},'msgN',0,'fullfile');  %SubSubDest
            catch
                CurDSubs    =   pf_findfile(CurDSub,conf.dir.subsubdest{1},'msgN',0,'fullfile');  %SubSubDest
            end
            
            for d = 1:nFiles
                
                CurFile         =   pf_findfile(CurOSubs,conf.file.name{d},'msgN',0,'fullfile');   % Current File
                
%                 CurFile         =   pf_findfile(CurFile,'*.jpg','fullfile');
                
                [~,CurFilen]    =   fileparts(CurFile);   
                
                % --- Copying files --- %
                
                fprintf('\n%s\n',['Current file is ' CurFile])
                if ~exist(CurDSubs,'dir'); mkdir(CurDSubs); end;
                copyfile(CurFile,CurDSubs)
                disp(['Copied file to ' CurDSubs])
                
                % === TMP === %
                cd(CurDSubs)
                renamefile('p*','p','c2-p')
                renamefile('S*','S','c2-S')
                % === TMP === %
                
 
                % --- New Name --- %
                
                if isfield(conf.file,'newname')
                    disp('You specified that this file should contain a new name, this is not implemented yet. Entering debug mode')
                    keyboard
                    cd(CurOSubs)
                end
                
                % === END === %
            end
        end
    end
end
                    
%% Benchmark

T = toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T/60) ' minutes'])                
            
            
            
            
            
        
        
        
        

    
    