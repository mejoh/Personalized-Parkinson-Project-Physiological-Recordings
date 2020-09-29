function EEG=emg_filter_highpass(EEG)

    % see help on matlab how to make butterworth filters.
    % why not chebyshev or elliptic filters???
    % --> probably better but not tried yet.

    
    
    % load emg_2.mat
    for i=1:EEG.nbchan
        EEG.data(i,:)=helper_filter(EEG.data(i,:),30,EEG.srate,'high');
    end



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