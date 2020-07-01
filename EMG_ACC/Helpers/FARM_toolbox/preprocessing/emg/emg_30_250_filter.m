%% pas nog een last-ditch filteractie toe...
%
% gooi alles tussen de 30 en de 250 Hz WEG!
%
function EEGOUT=emg_30_250_filter(EEG)
    srate=2^11;

    tmp=EEG.data';
    i_b=floor(size(tmp,1)/(srate/30)+0.5);
    i_e=floor(size(tmp,1)/(srate/250)+0.5);


    TMP=fft(tmp);

    EMGC=zeros(size(TMP));

    % i_size...
    i_s=size(TMP,1);

    % wat wil je houden? (teken t uit!)
    keep=[i_b:i_e (i_s-i_e+2):(i_s-i_b+2)];
    EMGC(keep,:)=TMP(keep,:);
    emgc=ifft(EMGC);

    % emgc=abs(emgc);

    EEG.data=emgc';

    EEGOUT=EEG;