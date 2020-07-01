function EEGOUT=emg_combine_traces(file1,file2)

    % plak data van EEG2 soort-van-interleaved achter EEG1. Gebruik alleen
    % markers van EEG1. de data moet even groot zijn.
    

    
    load(file2);
    EEG2=EEG;
    
    load(file1);


    EEGOUT=EEG;
    EEGOUT.nbchan=2*EEG.nbchan;


    for i=1:size(EEG.data,1)
        
        EEGOUT.data(2*i-1,:)=EEG.data(i,:);
        EEGOUT.data(2*i,:)  =EEG2.data(i,:);
    

        EEGOUT.chanlocs(2*i-1).labels   =EEG.chanlocs(i).labels;
        EEGOUT.chanlocs(2*i).labels     =['b_' EEG2.chanlocs(i).labels];
    end
  
    