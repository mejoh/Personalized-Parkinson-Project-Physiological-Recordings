function EEG=emg_filter_lowpass(EEG)


    % this gives huge artefact ringing...
%     e=round(freq/EEG.srate*EEG.pnts);
%     
%     tmp=EEG.data';
%     
%     TMP=fft(tmp);
%     
%     TMP([e:end-e+2],:)=0;
%     
%     tmp=ifft(TMP);
%     
%     EEG.data=tmp';


    % 500 Hz being the even acceptable for 1024 sampling rates...
    
    Wp=120/(EEG.srate/2);
    Ws=200/(EEG.srate/2);
    [n,Wn]=buttord(Wp,Ws,3,40);
    [b,a] = butter(n,Wn);

    d=EEG.data';

    df=filtfilt(b,a,d);

    EEG.data=df';