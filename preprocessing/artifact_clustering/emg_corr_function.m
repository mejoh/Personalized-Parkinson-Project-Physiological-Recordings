%% from a script to a function.
% this is the same as calling the emg_corr, only it cleans up memory
% (hopefully) as well as allows for passing of override arguments in
% contrast to those arguments defined in init.m
%
% give overrides as a strings... the'll be evaluated later on.
%
% keep = 0 -- for removing all of the correction files
% 
% dest = destination directory for corrected EMG.
%

function out=emg_corr_function(keep,varargin)

    % keyboard;
    % initialize options, data and sl struct.
    % o = options.
    % d = data.
    % sl = data for generating slice-artifacts.
    % m = markers.
    
    
    if ~keep
        
        disp('deleting files!');
        
        if numel(dir('state_after*'))>0
            delete state_after*
        end
        if numel(dir('emg_added*'))>0
            delete emg_added*
        end
        if numel(dir('emg_corrected*'))>0
            delete emg_corrected*
        end
        if exist('slicetrigger_check','dir')
            rmdir slicetrigger_check s
        end
        
        fclose all;
        
    end
    
    

    if numel(varargin)==0
        disp('no overrides... proceding with normal parameters.');
    elseif numel(varargin)>0
        disp('overrides detected. know what you are doing!');
        disp('normal overrides are o.filter.hpf, or:');
        disp('o.pca.usr_max_components, or:');
        disp('o.anc');
    end

    tic

    % keyboard;
    % start eeglab!
    if isempty(findobj('Tag','EEGLAB'))
        eeglab
    end



    % if strcmpi(computer,'GLNX86')||strcmpi(computer,'GLNXA64')
    %     % maybe, if we add the path to the correct mex file, it'll work...
    %     disp('youre working on linux, so adding the mex paths...');
    %     disp(computer);
    %     addpath([regexprep(pwd,'(^.*)(Onderzoek.*)','$1') 'ICT/Software/mltoolboxes/emgfmri/mex/' computer]);
    % end



    % add slice-trigs.
    if ~exist('emg_added_slicetriggers.mat','file')

        if exist('emg.mat','file')
            load emg.mat
        else
            error(['there was no emg.mat file in this directory! : ' pwd]);
        end

        if EEG.nbchan>8
            EEG=emg_make_bipolar(EEG);
        end

        EEG=emg_add_names(EEG);
        maxvals=max(abs(EEG.data(1:4,:)),[],2);
        trigchannel = find(maxvals==max(maxvals)); % add slice-triggers.
        EEG=emg_add_slicetriggers(EEG,trigchannel); % heeft emg_mono_uncorr nodig!
        save('emg_added_slicetriggers.mat','EEG');

    else
        load('emg_added_slicetriggers.mat');
    end


    % consistency check.

    % keyboard;
    load(regexprep([pwd '/../parameters'],'\\','/'))
    ve=EEG.event(strcmp({EEG.event.type},'V'));
    Tr=mean(([ve(2:end).latency]-[ve(1:end-1).latency])/EEG.srate);
    if ~sum(abs(([ve(2:end).latency]-[ve(1:end-1).latency])/EEG.srate-parameters(1))>0.1)

        % reject (possibly!) extragenous data.
        % re-do muscle names from files.txt file.
        % samples that is 1 [s] before 1st V
        % smaples that is 1+Tr [s] after last V
        % estimate Tr.
        if ~exist('emg_added_slicetriggers_revised.mat','file')


            % load emg_added_slicetriggers.mat

            % save memory --
            omit_begin=ve(1).latency-3*EEG.srate;
            if omit_begin<2
                omit_begin=2;
            end

            omit_end=ve(end).latency+round((3+Tr)*EEG.srate);
            if omit_end>(size(EEG.data,2)-1)
                omit_end=size(EEG.data,2)-1;
            end

            EEG = eeg_eegrej( EEG, [1 omit_begin;omit_end size(EEG.data,2)]);

            % re-do the names!
            try
                ruwDir=regexprep(regexprep(pwd,'(.*\d{4}).*','$1'),'pp','ruw','once');
                muscles=read_channels_file(regexprep(regexprep([ruwDir '\channels.txt'],'\\','/'),'//','/'));
                for i=1:8
                    EEG.chanlocs(i).labels=muscles{i};
                end
            catch
                error(['check your channels.txt file!!!! ' lasterr]);
            end

            save('emg_added_slicetriggers_revised.mat','EEG');

        else

            load emg_added_slicetriggers_revised.mat

        end








        % if slicetiming is already done, don't repeat it.
        if exist('state_after_slicetiming.mat','file')
            disp('skipping the slice-timing (already done) !!');
            disp('to re-do, delete state_after_slicetiming.mat');

            % load the state, as if slicetiming has just been completed...
            load state_after_slicetiming.mat
        else

            % load emg_1106.mat
            [o d sl m]=init(EEG);

            if numel(varargin)>0
                for vai=1:numel(varargin)
                    disp('overriding');
                    eval(varargin{vai});
                    disp(varargin{vai});
                end
            end

            % debug & tryout of some parameters.
            % o.filter.hpf=30;
            % o.pca.usr_max_components=4;
            % o.anc=0;

            % high-pass filter.
            d=filter_lowfrequency(d,o);

            sl=pick_other_templates(sl,o);

            % calculate the needed adjustments.
            tmp=mean(abs(EEG.data(1:4,:)),2);
            trigchannel=find(tmp==max(tmp));
            disp('starting slicetiming, using third workflow (incl. phaseshifting)');
            [sl o]=do_new_slicetiming3(d,sl,o,m,trigchannel);
            save state_after_slicetiming.mat d sl m o
            close all;
        end



        % warning: may require large-ish memory.
        % if already done, don't repeat...
        if exist('state_after_volume_correction.mat','file')
            disp('skipping volume-correction (already done)');
            disp('to re-do, delete state_after_volume_correction.mat');

            load state_after_volume_correction.mat

        else
            disp('starting volume correction..');
            d=do_volume_correction(d,sl,o,m);
            save state_after_volume_correction.mat d sl m o
        end


        % then cluster the artifacts into most-resembling sub-groups.
        disp('starting clustering...');
        sl=do_clustering(d,sl,o,m); % makes helper_slice possible.
        save state_after_clustering.mat d sl m o


        % if strcmpi(option,'expand')



        % upsample (cluster&align), do pca, and downsample.
        disp(['starting pca, using ' num2str(o.pca.usr_max_components) ' PCA components...']);
        [d sl m]=do_pca(d,sl,o,m);




        % filters d.clean and keeps > 50 Hz.
        d=filter_high(d,o);

        
        disp('starting ANC analysis...');
        d=do_anc(d,o,m,sl);


        d=filter_low(d,o);
        
        
        save('state_after_pca.mat','d','sl','m','o');
        
        disp('correction procedure completed!');
        disp('but you still need to export it!');

        toc;
        t=toc;


    else
        % keyboard;
        error(['you should check your emg trace more carefully! -- dir = ' pwd]);
        out=0;
    end


    out=1;


end

