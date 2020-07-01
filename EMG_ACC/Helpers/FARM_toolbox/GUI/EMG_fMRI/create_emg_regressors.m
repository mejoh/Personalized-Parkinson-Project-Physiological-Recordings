function varargout = create_emg_regressors(varargin)
% CREATE_EMG_REGRESSORS M-file for create_emg_regressors.fig
%      CREATE_EMG_REGRESSORS, by itself, creates a new CREATE_EMG_REGRESSORS or raises the existing
%      singleton*.
%
%      H = CREATE_EMG_REGRESSORS returns the handle to a new CREATE_EMG_REGRESSORS or the handle to
%      the existing singleton*.
%
%      CREATE_EMG_REGRESSORS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_EMG_REGRESSORS.M with the given input arguments.
%
%      CREATE_EMG_REGRESSORS('Property','Value',...) creates a new CREATE_EMG_REGRESSORS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_emg_regressors_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_emg_regressors_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_emg_regressors

% Last Modified by GUIDE v2.5 16-Nov-2009 17:54:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_emg_regressors_OpeningFcn, ...
                   'gui_OutputFcn',  @create_emg_regressors_OutputFcn, ...
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


% --- Executes just before create_emg_regressors is made visible.
function create_emg_regressors_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % Choose default command line output for create_emg_regressors
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    if isempty(EMG_fMRI_study_dir) || ~isdir(EMG_fMRI_study_dir)
        errordlg('First select ''Select dataset''','Initialization error','modal'); 
        error('First select ''Select dataset'''); 
    end

 %   set(handles.btn_apply,'String','confirm bandfilter settings');

    wdir=[EMG_fMRI_study_dir '/pp/' EMG_fMRI_patient ];
    cd(wdir);
    answer = EMG_fMRI_proto_answer;

    % init globals
%     EMG_fMRI_proto_muscles = [0 0 0 0 0]; % should probably be removed
    EMG_fMRI_freq_band_emg_model = [3 7];

    % UIWAIT makes create_emg_regressors wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


function init_button(handle, title)
    if ~isempty(title)
        set(handle,'String',title);
    else
        set(handle,'Enable','off') 
        set(handle,'String','N/A')
    end

% --- Executes during object creation, after setting all properties.
function lst_protocols_CreateFcn(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn;
    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % get the names of the protocols
    protocols = EMG_fMRI_proto_answer;
    % and remove empty cells
    protocols(cellfun(@isempty,protocols)) = [];
    if numel(protocols)>0
        set(hObject,'String',protocols);
    else
        set(hObject,'String',{'Not defined'});
        set(hObject,'Enable','off');
    end
    
% --- Returns the name of the selected protocol
function protocol = GetSelectedProtocol(hObject)
    index_selected = get(hObject,'Value');
    % use strings in list instead of base values because empty ones might have been removed (which could shift the indices)
    protocols = get(hObject,'String'); 
    protocol = protocols{index_selected};
    
% --- Outputs from this function are returned to the command line.
function varargout = create_emg_regressors_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

function edit_bandpass_low_freq_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    EMG_fMRI_freq_band_emg_model(1) = str2double(get(handles.edit_bandpass_low_freq,'String'));

% --- Executes during object creation, after setting all properties.
function edit_bandpass_low_freq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_bandpass_high_freq_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    EMG_fMRI_freq_band_emg_model(2) = str2num(get(handles.edit_bandpass_high_freq,'String'));

% --- Executes during object creation, after setting all properties.
function edit_bandpass_high_freq_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in btn_apply.
function btn_apply_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    if EMG_fMRI_freq_band_emg_model(1) >= EMG_fMRI_freq_band_emg_model(2)
        msgbox('Onjuiste bandfilter instellingen!!!','ERROR');
    else
        msgbox('Bandfilter instellingen applied','Confirmation')
    end
  

% --- Executes on selection change in lst_protocols.
function lst_protocols_Callback(hObject, eventdata, handles)

% --- Executes on button press in btn_select_muscles.
function btn_select_muscles_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn

    protocol = GetSelectedProtocol(handles.lst_protocols);
    
    wdir=fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient );
    cd(wdir)

    if EMG_fMRI_freq_band_emg_model(1) >= EMG_fMRI_freq_band_emg_model(2)
        msgbox('Onjuiste bandfilter instellingen!!!','ERROR');
    else
        if ~isempty(protocol)
            wdir = fullfile(wdir, protocol, 'emg'); 
            emgdir = wdir;
            default_file = fullfile(emgdir,'emg_corrected2.mat');
            if ~exist(default_file,'file')
                default_file = fullfile(emgdir,'emg_corrected.mat');
                if ~exist(default_file,'file')
                    default_file = emgdir;
                end
            end
            [filename, pathname] =  uigetfile('*.mat','Select the EMG mat-file',default_file);
            if filename~=0
                cd(pathname);
                load(filename);
                msg = ['laad ' filename ' in voor ' protocol];
                disp(msg);
                EMG_fMRI_protoname_select_muscle = protocol;
                wdir=fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient, protocol ); 
                cd(wdir);        % is nodig om extract_frequency_band uit te kunnen voeren

                h = waitbar(0,'Wait while rectifying EMG and calculating power');
                T = EEG; % temporary copy
                for i=1:EEG.nbchan
                    
                    % create a copy of rectified EMG for debugging purposes
                    EMG = T.data(i,:);
                    % filter high-pass @25Hz...
                    [b a]=butter(5,25/(T.srate/2),'high');
                    T.data(i,:)=abs(filter(b,a,T.data(i,:)));
                    
                    % use hilbert for johan's script
                    EEG.data(i, :) = abs(hilbert(EEG.data(i,:) ));
                    waitbar(i/(2*EEG.nbchan),h);
                end
                rect_file = fullfile(emgdir,'emg_rectified.mat');
                EEG0=EEG; % copy original because we must save T as EEG
                EEG=T;
                save(rect_file,'EEG');
                EEG=EEG0;
                disp(['saved ' rect_file]);
                clear T

                EMG_fMRI_freqreg = extract_frequency_band(EEG,EMG_fMRI_freq_band_emg_model(1),EMG_fMRI_freq_band_emg_model(2));
                waitbar(1,h);
                close(h);
                create_emg_regressors_select_muscles;
            end
        else
            msgbox('THAT IS IMPOSSIBLE','ERROR');
        end
    end

% --- Executes on button press in btn_show_power.
function btn_show_power_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn

    protocol = GetSelectedProtocol(handles.lst_protocols);
    
    wdir=fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient );
    cd(wdir)

    if ~isempty(protocol)
        wdir = fullfile(wdir, protocol, 'emg'); 
        default_file = fullfile(wdir,'emg_corrected2.mat');
        if ~exist(default_file,'file')
            default_file = fullfile(wdir,'emg_corrected.mat');
            if ~exist(default_file,'file')
                default_file = wdir;
            end
        end
        [filename, pathname] =  uigetfile('*.mat','Select the EMG mat-file',default_file);
        if filename~=0
            cd(pathname);
            load(filename);
            inspect_spectrograms;
        end
    else
        msgbox('THAT IS IMPOSSIBLE','ERROR');
    end


% --- Executes on button press in Close button
function btn_close_Callback(hObject, eventdata, handles)
    close
