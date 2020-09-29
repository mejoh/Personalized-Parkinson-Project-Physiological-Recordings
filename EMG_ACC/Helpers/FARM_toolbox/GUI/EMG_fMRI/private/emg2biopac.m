% Matlab script to convert an EEGLab data set to a matlab file that can be imported into BioPac Acknowledge
% 2009-11-18, created by Paul F.C. Groot

[filename, pathname] =  uigetfile('*.mat','Select the EMG mat-file');
if filename~=0
    set = load(fullfile(pathname,filename));
%     for i=1:8
%         set.EEG.data(i, :) = abs(hilbert(set.EEG.data(i,:) ));
%     end

    data = double(set.EEG.data');
    isi = 1000.0/set.EEG.srate;
    isi_units = 'ms';
    labels = strvcat(set.EEG.chanlocs.labels);
    start_sample = 0;
    units = 'uV';
    for i=2:size(data,2)
        units = char(units, 'uV');
    end
    
    [dummy, name, ext] = fileparts(filename);
    saveas = fullfile(pathname, [name, '_biopac.mat']);
    [filename, pathname] =  uiputfile('*.mat','Select the EMG mat-file', saveas);
    if filename~=0
        saveas = fullfile(pathname, filename);
        save(saveas,'data','isi','isi_units','labels','start_sample','units','-v6')
    end
end

