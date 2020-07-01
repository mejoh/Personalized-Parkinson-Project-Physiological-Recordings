function pf_pmg_prepraw_sig2edf(conf,Files)
% pf_pmg_prepraw_sig2edf is part of the 'prepraw' part of the pf_pmg_batch.
% Specifically, it will convert files saved with Signal (in .mat) to EDF+,
% so it will work with the rest of the batch. NOT WORKING YET.
%
% Part of pf_pmg_batch

% © Michiel Dirkx, 2015
% $ParkFunC, 20150515

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nFiles  =   length(Files);
nChan   =   length(conf.prepraw.sig2edf.chan);
chans   =   cell(1,nChan);

%--------------------------------------------------------------------------

%% Loop 
%--------------------------------------------------------------------------

fprintf('\n')

for a = 1:nFiles
    
   CurFile  =   Files{a};
   CurSub   =   CurFile.sub;
   CurSess  =   CurFile.sess;
   CurF     =   CurFile.file;
   
   [p,n,ex] =   fileparts(CurF);
   
   fprintf('%s\n',['Working on ' n]);
   
   % --- Load file --- %
   
   F        =   load(CurF);
   fn       =   fieldnames(F);
   file     =   F.(fn{1});
   
   onetrial =   size(file.values,1); 
   Fsample  =   onetrial/10;    % onetrial is fixed 10 seconds
   nEvent   =   length(file.frameinfo);
   
   % --- Build data: divide channels / concatenate trials --- %
   
   fprintf('%s\n',['- Adding ' num2str(nChan) ' channels with samplerate ' num2str(Fsample) ' Hz.'])
   
   for b = 1:nChan
       
       chans{b}     =   file.values(:,b,:);
       
       nTrials      =   size(chans{b},3);
       fulldat      =   nan(onetrial*nTrials,1);
       cnt          =   1;
       
       for c = 1:nTrials
           fulldat(cnt:cnt+onetrial-1,1) =   chans{b}(:,1,c);
           cnt              =   cnt+onetrial;
       end
       
       chans{1,b}     =   fulldat;
   end
   
   d = chans;
    
   % --- Build Header --- %
   
    h.patientID  =   n;                     
    h.recordID   =   n;
    h.startdate  =   'Unknown';
    h.starttime  =   'Unknown';
    h.channels   =  nChan;
    h.labels     =  conf.prepraw.sig2edf.chan;
    
    for b = 1:nChan
    h.samplerate(b,1) =  Fsample;
    end
    
    for b = 1:nEvent
       
        h.annotation.event{1,b}     =   ['POSH' num2str(b)];
        h.annotation.starttime(b,1) =   file.frameinfo(b).start;
        
        if b~=nEvent
            h.annotation.duration(b,1) = file.frameinfo(b+1).start-file.frameinfo(b).start;
        else
            h.annotation.duration(b) = h.annotation.duration(b-1);
        end
    end
    
    % --- Save as EDF+ ---%
    
    if ~exist(conf.dir.prepraw,'dir'); mkdir(conf.dir.prepraw); end
    savename    =   fullfile(conf.dir.prepraw,[n '.edf']);
    SaveEDF_shapkin(savename,d,h);
    fprintf('%s\n',['Saved EDF+ file to ' savename])
    
    
end

