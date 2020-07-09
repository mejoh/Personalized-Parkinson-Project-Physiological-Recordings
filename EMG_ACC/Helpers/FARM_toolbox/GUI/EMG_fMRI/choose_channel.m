function varargout = choose_channel(varargin)
% CHOOSE_CHANNEL M-file for choose_channel.fig
%      CHOOSE_CHANNEL, by itself, creates a new CHOOSE_CHANNEL or raises the existing
%      singleton*.
%
%      H = CHOOSE_CHANNEL returns the handle to a new CHOOSE_CHANNEL or the handle to
%      the existing singleton*.
%
%      CHOOSE_CHANNEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSE_CHANNEL.M with the given input arguments.
%
%      CHOOSE_CHANNEL('Property','Value',...) creates a new CHOOSE_CHANNEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before choose_channel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to choose_channel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help choose_channel

% Last Modified by GUIDE v2.5 04-Oct-2009 22:35:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @choose_channel_OpeningFcn, ...
                   'gui_OutputFcn',  @choose_channel_OutputFcn, ...
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


% --- Executes just before choose_channel is made visible.
function choose_channel_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % for EEG; make surethis is the first line in this fn
    
    % store the extra arguments (sould be callback function and handles of calling window)
    set(hObject,'UserData',varargin);

    % Choose default command line output for choose_channel
    handles.output = hObject;
    set(handles.channel_select,'SelectionChangeFcn',@channel_select_SelectionChangeFcn);

    % Set standard channel in workspace to be 8.
    handles.channel = 8; 

    % Set standard channel names in the GUI
    set(handles.text2,'String',EEG.chanlocs(1).labels);
    set(handles.text3,'String',EEG.chanlocs(2).labels);
    set(handles.text4,'String',EEG.chanlocs(3).labels);
    set(handles.text5,'String',EEG.chanlocs(4).labels);
    set(handles.text6,'String',EEG.chanlocs(5).labels);
    set(handles.text7,'String',EEG.chanlocs(6).labels);
    set(handles.text8,'String',EEG.chanlocs(7).labels);
    set(handles.text9,'String',EEG.chanlocs(8).labels);

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes choose_channel wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = choose_channel_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in btn_ok.
function btn_ok_Callback(hObject, eventdata, handles)
    % get user defined callback info before closing the figure
    callback_info = get(handles.figure1,'UserData');
    
    %close the GUI choose_channel 
    close
    
    % call the user defined callback to update the chosen channel
    if size(callback_info,2)==2
        fn = callback_info{1};
        cb_handles = callback_info{2};
        fn(cb_handles, handles.channel);
    end


function channel_select_SelectionChangeFcn(hObject, eventdata)
     %retrieve GUI data, i.e. the handles structure
    handles = guidata(hObject); 

    % assume the tag has a sequential channel number at the end
    tag = get(eventdata.NewValue,'Tag');
    handles.channel = str2double(tag(end));

    %updates the handles structure
    guidata(hObject, handles);
