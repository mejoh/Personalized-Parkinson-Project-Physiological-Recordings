function out=emg_brainvision_export(EEG,file)
out=1;

    %#%#% Export BrainVision
    %
    % stop in map /pp/1115/BVA_Export/<NAMES>.vhdr, etc

    % keyboard;
    % en dan hier voorbereiden EMG trace voor export...
    wdir=pwd;
    expdir=[wdir '/BVA_Export/'];
    if ~isdir(expdir);mkdir(expdir);end
    
    
    file=regexprep(file,'(.*)\.(.*)','$1');
       
    disp(['written... ' file]);
    pop_writebva(EEG,[file]);
    movefile([file '.dat'],expdir);
    movefile([file '.vmrk'],expdir);
    movefile([file '.vhdr'],expdir);

    
    