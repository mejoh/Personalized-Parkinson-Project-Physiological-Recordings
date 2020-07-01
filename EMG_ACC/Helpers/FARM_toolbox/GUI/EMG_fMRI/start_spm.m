function varargout = start_spm(varargin)
% START_SPM M-file for start_spm.fig
%      START_SPM, by itself, creates a new START_SPM or raises the existing
%      singleton*.
%
%      H = START_SPM returns the handle to a new START_SPM or the handle to
%      the existing singleton*.
%
%      START_SPM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in START_SPM.M with the given input arguments.
%
%      START_SPM('Property','Value',...) creates a new START_SPM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before start_spm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to start_spm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help start_spm

% Last Modified by GUIDE v2.5 02-Jun-2009 15:51:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @start_spm_OpeningFcn, ...
                   'gui_OutputFcn',  @start_spm_OutputFcn, ...
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


% --- Executes just before start_spm is made visible.
function start_spm_OpeningFcn(hObject, eventdata, handles, varargin)
    if ~exist('spm.m','file')
        set(handles.pushbutton1,'Enable','off');
        set(handles.text1,'String','SPM not installed');
    else
        spm_version = spm('Ver');
        set(handles.text1,'String',sprintf('Start %s?',spm_version));
    end
    % Choose default command line output for start_spm
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes start_spm wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = start_spm_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    spm fmri
    close

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    close
