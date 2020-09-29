function varargout = preprocessing_emg_personalised(varargin)
% PREPROCESSING_EMG_PERSONALISED M-file for preprocessing_emg_personalised.fig
%      PREPROCESSING_EMG_PERSONALISED, by itself, creates a new PREPROCESSING_EMG_PERSONALISED or raises the existing
%      singleton*.
%
%      H = PREPROCESSING_EMG_PERSONALISED returns the handle to a new PREPROCESSING_EMG_PERSONALISED or the handle to
%      the existing singleton*.
%
%      PREPROCESSING_EMG_PERSONALISED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCESSING_EMG_PERSONALISED.M with the given input arguments.
%
%      PREPROCESSING_EMG_PERSONALISED('Property','Value',...) creates a new PREPROCESSING_EMG_PERSONALISED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preprocessing_emg_personalised_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preprocessing_emg_personalised_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help preprocessing_emg_personalised

% Last Modified by GUIDE v2.5 02-Nov-2009 15:42:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @preprocessing_emg_personalised_OpeningFcn, ...
                   'gui_OutputFcn',  @preprocessing_emg_personalised_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before preprocessing_emg_personalised is made visible.
function preprocessing_emg_personalised_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % Choose default command line output for preprocessing_emg_personalised
    handles.output = hObject;

    set(handles.method,'SelectionChangeFcn',@method_SelectionChangeFcn);

    % unflag step done so far
    EMG_fMRI_steps_emgpre = zeros(7,1);

    if isempty(EEG)
        error('EEG data must be loaded into global workspace before opening preprocessing_emg_personalised.fig');
    end
    
    % note: check if EEG is already bipolar (this is normally done immediately after loading the raw emg in the calling fn)
    if EEG.nbchan>8
        disp('Warning: EMG is not bipolar: fixing it...');
        EEG=emg_make_bipolar(EEG); % << during choose channel !!!!!!!!!!!!! TODO
    end

    % load last used or default profile
    try
        profile = EMG_fMRI_profile;
    catch
        profile = [];
    end
    if isempty(profile)
        profile = LoadProfile();
        EMG_fMRI_profile = profile;
    end
    % and update GUI
    set(handles.profile_name, 'String', profile{1} );

    set(handles.txt_title,'String', sprintf('Preprocessing EMG: %s, %s, %s',EMG_fMRI_study,EMG_fMRI_patient,EMG_fMRI_protoname_select_muscle));
%    set(handles.save_data,'Enable','off');
%    set(handles.msg_channel, 'String', num2str(profile{2}));
    % Update handles structure
    guidata(hObject, handles);
    
    updateMyGUI(handles);
    
  
    
    % UIWAIT makes preprocessing_emg_personalised wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = preprocessing_emg_personalised_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;


function flagStepDone(nr)
    emg_fmri_globals; % make sure this is the first call in the fn
	EMG_fMRI_steps_emgpre(nr) = 1;
    
% function enableSaveButton(handles)
%     if nargin>=2
%         set(handles.save_data,'Enable','on');
%     end

