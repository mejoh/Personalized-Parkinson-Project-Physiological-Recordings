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

    for i=1:EEG.nbchan
        EEG.data(i,:)=helper_filter(EEG.data(i,:),250,EEG.srate,'low');
    end