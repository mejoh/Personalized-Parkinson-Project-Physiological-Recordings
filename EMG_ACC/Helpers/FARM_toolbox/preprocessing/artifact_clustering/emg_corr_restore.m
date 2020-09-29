
% first... copy our own emg (which has been performed with anc), to
% folder: emg_anc.

R=input(sprintf('\n\nHerstellen PCA analyse... Weet je het zeker? (J/N) '),'s');
if strcmpi(R,'n')
    disp('afbreken...');
elseif strcmpi(R,'j')
    
    
    test=pwd;
    if ~strcmp(test(end-2:end),'emg')
        disp('dit script moet worden gedraait in de directory "emg"!!');
        disp(' dus.... niet hier!!!');
        disp('  probeer: 1xxx/motor_tappen/emg');
        disp('   afgebroken...');
    else
    
        
        R=input(sprintf('\n\nWil je de huidige emg_corrected.mat in emg_new stoppen? (J/N) '),'s');
        
        if strcmpi(R,'j')
            
            % IF there are also .mat files (block_markers.mat, report_myo1.mat,
            % bad_signal.mat), copy those too.
            disp('ik maak een nieuwe folder: emg_new');
            mkdir ../emg_new
            
            disp('kopieer bestanden: emg_corrected + BDG bestanden...');
            if exist('emg_corrected.mat','file')
                copyfile emg_corrected.mat ../emg_new/.
            end
            if exist('markers_block.mat','file')
                copyfile markers_block.mat ../emg_new/.
            end
            if exist('bad_signal.mat','file')
                copyfile bad_signal.mat ../emg_new/.
            end
            if exist('report_myo1.mat','file')
                copyfile report_myo1.mat ../emg_new/.
            end
            
        else
            disp('ok, alleen maar herstellen oude emg... niet kopieren');
        end
        
        
        
        
        
        
        
        
        % second... load the state of the correction just after PCA, and prepare an
        % EEG data structure.
        disp('laad originele, met PCA gecorrigeerde, EMG');
        clear EEG;
        load state_after_pca.mat
        
        if exist('emg_added_slicetriggers_revised.mat','file')
            load emg_added_slicetriggers_revised.mat
        elseif exist('emg_added_slicetriggers_revised.mat','file')
            load emg_added_slicetriggers.mat
        end
        
        d=filter_high(d,o);
        d=filter_low(d,o);
        
        EEG.data=d.clean';
        EEG.emgcorroptions=o;
        
        
        
        % do_pca also returns, if you ask for it, the samples at where segments
        % start and end! -- see if there's bursts there too.
        for sc=1:numel(m.beginsegmarker)
            EEG.event(end+1).type='b_seg';
            EEG.event(end).latency=m.beginsegmarker(sc);
            EEG.event(end).duration=1;
            EEG.event(end+1).type='e_seg';
            EEG.event(end).latency=m.endsegmarker(sc);
            EEG.event(end).duration=1;
        end
        
        
        EEG=emg_remove_outsidemeasurementdata(EEG);
        EEG=emg_remove_slicetriggers(EEG);
        try
            EEG=emg_add_modeltriggers(EEG);
        catch;end
        try
            add_events;
        end
        
        
        
        % third... replace emg_corrected.
        disp('bezig vervangen van emg_corrected.mat...');
        save emg_corrected.mat EEG
        disp('emg_corrected.mat is vervangen...');
        
        str=['Het EMG wordt nu op volgende manier gecorrigeerd:\n'...
            '1) Average Artifact Removal\n'...
            '2) PCA Removal Residuals (noodzakelijk)\n'...
            '3) Ruis Removal met ANC (optioneel)\n'...
            '###\n'...
            'In de folder \''emg\'' is nu het EMG met alleen 1 en 2.\n'...
            'In de folder \''emg_new\'' is nu het EMG met 1, 2 EN 3...\n'...
            'Als je hebt gekozen om te backuppen\n'];
        
        disp(sprintf(str));
    end

end
