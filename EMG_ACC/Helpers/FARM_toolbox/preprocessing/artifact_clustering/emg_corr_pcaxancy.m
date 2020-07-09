% execute this script only if emg_corr was already completed.
%
% if ~exist('curr_dir','var')
%     curr_dir=pwd;
% end
% cd(curr_dir);
% pwd;
%
% Problem: Arent we, with 6 PCA components and ANC option enabled,
% 'throwing the baby away with the bathwater' as far as artifact removal
% (to detect myoclonus) is concerned?
%
% create an 'expand' option. of this is activated, a lot of different EMG's
% will be produced in different sub-folders. Each sub-folder will have a
% different permutation of corrective properties, along two dimensions.
% the first dimension is the # of PCA components used. We think 2-4-6-8.
% the second dimension is dichotomous and is whether or not Adaptive Noise
% Cancellation was used on the data to be corrected.
% naming convention:
%
% emg_pca2_anc0
% emg_pca2_anc1
% emg_pca3_anc0
% emg_pca3_anc1
% emg_pca4_anc0
% emg_pca4_anc1
% emg_pca6_anc0
% emg_pca6_anc1
% emg_pca8_anc0
% emg_pca8_anc1
% emg_pca10_anc0
% emg_pca10_anc1
%
% for each option, the corresponding parameter in the init.m file is
% changed, so that the o struct has different control values for performing
% pca or amc.
%
% basically we want to see what the effects are of these (extra) processing
% steps on the indidence of 'myoclonus' in the EMG; compared with video.
%
% this needs to be run in the emg/ directory (!). 


% anc=[0 1];
pcaList=[4 5];

for pcaNum=1:numel(pcaList);


    if ~exist('emg_added_slicetriggers_revised.mat','file')||~exist('state_after_clustering.mat','file')
        disp('you need to run emg_corr again!');
    else
        outdir = ['../emg_pca' num2str(pcaList(pcaNum)) 'anc0/'];
        if ~exist(outdir,'dir');mkdir(outdir);end
        
        if exist([outdir 'emg_corrected.mat'],'file')
            disp('you already seem to have correctedd this trace');
        else
        
            load state_after_clustering.mat

            
            % do the complete analysis in d sl o m-space.
            % set the # of pca components to remove:
            o.pca.usr_max_components=pcaList(pcaNum);

            % do pca analysis.
            [d sl m]=do_pca(d,sl,o,m);

            % filters d.clean and keeps > 50 Hz.
            d=filter_high(d,o);

            d=do_anc(d,o,m,sl);

            d=filter_low(d,o);

            disp('PCA analysis is done.');
            
            
            
            
            
            

            %
            % Export EEG without ANC.
            %
            % prepare outout in emg_
            disp('exporting model without anc...')

            load emg_added_slicetriggers_revised.mat
            EEG.data=d.clean';
            o.anc=0;
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
            catch
                disp('cannot find model triggers...');
            end
            save([outdir 'emg_corrected.mat'],'EEG');
            % copy, if they exist, also the other files needed for the
            % burst_detector_gui.

            files={'markers_block.mat','marker_block.mat','bad_signal.mat','report_myo1.mat','report_myo1.m'};
            for f_i=1:numel(files)
                if exist(files{f_i},'file')
                    disp(['copying file: ' files{f_i}]);
                    copyfile(files{f_i},[outdir files{f_i}]);
                end
            end
            
        end
            
            
        
        % do BDG on it, too, to detect bursts*calculate mode...
        if exist([outdir 'bursts.mat'],'file')
            disp('you also seem to have completed all the preprocessing steps in the BDG.');
            disp(['outdir = ' outdir]);
        else
            curdir=pwd;cd(outdir);automatic_BDG_runner;cd(curdir);
        end






        %
        % doing now, WITH ANC...
        %
        % prepare outout in emg_
        % d is is essence now ready.
        disp('exporting model WITH anc...');
        outdir = ['../emg_pca' num2str(pcaList(pcaNum)) 'anc1/'];
        if ~exist(outdir,'dir');mkdir(outdir);end
        
        if exist([outdir 'emg_corrected.mat'],'file')
            disp('you already seem to have correctedd this trace');
        else
            

            load emg_added_slicetriggers_revised.mat
            EEG.data=d.anc';
            o.anc=1;
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
            catch
                disp('cannot find model triggers...');
            end
            save([outdir 'emg_corrected.mat'],'EEG');
            files={'markers_block.mat','marker_block.mat','bad_signal.mat','report_myo1.mat','report_myo1.m'};
            for f_i=1:numel(files)
                if exist(files{f_i},'file')
                    disp(['copying file: ' files{f_i}]);
                    copyfile(files{f_i},[outdir files{f_i}]);
                end
            end
            
        end
        
        
        % do BDG...
        if exist([outdir 'bursts.mat'],'file')
            disp('you also seem to have completed all the preprocessing steps in the BDG.');
            disp(['outdir = ' outdir]);
        else
            curdir=pwd;cd(outdir);automatic_BDG_runner;cd(curdir);
        end
        curdir=pwd;cd(outdir);automatic_BDG_runner;cd(curdir);
        clear d sl o m EEG;
        
    end
end

        
        
