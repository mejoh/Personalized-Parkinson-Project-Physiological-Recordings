function pf_pmg_prepraw_cremont(conf,files)
% pf_pmg_prepraw_cremont(conf,files) is part of the prepraw section of
% pf_pmg_batch. Specifically, it will create a user defined montage of the
% raw data. For instance, you can convert monopolar>dipolar.
%
% Part of pf_pmg_batch.m

% © Michiel Dirkx, 2015
% $ParkFunC, version 20150428

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nFile   =   length(files);

%% Loop
%--------------------------------------------------------------------------

for a = 1:nFile
    
    CurFile     =   files{a};
    CurSub      =   CurFile.sub;
    CurSess     =   CurFile.sess;
    CurHand     =   CurFile.hand;
    CurRaw      =   CurFile.file;
    
    [path,nm,ex]    =   fileparts(CurRaw);
    fprintf('\n%s\n',['Working on ' nm])
   
    [dat,hdr]   =   ReadEDF_shapkin(CurRaw);
    
    % --- Retrieve correct channels for CurHand --- %
    
    iChan = strcmp(conf.prepraw.cremont.handchan(:,1),CurHand);
    iChan = conf.prepraw.cremont.handchan{iChan,2};
    Chan  = conf.prepraw.cremont.mont(iChan,:);  
    nChan = size(Chan,1);
    
    % --- Create fresh new montage --- %
    
    newdat      =   cell(1,nChan);
    labels      =   cell(nChan,1);
    transducer  =   cell(nChan,1);
    units       =   cell(nChan,1);
    physmin     =   nan(nChan,1);
    physmax     =   nan(nChan,1);
    digmin      =   nan(nChan,1);
    digmax      =   nan(nChan,1);
    prefilt     =   cell(nChan,1);
    samplerate  =   nan(nChan,1);
    
    for b = 1:nChan
        
        CurChan =   Chan(b,:);
        
        % --- Retrieve Active and Reference electrode --- %
        
        iA      =   find(strcmp(hdr.labels,CurChan{2}));
        iR      =   find(strcmp(hdr.labels,CurChan{3}));
        
        % --- Build newdat --- %
        
        CurAct      =   dat{iA};
        CurRef      =   dat{iR};
        newdat{b}   =   CurAct - CurRef;
        
        % --- Build new header --- %
        
        labels(b)       =   CurChan(1);
        transducer(b)   =   hdr.transducer(iA);
        units(b)        =   hdr.units(iA);
        physmin(b)      =   hdr.physmin(iA);
        physmax(b)      =   hdr.physmin(iA);
        digmin(b)       =   hdr.digmin(iA);
        digmax(b)       =   hdr.digmax(iA);
        prefilt(b)      =   hdr.prefilt(iA);
        samplerate(b)   =   hdr.samplerate(iA);
        
        % --- plot if desired --- %
        
        if strcmp(conf.prepraw.cremont.plot,'yes')
            figure
            keyboard
            subplot(3,1,1)
            plot(CurAct)
            title([CurChan{2} ' (Active electrode)'])
            subplot(3,1,2)
            plot(CurRef)
            title([CurChan{3} ' (Reference electrode)'])
            subplot(3,1,3)
            plot(newdat{b})
            title([CurChan{1} ' (Active - Reference)'])
        end
            
    end
    
    % --- Build final header --- %
    
    newhdr.ver        =   hdr.ver;
    newhdr.patientID  =   hdr.patientID;
    newhdr.recordID   =   hdr.recordID;
    newhdr.startdate  =   hdr.startdate;
    newhdr.starttime  =   hdr.starttime;
    newhdr.length     =   hdr.length;
    newhdr.records    =   hdr.records;
    newhdr.duration   =   hdr.duration;
    newhdr.channels   =   nChan;
    newhdr.labels     =   labels;
    newhdr.transducer =   transducer;
    newhdr.units      =   units;
    newhdr.physmin    =   physmin;
    newhdr.physmax    =   physmax;
    newhdr.digmin     =   digmin;
    newhdr.digmax     =   digmax;
    newhdr.prefilt    =   prefilt;
    newhdr.samplerate =   samplerate;
    newhdr.annotation =   hdr.annotation;
    
    % --- Check Fs consistency, adjust if necessary --- %
    
    uFs =   unique(newhdr.samplerate);
    
    if length(uFs) > 1
       fprintf('%s\n','- Cannot handle multiple samplerates, resampling data with lowest Fs...')
       refFs =   max(newhdr.samplerate);
       iFs   =   find(newhdr.samplerate~=refFs);
       for c = 1:length(iFs)
           CurDat                       =   resample(newdat{iFs(c)},refFs,newhdr.samplerate(iFs(c)));
           newdat{iFs(c)}               =   CurDat;
           fprintf('%s\n',['-- Resampled channel ' num2str(iFs(c)) ' with Fs=' num2str(newhdr.samplerate(iFs(c))) ' Hz to ' num2str(refFs) ' Hz' ]);
           newhdr.samplerate(iFs(c))    =   refFs;
       end   
    end
    
    % --- Prepare to save --- %
    
    iRAW            =   strfind(nm,'RAW');
    
    if ~isempty(iRAW)
        newnm  =    [nm(1:iRAW-1) conf.prepraw.cremont.montname nm(iRAW+3:end) ex];   
    else
        newnm  =   [nm '_' conf.prepraw.cremont.montname ex];
    end
    
    % --- Save --- %
    
    savedir    =   conf.dir.prepraw;
    if ~exist(savedir,'dir'); mkdir(savedir); end
    savename   =   fullfile(savedir,newnm);
    SaveEDF_shapkin(savename,newdat,newhdr);
    
    fprintf('%s\n',['Saved as ' newnm])
    
end
    
    
    


