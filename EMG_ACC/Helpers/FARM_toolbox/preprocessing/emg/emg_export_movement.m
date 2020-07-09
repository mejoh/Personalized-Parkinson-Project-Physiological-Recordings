
function emg_export_movement(study,pp)

    load emg.mat

    EEG=emg_make_bipolar(EEG);
    EEG=emg_filter_bandpass(EEG,2,11);
    EEG=emg_add_names(EEG,study,pp);
    EEG=emg_add_modeltriggers(EEG);

    save mov.mat EEG
    
    
    
    
    



