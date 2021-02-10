function varargout = AccEmgChecker_includingcolorscaleimage(varargin)
% NOTE - It is necessary to also download the AccEmgChecker_includingcolorscaleimage.fig

% This gui provides an efficient way to loop though all the powerspectra images and define presence of tremor and if the corrected peak was selected. 
% Per image, the user has the option to define the selected peak as right/not right/unclear and the tremor as present/not present/unclear.
% The output is a xlsx and mat table for Tremor and Peak data separately. 
% Here is the image name shown accomponied by 0 (no tremor or not the right peak is selected, 1 (tremor or right peak selected) or 2(unclear). 
% This allows a clear overview of the data. 

% Important to change user settings!


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @AccEmgChecker_includingcolorscaleimage_OpeningFcn, ...
    'gui_OutputFcn',  @AccEmgChecker_includingcolorscaleimage_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before AccEmgChecker_includingcolorscaleimage is made visible.
function AccEmgChecker_includingcolorscaleimage_OpeningFcn(hObject, eventdata, handles, varargin)

%% OS CHECK
if ispc
    pfProject="P:\";
elseif isunix
    pfProject="/project/";
else
    warning('Platform not supported - Linux settings are used')
    pfProject="/project/";
end

%%%%%%%%%%%%%%%%%%--------------------------- START USER SETTINGS
Task="rest";
handles.savedir = fullfile(pfProject, "3022026.01", "analyses", "EMG", Task, "manually_checked", "Freek");
handles.filesDir = fullfile(pfProject, "3022026.01", "analyses", "EMG", Task, "automaticdir") ;
%%%%%%%%%%%%%%%%%%--------------------------- END USER SETTINGS

% Choose default command line output for AccEmgChecker_includingcolorscaleimage
handles.output = hObject;

%% OS CHECK
AllFiles = struct2table(dir(handles.filesDir));
handles.files = fullfile(AllFiles.folder(3:end), AllFiles.name(3:end));
Img = imread(handles.files{1});
axes(handles.axes1);
imshow(Img);

handles.Peak.cVal = [] ;
handles.Peak.cName = [] ;
handles.Tremor.cVal = [] ;
handles.Tremor.cName = [] ;

handles.index = 1;
Cek(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = AccEmgChecker_includingcolorscaleimage_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------- Prev and Next Sub buttons -----%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in PrevSub.
function PrevSub_Callback(hObject, eventdata, handles)
handles.output = hObject;
handles.index = handles.index - 1;
Cek(hObject, eventdata, handles);
Img = imread(handles.files{handles.index});
axes(handles.axes1);
imshow(Img);
guidata(hObject, handles);


% --- Executes on button press in NextSub.
function NextSub_Callback(hObject, eventdata, handles)
handles.output = hObject;
handles.index = handles.index + 1;
Cek(hObject, eventdata, handles);
Img = imread(handles.files{handles.index});
axes(handles.axes1);
imshow(Img);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------Cek function to display img-------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Cek(hObject, eventdata, handles)
handles.output = hObject;
n = length(handles.files);
if handles.index > 1
    set(handles.PrevSub,'enable','on');
else
    set(handles.PrevSub,'enable','off');
end
if handles.index < n
    set(handles.NextSub,'enable','on');
else
    set(handles.NextSub,'enable','off');
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------Button presses Tremor -------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If tremor, than 1
% If no tremor, than 0.
% If unsure tremor, than 2.


% --- Executes on button press in TremorN.
function TremorN_Callback(hObject, eventdata, handles)
Cek(hObject, eventdata, handles);
handles.Tremor.cVal(handles.index,1) = 0;
handles.Tremor.cName{handles.index,1} = handles.files{handles.index};
guidata(hObject, handles);

% --- Executes on button press in TremorY.
function TremorY_Callback(hObject, eventdata, handles)
Cek(hObject, eventdata, handles);
handles.Tremor.cVal(handles.index,1) = 1;
handles.Tremor.cName{handles.index,1} = handles.files{handles.index};
guidata(hObject, handles);


% --- Executes on button press in TremorU.
function TremorU_Callback(hObject, eventdata, handles)
Cek(hObject, eventdata, handles);
handles.Tremor.cVal(handles.index,1) = 2;
handles.Tremor.cName{handles.index,1} = handles.files{handles.index};
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------Button presses Peak-------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If correct peak was selected, than 1
% If not the correct peak was selected, than 0.
% If you are unsure that the correct peak was selected, than 2.

% --- Executes on button press in PeakN.
function PeakN_Callback(hObject, eventdata, handles)
Cek(hObject, eventdata, handles);
handles.Peak.cVal(handles.index,1) = 0;
handles.Peak.cName{handles.index,1} = handles.files{handles.index};
guidata(hObject, handles);


% --- Executes on button press in PeakY.
function PeakY_Callback(hObject, eventdata, handles)
Cek(hObject, eventdata, handles);
handles.Peak.cVal(handles.index,1) = 1;
handles.Peak.cName {handles.index,1} = handles.files{handles.index};
guidata(hObject, handles);



% --- Executes on button press in PeakU.
function PeakU_Callback(hObject, eventdata, handles)
Cek(hObject, eventdata, handles);
handles.Peak.cVal(handles.index,1) = 2;
handles.Peak.cName {handles.index,1}= handles.files{handles.index};
guidata(hObject, handles);



% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
Cek(hObject, eventdata, handles);
guidata(hObject, handles);
Tremor_check = struct2table(handles.Tremor);
Peak_check = struct2table(handles.Peak);

if ~exist(handles.savedir,'dir');mkdir(handles.savedir);end
writetable (Tremor_check, fullfile(handles.savedir, ['Tremor_check-' date '.csv']));
writetable (Peak_check, fullfile(handles.savedir, ['Peak_check-' date '.csv']));
save (fullfile(handles.savedir, ['Tremor_check-' date '.mat']), 'Tremor_check');
save (fullfile(handles.savedir, ['Peak_check-' date '.mat']), 'Peak_check');
disp 'Data is saved'

% --- Executes during object creation, after setting all properties.
function edit3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


