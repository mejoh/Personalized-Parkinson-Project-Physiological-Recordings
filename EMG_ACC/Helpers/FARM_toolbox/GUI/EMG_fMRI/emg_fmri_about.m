function varargout = emg_fmri_about(varargin)
% EMG_FMRI_ABOUT M-file for emg_fmri_about.fig
%      EMG_FMRI_ABOUT, by itself, creates a new EMG_FMRI_ABOUT or raises the existing
%      singleton*.
%
%      H = EMG_FMRI_ABOUT returns the handle to a new EMG_FMRI_ABOUT or the handle to
%      the existing singleton*.
%
%      EMG_FMRI_ABOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMG_FMRI_ABOUT.M with the given input arguments.
%
%      EMG_FMRI_ABOUT('Property','Value',...) creates a new EMG_FMRI_ABOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emg_fmri_about_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emg_fmri_about_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emg_fmri_about

% Last Modified by GUIDE v2.5 10-Nov-2009 14:59:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @emg_fmri_about_OpeningFcn, ...
                   'gui_OutputFcn',  @emg_fmri_about_OutputFcn, ...
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


% --- Executes just before emg_fmri_about is made visible.
function emg_fmri_about_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for emg_fmri_about
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes emg_fmri_about wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = emg_fmri_about_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    close