function updateMyGUI(handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % update a few labels
    set(handles.profile_name, 'String', EMG_fMRI_profile{1} );
    set(handles.msg_channel, 'String', num2str(EMG_fMRI_profile{2}));
    
    % check if a channel is selected
    if ~isempty(EMG_fMRI_profile{2})
        on_or_off = 'on';
    else
        on_or_off = 'off';
    end
    set([   handles.addslicetriggers ...
            handles.sliceartifact ...
            handles.volumeartifact ...
            handles.btn_run_all],...
        'Enable', on_or_off);

    if ~license('checkout','signal_toolbox')
        disp('Signal Processing Toolbox missing. Most functions are disabled')
        set([   handles.sliceartifact ...
                handles.volumeartifact ...
                handles.highfilter ...
                handles.bandpass ...
                handles.lowpass ...
                handles.btn_run_all], ...
            'Enable', 'off');
    end

    % check if emg data was modified
    if sum(EMG_fMRI_steps_emgpre(2:end))>=1
        set(handles.save_data,'Enable','on');
    else
        set(handles.save_data,'Enable','off');
    end
    
% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
    % loads the confirmation to quit whem EEG was modified
    if strcmpi(get(handles.save_data,'Enable'),'on')
        % confirm:
        choice = questdlg('EMG not saved! Are you sure you would like to close the EMG preprocessing window?', ...
            'Confirm', 'No','Yes','Yes');
        switch choice
            case 'No'
            case 'Yes'
                close;
        end
    else
        close; % close without warning if nothing was changed
    end

% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; amd EEG

    emgpath=fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient, EMG_fMRI_protoname_select_muscle, 'emg', 'emg_preprocessed');
    % check if emg_preprocessed directory is there
    if ~isdir(emgpath)
        mkdir(emgpath);
    end
 
    savefile = 'emg_oude_methode';

%   if EMG_fMRI_steps_emgpre(1) == 1   always add channel#, even if it was not selected manually
        savefile = [savefile '_ch_' num2str(EMG_fMRI_profile{2})];
%   end

    if EMG_fMRI_steps_emgpre(2) == 1
        savefile = [savefile '_st_added'];
    end

    if EMG_fMRI_steps_emgpre(7) == 1
        savefile = [savefile '_lpf_' num2str(EMG_fMRI_profile{7}(1)) '_' num2str(EMG_fMRI_profile{7}(1)) '_'];
    end

    if EMG_fMRI_steps_emgpre(3) == 1
        savefile = [savefile '_hpf_' num2str(EMG_fMRI_profile{3}(1))];
    end

    if EMG_fMRI_steps_emgpre(6) == 1
        savefile = [savefile '_bpf_' num2str(EMG_fMRI_profile{6}(1)) '_' num2str(EMG_fMRI_profile{6}(2)) '_'];
    end
    
    EEG.setname     = [EMG_fMRI_patient ', ' EMG_fMRI_protoname_select_muscle, ', pre-processed emg'];
    % include the text as comment inside EEG
    EEG.comments = [ EEG.comments ' EMGfMRI:' savefile];

    savefile = fullfile(emgpath, [savefile '.mat']); % paul removed datestr(now,'yyyy.mm.dd__HH.MM.SS') 
    [filename pathname ] = uiputfile('*.mat','Save processed emg as',savefile);
    if filename~=0
        % update the new filename in EEG header
        EEG.filename = filename;
        
        save(fullfile(pathname,filename), 'EEG');
        set(handles.save_data,'Enable','off')
        
        % update some EEGlab stuff...
         % add modified data to eeglab dataset store
        [ ALLEEG, EEG, CURRENTSET ] = eeg_store(ALLEEG, EEG, 2); % add CURRENTSET as 3th argument to overwrite the current set
        % flag as saved
        EEG.saved = 'yes'; 
        % and update it's GUI
        eeglab_redraw;
    end


% --- Executes on button press in inspect_data.
function inspect_data_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    try
        pop_eegplot(EEG, 1, 1, 1);
    catch
        msgbox('EEGPlot could not been displayed','Error');
    end
    try 
        pop_spectopo(EEG);
    catch
        msgbox('spectoplot could not been displayed','Error');
    end
   

% --- Executes on button press in new_method.
function new_method_Callback(hObject, eventdata, handles)

% --- Executes on button press in old_method.
function old_method_Callback(hObject, eventdata, handles)

% --- Executes on button press in radio_personalised.
function radio_personalised_Callback(hObject, eventdata, handles)

% --- Executes on button press in makebipolar.

% The button make bipolar is removed in the final version, because this
% is an action that always must been done.

