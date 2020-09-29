%% en gooi dan wat EMG weg. hiermee haal je de stukjes EMG vlak voor de
% nieuwe trigger weg.

function EEGOUT = emg_clean_volumetriggers_oud(EEG)

    load parameters

    tmp2=find(strcmp({EEG.event(:).type},'V')==1);
    d=EEG.event(tmp2(2)).latency-EEG.event(tmp2(1)).latency;
    st=d/parameters(2);

    for i=tmp2

        b=EEG.event(i).latency-round(st*1.5);
        e=EEG.event(i).latency+round(st*0.5);
        EEG.data(:,b:e)=0;

    end

    EEGOUT=EEG;
