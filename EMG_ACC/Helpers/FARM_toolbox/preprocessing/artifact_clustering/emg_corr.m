% initialize options, data and sl struct.
% o = options.
% d = data.
% sl = data for generating slice-artifacts.
% m = markers.

%% MDx - TMP conf
%--------------------------------------------------------------------------

% --- Directories --- %

conf.dir.root           =   '/home/action/micdir/data/EMG/Cohort 2 - relaunched/RAW';
conf.dir.save           =   '/home/action/micdir/data/EMG/Cohort 2 - relaunched/FARM/';

% --- Preprocessing --- %

conf.preproc.mkbipol    =   'no';       % If yes, then it will make bipolar out of monopolar channels

% --- Marker info --- %

conf.file.scanpar       =   [1.82;35;300]; % TR / nSlices / nScans 
conf.file.etype         =   'F  1';        % Scan marker (EEG.event.type)

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

tic

if ~exist(conf.dir.save,'dir'); mkdir(conf.dir.save); end

cd(conf.dir.save);

% 2009-11-16: paul added support for a simple progress bar
%             because this script is not a function you can simply
%             define a boolean show_waitbar variable beforehand to switch it on or off.
if ~exist('show_waitbar','var')
    show_waitbar = false;
end

oEve    =   EEG.event;

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nChans  =   size(EEG.data,1);

%--------------------------------------------------------------------------

%%  add slice-triggers
%--------------------------------------------------------------------------

if show_waitbar
    hWaitBar = waitbar(0,'emg\_corr: adding slice triggers');
end
if ~exist('emg_added_slicetriggers.mat','file')

    if strcmp(conf.preproc.mkbipol,'yes')
        EEG=emg_make_bipolar(EEG);
    end

%     EEG=emg_add_names(EEG);
    maxvals=max(abs(EEG.data(1:nChans,:)),[],2);
    trigchannel = find(maxvals==max(maxvals));       % add slice-triggers.
    EEG=emg_add_slicetriggers(EEG,trigchannel,conf);

    save('emg_added_slicetriggers.mat','EEG');

else
    load('emg_added_slicetriggers.mat');
end

%--------------------------------------------------------------------------

%% Rest of analysis
%--------------------------------------------------------------------------

ve=EEG.event(strcmp({EEG.event.type},'V'));
Tr=mean(([ve(2:end).latency]-[ve(1:end-1).latency])/EEG.srate);
if ~sum(abs(([ve(2:end).latency]-[ve(1:end-1).latency])/EEG.srate-conf.file.scanpar(1))>0.1)


    % reject (possibly!) extragenous data.
    % re-do muscle names from files.txt file.
    % samples that is 1 [s] before 1st V
    % smaples that is 1+Tr [s] after last V
    % estimate Tr.
    if show_waitbar
        waitbar(0.1, hWaitBar, 'emg\_corr: reject extragenous data');
    end;
    if ~exist('emg_added_slicetriggers_revised.mat','file')

        % --- Cut out part of the end and part of the beginning --- %
        
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
%         try
%             ruwDir=regexprep(regexprep(pwd,'(.*\d{4}).*','$1'),'pp','ruw','once');
%             muscles=read_channels_file(regexprep(regexprep([ruwDir '\channels.txt'],'\\','/'),'//','/'));
%             for i=1:8
%                 EEG.chanlocs(i).labels=muscles{i};
%             end
%         catch
%             error(['check your channels.txt file!!!! ' lasterr]);
%         end

        save('emg_added_slicetriggers_revised.mat','EEG');

    else

        load emg_added_slicetriggers_revised.mat

    end

    % --- Additional Slice timing --- %
   
    if show_waitbar
        waitbar(0.2, hWaitBar, 'emg\_corr: slice-timing');
    end;
    if exist('state_after_slicetiming.mat','file')
        disp('skipping the slice-timing (already done) !!');
        disp('to re-do, delete state_after_slicetiming.mat');

        load state_after_slicetiming.mat
    else
        
        % == Convert to double == %
        EEG.data    =   double(EEG.data);
        % ======================= %
        
        [o d sl m]=init(EEG,conf);
        
        
        % --- High-pass filter --- %
        
