function varargout = preprocessing_emg_personalised_profile_settings(varargin)
% PREPROCESSING_EMG_PERSONALISED_PROFILE_SETTINGS M-file for preprocessing_emg_personalised_profile_settings.fig
%      PREPROCESSING_EMG_PERSONALISED_PROFILE_SETTINGS, by itself, creates a new PREPROCESSING_EMG_PERSONALISED_PROFILE_SETTINGS or raises the existing
%      singleton*.
%
%      H = PREPROCESSING_EMG_PERSONALISED_PROFILE_SETTINGS returns the handle to a new PREPROCESSING_EMG_PERSONALISED_PROFILE_SETTINGS or the handle to
%      the existing singleton*.
%
%      PREPROCESSING_EMG_PERSONALISED_PROFILE_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCESSING_EMG_PERSONALISED_PROFILE_SETTINGS.M with the given input arguments.
%
%      PREPROCESSING_EMG_PERSONALISED_PROFILE_SETTINGS('Property','Value',...) creates a new PREPROCESSING_EMG_PERSONALISED_PROFILE_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preprocessing_emg_personalised_profile_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preprocessing_emg_personalised_profile_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help preprocessing_emg_personalised_profile_settings

% Last Modified by GUIDE v2.5 06-Nov-2009 16:18:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @preprocessing_emg_personalised_profile_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @preprocessing_emg_personalised_profile_settings_OutputFcn, ...
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

%--------------------------------------------------------------------------
% Unfortunately the profile cell array was not defined as a structure,
% so lets define the fields here:
%
%   profile{1} = name of the profile  (default 'Standard Profile')
%   profile{2} = channel number       (default 4)
%   profile{3} = high pass cutoff     (default 25)
%   profile{4} = slice artifact filter (default [0 10 10 0.03])
%   profile{5} = VOLUME artifact fiter (default [0 10 10 0.07])
%   profile{6} = bandpassfilter       (default [20 250])
%   profile{7} = lowpass order,cuttof
%--------------------------------------------------------------------------
    
% --- Executes just before preprocessing_emg_personalised_profile_settings is made visible.
function preprocessing_emg_personalised_profile_settings_OpeningFcn(hObject, eventdata, handles, varargin)
     emg_fmri_globals; % make sure this is the first call in the fn; and EEG
     
   % Choose default command line output for preprocessing_emg_personalised_profile_settings
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    SetTextValue(handles.text9, EMG_fMRI_profile, 1);
    SetTextValue(handles.text10, EMG_fMRI_profile, 2, 1);
    SetTextValue(handles.text33, EMG_fMRI_profile, 3, 1);
    SetTextValue(handles.text12, EMG_fMRI_profile, 4, 1);
    SetTextValue(handles.text34, EMG_fMRI_profile, 4, 2);
    SetTextValue(handles.text38, EMG_fMRI_profile, 4, 3);
    SetTextValue(handles.text40, EMG_fMRI_profile, 4, 4);
    SetTextValue(handles.text13, EMG_fMRI_profile, 5, 1);
    SetTextValue(handles.text35, EMG_fMRI_profile, 5, 2);
    SetTextValue(handles.text39, EMG_fMRI_profile, 5, 3);
    SetTextValue(handles.text41, EMG_fMRI_profile, 5, 4);
    SetTextValue(handles.text14, EMG_fMRI_profile, 6, 1);
    SetTextValue(handles.text36, EMG_fMRI_profile, 6, 2);
    SetTextValue(handles.text37, EMG_fMRI_profile, 7, 1);

    % UIWAIT makes preprocessing_emg_personalised_profile_settings wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

% Used to update one of the text elements according to the corresponding profile value
function SetTextValue(handle,profile,cellnr,index)
    try
        if nargin<4
            msg = profile{cellnr};
        else
            msg = num2str(profile{cellnr}(index));
        end
    catch
        msg = 'empty';
    end
    set(handle,'String',msg);


