function varargout = remove_horns_protocol_selection(varargin)
% REMOVE_HORNS_PROTOCOL_SELECTION M-file for remove_horns_protocol_selection.fig
%      REMOVE_HORNS_PROTOCOL_SELECTION, by itself, creates a new REMOVE_HORNS_PROTOCOL_SELECTION or raises the existing
%      singleton*.
%
%      H = REMOVE_HORNS_PROTOCOL_SELECTION returns the handle to a new REMOVE_HORNS_PROTOCOL_SELECTION or the handle to
%      the existing singleton*.
%
%      REMOVE_HORNS_PROTOCOL_SELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REMOVE_HORNS_PROTOCOL_SELECTION.M with the given input arguments.
%
%      REMOVE_HORNS_PROTOCOL_SELECTION('Property','Value',...) creates a new REMOVE_HORNS_PROTOCOL_SELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before remove_horns_protocol_selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to remove_horns_protocol_selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help remove_horns_protocol_selection

% Last Modified by GUIDE v2.5 31-May-2010 22:06:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @remove_horns_protocol_selection_OpeningFcn, ...
                   'gui_OutputFcn',  @remove_horns_protocol_selection_OutputFcn, ...
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


% --- Executes just before remove_horns_protocol_selection is made visible.
function remove_horns_protocol_selection_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to remove_horns_protocol_selection (see VARARGIN)

% Choose default command line output for remove_horns_protocol_selection
    handles.output = hObject;

% Update handles structure
    guidata(hObject, handles);
    
     if isempty(EMG_fMRI_study_dir) || ~isdir(EMG_fMRI_study_dir)
        errordlg('First select ''Select dataset''','Initialization error','modal'); 
        error('First select ''Select dataset'''); 
    end

% UIWAIT makes remove_horns_protocol_selection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = remove_horns_protocol_selection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
   
function [protocol] = GetSelectedProtocol(hObject)
    index_selected = get(hObject,'Value');
    % use strings in list instead of base values because empty ones might have been removed (which could shift the indices)
    protocols = get(hObject,'String'); 
    protocol = protocols{index_selected};
       
    
% --- Executes on button press in btn_open_emg_corrected. % btn_open_emg_corrected = Open EMG_corrected
function btn_open_emg_corrected_Callback(hObject, eventdata, handles)
% hObject    handle to btn_open_emg_corrected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 emg_fmri_globals; % make sure this is the first call in the fn; and global EEG - see load below
    
    ppdir = fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient);
    protocol = GetSelectedProtocol(handles.popupmenu1);
    protocoldir = fullfile(ppdir,protocol);
    
    [filename, pathname] =  uigetfile('*.mat','Select the corrected EMG mat-file',fullfile(protocoldir,'emg','emg_corrected.mat'));
    if filename==0
        % user cancelled
        return;
    end
    filepath = fullfile(pathname,filename);
    
    disp(['Loading ' filepath]);
    load(filepath); % this will load into EEG
    close;
    remove_horns(protocol);
    

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
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
