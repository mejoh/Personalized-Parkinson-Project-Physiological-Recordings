function varargout = select_dataset_confirmation(varargin)
% SELECT_DATASET_CONFIRMATION M-file for select_dataset_confirmation.fig
%      SELECT_DATASET_CONFIRMATION, by itself, creates a new SELECT_DATASET_CONFIRMATION or raises the existing
%      singleton*.
%
%      H = SELECT_DATASET_CONFIRMATION returns the handle to a new SELECT_DATASET_CONFIRMATION or the handle to
%      the existing singleton*.
%
%      SELECT_DATASET_CONFIRMATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_DATASET_CONFIRMATION.M with the given input arguments.
%
%      SELECT_DATASET_CONFIRMATION('Property','Value',...) creates a new SELECT_DATASET_CONFIRMATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_dataset_confirmation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_dataset_confirmation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_dataset_confirmation

% Last Modified by GUIDE v2.5 02-Nov-2009 11:17:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @select_dataset_confirmation_OpeningFcn, ...
                   'gui_OutputFcn',  @select_dataset_confirmation_OutputFcn, ...
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


% --- Executes just before select_dataset_confirmation is made visible.
function select_dataset_confirmation_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % Choose default command line output for select_dataset_confirmation
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    try
        set(handles.studytitle,'String',EMG_fMRI_study);
        set(handles.number,'String',EMG_fMRI_patient);
        set(handles.text_dir,'String',EMG_fMRI_study_dir);

        set(handles.text13,'String',EMG_fMRI_proto_answer{1});
        set(handles.text14,'String',EMG_fMRI_proto_answer{2});
        set(handles.text15,'String',EMG_fMRI_proto_answer{3});
        set(handles.text16,'String',EMG_fMRI_proto_answer{4});
        set(handles.text17,'String',EMG_fMRI_proto_answer{5});
        
        % paul inserted some additional checks here
        
        % 2009-08-19: (Paul) some routines require the Signal Processing Toolbox, so better check it now...
        result = license('test','signal_toolbox');
        set(handles.checkbox_signal_processing, 'Value', result);
        if result
            set(handles.msg_signal_processing,'String', 'license found');
        else
            set(handles.msg_signal_processing,'String','license not found');
            set(handles.msg_signal_processing,'ForegroundColor','red');
        end

        % 2009-10-03: (Paul) check SPM version
        if exist('spm.m','file')
            spm_version = spm('Ver');
            result = 1;
        else
            spm_version = 'install from www.fil.ion.ucl.ac.uk/spm';
            result = 0;
            set(handles.msg_spm_version,'ForegroundColor','red');
        end
        set(handles.checkbox_spm_version, 'Value', result);
        set(handles.msg_spm_version, 'String', spm_version);
        
        % 2009-10-03: (Paul) check r2agui tool
        if exist('r2agui.m','file')
            message = 'OK';
            result = 1;
        else
            message = 'install from r2agui.sourceforge.net';
            result = 0;
            set(handles.msg_r2agui,'ForegroundColor','red');
        end
        set(handles.checkbox_r2agui, 'Value', result);
        set(handles.msg_r2agui, 'String', message);
        
        % 2009-10-01: (Paul) make sure the parameter files exist; if not: create them on the fly
        if exist(EMG_fMRI_study_dir,'dir')
            [ result, message ] = MakeParameterFiles( EMG_fMRI_study_dir, EMG_fMRI_patient );
            set(handles.checkbox_parameter_files, 'Value', result);
            set(handles.msg_parameter_files, 'String', message);
            if ~result
                set(handles.msg_parameter_files,'ForegroundColor','red');
            end
        end
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        % getReport(ME) %only works with R2007+ in combination with catch ME
       
        
        set(handles.studytitle,'String','title');
        set(handles.number,'String','number');
        set(handles.text_dir,'String','Please choose the study directory');
        % reset globals
%         EMG_fMRI_study = [];
%         EMG_fMRI_patient = [];
%         EMG_fMRI_study_dir = [];
        set(handles.text13,'String','');
        set(handles.text14,'String','');
        set(handles.text15,'String','');
        set(handles.text16,'String','');
        set(handles.text17,'String','');
    end


% UIWAIT makes select_dataset_confirmation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = select_dataset_confirmation_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
    %close(input_function) removed by paul
    close

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
    % Go back to voorbewerking
    close
    input_function()

% --- Executes on button press in checkbox_parameter_files.
function checkbox_parameter_files_Callback(hObject, eventdata, handles)

% --- Executes on button press in checkbox_signal_processing.
function checkbox_signal_processing_Callback(hObject, eventdata, handles)

% --- Executes on button press in checkbox_spm_version.
function checkbox_spm_version_Callback(hObject, eventdata, handles)

% --- Executes on button press in checkbox_r2agui.
function checkbox_r2agui_Callback(hObject, eventdata, handles)
