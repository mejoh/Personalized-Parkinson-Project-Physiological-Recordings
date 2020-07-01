function [ onsetSamples nSamplesPerEpoch ] = get_volume_onset_indices(EEG)
% get_volume_onset_indices: get the volume onsets from EEG events 
    
    volTrigs=find(strcmp({EEG.event(:).type},'V')==1);
    if numel(volTrigs)==0
        volTrigs=find(strcmp({EEG.event(:).type},'65535')==1);
    end
    onsetSamples=[EEG.event(volTrigs).latency]; % array van beginsamples.
    if nargout>=2
        if length(onsetSamples)>=2
            nSamplesPerEpoch=onsetSamples(2)-onsetSamples(1); % scalar (hoeveel samples/vol)
            % calculate Tr for debugging/error checking
            Tr = nSamplesPerEpoch/EEG.srate;
            % sprintf('Time between first volume onsets: %g',Tr);
            if Tr<2 || Tr>4
                Error('Tr invalid');
            end
        else
            nSamplesPerEpoch = 0;
            warning('no volume triggers found in EEG event table');
        end
    end