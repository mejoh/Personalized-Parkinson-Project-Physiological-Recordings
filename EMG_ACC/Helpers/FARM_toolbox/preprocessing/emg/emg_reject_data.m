% cleans an EMG trace for wavelet analysis...

% calculate first V event...

function out=emg_reject_data(EEG)


    Vmarkers=find(strcmp({EEG.event(:).type},'V'));
    smarkers=find(strcmp({EEG.event(:).type},'s'));

    Vlatencies=[EEG.event(Vmarkers).latency];
    slatencies=[EEG.event(smarkers).latency];

    mean_s_lat=round(mean(slatencies(2:end)-slatencies(1:end-1)));

    beginning=Vlatencies(1);
    ending=slatencies(end)+mean_s_lat;

    % first the end, then the begin...
    EEG.data(:,ending+1:end)=[];
    EEG.data(:,1:beginning-1)=[];

    EEG.pnts=beginning-ending+1;


    % and then fix the events.
    for i=1:numel(EEG.event)
        EEG.event(i).latency=EEG.event(i).latency-(beginning-1);
    end

    % and finally, 0 the 0.1 sec in the first V and at the end.
    EEG.data(:,1:floor(EEG.srate/50))=0;
    EEG.data(:,end:-1:end-floor(EEG.srate/50))=0;
    
    out=EEG;