%  function makebipolar_Callback(hObject, eventdata, handles)
% % hObject    handle to makebipolar (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % makes the signal bipolar using emg_make_bipolar
% try 
%     EEG=evalin('base','EEG');
%     EEG=emg_make_bipolar(EEG);
%     assignin('base','EEG',EEG); 
%     msgbox('EMG signal is now bipolar','Make bipolar succeeded!');
% catch
%     msgbox('Something went wrong, EEG variable not loaded, select emg.mat file.','Error');
%     [tmpfile tmppath] = uigetfile('*.mat', 'emg');
%     EEG = [tmppath tmpfile];
%     EEG =load('EEG');
%     assignin('base','EEG',EEG);
%     EEG=evalin('base','EEG');
%     EEG=emg_make_bipolar(EEG);
%     msgbox('EMG signal is now bipolar','Make bipolar succeeded!');
% end

function post_choosechannel_Callback(handles,nr)
    emg_fmri_globals; % make sure this is the first call in the fn; 
    % update channel in profile
    EMG_fMRI_profile{2} = nr;
    % update GUI
    updateMyGUI(handles);
    
% --- Executes on button press in choosechannel.
function choosechannel_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    flagStepDone(1);

    %opens the GUI and a plot to define the channel with te biggest artifact
    choose_channel(@post_choosechannel_Callback,handles); % this show dialog and fill profile{2} when done
    pop_eegplot(EEG, 1, 1, 1);

    % construct a cell, for profile option
%     profile = cell (7,1);
%     % add profile to base
%     assignin('base','EMG_fMRI_profile', profile);  

 % --- Executes on button press in addslicetriggers.
function addslicetriggers_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG

    if isempty(EMG_fMRI_profile{2})
        msgbox('Choose a channel first!'); % cannot happen: button will be disabled until channel is selected
        return;
    end

    try 
        %execute script to add slicetriggers
        [EEG msg] = addslicetriggers(EEG, EMG_fMRI_profile{2});
        if isempty(msg)
            updateMyGUI(handles);
            %display message when done
            msgbox('Succesfully added slice triggers','Success!');
        else
            errordlg(msg);
        end
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg(ME.message);
    end

function [EEG msg] = addslicetriggers(EEG, channel)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    fprintf('running addslicetriggers(EEG, channel=%d)\n', channel);
    msg = [];
    h = waitbar(0,'Please wait while adding slice triggers...');
    try 
        wdir=fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient, EMG_fMRI_protoname_select_muscle, 'emg');
        cd(wdir);

        %execute script to add slicetriggers
        EEG=emg_add_slicetriggers(EEG, channel);

        flagStepDone(2);
    catch% ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg(ME.message);
    end
    close(h);
    
% --- Executes on button press in highfilter.
function highfilter_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG

    % 2009-08-19: (Paul) this routine requires the Signal Processing Toolbox, so better check it now...
    if ~license('checkout','signal_toolbox')
        errordlg('This function requires the Signal Processing Toolbox')
        return
    end

     % Ask for filtervalues
    prompt={'Choose the cutoff frequency of your highpass filter'};
    name='Highpass filter';
    if ~isempty(EMG_fMRI_profile{3})
        defaultanswer = {num2str(EMG_fMRI_profile{3})};
    else
        defaultanswer={'25'};
    end
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    try
        %convert input values to numbers
        cutoff = str2double(answer{1});

        % add cutoff and cutoff to profile cell
        EMG_fMRI_profile{3} = cutoff;

        [EEG msg] = highfilter(EEG, cutoff);

        if isempty(msg)
            updateMyGUI(handles);
            % display confirmation
            msgbox('Highpass filtering succeeded','Succes!');
        else
            errordlg(msg);
        end

    catch% ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg(ME.message);
    end

