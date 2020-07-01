function [A freq] = extract_emg_frequencies(EEG,fmin,fmax)
% this function is still 'work in progress...' BUT NEVER USED

%     load parameters

    % mkdir emg_check
    emgmat=EEG.data';

    volTrigs=find(strcmp({EEG.event(:).type},'V')==1); % of 'beide_strekken' ?
    if numel(volTrigs)==0
        volTrigs=find(strcmp({EEG.event(:).type},'65535')==1); 
    end

    nSignals = size(emgmat,2);
    volB=[EEG.event(volTrigs).latency]; % array van beginsamples.
% volB = volB+4*EEG.srate;
    nEpochs = length(volB);
    NFFT=EEG.event(volTrigs(2)).latency-EEG.event(volTrigs(1)).latency; % scalar (hoeveel samples/vol)
    Fs = EEG.srate;
%NFFT = Fs * 10;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    ind = find(f>=fmin & f<=fmax);
    freq = f(ind); % only return the frequencies within range
    A = zeros(length(freq),nSignals); % prepallocate for all muscles and number of frequency bins
    
    % loop through all muscles
    for i=1:nSignals

%         disp(['processing muscle... ' num2str(i)]);
        % maak het model voor emg en voor 'mov'...
        emg=zeros(NFFT,nEpochs);

        % get emg data of all volumes of current muscle 
        for j=1:nEpochs
            b=volB(j);
            e=b+NFFT-1;
            emg(:,j)=emgmat(b:e,i);
        end

        f_ind=round([fmin fmax]/(Fs/NFFT));
        f_ind=f_ind(1):f_ind(2);

        % filter high-pass...
        [b a]=butter(5,25/(Fs/2),'high');
        emg=filter(b,a,emg);
        % then take envelope with absolute values.
        emg=abs(emg);

        % and then fourier-transform it...
        EMG=fft(emg);
        % then sum all volumes
        F = EMG(:,1);
        for j=2:nEpochs
           F = F + EMG(:,j);
        end
        %NFFT = size(emg,1);
        F = 2*abs(F(1:NFFT/2+1))/NFFT;
        % add this spectrum to the return buffer
        A(:,i) = F(ind);

%         % and then take sum of power between 9 and 20.
%         % i checked, that this does NOT coincide with the volume artefact peaks
%         % in the EMG spectrum.
%         emgreg(:,i)=sum(abs(EMG(f_ind,:)));

    end