%         d=filter_lowfrequency(d,o);% ZET DIT UIT OM HPfilt UIT TE ZETTEN!!!
        sl=pick_other_templates(sl,o);
        
        % calculate the needed adjustments.
        tmp=mean(abs(EEG.data(nChans,:)),2);
        trigchannel=find(tmp==max(tmp));
        disp('starting slicetiming, using third workflow (incl. phaseshifting)');
        [sl o]=do_new_slicetiming3(d,sl,o,m,trigchannel);
        save state_after_slicetiming.mat d sl m o
        if show_waitbar
        if hWaitBar ~= gcf
            close; % do not use all because this will close the wait bar
        end
        end
    end

    if show_waitbar
        waitbar(0.3, hWaitBar, 'emg\_corr: volume correction');
    end;
    if exist('state_after_volume_correction.mat','file')
        disp('skipping volume-correction (already done)');
        disp('to re-do, delete state_after_volume_correction.mat');
        
        load state_after_volume_correction.mat
        
    else
        disp('starting volume correction..');
        d=do_volume_correction(d,sl,o,m);
        save state_after_volume_correction.mat d sl m o
    end

    % --- Cluster the artifacts into most-resembling sub-groups --- %
    
    if show_waitbar
        waitbar(0.4, hWaitBar, 'emg\_corr: clustering');
    end;
    if ~exist('state_after_clustering.mat','file')
        disp('starting clustering...');
        sl=do_clustering(d,sl,o,m);
        save state_after_clustering.mat d sl m o
    else
        disp('skipping volume-correction (already done)');
        disp('to re-do, delete state_after_volume_correction.mat');
        load('state_after_clustering.mat')
    end

    % --- Upsample (cluster&align), do pca, and downsample. --- %
    
    if show_waitbar
        waitbar(0.6, hWaitBar, 'emg\_corr: pca');
    end;
    disp(['starting pca, using ' num2str(o.pca.usr_max_components) ' PCA components...']);
    [d sl m]=do_pca(d,sl,o,m);

    save(['state_after_pca.mat'],'d','sl','m','o');


    d=filter_high(d,o);% ZET DIT UIT OM HPfilt UIT TE ZETTEN!!!
    
    if show_waitbar
        waitbar(0.75, hWaitBar, 'emg\_corr: ANC analysis');
    end;
    
    % 2010-05-12: seems that anc field was added later, but is not defined under all circumstances 
    if ~isfield(o,'anc')
        o.anc = 1;
    end
    if o.anc==1
        disp('starting ANC analysis...');
        d=do_anc(d,o,m,sl);
    end

    d=filter_low(d,o);

    load emg_added_slicetriggers_revised.mat
    EEG.data=d.clean';
    EEG.emgcorroptions=o;
    
    if show_waitbar
        waitbar(0.9, hWaitBar, 'emg\_corr: updating events');
    end;
    
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
    
    % --- Remove outside measurments and slice triggers --- %
    
    EEG=emg_remove_outsidemeasurementdata(EEG);
    EEG=emg_remove_slicetriggers(EEG);
    try
        EEG=emg_add_modeltriggers(EEG);
    catch;end
    try
        add_events;
    end

    % --- DONE, save --- %
    
    save emg_corrected.mat EEG

    disp('correction procedure completed!');
    if show_waitbar
        waitbar(1, hWaitBar, 'emg\_corr: complete');
    end

    
    t=toc;
    fprintf('\n%s\n',['Mission accomplished after ' num2str(t/60) ' minutes!!'])

else
    error(['you should check your emg trace more carefully! -- dir = ' pwd]);
end


if show_waitbar
    close(hWaitBar);
end;
