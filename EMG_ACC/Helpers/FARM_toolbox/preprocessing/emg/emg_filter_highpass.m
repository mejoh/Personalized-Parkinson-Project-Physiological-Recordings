function EEG=emg_filter_highpass(EEG)

    % see help on matlab how to make butterworth filters.
    % why not chebyshev or elliptic filters???
    % --> probably better but not tried yet.

    Wp=80/(EEG.srate/2);
    Ws=40/(EEG.srate/2);
    [n,Wn]=buttord(Wp,Ws,3,40);
    [b a]=butter(n,Wn,'high');
    
    % load emg_2.mat
    d=EEG.data';
    df=filtfilt(b,a,d);
    EEG.data=df';


%     b=round(freq/EEG.srate*EEG.pnts);
%     
%     tmp=EEG.data';
%     
%     TMP=fft(tmp);
%     
%     TMP([1:b end-b+2:end],:)=0;
%     
%     tmp=ifft(TMP);
%     
%     EEG.data=tmp';