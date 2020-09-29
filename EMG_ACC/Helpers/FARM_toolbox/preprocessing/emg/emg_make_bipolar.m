function EEGOUT=emg_make_bipolar(EEG)
    if EEG.nbchan<12
        error('Expected 12 channels in emg_make_bipolar');
    else
        if EEG.nbchan>12
            warning('EMG_fMRI:WrongChannels','Expected 12 channels in emg_make_bipolar, found %d',EEG.nbchan);
        end
        
        % dit mag, als t goed is, wel.
        EEG.data(5,:)=EEG.data(5,:)-EEG.data(6,:);
        EEG.data(6,:)=EEG.data(7,:)-EEG.data(8,:);
        EEG.data(7,:)=EEG.data(9,:)-EEG.data(10,:);
        EEG.data(8,:)=EEG.data(11,:)-EEG.data(12,:);

        % kanalen verwijderen...
        EEG.data(9:12,:)=[];
        EEG.nbchan=8;

        % also reflect the subtraction in the channel names
        EEG.chanlocs(5).labels=[EEG.chanlocs(5).labels '-' EEG.chanlocs(6).labels];     %'Wpm';
        EEG.chanlocs(6).labels=[EEG.chanlocs(7).labels '-' EEG.chanlocs(8).labels];     %'Gpm';
        EEG.chanlocs(7).labels=[EEG.chanlocs(9).labels '-' EEG.chanlocs(10).labels];    %'Ypm';
        EEG.chanlocs(8).labels=[EEG.chanlocs(11).labels '-' EEG.chanlocs(12).labels];   %'Rpm';
        % replace with shorter versions for known cases
        if strcmpi(EEG.chanlocs(5).labels,'Wp-Wm'), EEG.chanlocs(5).labels='Wpm'; end;
        if strcmpi(EEG.chanlocs(6).labels,'Gp-Gm'), EEG.chanlocs(6).labels='Gpm'; end;
        if strcmpi(EEG.chanlocs(7).labels,'Yp-Ym'), EEG.chanlocs(7).labels='Ypm'; end;
        if strcmpi(EEG.chanlocs(8).labels,'Rp-Rm'), EEG.chanlocs(8).labels='Rpm'; end;
        EEG.chanlocs(9:12)=[];

        EEGOUT=EEG;
    end