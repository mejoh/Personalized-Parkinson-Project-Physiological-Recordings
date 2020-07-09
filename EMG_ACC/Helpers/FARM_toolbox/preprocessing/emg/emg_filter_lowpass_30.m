function EEG=emg_filter_lowpass_30(EEG)


    wp=30/EEG.srate*2;
    ws=60/EEG.srate*2;
    Rp=3;
    Rs=40;
    [n,Wn]=buttord(wp,ws,Rp,Rs);
    [b a]=butter(n,Wn,'low');

    d=EEG.data';
    df=filtfilt(b,a,d);
    EEG.data=df';


