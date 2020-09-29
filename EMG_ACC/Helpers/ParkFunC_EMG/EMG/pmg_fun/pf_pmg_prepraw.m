function pf_pmg_prepraw(conf)
% pf_pmg_prepraw(conf) is part of the pf_pmg_batch, a function to
% analyze PMG (EMG+Accelerometer) data. Specifically, it
% prepares raw data for further analysis. 
% You can choose the following preparing methods (using your conf.prepraw.meth):
%   -   'cremont': this will convert raw, unipolar EMG data to your
%                  specified montage
%   -   'edfmerge': merges EDF files, e.g. ones who had a 'toilet break'
%   -   'sig2edf': convert mat files created with Signal to EDF+ (NOT
%                  WORKING YET)
%
%OLD NOT WORKING YET:
%   -   'cutedf': this will cut the EDF files into NxFs EDF files (NOTE: I HAVE TO DEBUG THIS)
%   -   'edfequalize': equalizes the Fs of the EDF files
%
% Part of pf_pmg_batch.m

% Michiel Dirkx, 2015
% $ParkFunC, version 20150428

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nSub    =   length(conf.sub.name);
nSess   =   length(conf.sub.sess);

Files   =   cell(nSub*nSess,1);
nAddon  =   length(conf.prepraw.edfmerge.addfiles);
cnt     =   1;

nMeth   =   length(conf.prepraw.meth);

%--------------------------------------------------------------------------

%% Retrieve all fullfiles
%--------------------------------------------------------------------------

fprintf('%s\n\n','1) Retrieving all file info')

for a = 1:nSub
    CurSub  =   conf.sub.name{a};
    CurHand =   conf.sub.hand{a};
    for b = 1:nSess
        CurSess =   conf.sub.sess{b};
        CurFile =   pf_findfile(conf.dir.raw,conf.prepraw.file,'conf',conf,'CurSub',a,'CurSess',b);
        %==========================FILES==================================%
        Files{cnt,1}.sub        =   CurSub;
        Files{cnt,1}.sess       =   CurSess;
        Files{cnt,1}.hand       =   CurHand;
        Files{cnt,1}.file       =   fullfile(conf.dir.raw,CurFile);
        if strcmp(conf.prepraw.meth,'edfmerge')
            for c = 1:nAddon
                add{c} = pf_findfile(conf.dir.raw,conf.prepraw.edfmerge.addfiles{c},'conf',conf,'CurSub',a,'CurSess',b,'fullfile');
            end
            Files{cnt,1}.addon  =   add;
        end
        %=================================================================%
        cnt =   cnt+1;
        fprintf('%s\n',['- added ' CurFile]);
    end
end

%--------------------------------------------------------------------------

%% Perform prepraw
%--------------------------------------------------------------------------

for a = 1:nMeth
    CurMeth =   conf.prepraw.meth{a};
    switch  CurMeth
        
        %=================================================================%
        case 'sig2edf'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Converting Signal files to EDF+'])
        pf_pmg_prepraw_sig2edf(conf,Files);
        
        %=================================================================%
        case 'cremont'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Prepping the raw data'])
        pf_pmg_prepraw_cremont(conf,Files);
        
%         %=================================================================%
%         case 'cutedf'
%         %=================================================================%
%         
%         fprintf('\n%s\n',[num2str(a+1) ') Cutting EDF files into NxFs files'])
%         pf_pmg_cutedf(conf.dir.root,conf.preproc.file,'sbdir',conf.sub.name,'sbsbdir',conf.sub.sess,'save');
%         
%         %=================================================================%
%         case 'edfequalize'
%         %=================================================================%
%         
%         fprintf('\n%s\n',[num2str(a+1) ') Equalizing the Fs in EDF file'])
%         pf_edf_equalizeFs(conf.dir.root,conf.preproc.file,'sbdir',conf.sub.name,'sbsbdir',conf.sub.sess,'save');
%          
        %=================================================================%
        case 'edfmerge'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Merge EDF files'])
        pf_pmg_prepraw_edfmerge(conf,Files);
        
        %=================================================================%
        otherwise
        %=================================================================%
        
        warning('pmg:prepraw',['Could not determine prepraw method "' CurMeth '"'])
        
        %=================================================================%
    end
end
            