function [EEG msg] = highfilter(EEG, cutoff)
    fprintf('running highfilter(EEG, cutoff=%g)\n',cutoff);
    msg = [];
    h = waitbar(0,'Applying high-pass filter...');
    try
        % create & apply filter to EMG
        for i=1:EEG.nbchan
            EEG.data(i,:)  = helper_filter(EEG.data(i,:) ,cutoff,EEG.srate,'high');
            waitbar(i/EEG.nbchan);
        end
        flagStepDone(3);
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg(ME.message);
    end
    close(h);

% --- Executes on button press in sliceartifact.
function sliceartifact_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    % 2009-08-19: (Paul) this routine requires the Signal Processing Toolbox, so better check it now...
    if ~license('checkout','signal_toolbox')
        errordlg('This function requires the Signal Processing Toolbox')
        return
    end

    % Ask for filtervalues
    prompt={'Choose the low pass filter cutoff','Choose the interpolation folds','Choose number of artifacts in average window','Relatve location of slice triggers to actual start'};
    name='Slice Artifact';
    if ~isempty(EMG_fMRI_profile{4})
        defaultanswer = {num2str(EMG_fMRI_profile{4}(1)), num2str(EMG_fMRI_profile{4}(2)), num2str(EMG_fMRI_profile{4}(3)), num2str(EMG_fMRI_profile{4}(4))};
    else
        defaultanswer={'0','10','10','0.07'};
    end
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    % Assign values to variables
    lowpass         = str2double(answer{1});
    interpolation   = str2double(answer{2});
    artifacts       = str2double(answer{3});
    pre_frac        = str2double(answer{4});

    % add lowpass, interpolation, artifacts and prefrac to profile cell
    EMG_fMRI_profile{4} = [lowpass interpolation artifacts pre_frac];

    [EEG msg] = sliceartifact(EEG, lowpass, interpolation, artifacts, pre_frac);
    if ~isempty(msg)
        errordlg(msg);
    else
        updateMyGUI(handles);
    end
    
function [EEG msg] = sliceartifact(EEG, lowpass, interpolation, artifacts, pre_frac)
    fprintf('running sliceartifact(EEG, lowpass=%g, interpolation=%g, artifacts=%g, pre_fact=%g)\n',lowpass, interpolation, artifacts, pre_frac);
    msg = [];
    % standard values for slice artifact
    etype = 's';
    timingevent = 1;
    anc_check = [];
    trig_correct = [];
    volumes = [];
    slices = [];
    exc_chan = '';
    NPC = '';
    h = waitbar(0,'Wait while removing slice artefacts...');
    try 
        EEG = pop_fmrib_fastr(EEG,lowpass,interpolation,artifacts,etype,timingevent,anc_check,trig_correct,volumes,slices,pre_frac,exc_chan,NPC);
        flagStepDone(4);
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg(ME.message);
    end
    close(h);

% --- Executes on button press in volumeartifact.
function volumeartifact_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    % 2009-08-19: (Paul) this routine requires the Signal Processing Toolbox, so better check it now...
    if ~license('checkout','signal_toolbox')
        errordlg('This function requires the Signal Processing Toolbox')
        return
    end

    prompt={'Choose the low pass filter cutoff','Choose the interpolation folds','Choose number of artifacts in average window','Relatve location of slice triggers to actual start'};
    name='Volume Artifact';
    if ~isempty(EMG_fMRI_profile{5})
        defaultanswer = {num2str(EMG_fMRI_profile{5}(1)), num2str(EMG_fMRI_profile{5}(2)), num2str(EMG_fMRI_profile{5}(3)), num2str(EMG_fMRI_profile{5}(4))};
    else
        defaultanswer={'0','10','10','0.03'};
    end
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    % Assign values to variables
    lowpass         = str2double(answer{1});
    interpolation   = str2double(answer{2});
    artifacts       = str2double(answer{3});
    pre_frac        = str2double(answer{4});

    % add lowpass, interpolation, artifacts and prefrac to profile cell
    EMG_fMRI_profile{5} = [lowpass interpolation artifacts pre_frac];

    [ EEG msg ] = volumeartifact(EEG, lowpass, interpolation, artifacts, pre_frac);
    
    if ~isempty(msg)
        errordlg(msg);
    else
        updateMyGUI(handles);
    end