% --- Outputs from this function are returned to the command line.
function varargout = preprocessing_emg_personalised_profile_settings_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
     
    % load values
    try
        nameprofile = EMG_fMRI_profile{1};
    catch
        nameprofile = 'empty';
    end
    
    % Ask for filtervalues
    prompt={'Choose the name of your profile'};
    name='Name of your profile';
    defaultanswer={nameprofile};
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    % add name as string to profile cell
    EMG_fMRI_profile{1} = answer{1};

    SetTextValue(handles.text9, EMG_fMRI_profile, 1);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    try
        channel = num2str(EMG_fMRI_profile{2});
    catch
        channel = 'empty';
    end

    % Ask for filtervalues
    prompt={'Choose the channel with the biggest artifact'};
    name='Channel with the biggest artifact';
    defaultanswer={channel};
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    % add name to profile cell
    channel = str2double(answer{1});
    EMG_fMRI_profile{2} = channel;

    SetTextValue(handles.text10, EMG_fMRI_profile, 2, 1);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG

    cutoff = num2str(EMG_fMRI_profile{3});

    % Ask for filtervalues
    prompt={'Choose the cutoff frequency of your highpass filter'};
    name='Highpass filter';
    defaultanswer={cutoff};
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    try
        %convert input values to numbers
        cutoff = str2double(answer{1});
        % add order and cutoff to profile cell
        EMG_fMRI_profile{3} = cutoff;
    catch
        msgbox('Something went wrong','Error');
    end

    SetTextValue(handles.text33, EMG_fMRI_profile, 3, 1);

    
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    try
        lowpass         = num2str(EMG_fMRI_profile{4}(1));
        interpolation   = num2str(EMG_fMRI_profile{4}(2));
        artifacts       = num2str(EMG_fMRI_profile{4}(3));
        pre_frac        = num2str(EMG_fMRI_profile{4}(4));
    catch 
        lowpass         = 'empty';
        interpolation   = 'empty';
        artifacts       = 'empty';
        pre_frac        = 'empty';
    end

    % Ask for filtervalues
    prompt={'Choose the low pass filter cutoff','Choose the interpolation folds','Choose number of artifacts in average window','Relatve location of slice triggers to actual start'};
    name='Slice Artifact';
    defaultanswer={lowpass,interpolation,artifacts,pre_frac};
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    try
        % Assign values to variables
        lowpass         = str2double(answer{1});
        interpolation   = str2double(answer{2});
        artifacts       = str2double(answer{3});
        pre_frac        = str2double(answer{4});

        % add lowpass, interpolation, artifacts and prefrac to profile cell
        EMG_fMRI_profile{4} = [lowpass interpolation artifacts pre_frac];
    catch
        msgbox('Something went wrong','Error');
    end
    SetTextValue(handles.text12, EMG_fMRI_profile, 4, 1);
    SetTextValue(handles.text34, EMG_fMRI_profile, 4, 2);
    SetTextValue(handles.text38, EMG_fMRI_profile, 4, 3);
    SetTextValue(handles.text40, EMG_fMRI_profile, 4, 4);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG

    try
        lowpass         = num2str(EMG_fMRI_profile{5}(1));
        interpolation   = num2str(EMG_fMRI_profile{5}(2));
        artifacts       = num2str(EMG_fMRI_profile{5}(3));
        pre_frac        = num2str(EMG_fMRI_profile{5}(4));
    catch 
        lowpass         = 'empty';
        interpolation   = 'empty';
        artifacts       = 'empty';
        pre_frac        = 'empty';
    end

    % Ask for filtervalues
    prompt={'Choose the low pass filter cutoff','Choose the interpolation folds','Choose number of artifacts in average window','Relatve location of slice triggers to actual start'};
    name='Volume Artifact';
    defaultanswer={lowpass,interpolation,artifacts,pre_frac};
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    try
        % Assign values to variables
        lowpass         = str2double(answer{1});
        interpolation   = str2double(answer{2});
        artifacts       = str2double(answer{3});
        pre_frac        = str2double(answer{4});
        % add lowpass, interpolation, artifacts and prefrac to profile cell
        EMG_fMRI_profile{5} = [lowpass interpolation artifacts pre_frac];
    catch
        msgbox('Something went wrong','Error');
    end

    SetTextValue(handles.text13, EMG_fMRI_profile, 5, 1);
    SetTextValue(handles.text35, EMG_fMRI_profile, 5, 2);
    SetTextValue(handles.text39, EMG_fMRI_profile, 5, 3);
    SetTextValue(handles.text41, EMG_fMRI_profile, 5, 4);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    try
        low = num2str(EMG_fMRI_profile{6}(1));
        high = num2str(EMG_fMRI_profile{6}(2));
    catch
        low = 'empty';
        high = 'empty';
    end

    % Ask for filtervalues
    prompt={'Choose the lower cutoff frequency of your bandpass filter','Choose the higher cutoff frequency of your bandpass filter'};
    name='Bandpass filter';
    defaultanswer={low,high};
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    try
        %convert input values to numbers
        low = str2double(answer{1});
        high = str2double(answer{2});

        % add order and cutoff to profile cell
        EMG_fMRI_profile{6} = [low high];
    catch
        msgbox('Something went wrong','Error');
    end

    SetTextValue(handles.text14, EMG_fMRI_profile, 6, 1);
    SetTextValue(handles.text36, EMG_fMRI_profile, 6, 2);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    try
%       order = num2str(EMG_fMRI_profile{7}(1));
        cutoff = num2str(EMG_fMRI_profile{7});
    catch
%       order = 'empty';
        cutoff = 'empty';
    end

    % Ask for filtervalues
    prompt={'Choose the cutoff frequency of your lowpass filter'};
    name='Lowpass filter';
    defaultanswer={cutoff};
    answer=inputdlg(prompt,name,1,defaultanswer);
    if isempty(answer), return, end

    try
        %convert input values to numbers
        cutoff = str2double(answer{1});
        
        % add order and cutoff to profile cell
        EMG_fMRI_profile{7} = cutoff;
    catch
        msgbox('Something went wrong','Error');
    end

    SetTextValue(handles.text37, EMG_fMRI_profile, 7, 1);


% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% 2009-10-01; paul removed the automatic save functionalitiy because this will be handled in preprocessing_emg_advanced
%     %go to desired directory
%     pdir =EMG_fMRI_study_dir;
%     cd(pdir);
%  
%     study = EMG_fMRI_study;
%       
%     wdir=([regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/' ]);
%     cd(wdir);
%     
%     % check if there is a directory profiles, if not make one
%     if ~isdir ('profiles') == 1
%         mkdir profiles;
%     end
%     % go to profiles directory
%     cd profiles
%     try
%         % save as user_profile
%         filename = EMG_fMRI_profile{1};
%         filename = char(filename);
%         save(filename,'EMG_fMRI_profile');
% 
%         % save as last_used_profile
%         save('last_used_profile.mat', 'EMG_fMRI_profile');
%     catch
%         msgbox('There are no parameters to save','Error');
%         pause
%     end
    close
    preprocessing_emg_personalised
