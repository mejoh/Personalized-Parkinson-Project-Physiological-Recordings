% neat little script, to be run in /ruw/9999/trc/.
% it trctomatlab's all of the .TRC files.
% function that does all of the EMG preprocessing, and picks up where you
% left off.


function batch_emg_preprocessing(varargin)

    study=varargin{1};
    pp=varargin{2};
    taken=varargin(3:end);
    
    if ~ischar(taken{1});taken=taken{1};end
    
    
    eeglab
    
    
    cd([regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp]);
    disp('current directory is now:');
    disp(pwd);

    
    for i=1:numel(taken)
        
         cd([regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/' taken{i} '/emg']);
    

        
        
        
        name{1}='emg_added_slicetriggers.mat';
        if numel(ls(name{1}))==0
            load emg.mat
            EEG=emg_make_bipolar(EEG);
            EEG=emg_add_names(EEG);   
            trigchannel = 1;                            % add slice-triggers.
            EEG=emg_add_slicetriggers(EEG,trigchannel); % heeft emg_mono_uncorr nodig!
            save(name{1},'EEG');
            
        end
        
        
        name{end+1}='emg_removed_sliceartifacts.mat';
        if numel(ls(name{end}))==0&&numel(ls(name{end-1}))~=0
            if ~exist('EEG','var');load(name{end-1});elseif numel(EEG.data)==0;load(name{end-1});end

            EEG=emg_filter_highpass(EEG);
            EEG=emg_remove_sliceartifact(EEG);

            save(name{end},'EEG');
            
        end

        
        name{end+1}='emg_removed_volumeartifacts.mat';
        if numel(ls(name{end}))==0&&numel(ls(name{end-1}))~=0
            if ~exist('EEG','var');load(name{end-1});elseif numel(EEG.data)==0;load(name{end-1});end

            EEG=emg_remove_volumeartifact(EEG);

            save(name{end},'EEG');
            
        end
        
        name{end+1}='emg_frequency_filtered.mat';
        if numel(ls(name{end}))==0&&numel(ls(name{end-1}))~=0
            if ~exist('EEG','var');load(name{end-1});elseif numel(EEG.data)==0;load(name{end-1});end

            EEG=emg_remove_outsidemeasurementdata(EEG);
            EEG=emg_filter_artifact_frequencies(EEG,3.0901,4,2);

            save(name{end},'EEG');
            
        end
        

        name{end+1}='emg_corrected.mat';
        if numel(ls(name{end}))==0&&numel(ls(name{end-1}))~=0
            if ~exist('EEG','var');load(name{end-1});elseif numel(EEG.data)==0;load(name{end-1});end

            EEG=emg_add_modeltriggers(EEG);
            markers=EEG.event;
            save('markers.mat','markers');
            EEG=emg_remove_slicetriggers(EEG);
            EEG=emg_filter_lowpass(EEG);
            EEG=emg_filter_highpass(EEG);
            EEG.data=abs(EEG.data);
            
            save(name{end},'EEG');
            emg_brainvision_export(EEG,[taken{i} '_freqfilter.mat']);
        
        end
        
        name{end+1}='emg_corrected_with_wavelets.mat';
        if numel(ls(name{end}))==0&&numel(ls(name{end-1}))~=0
            if ~exist('EEG','var');load(name{end-1});elseif numel(EEG.data)==0;load(name{end-1});end

            EEG=emg_filter_wavelet(EEG);
            save(name{end},'EEG');
            emg_brainvision_export(EEG,[taken{i} '_wavelets.mat']);
            
            
        end
        
        
        name{end+1}='emg_corrected_oldway.mat';
        if numel(ls(name{end}))==0&&numel(ls(name{end-4}))~=0
            load(name{end-4});

            EEG=emg_remove_outsidemeasurementdata(EEG);
            EEG=emg_filter_lowpass(EEG);
            EEG=emg_filter_highpass(EEG);
            EEG=emg_remove_slicetriggers(EEG);
            EEG=emg_add_modeltriggers(EEG);
            EEG.data=abs(EEG.data);

            save(name{end},'EEG');
            emg_brainvision_export(EEG,[taken{i} '_oldway.mat']);
            
        end
        
        
        
        
        %% de pre-scan dingetjes pre-processen...
        if numel(ls('emg_nofield_2.mat'))==0&&numel(ls('emg_nofield.mat'))~=0
            load emg_nofield
            if EEG.nbchan>8
                EEG=emg_make_bipolar(EEG);
                EEG=emg_add_names(EEG,study,pp);
                EEG=emg_filter_notch(EEG,49.5,50.5);
                EEG=emg_filter_highpass(EEG);
                save emg_nofield2 EEG
                emg_brainvision_export(EEG,[taken{i} '_nofield2.mat']);
            end
        end
        
        if numel(ls('emg_prescan_2.mat'))==0&&numel(ls('emg_prescan.mat'))~=0
            load emg_prescan
            if EEG.nbchan>8
                EEG=emg_make_bipolar(EEG);
                EEG=emg_add_names(EEG,study,pp);
                EEG=emg_filter_notch(EEG,49.5,50.5);
                EEG=emg_filter_highpass(EEG);
                save emg_prescan2 EEG
                emg_brainvision_export(EEG,[taken{i} '_prescan2.mat']);
            end
        end
        
        

    
        
        
    end
    

