function EEGOUT=emg_add_labels(EEG)

    % netjes een labeltje verzorgen:
    labels={'Ppm','Kpm','Bpm','Opm','Wp','Wm','Gp','Gm','Yp','Ym','Rp','Rm'};
    for i=1:numel(labels)

        EEG.chanlocs(i).labels  = labels{i};
    %     EEG.chanlocs(i).X       = i*10;
    %     EEG.chanlocs(i).Y       = 0;
    %     EEG.chanlocs(i).Z       = 0;
    %     EEG.chanlocs(i).type    = 'EMG';
    end


EEGOUT=EEG;