% opschonen Volume Triggers
%

function EEGOUT = emg_remove_volumeartifact(EEG)

    load ../parameters

    
    mV=find(strcmp({EEG.event(:).type},'V'));
    sV=[EEG.event(mV).latency];
    

    Vdur_seconds = 0.060;
    relVmarker = 0.6;
    
    % now the markers and data samples are known.

    % we know also that the artifact from the volume lasts about 24-25 ms.
    % (see powerpoint presentation on artifact corrections).
    % !! re-calculate for different scanners or sequences...
    % now calculate the amount of samples that need to be thrown away.
    Vdur=round(Vdur_seconds*EEG.srate);
    
    
    % The artifact is at about 95% of the total marker duration... so, the
    % calculate the beginning relative to the volume marker, and the end
    % relative to the volume marker
    s_pre = ceil(relVmarker*Vdur*1.4); % 10 % extra aan Vdur...
    s_post = ceil((1-relVmarker)*Vdur*1.4); % 10 % extra aan Vdur ook hier...
    

    % do some magic for getting the samples that need work on, b and e
    % samples, part 1.
    be=reshape(sort([sV-s_pre sV+s_post]),2,numel(sV))';
    b=be(:,1);
    e=be(:,2);
    
    
    
    
        %% 2nd try: with splines, fitting in-between.
    % what are the samples that need to be worked on, part 2.
    % define filter to keep low-f components...
    % butter-b and butter-a...
    % some filtering...
%     Wp=30/(EEG.srate/2);
%     Ws=15/(EEG.srate/2);
%     Rp=3;Rs=40;
%     [n Wn]=buttord(Wp,Ws,Rp,Rs);
%     [bb ba]=butter(n,Wn,'low');
    
    
    

%     for j=1:size(EEG.data,1)
%         for i=1:numel(b)
% 
%             % do spline-interpolation in the 
% 
%             xpoints=(b(i)-Vdur):(e(i)+Vdur);
%             ypoints=EEG.data(j,xpoints);
%             indices=(Vdur+1):(numel(xpoints)-Vdur);
% 
% 
%             ypoints=filtfilt(bb,ba,ypoints);
%             xpoints(indices)=[];
%             ypoints(indices)=[];
% 
%             % figure;plot(xpoints,ypoints);
% 
%             % from matlab spline tutorial...
%             xx=xpoints(1):1:xpoints(end);
%             yy=spline(xpoints,ypoints,xx);
%             % figure;plot(xpoints,ypoints,'o',xx,yy);
% 
%             newYpoints=yy(indices);
% 
%             EEG.data(j,b(i):e(i))=newYpoints;
%             
%             if i==2
%                 keyboard;
%             end
%             % fh=figure;plot(xpoints,ypoints,'o',xx,yy);
%             % close(fh);
% 
% 
%         end
%         
%     end
% 
%    target_samples=[];
    for i=1:numel(b)
        
        olddat=EEG.data(:,b:e);
        multiplier=ones(EEG.nbchan,1)*(1-hanning(1:numel(b:e))');
        % apply hanning window
        newdat=olddat.*multiplier;
        EEG.data(:,b:e)=newdat;
        
    end
    
    % EEG.data(:,target_samples)=0;
    
    % and now actually do something with it...
    
    % EEG.data(:,target_samples)=0;
    
    % keyboard;
    
    EEGOUT=EEG;
    
    
%     if numel(mV)==0;
%         mV=find(strcmp({EEG.event(:).type},'65535'));
%     end
    

%     fmrib_fastr.m uses a window length of ~5000 (ie, the entire data of 1 volume, for volume correction.
%     Together with PCA this may deteriorate the 'biosignal'; it's an extra filtering step that's not really neede for our purposes
%     Therefore we will use only slice-artefact correction, and just throw away our short periods of data near the volume-marker. (~50 in 2048 mode and ~25 in 1024 mode.)
% 
%     
%     lpf=[];
%     if EEG.srate==1024
%         L=20;
%     elseif EEG.srate==2048
%         L=10;
%     end
% 
% 
%     % L=10;
%     Win=15;
%     etype='V';
%     strig=0;
%     anc_chk=0;
%     trig_correct=0;
%     Volumes=[];
%     Slices=[];
%     pre_frac=0.00; % 0.03, dus...?
%     exc_chan=[];
%     NPC='auto';
% 
%     EEGOUT=pop_fmrib_fastr(EEG,lpf,L,Win,etype,strig,anc_chk,trig_correct,Volumes,Slices,pre_frac,exc_chan,NPC);
