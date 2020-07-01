function pf_emg_raw2regr_preproc_combifile(conf)
% pf_emg_raw2regr_preproc_combifile is a bit of an in between function
% within the preprocessing step of the EMG raw2regr batch. Specifically it
% can combine files into one file. This might be useful, because you don't
% always perform the same preprocessing on all channels within your
% dataset.
%
% Part of pf_emg_raw2regr.m NB: NOT FINISHED YET

% © Michiel Dirkx, 2015
% $ParkFunC, version 20150220

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nSub    =   length(conf.sub.name);
nSess   =   length(conf.sub.sess);
nRun    =   length(conf.sub.run);
nFiles  =   size(conf.preproc.combi.hdrfile,1);

Files   =   cell(nSub*nSess*nRun,1);
cnt     =   1;

%--------------------------------------------------------------------------

%% Retrieve all file info
%--------------------------------------------------------------------------

for a = 1:nSub
    CurSub  =   conf.sub.name{a};
    for b = 1:nSess
        CurSess =   conf.sub.sess{b};
        for c = 1:nRun
            CurRun  =   conf.sub.run{c};    
            CurFile =   cell(nFiles,1);
            Chans   =   cell(nFiles,1);
            for d = 1:nFiles                
                CurInfo     =   conf.preproc.combi.hdrfile(a,:);
                CurFile{d}  =   pf_findfile(fullfile(conf.dir.root,CurInfo{1}),CurInfo{2},'conf',conf,'CurSub',a,'CurSess',b,'CurRun',c,'fullfile');
                Chans{d}    =   conf.preproc.combi.chans{a};
            end            
            %===========================STORE=============================%
            Files{cnt,1}.sub    =   CurSub;
            Files{cnt,1}.sess   =   CurSess;
            Files{cnt,1}.run    =   CurRun;
            Files{cnt,1}.hdr    =   CurFile;
            Files{cnt,1}.chans  =   Chans;
            %=============================================================%
            cnt     =   cnt+1;
        end
    end
end
keyboard
%--------------------------------------------------------------------------

%% Combine the mofos
%--------------------------------------------------------------------------




