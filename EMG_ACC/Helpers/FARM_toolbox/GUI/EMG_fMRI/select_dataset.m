function varargout = select_dataset(varargin)
% SELECT_DATASET M-file for select_dataset.fig
%      SELECT_DATASET, by itself, creates a new SELECT_DATASET or raises the existing
%      singleton*.
%
%      H = SELECT_DATASET returns the handle to a new SELECT_DATASET or the handle to
%      the existing singleton*.
%
%      SELECT_DATASET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_DATASET.M with the given input arguments.
%
%      SELECT_DATASET('Property','Value',...) creates a new SELECT_DATASET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_dataset_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_dataset_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_dataset

% Last Modified by GUIDE v2.5 02-Nov-2009 10:57:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_dataset_OpeningFcn, ...
                   'gui_OutputFcn',  @select_dataset_OutputFcn, ...
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


% --- Executes just before select_dataset is made visible.
function select_dataset_OpeningFcn(hObject, eventdata, handles, varargin)

    emg_fmri_globals; % make sure this is the first call in the fn
    
    % Choose default command line output for select_dataset
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    try
        % 2009-08-17, Paul added some code to reload user settings from registry.
        %             Also tweaked the code to remove some weird constructions...
        if ispc && ~var_has_value('EMG_fMRI_study_dir')
            % load parameters from registry
            strRegistryKey = 'AMC\KNF\EMG_fMRI\laststudy';
            t = settings(strRegistryKey);
            if isstruct(t)
                EMG_fMRI_study = t.study;
                EMG_fMRI_patient = t.patient;
                EMG_fMRI_study_dir = t.study_dir;
                EMG_fMRI_proto_answer{1} = t.proto_answer_1;
                EMG_fMRI_proto_answer{2} = t.proto_answer_2;
                EMG_fMRI_proto_answer{3} = t.proto_answer_3;
                EMG_fMRI_proto_answer{4} = t.proto_answer_4;
                EMG_fMRI_proto_answer{5} = t.proto_answer_5;
            end
        end
    catch
    end
    
    if isempty(EMG_fMRI_study_dir) 
        EMG_fMRI_study_dir = 'Please choose the study directory';
    end
    if isempty(EMG_fMRI_proto_answer) 
        EMG_fMRI_proto_answer = cell(1,5);
    end

    set(handles.studytitle,'String',EMG_fMRI_study);
    set(handles.number,'String',EMG_fMRI_patient);
    set(handles.text_dir,'String',EMG_fMRI_study_dir);
    set(handles.proto1,'String',EMG_fMRI_proto_answer{1});
    set(handles.proto2,'String',EMG_fMRI_proto_answer{2});
    set(handles.proto3,'String',EMG_fMRI_proto_answer{3});
    set(handles.proto4,'String',EMG_fMRI_proto_answer{4});
    set(handles.proto5,'String',EMG_fMRI_proto_answer{5});


    % UIWAIT makes select_dataset wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

% -- returns logical 1 if var 'v' exist and is not empty
function b = var_has_value(v)
    if exist(v,'var')
        b = isempty(eval(v));
    else
        b = false; %logical(0)
    end

% --- Outputs from this function are returned to the command line.
function varargout = select_dataset_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % Get default command line output from handles structure
    varargout{1} = handles.output;


