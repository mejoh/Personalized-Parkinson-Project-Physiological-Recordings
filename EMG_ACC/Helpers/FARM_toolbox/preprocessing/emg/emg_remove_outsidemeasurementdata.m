% cleans an EMG trace for wavelet analysis...

% calculate first V event...

function out=emg_remove_outsidemeasurementdata(EEG,mark)


    
    Vmarkers=find(strcmp({EEG.event(:).type},mark));
    % smarkers=find(strcmp({EEG.event(:).type},'s'));

    Vlatencies=[EEG.event(Vmarkers).latency];   
    % slatencies=[EEG.event(smarkers).latency];

    mean_V_lat=round(mean(Vlatencies(2:end)-Vlatencies(1:end-1)));

    beginning=Vlatencies(1);
    ending=Vlatencies(end)+mean_V_lat;   %EEGending=3193267

    % first the end, then the begin...
%     EEG.data(:,ending+1:end)=[];      % OLD (<20150721) situation 
    
    % --- 20150727: we take a little longer, we go for 2second but if this
    % is longer thant the actual data we take 1.5. This doesn't matter as
    % we save the end of the last scan (and if you know the TR it doesnt
    % matter at all since you always have the start scan marker)
    if isempty(EEG.data(:,ending+EEG.srate*1+1:end))
        EEG.data(:,ending+EEG.srate*0.5+1:end)=[];        % NEW (>20150721) situation, we take a litte longer data so that we can use a hanning taper of 2s
        fprintf('%s\n','- Used 0.5 seconds extra data for hanning taper');
    elseif isempty(EEG.data(:,ending+EEG.srate*1.5+1:end))
        EEG.data(:,ending+EEG.srate*1+1:end)=[];        % NEW (>20150721) situation, we take a litte longer data so that we can use a hanning taper of 2s
        fprintf('%s\n','- Used 1 second extra data for hanning taper');
    elseif isempty(EEG.data(:,ending+EEG.srate*2+1:end)) 
        EEG.data(:,ending+EEG.srate*1.5+1:end)=[];        % NEW (>20150721) situation, we take a litte longer data so that we can use a hanning taper of 2s
        fprintf('%s\n','- Used 1.5 seconds extra data for hanning taper');
    else
        EEG.data(:,ending+EEG.srate*2+1:end)=[];        % NEW (>20150721) situation, we take a litte longer data so that we can use a hanning taper of 2s 
        fprintf('%s\n','- Used 2 seconds extra data for hanning taper');
    end
    
    EEG.data(:,1:beginning-1)=[];

    EEG.pnts=ending-beginning+1;
    EEG.xmax=(EEG.pnts-1)/EEG.srate;
    
    % and then fix the events.
    for i=1:numel(EEG.event)
        EEG.event(i).latency=EEG.event(i).latency-(beginning-1);
    end
    
    % --- 20150721 And enter the event, ending of scan --- %
    
    newending                 = ending-(beginning-1);
    EEG.event(end+1).latency  = newending;
    EEG.event(end).duration = 0;
    EEG.event(end).channel  = 0;
    EEG.event(end).bvtime   = EEG.event(Vmarkers(end)).bvtime;
    EEG.event(end).type     = 'ENDLASTSCAN';
    EEG.event(end).code     = 'Response';
    EEG.event(end).urevent  = EEG.event(Vmarkers(end)).urevent+1;
    
    % --- 20150721 add an extra event because the last scan will not be saved correctly --- %
    EEG.event(end+1).latency  = 66;
    EEG.event(end).duration = 0;
    EEG.event(end).channel  = 0;
    EEG.event(end).bvtime   = [];
    EEG.event(end).type     = 'easteregg';
    EEG.event(end).code     = 'Response';
    EEG.event(end).urevent  = [];
    
    
    % and finally, 0 the 0.1 sec in the first V and at the end. % NOTE
    % 20150721: WHY DO THIS?????
    EEG.data(:,1:floor(EEG.srate/50))=0;
%     EEG.data(:,end:-1:end-floor(EEG.srate/50))=0;
    EEG.data(:,newending:-1:newending-floor(EEG.srate/50))=0;
    
    out=EEG;