function [ EEG msg ] = volumeartifact(EEG, lowpass, interpolation, artifacts, pre_frac)
    fprintf('running volumeartifact(EEG, lowpass=%g, interpolation=%g, artifacts=%g, pre_fact=%g)\n',lowpass, interpolation, artifacts, pre_frac);
    msg = [];
    % standard values for volume artifact
    etype = 'V';
    timingevent = 1;
    anc_check = [];
    trig_correct = [];
    volumes = [];
    slices = [];
    exc_chan = '';
    NPC = '';
    h = waitbar(0,'Wait while removing volume artefacts...');
    try
        try 
            EEG = pop_fmrib_fastr(EEG,lowpass,interpolation,artifacts,etype,timingevent,anc_check,trig_correct,volumes,slices,pre_frac,exc_chan,NPC);
            flagStepDone(5);
        catch
            etype = '65535';
            EEG = pop_fmrib_fastr(EEG,lowpass,interpolation,artifacts,etype,timingevent,anc_check,trig_correct,volumes,slices,pre_frac,exc_chan,NPC);%was eerst pre_frac_exc_chan
            flagStepDone(5);
        end
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg(ME.message);
    end
    close(h);

% --- Executes on button press in bandpass.
function bandpass_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    % Ask for filtervalues
    prompt={'Choose your lower cutoff frequency of your frequency bandpass filter','Choose your upper cutoff frequency of your frequency bandpass filter'};
    name='Frequency bandpass filter';
    if ~isempty(EMG_fMRI_profile{6})
        defaultanswer = {num2str(EMG_fMRI_profile{6}(1)), num2str(EMG_fMRI_profile{6}(2))};
    else
        defaultanswer={'20','250'};
    end
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    % convert inputvalues to  numbers
    lowercutoff     = str2double(answer{1});
    highercutoff    = str2double(answer{2});

    % add lowercutoff and highercutoff to profile cell
    EMG_fMRI_profile{6} = [lowercutoff highercutoff];

    % apply band pass filter
    EEG=bandpass(EEG,lowercutoff,highercutoff);

    updateMyGUI(handles);

    % display confirmation
    msgbox('band pass filtering succeeded!','Succes!');

 function EEG = bandpass(EEG, lowercutoff, highercutoff)
    fprintf('running bandpass(EEG, lowercutoff=%g, highercutoff=%g)\n',lowercutoff, highercutoff);
    h = waitbar(0,'Wait while applying bandpass filter...');
    % apply band pass filter
    EEG=emg_filter_bandpass(EEG,lowercutoff,highercutoff);
    flagStepDone(6);
    close(h);


% --- Executes on button press in lowpass.
function lowpass_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    % 2009-08-19: (Paul) this routine requires the Signal Processing Toolbox, so better check it now...
    if ~license('checkout','signal_toolbox')
        errordlg('This function requires the Signal Processing Toolbox')
        return
    end

     % Ask for filtervalues
    prompt={'Choose the cutoff frequency of your lowpass filter'};
    name='Lowpass filter';
    if ~isempty(EMG_fMRI_profile{7})
        defaultanswer = {num2str(EMG_fMRI_profile{7})};
    else
        defaultanswer={'?'};
    end
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer) || ~isreal(answer{1}) , return, end

    try
        %convert input values to numbers
        cutoff = str2double(answer{1});

        % add cutoff and cutoff to profile cell
        EMG_fMRI_profile{7} = cutoff;

        [EEG msg] = lowpass(EEG, cutoff);

        if isempty(msg)
            updateMyGUI(handles);
            % display confirmation
            msgbox('Lowpass filtering succeeded','Succes!');
        else
            errodlg(msg);
        end
        
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg(ME.message);
    end


