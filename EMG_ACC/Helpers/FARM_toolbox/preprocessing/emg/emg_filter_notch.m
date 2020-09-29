function EEG=emg_filter_notch(EEG,freql,freqh)

    b=round(freql/EEG.srate*EEG.pnts);
    e=round(freqh/EEG.srate*EEG.pnts);
    
    tmp=EEG.data';
    
    TMP=fft(tmp);
    
    TMP([b:e end-e+2:end-b+2],:)=0;
    
    tmp=ifft(TMP);
    
    EEG.data=tmp';