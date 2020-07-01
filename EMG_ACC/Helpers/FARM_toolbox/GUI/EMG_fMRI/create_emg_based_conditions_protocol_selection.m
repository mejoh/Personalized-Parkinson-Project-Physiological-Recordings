function varargout = create_emg_based_conditions_protocol_selection(varargin)
% CREATE_EMG_BASED_CONDITIONS_PROTOCOL_SELECTION M-file for create_emg_based_conditions_protocol_selection.fig
%      CREATE_EMG_BASED_CONDITIONS_PROTOCOL_SELECTION, by itself, creates a new CREATE_EMG_BASED_CONDITIONS_PROTOCOL_SELECTION or raises the existing
%      singleton*.
%
%      H = CREATE_EMG_BASED_CONDITIONS_PROTOCOL_SELECTION returns the handle to a new CREATE_EMG_BASED_CONDITIONS_PROTOCOL_SELECTION or the handle to
%      the existing singleton*.
%
%      CREATE_EMG_BASED_CONDITIONS_PROTOCOL_SELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_EMG_BASED_CONDITIONS_PROTOCOL_SELECTION.M with the given input arguments.
%
%      CREATE_EMG_BASED_CONDITIONS_PROTOCOL_SELECTION('Property','Value',...) creates a new CREATE_EMG_BASED_CONDITIONS_PROTOCOL_SELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_emg_based_conditions_protocol_selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_emg_based_conditions_protocol_selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_emg_based_conditions_protocol_selection

% Last Modified by GUIDE v2.5 06-Nov-2009 15:54:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_emg_based_conditions_protocol_selection_OpeningFcn, ...
                   'gui_OutputFcn',  @create_emg_based_conditions_protocol_selection_OutputFcn, ...
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


% --- Executes just before create_emg_based_conditions_protocol_selection is made visible.
function create_emg_based_conditions_protocol_selection_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % Choose default command line output for create_emg_based_conditions_protocol_selection
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    if isempty(EMG_fMRI_study_dir) || ~isdir(EMG_fMRI_study_dir)
        errordlg('First select ''Select dataset''','Initialization error','modal'); 
        error('First select ''Select dataset'''); 
    end

    % (Paul) btn_make_regressor requires the Signal Processing Toolbox, so better check it now...
    result = license('test','signal_toolbox');
    if result
        on_or_off = 'on';
    else
        on_or_off = 'off';
    end
    set(handles.btn_make_regressor,'Enable', on_or_off);
    
    % UIWAIT makes create_emg_based_conditions_protocol_selection wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = create_emg_based_conditions_protocol_selection_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

% --- Returns the name of the selected protocol
function [protocol] = GetSelectedProtocol(hObject)
    index_selected = get(hObject,'Value');
    % use strings in list instead of base values because empty ones might have been removed (which could shift the indices)
    protocols = get(hObject,'String'); 
    protocol = protocols{index_selected};

% --- Executes on button press in btn_make_block_emg.
function btn_make_block_emg_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; and global EEG - see load below
    
    ppdir = fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient);
    protocol = GetSelectedProtocol(handles.lst_protocols);
    protocoldir = fullfile(ppdir,protocol);
    
    [filename, pathname] =  uigetfile('*.mat','Select the corrected EMG mat-file',fullfile(protocoldir,'emg','emg_corrected2.mat'));
    if filename==0
        % user cancelled
        return;
    end
    filepath = fullfile(pathname,filename);
    
    disp(['Loading ' filepath]);
    load(filepath); % this will load into EEG
    close;
    create_emg_based_conditions(protocol);
    
% don't use the old stuff anymore....
%   blokemgmaken(GetSelectedProtocol(handles.lst_protocols));

% --- Executes on button press in btn_make_regressor.
function btn_make_regressor_Callback(hObject, eventdata, handles)
    disp('r_emg_maken has been removed');
%    r_emg_maken(GetSelectedProtocol(handles.lst_protocols));  % requires the signal procesing toolbox

% --- Executes on selection change in lst_protocols.
function lst_protocols_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns lst_protocols contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_protocols


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
    