function [EEG msg] = lowpass(EEG, cutoff)
    msg = [];
    h = waitbar(0,'Applying low pass...');
    try
        for i=1:EEG.nbchan
            waitbar(i/EEG.nbchan);
            EEG.data(i,:)  = helper_filter(EEG.data(i,:),cutoff,EEG.srate,'low');
        end
        flagStepDone(7);
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg(ME.message);
    end
    close(h);

    
function method_SelectionChangeFcn(hObject, eventdata)

    %retrieve GUI data, i.e. the handles structure
    handles = guidata(hObject); 

    switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
         case 'new_method'
           %execute this code when radiobutton1 is selected
           preprocessing_emg_corr
           close(preprocessing_emg_personalised)
         case 'radio_personalised'
%            %execute this code when radiobutton1 is selected
%            preprocessing_emg_personalised
%            close(preprocessing_emg_corr)
         otherwise
            % Code for when there is no match.
            msgbox('Choose a method!','Error');
    end


% --- Executes on button press in 'Save Profile'.
function save_profile_Callback(hObject, eventdata, handles)
    % this will save the used settings in a profile file. 
 
    SaveProfile();


% --- Executes on button press in load_profile.
function load_profile_Callback(hObject, eventdata, handles)
    % this will load an existing profile file. 
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    profiledir = fullfile(EMG_fMRI_study_dir,'profiles');
    
    % check if there is a directory profiles, if not make one
    if ~isdir (profiledir)
        mkdir profiledir;
    end
    try
        [filename pathname ] = uigetfile([profiledir filesep '*.mat'],'Load Profile from');
        if filename~=0
            profile = LoadProfile(fullfile(pathname, filename));
            % and update GUI
            updateMyGUI(handles);
        end
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg(ME.message);
    end


% --- Executes on button press in edit_profile.
function edit_profile_Callback(hObject, eventdata, handles)
    close
    preprocessing_emg_personalised_profile_settings

% --- Executes on button press in btn_run_all.
function btn_run_all_Callback(hObject, eventdata, handles)
    % This function just runs the complete batch of the current profile
    
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    % 2009-08-19: (Paul) this routine requires the Signal Processing Toolbox, so better check it now...
    if ~license('checkout','signal_toolbox')
        errordlg('This function requires the Signal Processing Toolbox')
        return
    end
    
    msg = [];
    
    % execute script to add slicetriggers
    if isempty(msg)
        [EEG msg] = addslicetriggers(EEG, EMG_fMRI_profile{2}); 
    end

    % cutoff = profile{3};
    if isempty(msg)
        [EEG msg] = highfilter(EEG, EMG_fMRI_profile{3});
    end

    % [lowpass interpolation artifacts pre_frac] = profile{4};
    if isempty(msg)
        [EEG msg] = sliceartifact(EEG, EMG_fMRI_profile{4}(1), EMG_fMRI_profile{4}(2), EMG_fMRI_profile{4}(3), EMG_fMRI_profile{4}(4));
    end

    % [lowpass interpolation artifacts pre_frac] = profile{5};
    if isempty(msg)
        [ EEG msg ] = volumeartifact(EEG, EMG_fMRI_profile{5}(1), EMG_fMRI_profile{5}(2), EMG_fMRI_profile{5}(3), EMG_fMRI_profile{5}(4));
    end

    % [lowercutoff highercutoff] = profile{6};
    if isempty(msg)
        EEG = bandpass(EEG,EMG_fMRI_profile{6}(1),EMG_fMRI_profile{6}(2));
    end

    %cutoff = profile{7};
    if isempty(msg) && ~isempty(EMG_fMRI_profile{7})
        [EEG msg] = lowpass(EEG, EMG_fMRI_profile{7});
    end
        
    if isempty(msg)
        updateMyGUI(handles);
        % display confirmation
        msgbox('Ready!','Succes!');
    else
        errordlg(msg);
    end
