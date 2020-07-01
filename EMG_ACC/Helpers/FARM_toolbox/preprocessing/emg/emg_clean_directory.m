function emg_clean_directory(study,pp,task)


    cd([regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/']);
    disp(['current directory is now:' pwd]);
    
    disp('cleaning emg directory...');
    if exist('emg','dir')
        if exist('emg/emg.mat','file')
            load('emg/emg.mat');
        end
        
        rmdir('emg','s');
        mkdir('emg');
        save('emg/emg.mat','EEG');
    end
    