ed% artifact correction, using an artifact template made up of clustered
% templates.
%
% we follow Niazy's example for EEG, but with modifications for EMG.
% for in the EMG you CANNOT assume the slice-artifacts are the same... but
% perhaps, they can be clustered.
% the most important modifications:
% - a 40-Hz high-pass filter, ie: 2X the slice-frequency, to counter any
%   kind of movement artifacts degrading the slice-template, instead of 1
%   Hz.
% - for slice correction, the average artifact made up of the best-fitting
%   cluster of artifact templates
% - using optimal basis sets for removal of remainding artifacts.
% - for volume correction, using 0-filling at the times of the start of the
%   new scan
% - in frequency domain, 0-filling at all of the slice-frequencies
%   (optional)
% - a higher low-pass filter than the 70 Hz, before ANC.

function EEG=emg_slicecorrection(EEG)

    beginshift=0.07;
    interpfactor=15;
    srate=EEG.srate;
    

    
    window=40;
    
    % markers for s and V
    ms=find(strcmp({EEG.event(:).type},'sliceTrigger'));
    mV=find(strcmp({EEG.event(:).type},'65535'));
    
    % samples for s and V
    ss=[EEG.event(ms).latency];
    sV=[EEG.event(mV).latency];

    
    % calculate # samples for slices.
    sduration=ceil(median(ss(2:end)-ss(1:end-1)));
    % calculate beginning for offset.
    soffset=round(-1*beginshift*sdur);
    
    % this is valid, for each channel!
    % the clusterdata is calculated separetely for each channel.
    sl=struct('others',[],'b',[],'adjusts',[]);
    
    % initial choice for the other slices.
    % and initial adjustments for the other slice artifacts.
    for i=1:numel(ss)
        sl(i).others=pick_function(i,numel(ss),window);
        sl(i).b=(ss(i)+soffset)*interpfactor;
        sl(i).e=(ss(i)+soffset+sduration-1)*interpfactor;
        sl(i).adjusts=zeros(size(sl(i).others));
    end
    
    
    % take first channel, interp data, and make iss; the marker position
    % for the interpolated slice-marker.
    v=EEG.data(1,:);
    iv=interp(v,interpfactor);
    
    % now calculate the 'adjusts'; the amount of data points the others
    % have to shift to be in 'perfect' alignment with the current slice
    % template.
    for i=1:numel(ss)
        
        curdata=iv(sl(i).b:sl(i).e)';

        for j=1:numel(sl(i).others)
            
            % what is the beginning and ending of the other slices??
            tmp_b=sl(sl(i).others(j)).b;
            tmp_e=sl(sl(i).others(j)).e;
            % construct the matrix.
            otherdata=iv(tmp_b:tmp_e);

            sl(i).adjusts(j)=find_adjustment(curdata,otherdata);
            
        end
        
    end
        


    

    
    
    shifts=round(-1.1*interpfactor):round(1.1*interpfactor);
    % calculate time-shifts for each slice candidate.
    for i=1:numel(ss)

        % current template
        cur=iv(
    
        % other templates
        for j=1:numel(sl.others)
            
        
    
    for i=2:numel(ss);

        % samples of current slice.
        iss(i)=(ss(i)+sbgn)*interpfactor;

        prevdata=iv(iss(i-1):(iss(i-1)+isdur-1))';
        curdata=iv(iss(i):(iss(i)+isdur-1))';


        shifteddata=zeros(isdur,numel(shifts));

        for j=1:numel(shifts)
            
            b=iss(i)+shifts(j);
            e=iss(i)+shifts(j)+isdur-1;
            
            shifteddata(:,j)=iv(b:e);
        end
        
        % correlations, between shifted (current) data and the previous
        % data.
        r=corr(prevdata,shifteddata);
        % only 1 can be the max. otherwise take the first one.
        adjust=find(r==max(r),1)-(numel(shifts)-1)/2-1;
        
        aiss(i)=iss(i)+adjust;
        
        
    end
    
    m=[];
    for i=1:5
        m(:,end+1)=iv(aiss(i):(aiss(i)+isdur-1));
    end
    figure;plot(m);
    
    
    
    

    