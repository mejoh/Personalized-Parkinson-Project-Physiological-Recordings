% neat little script, to be run in /ruw/9999/trc/.
% it trctomatlab's all of the .TRC files.
% function that does all of the EMG preprocessing, and picks up where you
% left off.


function batch_emg_preprocessing(varargin)

    study=varargin{1};
    pp=varargin{2};
    taken=varargin(3:end);
    name={};
    clear EEG;
    
    if ~ischar(taken{1});taken=taken{1};end
    
    
    eeglab
    
    
    cd([regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Lopend_onderzoek/Onderzoek/fMRI/' study '/pp/' pp]);%cd([regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp]);
    disp('current directory is now:');
    disp(pwd);

    
    for i=1:numel(taken)
        
        cd([regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Lopend_onderzoek/Onderzoek/fMRI/' study '/pp/' pp '/' taken{i} '/emg']);% cd([regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/' taken{i} '/emg']);

         tic

        load emg.mat
        
        c=0;c2=0;
        c=sum(abs(diff(diff([EEG.event(find(strcmp({EEG.event(:).type},'65535'))).latency])))>2);
        c2=sum(abs(diff(diff([EEG.event(find(strcmp({EEG.event(:).type},'65535'))).latency])))>2);
        if c
            warning(sprintf('warning: Volume Triggers may not be entirely in place'));
        elseif c2
            warning(sprintf('warning: Volume Triggers may not be entirely in place'));
        else
            
            EEG=emg_make_bipolar(EEG);
            EEG=emg_add_names(EEG);   
            trigchannel = 1;                            % add slice-triggers.
            EEG=emg_add_slicetriggers(EEG,trigchannel); % heeft emg_mono_uncorr nodig!

            save emg_added_slicetriggers.mat EEG
            
            [o d sl m]=init(EEG);

            % high-pass filter.
            d=filter_lowfrequency(d,o);

            sl=pick_other_templates(sl,o);

            % calculate the needed adjustments.
            [sl o]=do_new_slicetiming(d,sl,o,m);



            % warning: may require large-ish memory.
            d=do_volume_correction(d,sl,o,m);
            save state_after_volume_correction.mat d sl m o


            % then cluster the artifacts into most-resembling sub-groups.
            sl=do_clustering(d,sl,o,m); % makes helper_slice possible.
            save state_after_clustering.mat d sl m o



            % upsample (cluster&align), do pca, and downsample.
            [d sl]=do_pca(d,sl,o);
            save state_after_pca.mat d sl m o

            % filters d.clean and keeps > 50 Hz.
            d=filter_high(d,o);
            d=do_anc(d,o,m);
            d=filter_low(d,o);


            EEG=emg_add_modeltriggers(EEG);
            EEG=emg_remove_slicetriggers(EEG);

            EEG.data=d.clean';
            save emg_corrected_pca EEG

            EEG.data=d.anc';
            save emg_corrected_pcaanc EEG
            
            load emg_corrected_pca
            EEG=emg_remove_outsidemeasurementdata(EEG);
            save emg_corrected_pca EEG
            
            
            
            load emg_corrected_pcaanc
            EEG=emg_remove_outsidemeasurementdata(EEG);
            save emg_corrected_pcaanc EEG


            emg_brainvision_export(EEG,[taken{i} '_pcaanc']);
        end
        
        
        seconds=toc;
        disp(sprintf('this operation lasted %.2d minutes and %.2d seconds',round(seconds/60),round(rem(seconds,60))));
        
        
    end
    

