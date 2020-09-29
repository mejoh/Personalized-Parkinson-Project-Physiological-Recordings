% initialize options, data and sl struct.
% o = options.
% d = data.
% sl = data for generating slice-artifacts.
% m = markers.


% if ~exist('curr_dir','var')
%     curr_dir=pwd;
% end
% cd(curr_dir);
% pwd;

tic

% keyboard;



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




    % load emg_1106.mat
    [o d sl m]=init(EEG);

    % high-pass filter.
    d=filter_lowfrequency(d,o);

    sl=pick_other_templates(sl,o);

    % calculate the needed adjustments.
    tmp=mean(abs(EEG.data(1:4,:)),2);
    trigchannel=find(tmp==max(tmp));
    [sl o]=do_new_slicetiming3(d,sl,o,m,trigchannel);
    save state_after_slicetiming.mat d sl m o
    close all;


    % warning: may require large-ish memory.
    d=do_volume_correction(d,sl,o,m);
    save state_after_volume_correction.mat d sl m o


    % then cluster the artifacts into most-resembling sub-groups.
    sl=do_clustering(d,sl,o,m); % makes helper_slice possible.
    save state_after_clustering.mat d sl m o


    % upsample (cluster&align), do pca, and downsample.
    [d sl m]=do_pca(d,sl,o,m);

    save(['state_after_pca.mat'],'d','sl','m','o');


    % filters d.clean and keeps > 50 Hz.
    d=filter_high(d,o);

    if o.anc==1;
        d=do_anc(d,o,m,sl);
    end

    d=filter_low(d,o);

    load emg_added_slicetriggers_revised.mat
    EEG.data=d.anc';
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

    save emg_corrected.mat EEG

    disp('correction procedure completed!');

    toc;
    t=toc;


else
    % keyboard;
    error(['you should check your emg trace more carefully! -- dir = ' pwd]);
end