function studytitle_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function studytitle_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function number_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function number_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)

    emg_fmri_globals; % make sure this is the first call in the fn
    
    %if strcmp(handles.studytitle,'title') && strcmp(handles.number,'number')
     %  foutmelding()

    % 2009-08-19, Paul tweaked the following to remove some weird constructions...
    studyt = get(handles.studytitle,'String');
    studyn = get(handles.number,'String');
    studyd = get(handles.text_dir,'String');
    studyp = cell(1,5);
    studyp{1} = get(handles.proto1,'String');
    studyp{2} = get(handles.proto2,'String');
    studyp{3} = get(handles.proto3,'String');
    studyp{4} = get(handles.proto4,'String');
    studyp{5} = get(handles.proto5,'String');

    % paul inserted some basic validity/sanity checks...
    msg=[];
    if     isempty(findstr(studyd,'fMRI'));     studyd = fullfile(studyd,'fMRI',studyt);
    elseif isempty(findstr(studyd,studyt));     studyd = fullfile(studyd, studyt);
    end
    if     isempty(studyt); msg='Require study name'; 
    elseif isempty(studyn); msg='Require patient ID'; 
    elseif isempty(studyd); msg='Require study data directory'; 
    elseif isempty(findstr(studyd,'Onderzoek')); msg='Require subdirectory ''Onderzoek'''; 
    elseif isempty(regexp(studyd, '(^.*)([\\/]fMRI[\\/])', 'once', 'ignorecase' )); msg='Require subdirectory ''fMRI'''; 
    elseif ~exist(studyd,'dir'); msg='Study directory doesn''t exist';
    end
    
    % also make sure that we can assemble the root of the study by appending the study name to the fMRI folder
    if isempty(msg)
        studyd=[regexprep(studyd, '(^.*)([\\/]fMRI[\\/].*)', '$1', 'once', 'ignorecase') '/fMRI/' studyt '/'];
        if ~exist(studyd,'dir'); msg=['Study directory doesn''t exist: ' studyd]; end
    end
    
    if ~isempty(msg)
        warning(msg)
        warndlg(msg)
    else

        % copy to globals
        EMG_fMRI_study = studyt;
        EMG_fMRI_patient = studyn;
        EMG_fMRI_study_dir = studyd;
        EMG_fMRI_proto_answer = studyp;

        % 2009-08-17, Paul added some code to save user settings to registry
        if ispc 
            % save parameters to registry
            strRegistryKey = 'AMC\KNF\EMG_fMRI\laststudy';
            t = struct('study',studyt, ...
                'patient',studyn, ...
                'study_dir',studyd, ...
                'proto_answer_1',studyp{1}, ...
                'proto_answer_2',studyp{2}, ...
                'proto_answer_3',studyp{3}, ...
                'proto_answer_4',studyp{4}, ...
                'proto_answer_5',studyp{5});
            settings(strRegistryKey,t);
        end

        close % paul inserted close 
        % call the controle GUI
        select_dataset_confirmation()

        % removed by paul: no need to copy GUI elements
        % % get the controle handle (access to the gui)
        % mainGUIhandle       = input_function_check;       
        % % get the data from the gui (all handles inside gui_main)
        % mainGUIdata         = guidata(input_function_check);
        %  
        % % change gui strings
        % set(mainGUIdata.studytitle, 'String', get(handles.studytitle, 'String'));
        % set(mainGUIdata.number, 'String', get(handles.number, 'String'));
        % 
        %  
        % % save changed data back into controle
        % guidata(input_function_check, mainGUIdata);
        % 
    end

% --- Executes on button press in resetbutton.
function resetbutton_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    set(handles.studytitle,'String','title');
    set(handles.number,'String','number');
    set(handles.text_dir,'String','Please choose the study directory');

    set(handles.proto1,'String','');
    set(handles.proto2,'String','');
    set(handles.proto3,'String','');
    set(handles.proto4,'String','');
    set(handles.proto5,'String','');

    % reset globals
    EMG_fMRI_study = [];
    EMG_fMRI_patient = [];
    EMG_fMRI_study_dir = [];
    EMG_fMRI_proto_answer = [];

    guidata(hObject, handles);


% --- Executes on button press in select_dir.
function select_dir_Callback(hObject, eventdata, handles)

    select_dir = uigetdir(get(handles.text_dir,'String'), 'Select the study directory');
    %assignin('base', 'EMG_fMRI_study_dir',select_dir); not yet (by paul)
    if select_dir~=0
        set(handles.text_dir,'String',select_dir);
    end


function study_dir_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function study_dir_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function proto1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function proto1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function proto2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function proto2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function proto3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function proto3_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function proto4_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function proto4_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function proto5_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function proto5_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
