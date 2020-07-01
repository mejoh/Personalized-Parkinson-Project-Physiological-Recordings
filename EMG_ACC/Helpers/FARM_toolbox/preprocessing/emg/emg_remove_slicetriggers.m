function EEGOUT=emg_remove_slicetriggers(EEG)


    s_trigs=find(strcmp({EEG.event(:).type},'s'));
    V_trigs=[];
    % V_trigs=find(strcmp({EEG.event(:).type},'V'));

    if numel(s_trigs)==0
        s_trigs=find(strcmp({EEG.event(:).type},'sliceTrigger'));
    end
    
    EEG.event([s_trigs V_trigs])=[];

    EEGOUT=EEG;
    
    