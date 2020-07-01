% deze functie haalt uit de .trc files, de EMG data van de acht spieren.
% in een .trc file zitten 64 kanalen opgeslagen, waarvan er 12 gebruikt
% zijn voor het EMG
%
% 4 zijn al bipilair en 8 monopolair, dus die moeten nog afgeleid worden,
% wat hieronder gebeurt met die regels van EEG.data etc...
%
% Usage:
% 
% function out=trctomatlab(file)
% what u get is an 'emg.set' file.
% 
%
% TRANSLATION:
%
% #   Bipolar     Ch      color       EMG.chanlocs    viewlabel   bipolar:
% 
% 10  ECG+-       32      Paars       Ppm             1           SAME
% 9   EMG1+-      31      Black       Kpm             2
% 11  EMG2+-      63      Blauw       Bpm             3
% 12  EMG3+-      64      Oranje      Opm             4
% 
% #   Monopolar   Ch      color       EMG.chanlocs    viewlabel   bipolar:
% 
% 2   CP1         24      Wit         Wp              5           5 Wpm
% 1   FC1         23                  Wm              6
% 
% 4   PO3         26      Groen       Gp              7           6 Gpm
% 3   CP2         25                  Gm              8
% 
% 6   FC6         28      Geel        Yp              9           7 Ypm
% 5   PO4         27                  Ym              10
% 
% 8   CP5         30      Rood        Rp              11          8 Rpm
% 7   FC5         29                  Rm              12
%
%
%[EEG] = trctomatlab(trcfile,'matfilenaamdiejewilthebben')
% 
%
%
% het volgende is van Rami Niazy in Oxford.
%
%       SETTINGS.filename :                 Name of file to be imported
%       SETTINGS.loadevents.state :         'yes' for loading event triggers
%                                           'no' for not
%       SETTINGS.loadevents.type :          'marker' for event triggers inserted 
%                                           on 'MKR channel
%                                           'eegchan' for triggers inserted on 
%                                           EEG channels
%                                           'none' or
%                                           'both'
%       SETTINGS.loadevents.dig_ch1:        number of name of eegchan marker channel 1
%       SETTINGS.loadevents.dig_ch1_label:  label to give events on eegchan marker channel 1
%       SETTINGS.loadevents.dig_ch2:        number of name of eegchan marker channel 2
%       SETTINGS.loadevents.dig_ch2_label:  label to give events on eegchan marker channel 2
%       SETTINGS.chan_adjust_status:        1 for adjusting amp of channels 0 for not
%       SETTINGS.chans                      channels to load, [ ] for all
%       (default)
%       SETTINGS.chan_adjust                channels to adjust


function out=trctomatlab(file)

% path add
% addpath g:/ICT/Software/mltoolboxes/eeglab5.03/
% start eeglab (if not already done !!!)


IN.filename                     = file;
IN.loadevents.state             = 'yes';
IN.loadevents.type              = 'marker';
% onderstaande alleen voor markers die niet op het marker channel liggen
% maar op een 'echt' (EMG, EEG, DC?) kanaal.
IN.loadevents.dig_ch1           = '';
IN.loadevents.dig_ch1_label     = '';
IN.loadevents.dig_ch2           = '';
IN.loadevents.dig_ch2_label     = '';
IN.chan_adjust_status           = 0;
IN.chans                        = '23:32 63 64';
IN.chan_adjust                  = [];

% EEG=eeg_emptyset();
% PARAM.filename='D:\project\paradigma\ruw\001\emgtrc\EEG_39.TRC'; PARAM.loadevents.state='yes'; PARAM.loadevents.type='marker'; PARAM.loadevents.dig_ch1=''; PARAM.loadevents.dig_ch1_label=''; PARAM.loadevents.dig_ch2=''; PARAM.loadevents.dig_ch2_label=''; PARAM.chan_adjust_status=0; PARAM.chan_adjust=''; PARAM.chans=''; [EEG,command]=pop_readtrc(PARAM);


[EEG COMMAND] =pop_readtrc(IN);

disp(['loaded data...']);


% #   Bipolar     Ch      color       EMG.chanlocs    viewlabel   bipolar:
% 
% 10  ECG+-       32      Paars       Ppm             1           SAME
% 9   EMG1+-      31      Black       Kpm             2
% 11  EMG2+-      63      Blauw       Bpm             3
% 12  EMG3+-      64      Oranje      Opm             4
% 
% #   Monopolar   Ch      color       EMG.chanlocs    viewlabel   bipolar:
% 
% 2   CP1         24      Wit         Wp              5           5 Wpm
% 1   FC1         23                  Wm              6
% 
% 4   PO3         26      Groen       Gp              7           6 Gpm
% 3   CP2         25                  Gm              8
% 
% 6   FC6         28      Geel        Yp              9           7 Ypm
% 5   PO4         27                  Ym              10
% 
% 8   CP5         30      Rood        Rp              11          8 Rpm
% 7   FC5         29                  Rm              12



% to make it just as it appears on the micromed screen
EEG.data=EEG.data([10 9 11 12 2 1 4 3 6 5 8 7],:);
EEG.data=EEG.data*-1;


EEG=emg_add_labels(EEG);

% pop_saveset(EEG,'emg.set');
save emg.mat EEG;

% numtmp=regexp(file,'[0-9]*','match');
% save(['emg_' numtmp{1} '.mat'],'EEG');

out='conversion completed';

% out=EEG;
% save(outfile,'EEG');

