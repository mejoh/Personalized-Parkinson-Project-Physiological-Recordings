function EEG=emg_filter_bandpass(EEG,freql,freqh)

    b=round(freql/EEG.srate*EEG.pnts);
    e=round(freqh/EEG.srate*EEG.pnts);
    
    tmp=EEG.data';
    
    TMP=fft(tmp);
    
    TMP([1:b e:end-e+2 end-b+2:end],:)=0;
    
    tmp=ifft(TMP);
    
    EEG.data=tmp';
    