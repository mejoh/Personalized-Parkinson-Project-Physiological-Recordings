function varargout = preprocessing_emg_protocol_selection(varargin)
% PREPROCESSING_EMG_PROTOCOL_SELECTION M-file for preprocessing_emg_protocol_selection.fig
%      PREPROCESSING_EMG_PROTOCOL_SELECTION, by itself, creates a new PREPROCESSING_EMG_PROTOCOL_SELECTION or raises the existing
%      singleton*.
%
%      H = PREPROCESSING_EMG_PROTOCOL_SELECTION returns the handle to a new PREPROCESSING_EMG_PROTOCOL_SELECTION or the handle to
%      the existing singleton*.
%
%      PREPROCESSING_EMG_PROTOCOL_SELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCESSING_EMG_PROTOCOL_SELECTION.M with the given input arguments.
%
%      PREPROCESSING_EMG_PROTOCOL_SELECTION('Property','Value',...) creates a new PREPROCESSING_EMG_PROTOCOL_SELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preprocessing_emg_protocol_selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preprocessing_emg_protocol_selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help preprocessing_emg_protocol_selection

% Last Modified by GUIDE v2.5 06-Nov-2009 16:10:28
% 2009-08-19: paul changed some buggy lines...
% 2009-09-30: paul removed standard emg prepocessing option and placed repeating code in local functions

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @preprocessing_emg_protocol_selection_OpeningFcn, ...
                   'gui_OutputFcn',  @preprocessing_emg_protocol_selection_OutputFcn, ...
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


% --- Executes just before preprocessing_emg_protocol_selection is made visible.
function preprocessing_emg_protocol_selection_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG

    handles.output = hObject;

    try
        wdir=([EMG_fMRI_study_dir '/pp/' EMG_fMRI_patient ]);
        cd(wdir); % ???
        answer = EMG_fMRI_proto_answer;
    catch
        msgbox('Please start analyse first!','Error');
    end

    CheckButtonEnable(answer{1},handles.pushbutton3);
    CheckButtonEnable(answer{2},handles.pushbutton4);
    CheckButtonEnable(answer{3},handles.pushbutton5);
    CheckButtonEnable(answer{4},handles.pushbutton6);
    CheckButtonEnable(answer{5},handles.pushbutton7);

    % Update handles structure
    guidata(hObject, handles);
    

    

    % UIWAIT makes preprocessing_emg_protocol_selection wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

function CheckButtonEnable(protocolname, handle)
    if ~isempty(protocolname)
        set(handle,'String',protocolname);
    else
        set(handle,'String','N/A')
        set(handle,'Enable','off')    
    end

% --- Outputs from this function are returned to the command line.
function varargout = preprocessing_emg_protocol_selection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in 'Cancel'.
function pushbutton1_Callback(hObject, eventdata, handles)
    close

function pushbutton3_Callback(hObject, eventdata, handles)
    HandleProtocol(1);

function pushbutton4_Callback(hObject, eventdata, handles)
    HandleProtocol(2);

function pushbutton5_Callback(hObject, eventdata, handles)
    HandleProtocol(3);

function pushbutton6_Callback(hObject, eventdata, handles)
    HandleProtocol(4);

function pushbutton7_Callback(hObject, eventdata, handles)
    HandleProtocol(5);

function HandleProtocol(nr)
    emg_fmri_globals; % make sure this is the first call in the fn; and EEG
    
    if ~isempty(EMG_fMRI_proto_answer{nr})
        emgfile=fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient, EMG_fMRI_proto_answer{nr}, 'emg', 'emg.mat');
        [filename,pathname] = uigetfile('*.mat','Select raw EMG file',emgfile);
        if filename~=0
            emgfile = fullfile(pathname,filename);
            try
                load(emgfile); % load into global EEG
                % make sure the 8 upper unipolar channels are converted to 4 bipolar
                if EEG.nbchan>8
                    EEG=emg_make_bipolar(EEG); 
                end
                % update channel labels: load into muscles
                try
                    load(fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient, 'muscles.mat'));
                    if numel(muscles)>=8
                        for iLabel=1:8
                            EEG.chanlocs(iLabel).labels = muscles{iLabel};
                        end
                    end
                catch
                    disp('muscle naming unknown');

                end
                EMG_fMRI_protoname_select_muscle = EMG_fMRI_proto_answer{nr};
                close();
            catch
                errordlg('An error occured while loading selected EMG file');
                EEG = [];
            end
            % reflect the new EEG in the EEGLab GUI
            EEG = eeg_checkset(EEG);
            EEG.saved = 'no';
            [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 1);
            eeglab_redraw;
            if ~isempty(EEG)
                % and continue processing the raw emg
                preprocessing_emg_personalised;
            end
        end
    else
        errordlg('No protocol selected!')
    end
