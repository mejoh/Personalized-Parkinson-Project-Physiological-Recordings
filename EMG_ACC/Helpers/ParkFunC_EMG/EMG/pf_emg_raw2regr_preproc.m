function pf_emg_raw2regr_preproc(conf)
%
% pf_emg_raw2regr_preproc preprocesses your raw EMG data using FARM or
% FASTR (e.g. removing MRI artifacts)
%
% Part of pf_emg_raw2regr.m

% Michiel Dirkx, 2015
% $ParkFunC, version 20150124

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

fprintf('\n%s\n\n','% -------------- Performing EMG preprocessing -------------- %')

nSub     =   length(conf.sub.name);
nSess    =   length(conf.sub.sess);
nRun     =   length(conf.sub.run);
Files    =   cell(nSub*nSess*nRun,1);
cnt      =   1;

nMeth    =   length(conf.preproc.meth);

if ~exist(conf.dir.preproc,'dir'); mkdir(conf.dir.preproc); end

%--------------------------------------------------------------------------

%% Retrieve all files
%--------------------------------------------------------------------------

fprintf('%s\n\n','1) Retrieving all file info')

for a = 1:nSub  
    CurSub  =   conf.sub.name{a};
    for b = 1:nSess
        CurSess =   conf.sub.sess{b};
        for c = 1:nRun
            CurRun  =   conf.sub.run{c};
            datfile =   pf_findfile(conf.dir.raw,conf.preproc.datfile,'conf',conf,'CurSub',a,'CurSess',b,'CurRun',c);
            hdrfile =   pf_findfile(conf.dir.raw,conf.preproc.hdrfile,'conf',conf,'CurSub',a,'CurSess',b,'CurRun',c);
            mrkfile =   pf_findfile(conf.dir.raw,conf.preproc.mrkfile,'conf',conf,'CurSub',a,'CurSess',b,'CurRun',c);
            %============================FILES============================%
            Files{cnt,1}.datfile    =   fullfile(conf.dir.raw,datfile);
            Files{cnt,1}.hdrfile    =   fullfile(conf.dir.raw,hdrfile);
            Files{cnt,1}.mrkfile    =   fullfile(conf.dir.raw,mrkfile);
            Files{cnt,1}.sub        =   CurSub;
            Files{cnt,1}.sess       =   CurSess;
            Files{cnt,1}.run        =   CurRun;
            %=============================================================%
            fprintf('%s\n',['- Added ' datfile]);
            cnt =   cnt+1;
        end
    end
end

%--------------------------------------------------------------------------

%% Perform preprocessing
%--------------------------------------------------------------------------

for a = 1:nMeth
    
    CurMeth =   conf.preproc.meth{a};
    
    switch CurMeth
        
        %=================================================================%
        case 'farm'
        %=================================================================%    
        
        fprintf('\n%s\n',[num2str(a+1) ') Performing FARM analysis'])
        keyboard;
            
        %=================================================================%
        case 'fastr'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Performing FASTR analysis'])
        pf_emg_raw2regr_preproc_fastr(conf,Files);
        
        %=================================================================%
        case 'combifile'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Combining BVA files'])
        pf_emg_raw2regr_preproc_combifile(conf);
        
        %=================================================================%
        otherwise
        %=================================================================%
            
        warning('raw2regr:preproc',['Could not determine method "' CurMeth '"'])  
        
        %=================================================================%
    end 
end





        
        
        
        
        
        




