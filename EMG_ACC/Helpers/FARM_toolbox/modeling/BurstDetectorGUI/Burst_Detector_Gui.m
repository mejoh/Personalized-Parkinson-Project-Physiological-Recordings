function varargout = Burst_Detector_Gui(varargin)
% BURST_DETECTOR_GUI M-file for Burst_Detector_Gui.fig
%      BURST_DETECTOR_GUI, by itself, creates a new BURST_DETECTOR_GUI or raises the existing
%      singleton*.
%
%      H = BURST_DETECTOR_GUI returns the handle to a new BURST_DETECTOR_GUI or the handle to
%      the existing singleton*.
%
%      BURST_DETECTOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BURST_DETECTOR_GUI.M with the given input arguments.
%
%      BURST_DETECTOR_GUI('Property','Value',...) creates a new BURST_DETECTOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Burst_Detector_Gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Burst_Detector_Gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Burst_Detector_Gui

% Last Modified by GUIDE v2.5 28-Sep-2009 13:29:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Burst_Detector_Gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Burst_Detector_Gui_OutputFcn, ...
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


% --- Executes just before Burst_Detector_Gui is made visible.
function Burst_Detector_Gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Burst_Detector_Gui (see VARARGIN)

% Choose default command line output for Burst_Detector_Gui
handles.output = hObject;

% initiualize some vals.
set(handles.edit_VOmit,'string','[-0.050 0.050]');
set(handles.edit_condOmit,'string','[0.1 -0.1;1.0 -1.0;1.0 -1.0]');
set(handles.edit_thresh,'string','[6 2;4 2;4 2]');
set(handles.edit_cutoff,'string','[0.025 Inf Inf;0.025 Inf Inf;0.025 Inf Inf]');
set(handles.edit_upcutoff,'string','[Inf Inf Inf;Inf Inf Inf;Inf Inf Inf]');

handles.usr.burstnumber=0;



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Burst_Detector_Gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Burst_Detector_Gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_todo.
function listbox_todo_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_todo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_todo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_todo

% if you press this function, make a plot!

burstid=handles.usr.in.tmpdata.shufflemat{1}(get(hObject,'Value'),4);
set(handles.edit_distance,'string','0');
update_axes(handles,burstid);






% --- Executes during object creation, after setting all properties.
function listbox_todo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_todo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_use.
function listbox_use_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_use (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_use contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_use
burstid=handles.usr.in.tmpdata.shufflemat{3}(get(hObject,'Value'),4);
set(handles.edit_distance,'string','0');
update_axes(handles,burstid);



% --- Executes during object creation, after setting all properties.
function listbox_use_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_use (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_omit.
function listbox_omit_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_omit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_omit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_omit
burstid=handles.usr.in.tmpdata.shufflemat{2}(get(hObject,'Value'),4);
set(handles.edit_distance,'string','0');
update_axes(handles,burstid);




% --- Executes during object creation, after setting all properties.
function listbox_omit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_omit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_runDetection.
function pushbutton_runDetection_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_runDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% first get all of the needed data from handles.

params=struct('VOmit',[],'condOmit',[],'thresh',[],'cutoff',[],'doMuscles',[],'upcutoff',[]);
pfields=fieldnames(params);

for i=1:numel(pfields) 
    params.(pfields{i}) = str2num(get(handles.(['edit_' pfields{i}]),'string'));
end


% and now... DO THE DETECTION!
% define our params
params2.b=handles.usr.in.b;
params2.e=handles.usr.in.e;
params2.Vmarker=[handles.usr.in.EEG.event(find(strcmp({handles.usr.in.EEG.event(:).type},'V'))).latency];
if isfield(handles.usr.in,'m')
params2.badparts=handles.usr.in.m;
else
    params2.badparts=[];
end
params2.srate=handles.usr.in.srate;
params2.totpoints=size(handles.usr.in.EEG.data,2);
params2.VOmit=str2num(get(handles.edit_VOmit,'string'));
params2.condOmit=str2num(get(handles.edit_condOmit,'string'));
params2.doMuscles=str2num(get(handles.edit_doMuscles,'string'));
params2.thresh=str2num(get(handles.edit_thresh,'string'));

data=handles.usr.in.EEG.data;
mode=handles.usr.in.mode;




vec=emg_make_eligibility_vector_gui(params2);
bursts=emg_do_detection_gui(data,mode,vec,params2);
bursts2=emg_transform_marker_backwards_gui(bursts,vec,data); 

disp('calculating event properties (duration, amplitude, area)');
srate=handles.usr.in.EEG.srate;
bursts3=emg_calculate_burst_properties(bursts2,data,mode,srate);

bursts=bursts3;

% and now... save it to bursts.mat, and store it in handles.usr.in.bursts.
handles.usr.in.bursts=bursts;
save([handles.usr.pathname 'bursts.mat'],'bursts');
set(handles.edit_burstsFile,'string',[handles.usr.pathname 'bursts.mat']);
disp('saved bursts.mat...');

guidata(hObject,handles);






function edit_thresholds_Callback(hObject, eventdata, handles)
% hObject    handle to edit_thresholds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_thresholds as text
%        str2double(get(hObject,'String')) returns contents of edit_thresholds as a double


% --- Executes during object creation, after setting all properties.
function edit_thresholds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_thresholds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_eeglabFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_eeglabFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_eeglabFile as text
%        str2double(get(hObject,'String')) returns contents of edit_eeglabFile as a double


% --- Executes during object creation, after setting all properties.
function edit_eeglabFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_eeglabFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_reportFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_reportFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_reportFile as text
%        str2double(get(hObject,'String')) returns contents of edit_reportFile as a double


% --- Executes during object creation, after setting all properties.
function edit_reportFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_reportFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_bad_signalFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bad_signalFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_bad_signalFile as text
%        str2double(get(hObject,'String')) returns contents of edit_bad_signalFile as a double


% --- Executes during object creation, after setting all properties.
function edit_bad_signalFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bad_signalFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_writeEvents.
function pushbutton_writeEvents_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_writeEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    



% --- Executes on button press in pushbutton_use.
function pushbutton_use_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_use (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_distance,'string','0');
shufflemat=handles.usr.in.tmpdata.shufflemat;
todomat=shufflemat{1};
omitmat=shufflemat{2};
usemat=shufflemat{3};
bursts=handles.usr.in.tmpdata.bursts;
% get the id of shufflemat{1}
value=get(handles.listbox_todo,'value');

% now.. say it is 'accepted' ... first get the correct burst from tmpdata.
entry=todomat(value,:);
ch=entry(2);
burstnumber=entry(4);
tmpburstn=find([bursts{entry(2)}.burstnumber]==burstnumber);
bursts{ch}(tmpburstn).verdict=5; % approve it!
handles.usr.in.tmpdata.bursts=bursts;

% now change the entry...
entry(5)=5; % 5 = manual accept!

% now change the shufflemats.
todomat(value,:) = []; % remove from todomat.

usemat=[usemat;entry];
usemat=sortrows(usemat,4);
newval=find(usemat(:,4)==burstnumber);
set(handles.listbox_use,'value',newval);
% usemat(:,1)=1:size(usemat,1);
% todomat(:,1)=1:size(todomat,1);

if value>size(todomat,1)
    value=value-1;
    set(handles.listbox_todo,'value',value);
    set(handles.listbox_todo,'string',num2str(todomat));
end

if size(todomat,1)==0
    value=1;
    set(handles.listbox_todo,'value',value);
    set(handles.listbox_todo,'string','empty!');
    update_axes(handles,entry(4));
    
else
    set(handles.listbox_todo,'string',num2str(todomat));
end

% and also update the listboxes.
set(handles.listbox_use,'string',num2str(usemat));
set(handles.listbox_omit,'string',num2str(omitmat));


% and update information in handles.
handles.usr.in.tmpdata.shufflemat={todomat,omitmat,usemat};


if size(todomat,1)>0
    newburst=todomat(value,4);
    update_axes(handles,newburst);
end

guidata(hObject,handles);









% --- Executes on button press in pushbutton_omit.
function pushbutton_omit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_omit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_distance,'string','0');
shufflemat=handles.usr.in.tmpdata.shufflemat;
todomat=shufflemat{1};
omitmat=shufflemat{2};
usemat=shufflemat{3};
bursts=handles.usr.in.tmpdata.bursts;
% get the id of shufflemat{1}
value=get(handles.listbox_todo,'value');

% now.. say it is 'accepted' ... first get the correct burst from tmpdata.
entry=todomat(value,:);
ch=entry(2);
burstnumber=entry(4);
tmpburstn=find([bursts{entry(2)}.burstnumber]==burstnumber);
bursts{ch}(tmpburstn).verdict=4; % reject it (manually)!
handles.usr.in.tmpdata.bursts=bursts;

% now change the entry...
entry(5)=4; % 5 = manual accept!

% now change the shufflemats.
todomat(value,:) = []; % remove from todomat.


omitmat=[entry;omitmat];



if value>size(todomat,1)
    value=value-1;
    set(handles.listbox_todo,'value',value);
    set(handles.listbox_todo,'string',num2str(todomat));
end

if size(todomat,1)==0
    value=1;
    set(handles.listbox_todo,'value',value);
    set(handles.listbox_todo,'string','empty!');
    update_axes(handles,entry(4));
    
else
    set(handles.listbox_todo,'string',num2str(todomat));
end

% and also update the listboxes.
set(handles.listbox_use,'string',num2str(usemat));
set(handles.listbox_omit,'string',num2str(omitmat));


% and update information in handles.
handles.usr.in.tmpdata.shufflemat={todomat,omitmat,usemat};


if size(todomat,1)>0
    newburst=todomat(value,4);
    update_axes(handles,newburst);
end

set(handles.listbox_omit,'value',1);
guidata(hObject,handles);




% --- Executes on button press in pushbutton_use2omit.
function pushbutton_use2omit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_use2omit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_distance,'string','0');
shufflemat=handles.usr.in.tmpdata.shufflemat;
todomat=shufflemat{1};
omitmat=shufflemat{2};
usemat=shufflemat{3};
bursts=handles.usr.in.tmpdata.bursts;
% get the id of shufflemat{1}
value=get(handles.listbox_use,'value');

% now.. say it is 'accepted' ... first get the correct burst from tmpdata.
entry=usemat(value,:);
ch=entry(2);
burstnumber=entry(4);
tmpburstn=find([bursts{entry(2)}.burstnumber]==burstnumber);
bursts{ch}(tmpburstn).verdict=4; % reject it (manually)!
handles.usr.in.tmpdata.bursts=bursts;

% now change the entry...
entry(5)=4; % 5 = manual reject!

% now change the shufflemats.
usemat(value,:) = []; % remove from todomat.


omitmat=[entry;omitmat];
% omitmat=sortrows(omitmat,4);
% usemat(:,1)=1:size(usemat,1);
% todomat(:,1)=1:size(todomat,1);

if value>size(usemat,1)
    value=value-1;
    set(handles.listbox_use,'value',value);
    set(handles.listbox_use,'string',num2str(usemat));
end

if size(usemat,1)==0
    value=1;
    set(handles.listbox_use,'value',value);
    set(handles.listbox_use,'string','empty!');
    update_axes(handles,entry(4));
    
else
    set(handles.listbox_use,'string',num2str(usemat));
end

% and also update the listboxes.
set(handles.listbox_todo,'string',num2str(todomat));
set(handles.listbox_omit,'string',num2str(omitmat));


% and update information in handles.
handles.usr.in.tmpdata.shufflemat={todomat,omitmat,usemat};


% also, update the axes again.


if size(usemat,1)>0
    newburst=usemat(value,4);
    update_axes(handles,newburst);
end

set(handles.listbox_omit,'value',1);
guidata(hObject,handles);



% --- Executes on button press in pushbutton_omit2use.
function pushbutton_omit2use_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_omit2use (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_distance,'string','0');
shufflemat=handles.usr.in.tmpdata.shufflemat;
todomat=shufflemat{1};
omitmat=shufflemat{2};
usemat=shufflemat{3};
bursts=handles.usr.in.tmpdata.bursts;
% get the id of shufflemat{1}
value=get(handles.listbox_omit,'value');

% now.. say it is 'accepted' ... first get the correct burst from tmpdata.
entry=omitmat(value,:);
ch=entry(2);
burstnumber=entry(4);
tmpburstn=find([bursts{entry(2)}.burstnumber]==burstnumber);
bursts{ch}(tmpburstn).verdict=5; % reject it (manually)!
handles.usr.in.tmpdata.bursts=bursts;

% now change the entry...
entry(5)=5; % 5 = manual accept (after all)!

% now change the shufflemats.
omitmat(value,:) = []; % remove from omitmat.


usemat=[usemat;entry];
usemat=sortrows(usemat,4);
newval=find(usemat(:,4)==burstnumber);
set(handles.listbox_use,'value',newval);
% usemat(:,1)=1:size(usemat,1);
% todomat(:,1)=1:size(todomat,1);

if value>size(omitmat,1)
    value=value-1;
    set(handles.listbox_omit,'value',value);
    set(handles.listbox_omit,'string',num2str(omitmat));
end

if size(omitmat,1)==0
    value=1;
    set(handles.listbox_omit,'value',value);
    set(handles.listbox_omit,'string','empty!');
    update_axes(handles,entry(4));
    
else
    set(handles.listbox_omit,'string',num2str(omitmat));
end

% and also update the listboxes.
set(handles.listbox_todo,'string',num2str(todomat));
set(handles.listbox_use,'string',num2str(usemat));


% and update information in handles.
handles.usr.in.tmpdata.shufflemat={todomat,omitmat,usemat};


% also, update the axes again.


if size(omitmat,1)>0
    newburst=omitmat(value,4);
    update_axes(handles,newburst);
end

guidata(hObject,handles);



% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    % [filename, pathname, filterindex] = uigetfile;
    filename='emg_corrected.mat';
    pathname=[pwd '/'];

    % look for other files...
    str=[];
    othervars={'eeglab','report','block','mode','parameters','tmpdata','bursts'};
    otherfiles={filename,'report_myo1.mat','markers_block.mat','mode.mat','params.mat','tmpdata.mat','bursts.mat'};
    
    
    for i=1:numel(othervars)
        if exist([pathname otherfiles{i}],'file')
            t=load([pathname otherfiles{i}]);
            
            
            tfields=fieldnames(t);
            for j=1:numel(tfields)
                handles.usr.in.(tfields{j})=t.(tfields{j});
            end

            str=[otherfiles{i} ' loaded... \n'];
            disp(sprintf(str));
            set(handles.(['edit_' othervars{i} 'File']),'string',[pathname otherfiles{i}]);
        else
            disp(['Burst_GUI:file_not_detected: ' otherfiles{i} ' not detected!']);
            set(handles.(['edit_' othervars{i} 'File']),'string','file not found!');
        end
        
    end
    
    % store pathname (for later).
    handles.usr.pathname=pathname;
    
    % see if parameters are stored... and adjust if needed.
    % update list(s).
    if isfield(handles.usr.in,'params')
        fields=fieldnames(handles.usr.in.params);
        for i=1:numel(fields)
            
            % formatting
            try
                tmpstr=num2str(handles.usr.in.params.(fields{i}),'%2g ');
            catch
                keyboard;
            end
            tmpstr2=[];
            for j=1:size(tmpstr,1)
                tmpstr2=[tmpstr2 '; ' tmpstr(j,:)];
            end
            tmpstr2(1)=[];
            tmpstr2=regexprep(tmpstr2,' *',' ');
            tmpstr2=['[' tmpstr2 ']'];
            
            set(handles.(['edit_' fields{i}]),'string',tmpstr2);

        end

    end
    

    
    
    % set muscles...
    set([handles.edit_doMuscles handles.edit_detectSelection],'string',num2str(handles.usr.in.r.myoclonus(1,:)));
        
    
    
    
    if isfield(handles.usr.in,'tmpdata')
       
        shufflemat=handles.usr.in.tmpdata.shufflemat;
        chosenMuscles=handles.usr.in.tmpdata.chosenMuscles;
        chosenConditions=handles.usr.in.tmpdata.chosenConditions;
        % if shufflemat.mat is there, update our listboxes!
        % update_listboxes(handles);
        update_listboxes(handles,shufflemat);
        
        % also update the number under the button 'apply cutoff'.
        
        set(handles.edit_detectSelection,'string',num2str(chosenMuscles));
        set(handles.edit_selectConditions,'string',num2str(chosenConditions));
        
    end
    
    if isfield(handles.usr.in,'EEG');
       
        ev=handles.usr.in.EEG.event;
        % all V markers.
        Vev=ev(strcmp({ev.type},'V'));
        sev=ev(strcmp({ev.type},'s'));
        Vevlat=[Vev.latency];
        sevlat=[sev.latency];
        
        handles.usr.in.Vevlat=Vevlat;
        handles.usr.in.sevlat=sevlat;
        
    end
    
    
    guidata(hObject, handles);

    


function edit_blockFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_blockFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_blockFile as text
%        str2double(get(hObject,'String')) returns contents of edit_blockFile as a double


% --- Executes during object creation, after setting all properties.
function edit_blockFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_blockFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton_runFMRI.
function pushbutton_runFMRI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_runFMRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function edit_VOmit_Callback(hObject, eventdata, handles)
% hObject    handle to edit_VOmit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_VOmit as text
%        str2double(get(hObject,'String')) returns contents of edit_VOmit as a double
VOmit=str2num(get(hObject,'string'));
pathname=handles.usr.pathname;

if exist([pathname 'params.mat'],'file')
    load([pathname 'params.mat']);
end
params.VOmit=VOmit;
handles.usr.in.params=params;
save([pathname 'params.mat'],'params');
disp('saved new VOmit into params.mat');
 



% --- Executes during object creation, after setting all properties.
function edit_VOmit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_VOmit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_condOmit_Callback(hObject, eventdata, handles)
% hObject    handle to edit_condOmit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_condOmit as text
%        str2double(get(hObject,'String')) returns contents of edit_condOmit as a double

condOmit=str2num(get(hObject,'string'));
pathname=handles.usr.pathname;

if exist([pathname 'params.mat'],'file')
    load([pathname 'params.mat']);
end
params.condOmit=condOmit;
handles.usr.in.params=params;
save([pathname 'params.mat'],'params');
disp('saved new condOmit into params.mat');



% --- Executes during object creation, after setting all properties.
function edit_condOmit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_condOmit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Thresh as text
%        str2double(get(hObject,'String')) returns contents of edit_Thresh as a double


thresh=str2num(get(hObject,'string'));
pathname=handles.usr.pathname;

if exist([pathname 'params.mat'],'file')
    load([pathname 'params.mat']);
end
params.thresh=thresh;
handles.usr.in.params=params;
save([pathname 'params.mat'],'params');
disp('saved new thresh into params.mat');



% --- Executes during object creation, after setting all properties.
function edit_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_cutoff_Callback(hObject, eventdata, handles)
% hObject    handle to edit_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_cutoff as text
%        str2double(get(hObject,'String')) returns contents of edit_cutoff as a double


cutoff=str2num(get(hObject,'string'));
pathname=handles.usr.pathname;

if exist([pathname 'params.mat'],'file')
    load([pathname 'params.mat']);
end
params.cutoff=cutoff;
handles.usr.in.params=params;
save([pathname 'params.mat'],'params');
disp('saved new cutoff into params.mat');
% and do a gui function.

guidata(hObject,handles);






% --- Executes during object creation, after setting all properties.
function edit_cutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_cutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_doMuscles_Callback(hObject, eventdata, handles)
% hObject    handle to edit_doMuscles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_doMuscles as text
%        str2double(get(hObject,'String')) returns contents of edit_doMuscles as a double
doMuscles=str2num(get(hObject,'string'));
pathname=handles.usr.pathname;

if exist([pathname 'params.mat'],'file')
    load([pathname 'params.mat']);
end
params.doMuscles=doMuscles;
handles.usr.in.params=params;
save([pathname 'params.mat'],'params');
disp('saved new doMuscles into params.mat');



% --- Executes during object creation, after setting all properties.
function edit_doMuscles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_doMuscles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton_calculateMode.
function pushbutton_calculateMode_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_calculateMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


params=struct('VOmit',[],'condOmit',[],'thresh',[],'cutoff',[],'doMuscles',[]);
pfields=fieldnames(params);

for i=1:numel(pfields) 
    params.(pfields{i}) = str2num(get(handles.(['edit_' pfields{i}]),'string'));
end


% and now... DO THE DETECTION!
% define our params
params2.b=handles.usr.in.b;
params2.e=handles.usr.in.e;
params2.Vmarker=[handles.usr.in.EEG.event(find(strcmp({handles.usr.in.EEG.event(:).type},'V'))).latency];
if isfield(handles.usr.in,'m')
params2.badparts=handles.usr.in.m;
else
    params2.badparts=[];
end
params2.srate=handles.usr.in.EEG.srate;
params2.totpoints=size(handles.usr.in.EEG.data,2);
params2.VOmit=str2num(get(handles.edit_VOmit,'string'));
params2.condOmit=str2num(get(handles.edit_condOmit,'string'));
params2.doMuscles=str2num(get(handles.edit_doMuscles,'string'));

data=handles.usr.in.EEG.data;


% and call the functions.
% segmentation + threshold detection.

vec=emg_make_eligibility_vector_gui(params2);
% keyboard;
mode=emg_calculate_mode_gui(data,vec,params2);

handles.usr.in.mode=mode;
handles.usr.in.params=params;

save([handles.usr.pathname 'mode.mat'],'mode');
save([handles.usr.pathname 'params.mat'],'params');

set(handles.edit_parametersFile,'string',[handles.usr.pathname 'mode.mat']);
set(handles.edit_modeFile,'string',[handles.usr.pathname 'params.mat']);

guidata(hObject,handles);



function edit_modeFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_modeFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_modeFile as text
%        str2double(get(hObject,'String')) returns contents of edit_modeFile as a double


% --- Executes during object creation, after setting all properties.
function edit_modeFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_modeFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_parametersFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_parametersFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_parametersFile as text
%        str2double(get(hObject,'String')) returns contents of edit_parametersFile as a double


% --- Executes during object creation, after setting all properties.
function edit_parametersFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_parametersFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_applyThresh.
function pushbutton_applyThresh_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_applyThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



cutoff=str2num(get(handles.edit_cutoff,'string'));
upcutoff=str2num(get(handles.edit_upcutoff,'string'));

srate=handles.usr.in.EEG.srate;
bursts=handles.usr.in.bursts;
doMuscles=str2num(get(handles.edit_doMuscles,'string'));
doConditions=str2num(get(handles.edit_selectConditions,'string'));

keptchannels=str2num(get(handles.edit_detectSelection,'string'));
omittedchannels=setxor(keptchannels,doMuscles);



if numel(omittedchannels)>0
    
    for i=1:numel(omittedchannels)
        bursts{omittedchannels(i)}(:)=[];
    end
end


for i=1:numel(bursts)
    marked=~ismember([bursts{i}.cond],doConditions);
    bursts{i}(marked)=[];
end
    


% and to all EMG channels.
for i=1:numel(bursts)

    
    for j=1:max([bursts{i}.cond])

        
        % bursts of muscle i that have condition j.
        burstind=find([bursts{i}.cond]==j);
        
        
        
        for k=1:numel(burstind)

            % this is the selection criterion. Pick bursts with
            % characteristics between dx and dy with x duration and y
            % amplitude, divided by the mode-at-those-points.

            
            
            verdict=bursts{i}(burstind(k)).verdict;
            if bursts{i}(burstind(k)).dur<cutoff(j,1)&&...
                    bursts{i}(burstind(k)).amp/bursts{i}(burstind(k)).mode<cutoff(j,2)&&...
                    bursts{i}(burstind(k)).area<cutoff(j,3)
                
                    verdict=1;
                    
            end
            
            if bursts{i}(burstind(k)).dur>upcutoff(j,1)||...
                    bursts{i}(burstind(k)).amp/bursts{i}(burstind(k)).mode>upcutoff(j,2)||...
                    bursts{i}(burstind(k)).area>upcutoff(j,3)

                    verdict=2;
            end
            
            bursts{i}(burstind(k)).verdict=verdict;
            
            
        end
        
    end
    

end




% for the shufflematrix file, this:
% keyboard;
l_total=[bursts{:}];
ind_accepted=find([l_total.verdict]==5);
ind_rejected=intersect(find([l_total.verdict]>0),find([l_total.verdict]<5));
ind_todo=find([l_total.verdict]==0);

disp(sprintf('%d events were detected.\n%d events were automatically rejected.\n%d events are left.',numel(l_total),numel(ind_rejected),numel(ind_todo)));



str={'todo','omit','use'};
mat={[],[],[]};
tmp={ind_todo,ind_rejected,ind_accepted};
for i=1:numel(tmp)
    for j=1:numel(tmp{i})
        ev=l_total(tmp{i}(j));
        mat{i}(j,:)=[j ev.ch ev.cond ev.burstnumber ev.verdict];
    end
    
    set(handles.(['listbox_' str{i}]),'string',num2str(mat{i}));
    
end

shufflemat=mat;


handles.usr.in.tmpdata.shufflemat=shufflemat;
handles.usr.in.tmpdata.bursts=bursts;
handles.usr.in.tmpdata.chosenMuscles=str2num(get(handles.edit_detectSelection,'string'));
handles.usr.in.tmpdata.chosenConditions=str2num(get(handles.edit_selectConditions,'string'));

tmpdata=handles.usr.in.tmpdata;
save([handles.usr.pathname 'tmpdata.mat'],'tmpdata');
disp('file tmpdata.mat saved...');


update_listboxes(handles,shufflemat);
guidata(hObject,handles);




% this is where the fun starts. Now that we have our events, we can throw
% them away if they don't fulfill our criteria.


function edit_burstsFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_burstsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_burstsFile as text
%        str2double(get(hObject,'String')) returns contents of edit_burstsFile as a double


% --- Executes during object creation, after setting all properties.
function edit_burstsFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_burstsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in pushbutton_plotFigures.
function pushbutton_plotFigures_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plotFigures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


bursts=handles.usr.in.bursts;
if isfield(handles.usr.in,'tmpdata')
    bursts=handles.usr.in.tmpdata.bursts;
end

whichfigs=str2num(get(handles.edit_plotMuscles,'string'));
whichconds=str2num(get(handles.edit_plotConds,'string'));


% get thr data... 
cutoff=str2num(get(handles.edit_cutoff,'string'));
upcutoff=str2num(get(handles.edit_upcutoff,'string'));

for i=whichfigs
    
    
    for j=whichconds
        
        b=bursts{i}(find([bursts{i}.cond]==j));
        
        
        
        fh=figure;
        
        ind=[find([b.verdict]==1),find([b.verdict]==2),find([b.verdict]==3),find([b.verdict]==4)];
        
        set(fh,'name',sprintf('muscle %d, condition %d: %d events (%d rejected).',i,j,numel(b)-numel(ind),numel(ind)));
        title(sprintf('muscle %d, condition %d: %d events (%d rejected).',i,j,numel(b)-numel(ind),numel(ind)));
        hold on;
        
              
        
        color={'b','r','m','y','k','g','c'};
        % 'rejected due to dur too low, amp too low, area too low, or
        % manual.
        for k=0:5
            try
                tmp=find([b.verdict]==k);
                if numel(tmp)>0
                    plot([b(tmp).dur],[b(tmp).amp]./[b(tmp).mode],[color{k+1} '.']);
                    
                end
            catch
                keyboard;
            end
        end
        set(gca,'xlim',get(gca,'xlim').*[0 1]);
        set(gca,'ylim',get(gca,'ylim').*[0 1]);
        
        
        % the others...
        
        xlabel('dur [s]');
        ylabel('amp/mode [au (uV/uV)]');
        
        
        line(get(gca,'xlim'),cutoff(j,2)*[1 1],'color','r');
        line(cutoff(j,1)*[1 1],get(gca,'ylim'),'color','r');
        
        line(get(gca,'xlim'),upcutoff(j,2)*[1 1],'color','m');
        line(upcutoff(j,1)*[1 1],get(gca,'ylim'),'color','m');
        
        
        
%         subplot(1,3,1);
%         plot([b.dur]);
%         title('duration, [s]');
% 
%         subplot(1,3,2);
%         plot([b.amp],'r');
%         title('amp, [uV]');
% 
%         subplot(1,3,3);
%         plot([b.area],'k');
%         title('area, [uV*s]');
        
        
        
    end
end







function edit_plotMuscles_Callback(hObject, eventdata, handles)
% hObject    handle to edit_plotMuscles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_plotMuscles as text
%        str2double(get(hObject,'String')) returns contents of edit_plotMuscles as a double
% pushbutton_plotFigures_Callback(hObject, eventdata, handles);
% keyboard;


% --- Executes during object creation, after setting all properties.
function edit_plotMuscles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_plotMuscles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_plotConds_Callback(hObject, eventdata, handles)
% hObject    handle to edit_plotConds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_plotConds as text
%        str2double(get(hObject,'String')) returns contents of edit_plotConds as a double
% pushbutton_plotFigures_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_plotConds_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_plotConds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_upcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to edit_upcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_upcutoff as text
%        str2double(get(hObject,'String')) returns contents of edit_upcutoff as a double

upcutoff=str2num(get(hObject,'string'));
pathname=handles.usr.pathname;

if exist([pathname 'params.mat'],'file')
    load([pathname 'params.mat']);
end
params.upcutoff=upcutoff;
handles.usr.in.params=params;
save([pathname 'params.mat'],'params');
disp('saved new upper cutoff into params.mat');
% and do a gui function.

guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function edit_upcutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_upcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_tmpdataFile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tmpdataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tmpdataFile as text
%        str2double(get(hObject,'String')) returns contents of edit_tmpdataFile as a double


% --- Executes during object creation, after setting all properties.
function edit_tmpdataFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tmpdataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton_writeTemporaryData.
function pushbutton_writeTemporaryData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_writeTemporaryData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function edit_detectSelection_Callback(hObject, eventdata, handles)
% hObject    handle to edit_detectSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_detectSelection as text
%        str2double(get(hObject,'String')) returns contents of edit_detectSelection as a double


% --- Executes during object creation, after setting all properties.
function edit_detectSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_detectSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%*%*%*%*% My own functions, so that this rule is used < 10x.
function update_listboxes(handles,shufflemat)
    
    
    str={'todo','omit','use'};
    for i=1:numel(str)
        set(handles.(['listbox_' str{i}]),'string',num2str(shufflemat{i}));
    end
    
    
    
function update_axes(handles,burstid)
    
    % which is it?
    
    % keyboard;

    set(handles.edit_burstId,'string',num2str(burstid));
    
    allbursts=[handles.usr.in.bursts{:}];
    
    
    % find([allbursts(:).burstnumber]==burstid)
    % find the burst with burstnumber = burstid.
    
    
    b=allbursts(find([allbursts(:).burstnumber]==burstid));
    beginandend=str2num(get(handles.edit_xlim,'string'));
    beginplot=beginandend(1);
    endplot=beginandend(2);
    srate=handles.usr.in.EEG.srate;

    yscale=str2num(get(handles.edit_ylim,'string'));
    ychannels=str2num(get(handles.edit_plotChannels,'string'));
    

    active_channels=str2num(get(handles.edit_detectSelection,'string'));
    

    ah=handles.axes_viewEvent;
    cla(ah);
    srate=handles.usr.in.EEG.srate;
    
    
    xb=round((b.bt+b.et)/2-beginplot*srate);
    xe=round((b.bt+b.et)/2+endplot*srate);
    
    
    % apply additional scrolling...
    extra=round(str2double(get(handles.edit_distance,'string'))*handles.usr.in.EEG.srate);
    
    xb=xb+extra;
    xe=xe+extra;
    

    set(handles.edit_burstOnset,'string',num2str(b.bt/handles.usr.in.EEG.srate));
    set(handles.edit_burstOffset,'string',num2str(b.et/handles.usr.in.EEG.srate));
        
    
    if xb<1
        xb=1;
    end
    if xe>handles.usr.in.EEG.pnts
        xe=handles.usr.in.EEG.pnts;
    end
    
    data=handles.usr.in.EEG.data(ychannels,xb:xe);
    mode=handles.usr.in.mode(ychannels,xb:xe);
    data_h=zeros(size(data));
    data_hf=zeros(size(data));
    
    ylim([0.25 8.75]);
    xlim([xb-numel(xb:xe)/80 xe+numel(xb:xe)/80]);
    
    
    % set box to on!
    box on
    % and while you're at it, also plot V and s markers.
    % first find 

    V=handles.usr.in.Vevlat;
    s=handles.usr.in.sevlat;
    
        
    allV=V(intersect(find(V>xb),find(V<xe)));
    alls=s(intersect(find(s>xb),find(s<xe)));
    
%     for i=1:numel(alls)
%         
%         
%         % line(alls(i)*[1 1],get(gca,'ylim')*[1 0.99;0 0.01],'color',[0.1 0.9 0.1]);
%         % line(alls(i)*[1 1],get(gca,'ylim')*[0.01 0;0.99 1],'color',[0.1 0.9 0.1]);
%         
%     end
    
    for i=1:numel(allV)
        
        line(allV(i)*[1 1],get(gca,'ylim'),'color','k');
        
    end
    
    
    
    tb=handles.usr.in.b;
    if isfield(handles.usr.in.b,'end')
        tb=rmfield(tb,'end');
    end
    fields=fieldnames(tb);
    for i=1:numel(fields)
            
        tstarts=[tb.(fields{i})];
        for j=1:numel(tstarts)
            
            if tstarts(j)>xb&&tstarts(j)<xe
               
                
                text(tstarts(j),get(gca,'ylim')*[0 0.98]',fields{i},'interpreter','none','fontsize',14);
                
            end
        end
    end
    

    
    % filter, hilbert, rectify a little bit.
    for i=1:size(data,1)
        data_h(i,:)=abs(hilbert(data(i,:)));
        data_hf(i,:)=helper_filter(data_h(i,:),25,srate,'low');
        
        d_o=data(i,:);
        d_h=data_h(i,:);
        d_hf=data_hf(i,:);
        d_m=mode(i,:);
        
        % take care of colors; non-'active' == grey.
        plotcolor=[0.5 0.5 0.5];
        
        if ismember(ychannels(i),active_channels)
            plotcolor='b';
        end

        if ychannels(i)==b.ch
            plotcolor=[0.4 0.4 0.4];
        end
        
        yfactor=8.5-(8.5-0.5)/numel(ychannels)*i;
        adjyscale=yscale(ychannels(i))/(2*8/numel(ychannels));

        % plot the line.
        plot(ah,xb:xe,d_h/adjyscale+yfactor,'color',plotcolor);

        % draw extra information around it.
        if ychannels(i)==b.ch
            d_hf=data_hf(i,:);
            % keyboard
            
            d_m=mode(i,:)*b.thresh(1);
            
            
            
            plot(ah,xb:xe,d_hf/adjyscale+yfactor,'k','linewidth',1.5);
            plot(ah,xb:xe,d_m/adjyscale+yfactor,'m');
            % plot(ah,xb:xe,d_o/2/yscale(i)+9-i,'color',[0.7 0.7 0.7]);
        end
    end
        
    
    
    %*%* this is where I plot 'event information'.
    % and now draw boxes indicating an event!
    boxcolors={'b','r','m','y','k','g','c'};

    % get all of the events.
    
    ab=[handles.usr.in.tmpdata.bursts{intersect(ychannels,active_channels)}];     % 'all bursts of active channels'
     
    abind=intersect(find([ab.bt]>xb),find([ab.et]<xe)); 

    ob=ab(abind);             % other bursts in the vincinity!!!

    
    for i=1:numel(ob)

        
        j=find(ychannels==ob(i).ch);
        
        yp_lower=8.5-(8.5-0.5)/numel(ychannels)*(j+0.05);
        yp_upper=8.5-(8.5-0.5)/numel(ychannels)*(j-0.8);
        
        evcolor=boxcolors{ob(i).verdict+1};
        
        xp=[ob(i).bt+[1 1] ob(i).et+[1 1]];
        yp=[yp_upper yp_lower yp_lower yp_upper];
        
        
        % make-a-patch!
        p(i)=fill(xp,yp,evcolor,'edgecolor',evcolor,'FaceAlpha',0);
        
        set(p(i),'buttonDownFcn',sprintf('Burst_Detector_Gui(\''patch_clickEvent_ButtonDownFcn\'',gcf,[],guidata(gcf),%d)',ob(i).burstnumber));
        
        
        % further annotations
        text(xp(2),yp_lower-(8.5-0.5)/numel(ychannels)*0.1,sprintf('%d',ob(i).burstnumber),'fontsize',6);

        
        %line(ob(i).bt*[1 1],[9.5-ob(i).ch 8.8-ob(i).ch],'color',evcolor);
        %line(ob(i).et*[1 1],[9.5-ob(i).ch 8.8-ob(i).ch],'color',evcolor);


    end
    
    
   

    
    
    % and now... take care of the markers!
    musclenames={handles.usr.in.EEG.chanlocs.labels};
    musclenames=musclenames(ychannels);
    set(gca,'ytick',0.5:8/numel(ychannels):7.5);
    set(gca,'yticklabel',musclenames(end:-1:1));

    

    % get some nice muscle informations.
    set(gca,'xtick',xb+(xe-xb)*[0.05 0.20 0.35 0.50 0.65 0.80 0.95]);
    % get some nice time information
    set(gca,'xticklabel',eval(regexprep(num2str((xb+(xe-xb)*[0.05 0.20 0.35 0.50 0.65 0.80 0.95])/srate,'%.1f '),'([\d\.]*) *([\d\.]*) *([\d\.]*) *([\d\.]*) *([\d\.]*) *([\d\.]*) *([\d\.]*) *','{$1, $2, $3, $4, $5, $6, $7}')));
    




function edit_xlim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xlim as text
%        str2double(get(hObject,'String')) returns contents of edit_xlim as a double


% --- Executes during object creation, after setting all properties.
function edit_xlim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ylim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ylim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ylim as text
%        str2double(get(hObject,'String')) returns contents of edit_ylim as a double


% --- Executes during object creation, after setting all properties.
function edit_ylim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ylim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_selectConditions_Callback(hObject, eventdata, handles)
% hObject    handle to edit_selectConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_selectConditions as text
%        str2double(get(hObject,'String')) returns contents of edit_selectConditions as a double


% --- Executes during object creation, after setting all properties.
function edit_selectConditions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_selectConditions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton_scrollForeward.
function pushbutton_scrollForeward_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_scrollForeward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
olddistance=str2double(get(handles.edit_distance,'string'));

extra=str2double(get(handles.edit_Scroll,'string'));
newdistance=olddistance+extra;

set(handles.edit_distance,'string',num2str(newdistance,'%.2g'));

guidata(hObject,handles);

burstid=str2double(get(handles.edit_burstId,'string'));
update_axes(handles,burstid);




function edit_Scroll_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Scroll as text
%        str2double(get(hObject,'String')) returns contents of edit_Scroll as a double


% --- Executes during object creation, after setting all properties.
function edit_Scroll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_scrollBackward.
function pushbutton_scrollBackward_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_scrollBackward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
olddistance=str2double(get(handles.edit_distance,'string'));

extra=str2double(get(handles.edit_Scroll,'string'));
newdistance=olddistance-extra;

set(handles.edit_distance,'string',num2str(newdistance,'%.2g'));

guidata(hObject,handles);

burstid=str2double(get(handles.edit_burstId,'string'));
update_axes(handles,burstid);


function edit_burstOnset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_burstOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_burstOnset as text
%        str2double(get(hObject,'String')) returns contents of edit_burstOnset as a double

newval=str2num(get(hObject,'string'));
newval=round(newval*handles.usr.in.EEG.srate);
burstnumber=handles.usr.burstnumber;

bursts=handles.usr.in.bursts;
tbursts=handles.usr.in.tmpdata.bursts;

for i=1:numel(bursts)
    tmp=bursts{i};
    tmpind=find([tmp.burstnumber]==burstnumber);
    if tmpind>0
        bursts{i}(tmpind).bt=newval;
    end
end
for i=1:numel(tbursts)
    tmp2=tbursts{i};
    tmp2ind=find([tmp2.burstnumber]==burstnumber);
    if tmp2ind>0
        tbursts{i}(tmp2ind).bt=newval;
    end
end

handles.usr.in.bursts=bursts;
handles.usr.in.tmpdata.bursts=tbursts;
guidata(hObject,handles);

update_axes(handles,burstnumber);





% --- Executes during object creation, after setting all properties.
function edit_burstOnset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_burstOnset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_addNewBurst_Callback(hObject, eventdata, handles)
% hObject    handle to edit_addNewBurst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_addNewBurst as text
%        str2double(get(hObject,'String')) returns contents of edit_addNewBurst as a double

vals=str2num(get(handles.edit_addNewBurst,'string'));
ch=vals(1);
bt=round(vals(2)*handles.usr.in.EEG.srate);
et=round(vals(3)*handles.usr.in.EEG.srate);


bursts=handles.usr.in.bursts;
tbursts=handles.usr.in.tmpdata.bursts;

b=handles.usr.in.b;
e=handles.usr.in.e;
if isfield(b,'end')
    b=rmfield(b,'end');
end
if isfield(e,'end')
    e=rmfield(e,'end');
end
fields=fieldnames(b);

cond=0;
for i=1:numel(fields)
    bi=b.(fields{i});
    ei=e.(fields{i});
    for j=1:numel(bi)
        
        if bi(j)<bt&&ei(j)>bt
            cond=i;
        end
    end
end
allb=[bursts{:}];
burstnumber=max([allb.burstnumber])+1;
            


%               b: 275478
%               e: 275549
%             amp: 38.0307
%             dur: 0.0352
%            area: 0.7489
%         verdict: 1
%            cond: 3
%          thresh: [4 2]
%              ch: 4
%            mode: 6.6538
%     burstnumber: 1322
%              bt: 1225020
%              et: 1225091


nb.b              = 1;
nb.e              = 2;
nb.amp            = max(filtfilt(1/round(handles.usr.in.EEG.srate*0.04)*ones(1,round(handles.usr.in.EEG.srate*0.04)),1,abs(hilbert(handles.usr.in.EEG.data(ch,(bt-round(handles.usr.in.EEG.srate/2)):(et+round(handles.usr.in.EEG.srate/2)))))));
nb.dur            = (et-bt)/handles.usr.in.EEG.srate;
nb.area           = sum(abs(hilbert(handles.usr.in.EEG.data(ch,bt:et))))/handles.usr.in.EEG.srate;
nb.verdict        = 5;
nb.cond           = cond;
nb.thresh         = [6 2];
nb.ch             = ch;
nb.mode           = mean(handles.usr.in.mode(ch,bt:et));
nb.burstnumber    = burstnumber;
nb.bt             = bt;
nb.et             = et;


handles.usr.in.bursts{ch}(end+1)=nb;
handles.usr.in.tmpdata.bursts{ch}(end+1)=nb;
sm=handles.usr.in.tmpdata.shufflemat{3};
sm(end+1,:)=[max(sm(:,1))+1 ch cond burstnumber 5];

handles.usr.in.tmpdata.shufflemat{3}=sm;
    
% keyboard;
tmpdata=handles.usr.in.tmpdata;
bursts=handles.usr.in.tmpdata.bursts;
% save, also the new& improved bursts.mat file and tmpdata.mat file.
% doh.

save('bursts.mat','bursts');
save('tmpdata.mat','tmpdata');


warning(sprintf('EPERIMENTAL!!! No guarantees that this\''ll work!'));

% keyboard;
set(handles.listbox_use,'string',num2str(handles.usr.in.tmpdata.shufflemat{3}));
set(handles.listbox_use,'value',size(handles.usr.in.tmpdata.shufflemat{3},1));

guidata(hObject,handles);
update_axes(handles,burstnumber);








% --- Executes during object creation, after setting all properties.
function edit_addNewBurst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_addNewBurst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_plotChannels_Callback(hObject, eventdata, handles)
% hObject    handle to edit_plotChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_plotChannels as text
%        str2double(get(hObject,'String')) returns contents of edit_plotChannels as a double
% keyboard;

burstnumber=handles.usr.burstnumber;

% keyboard;
update_axes(handles,burstnumber);


% --- Executes during object creation, after setting all properties.
function edit_plotChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_plotChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function Export_Callback(hObject, eventdata, handles)
% hObject    handle to Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function edit_distance_Callback(hObject, eventdata, handles)
% hObject    handle to edit_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_distance as text
%        str2double(get(hObject,'String')) returns contents of edit_distance as a double


% --- Executes during object creation, after setting all properties.
function edit_distance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_burstId_Callback(hObject, eventdata, handles)
% hObject    handle to edit_burstId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_burstId as text
%        str2double(get(hObject,'String')) returns contents of edit_burstId as a double


% --- Executes during object creation, after setting all properties.
function edit_burstId_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_burstId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on mouse press over axes background.
function axes_viewEvent_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_viewEvent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get mouse position?
% get position of mouse inside my fig.
% compare with the bursts that are present within the fig.

% find the correct mat.
% then, inside that mat, update the listbox/str/var so that it matches.

    p=get(handles.axes_viewEvent,'currentpoint');
    mx=round(p(1,1));
    my=p(1,2);


    % get the fig's xlim and ylim properties.
    % also get the fig's 'active' channels.
    % from this, determine the ob.
    % compare ob with mx and my.
    ychannels=str2num(get(handles.edit_plotChannels,'string'));
    active_channels=str2num(get(handles.edit_detectSelection,'string'));

    ab=[handles.usr.in.tmpdata.bursts{intersect(ychannels,active_channels)}];     % 'all bursts of active channels'
    be=get(handles.axes_viewEvent,'xlim');xb=be(1);xe=be(2);
    abind=intersect(find([ab.bt]>xb),find([ab.et]<xe)); 
    ob=ab(abind); 

    % find all patches -- these mark the onset/offset of bursts.!
    p=findobj(handles.axes_viewEvent,'type','patch');

    mark=0;
    for i=1:numel(p)
        xd=get(p(i),'xdata');
        yd=get(p(i),'ydata');
        
        
        
        xmin=xd(2);
        xmax=xd(3);
        ymin=yd(2);
        ymax=yd(1);
        
        % disp([xmin xmax ymin ymax mx my]);

        if mx>xmin&&mx<xmax&&my>ymin&&my<ymax
            mark=i;
        end
    end

    if mark==0
        disp('you missed!');
    else
        disp(sprintf('its a hit! %d',mark));
    end
    
    
    % this function is acivated when you clock a patch!!!
    function patch_clickEvent_ButtonDownFcn(hObject,eventdata,handles,burstnumber)

        % disp(burstnumber);
        

        % find the right entry
        % which one is it?
        mat=handles.usr.in.tmpdata.shufflemat;
        if numel(mat{1})>0
            todoid=find(mat{1}(:,4)==burstnumber);
            if numel(todoid)>0
                handle='listbox_todo';
                value=todoid;
            end
        end
        if numel(mat{2})>0
            omitid=find(mat{2}(:,4)==burstnumber);
            if numel(omitid)>0
                handle='listbox_omit';
                value=omitid;
            end
        end
        if numel(mat{3})>0
            useid=find(mat{3}(:,4)==burstnumber);
            if numel(useid)>0
                handle='listbox_use';
                value=useid;
            end
        end
        

 
   % keyboard; 
        set(handles.(handle),'value',value);
        set(handles.edit_distance,'string','0');
        handles.usr.burstnumber=burstnumber;
        guidata(hObject,handles);
        update_axes(handles,burstnumber);
        
        

            
        
        





% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

key=get(gcf,'currentkey');
burstnumber=handles.usr.burstnumber;


% and now also... facilitate... keyboard-scrolling!!!
if strcmp(key,'s')
    pushbutton_scrollBackward_Callback(hObject, eventdata, handles)
    
end

if strcmp(key,'d')
    pushbutton_scrollForeward_Callback(hObject, eventdata, handles)
    
end





if burstnumber~=0&&sum(strcmp(key,{'a','r','e','w'}))>0
    
    
    % adjust also, the tmpdata.bursts struct.
    % get 'active' ychannels
    ychannels=str2num(get(handles.edit_plotChannels,'string'));
    active_channels=str2num(get(handles.edit_detectSelection,'string'));
    bursts=handles.usr.in.tmpdata.bursts;

    

    for i=1:numel(bursts)
        tmp=find([bursts{i}.burstnumber]==burstnumber);
        if numel(tmp)>0
            burstind=tmp;
            burstindi=i;
        end
    end


    mat=handles.usr.in.tmpdata.shufflemat;
    todomat=mat{1};
    omitmat=mat{2};
    usemat=mat{3};
    
    if numel(mat{1})>0
        todoid=find(mat{1}(:,4)==burstnumber);
    else
        todoid=[];
    end
    if numel(mat{2})>0
        omitid=find(mat{2}(:,4)==burstnumber);
    else
        omitid=[];
    end
    if numel(mat{3})>0
        useid=find(mat{3}(:,4)==burstnumber);
    else
        useid=[];
    end

%     todoid=find(mat{1}(:,4)==burstnumber);
%     omitid=find(mat{2}(:,4)==burstnumber);
%     useid=find(mat{3}(:,4)==burstnumber);
    str={'todo','omit','use'};
    
    
    
    switch key
        
        case 'a'
            
            bursts{burstindi}(burstind).verdict=5;
            
            if numel(omitid)>0
                
                entry=omitmat(omitid,:);
                entry(5)=5;
                omitmat(omitid,:)=[];
                if omitid>size(omitmat,1)
                    omitid=omitid-1;
                end
                todoid=get(handles.listbox_todo,'value');
                
                usemat=[usemat;entry];
                usemat=sortrows(usemat,4);
                useid=find(usemat(:,4)==entry(4));
                
                
                
            elseif numel(todoid)>0
                
                % keyboard;
                entry=todomat(todoid,:);
                entry(5)=5;
                todomat(todoid,:)=[];
                if todoid>size(todomat,1)
                    todoid=todoid-1;
                end
                omitid=get(handles.listbox_omit,'value');
                
                usemat=[usemat;entry];
                usemat=sortrows(usemat,4);
                useid=find(usemat(:,4)==entry(4));
                
                
            end
            

            
            
        case 'r'
            
            bursts{burstindi}(burstind).verdict=4;
            
            if numel(useid)>0
                

                
                entry=usemat(useid,:);
                entry(5)=4;
                usemat(useid,:)=[];
                if useid>size(usemat,1)
                    useid=useid-1;
                end
                todoid=get(handles.listbox_todo,'value');
                
                omitmat=[entry;omitmat];
                omitid=find(omitmat(:,4)==entry(4));
                
                
                
            elseif numel(todoid)>0
                
                entry=todomat(todoid,:);
                entry(5)=4;
                todomat(todoid,:)=[];
                if todoid>size(todomat,1)
                    todoid=todoid-1;
                end
                useid=get(handles.listbox_use,'value');
                
                omitmat=[entry;omitmat];
                omitid=find(omitmat(:,4)==entry(4));
            end
            
            
        case 'e'
            
            bursts{burstindi}(burstind).verdict=3;
            
            if numel(useid)>0
                

                
                entry=usemat(useid,:);
                entry(5)=3;
                usemat(useid,:)=[];
                if useid>size(usemat,1)
                    useid=useid-1;
                end
                todoid=get(handles.listbox_todo,'value');
                
                omitmat=[entry;omitmat];
                omitid=find(omitmat(:,4)==entry(4));
                
                
                
            elseif numel(todoid)>0
                
                entry=todomat(todoid,:);
                entry(5)=3;
                todomat(todoid,:)=[];
                if todoid>size(todomat,1)
                    todoid=todoid-1;
                end
                useid=get(handles.listbox_use,'value');
                
                omitmat=[entry;omitmat];
                omitid=find(omitmat(:,4)==entry(4));
            end
            
            
            
            
        case 'w'
            
            bursts{burstindi}(burstind).verdict=6;
            
            if numel(useid)>0
                

                
                entry=usemat(useid,:);
                entry(5)=6;
                usemat(useid,:)=[];
                if useid>size(usemat,1)
                    useid=useid-1;
                end
                todoid=get(handles.listbox_todo,'value');
                
                omitmat=[entry;omitmat];
                omitid=find(omitmat(:,4)==entry(4));
                
                
                
            elseif numel(todoid)>0
                
                entry=todomat(todoid,:);
                entry(5)=6;
                todomat(todoid,:)=[];
                if todoid>size(todomat,1)
                    todoid=todoid-1;
                end
                useid=get(handles.listbox_use,'value');
                
                omitmat=[entry;omitmat];
                omitid=find(omitmat(:,4)==entry(4));
            end
            
            
            

    end
    
    
    % keyboard;
    shufflemat={todomat,omitmat,usemat};
    ids=[0 0 0];
    if numel(todoid)>0
        ids(1)=todoid;
    elseif numel(omitid)>0
        ids(2)=omitid;
    elseif numel(useid)>0
        ids(3)=useid;
    end
    
    
    handles.usr.in.tmpdata.shufflemat=shufflemat;
    handles.usr.in.tmpdata.bursts=bursts;
    
    for i=1:numel(str)
    
        
        set(handles.(['listbox_' str{i}]),'string',num2str(shufflemat{i}));
        if ids(i)>0
            set(handles.(['listbox_' str{i}]),'value',ids(i));
        end
    end
    
    guidata(hObject,handles);
    update_axes(handles,burstnumber);
    
end







% --------------------------------------------------------------------
function updateTmpdata_Callback(hObject, eventdata, handles)
% hObject    handle to updateTmpdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmpdata.shufflemat=handles.usr.in.tmpdata.shufflemat;
tmpdata.chosenMuscles=str2num(get(handles.edit_detectSelection,'string'));
tmpdata.bursts=handles.usr.in.tmpdata.bursts;
tmpdata.chosenConditions=str2num(get(handles.edit_selectConditions,'string'));

pathname=handles.usr.pathname;
handles.usr.in.tmpdata=tmpdata;
save([pathname 'tmpdata.mat'],'tmpdata');
disp('tmpdata.mat written -- selection, shufflemat and (abbreviated) bursts');
guidata(hObject,handles);


% --------------------------------------------------------------------
function updateBursts_Callback(hObject, eventdata, handles)
% hObject    handle to updateBursts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bursts_old=handles.usr.in.bursts;
bursts_new=handles.usr.in.tmpdata.bursts;
fname=[handles.usr.pathname 'bursts.mat'];
if exist(fname,'file')
    
    % rename the old bursts.mat to an older version (with time AND date! in
    % the title.
    cl=clock;
    addon=regexprep(num2str([cl(1:5) round(cl(6))],'%.2d  '),'([\d]*) *([\d]*) *([\d]*) *([\d]*) *([\d]*) *([\d]*) *','_backup_$3-$2-$1_$4-$5-$6');

    newfname=[fname(1:end-4) addon '.mat'];
    copyfile(fname,newfname);
    disp(['saved backup file: ' newfname]);
    % find the number...
end


for i=1:numel(bursts_old)
    
    bnumbers_old=[bursts_old{i}.burstnumber];
    


    newbursts=[bursts_new{:}];
    newnumbers=[newbursts.burstnumber];
    newverdicts=[newbursts.verdict];
    for j=1:numel(newnumbers);

         % very awkward code!
        oldi=find(bnumbers_old==newnumbers(j));
        if numel(oldi)>0
        bursts_old{i}(find(bnumbers_old==newnumbers(j))).verdict = newverdicts(j);
        end        
    end
end


bursts=bursts_old;
if isfield(handles.usr.in,'tmpdata')
    tmpdata=handles.usr.in.tmpdata;
    save([handles.usr.pathname 'tmpdata.mat'],'tmpdata');
end

save([handles.usr.pathname 'bursts.mat'],'bursts');
disp(sprintf('saved \''verdicts\'' to bursts.mat file.'));


% --------------------------------------------------------------------
function exportModel_Callback(hObject, eventdata, handles)
% hObject    handle to exportModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pathname=handles.usr.pathname;
pathname=regexprep(pathname,'emg','results','once');

directory_name = uigetdir(pathname,'choose save-dir! (press F2 to change dir name');
if sum(strcmp(directory_name,{'\','/'}))<1
    directory_name=[directory_name '/'];
end

handles.usr.in.savedir=directory_name;


% once the dirname is known, fill it with:
% a) a model.mat file, with the block model(defined by markers in it).
% first get all of the options.

% select from bursts:
% which muscle?
% edit_musclesExportQuery
whichmucles=str2num(get(handles.edit_musclesExportQuery,'string'));

% which conditions?
% edit_conditionsExportQuery
whichconds=str2num(get(handles.edit_conditionsExportQuery,'string'));

% which verdict?
% edit_useVerdict
whichverdict=str2num(get(handles.edit_useVerdict,'string'));

% for the selected bursts:
% which modulation --> store to temporary mat.
% edit_modulations
modulations=str2num(get(handles.edit_modulations,'string'));

% start at the manipulated 'bursts' data, in tmpdata.mat.
bursts=handles.usr.in.tmpdata.bursts;


% make the parametric modulation.
mod=struct('name',[],'param',[],'poly',[]);
pmod=struct('name',{''},'param',{},'poly',{});
% keyboard;
mod(1)=[];
% pmod(1)=[];
onsets={};
durations={};
names={};

% also do something with fcontrasts and tconstrasts.
fcontrasts={};
tcontrasts={};

for i=1:numel(whichmucles)
    for j=1:numel(whichconds)
        
        


        % now make a matrix for use with parametric modulations.
        % 1st column = the time, in seconds
        % 2nd column = parametric mod. 1
        btmp=bursts{whichmucles(i)}(find([bursts{whichmucles(i)}.cond]==whichconds(j)));
        
        % and those which match (!!) the verdict.
        
        btmp=btmp(find([btmp.verdict]==whichverdict));
        
        mat=[[btmp.bt]/handles.usr.in.EEG.srate; [btmp.dur]; [btmp.amp]; [btmp.area]]';
        
        
        % do it if you actually have anything!
        if size(mat,1)>0
        
            mat=sortrows(mat,1);
        
            names{end+1}=['M_' handles.usr.in.EEG.chanlocs(whichmucles(i)).labels '_C' num2str(whichconds(j))];
            onsets{end+1}=double([btmp.bt]/handles.usr.in.EEG.srate);
            durations{end+1}=zeros(size(onsets{end}));
            % find the bursts...
            modnames={'durmod','ampmod','areamod'};
            
            mod(end+1).name=modnames{find(modulations)};
            pmod(end+1).name={modnames{find(modulations)}};
            % mod(end).param=[];
            % mod(end).poly=[];

            % disp('you can only have ONE modulation!!!');
            for k=1:numel(modulations)
                if modulations(k)

                    mod(end).param=double(detrend(mat(:,k+1),'constant'));
                    pmod(end).param{1}=double(detrend(mat(:,k+1),'constant'));
                    mod(end).poly=1;
                    pmod(end).poly{1}=1;
                end
            end
        end
    end
    
    % fcontrasts{end+1,1:2}=''
    
    
end

% fix row-or-columns...
if size(names,1)>1
    names=names';
end
if size(onsets,1)>1
    onsets=onsets';
end
if size(durations,1)>1
    durations=durations';
end


% make the model --> save to model.mat
% add the model LATEST!
% the 0.6 at the end == a 'shifting' of markers, because I 'misplaced' them
% by about 0.6 secs. It gives the beginning and the end of the
% uncorrected artifact-due-to-movement (see placing of markers.)
if get(handles.checkbox_useBlock,'value')
    
    % keyboard;
    [model_names model_onsets model_durations] = emg_markers_2_design_gui(handles.usr.in.b,handles.usr.in.e,handles.usr.in.EEG.srate,0.6);

    % fix row-or-columns...
    if size(model_names,1)>1
        model_names=model_names';
    end
    if size(model_onsets,1)>1
        model_onsets=model_onsets';
    end
    if size(model_durations,1)>1
        model_durations=model_durations';
    end
    
    names=[model_names names];
    onsets=[model_onsets onsets];
    durations=[model_durations durations];
    % keyboard;
    prepmod=pmod(1);
    prepmod(1).name{1}='';prepmod(1).param{1}=[];prepmod(1).poly{1}=[];
    for i=1:numel(model_names)
        mod=[struct('name','','param',[],'poly',[]) mod];
        pmod=[prepmod pmod];
        
    end
end

% mod=de_mean_pmod(mod);

% then make a job_model.mat file --> store it to the results directory.
save([directory_name 'model.mat'],'names','onsets','durations','mod','pmod');



% b) a tr.txt file
% c) an nvol.txt file
if exist([directory_name '../../parameters'],'file')
    load([directory_name '../../parameters']);
    tr=parameters(1);
    nvol=parameters(3);
    save([directory_name 'tr.txt'],'tr','-ascii');
    save([directory_name 'nvol.txt'],'nvol','-ascii');
else
    error(sprintf('i can\''t find the parameters file!'));
end


% d) a filenames.txt file, indicating where the files are supposed to be
if exist([directory_name '../../fmri'],'dir');
    datadir=regexprep(pathname,'results','fmri','once');
    save([directory_name 'datadir.mat'],'datadir');
else
    error(sprintf('i can\''t find the EPI files!'));
end

disp('making a job_model.mat file.');

study=regexprep(directory_name,'.*fMRI.(.*).pp.[\d]{1}.*','$1');disp(['study = ' study]);
pp=regexp(directory_name,'\d{4}','match');pp=pp{1};disp(['pp = ' pp]);
analysis=regexprep(directory_name,'(.*results.)(.*).','$2');disp(['analysis = ' analysis]);
taak=regexprep(directory_name,'(.*)(\d{4}).([^\/\\]*).(results).*','$3');disp(['task = ' taak]);
prefix=get(handles.edit_queryprefix,'string');disp(['prefix = ' prefix]);
derivs=get(handles.edit_hrfDerivatives,'string');disp(['derivs = ' num2str(derivs)]);

% keyboard;
% make a jobfile.. and save it.

jobs={job_model(study,pp,taak,analysis,prefix,derivs)};
save([directory_name 'job_model.mat'],'jobs');

    
    
% e) a contrasts.mat file, with some (basic) contrasts
% g) for now... for quickness sake, the easiest solution!
% 
% h) add the directory_name to the stack, for later crunching!!!
% i) incorporate auto-reporting upon completion... but not yet!!!






function edit_musclesExportQuery_Callback(hObject, eventdata, handles)
% hObject    handle to edit_musclesExportQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_musclesExportQuery as text
%        str2double(get(hObject,'String')) returns contents of edit_musclesExportQuery as a double


% --- Executes during object creation, after setting all properties.
function edit_musclesExportQuery_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_musclesExportQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_conditionsExportQuery_Callback(hObject, eventdata, handles)
% hObject    handle to edit_conditionsExportQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_conditionsExportQuery as text
%        str2double(get(hObject,'String')) returns contents of edit_conditionsExportQuery as a double


% --- Executes during object creation, after setting all properties.
function edit_conditionsExportQuery_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_conditionsExportQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_modulations_Callback(hObject, eventdata, handles)
% hObject    handle to edit_modulations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_modulations as text
%        str2double(get(hObject,'String')) returns contents of edit_modulations as a double


% --- Executes during object creation, after setting all properties.
function edit_modulations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_modulations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_useVerdict_Callback(hObject, eventdata, handles)
% hObject    handle to edit_useVerdict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_useVerdict as text
%        str2double(get(hObject,'String')) returns contents of edit_useVerdict as a double


% --- Executes during object creation, after setting all properties.
function edit_useVerdict_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_useVerdict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_useBlock.
function checkbox_useBlock_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_useBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_useBlock


% --- Executes on button press in radiobutton_hrf.
function radiobutton_hrf_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_hrf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_hrf


% --- Executes on button press in radiobutton_hrfTime.
function radiobutton_hrfTime_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_hrfTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_hrfTime


% --- Executes on button press in radiobutton_hrfDispD.
function radiobutton_hrfDispD_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_hrfDispD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_hrfDispD



function edit_hrfDerivatives_Callback(hObject, eventdata, handles)
% hObject    handle to edit_hrfDerivatives (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_hrfDerivatives as text
%        str2double(get(hObject,'String')) returns contents of edit_hrfDerivatives as a double


% --- Executes during object creation, after setting all properties.
function edit_hrfDerivatives_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_hrfDerivatives (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_queryprefix_Callback(hObject, eventdata, handles)
% hObject    handle to edit_queryprefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_queryprefix as text
%        str2double(get(hObject,'String')) returns contents of edit_queryprefix as a double


% --- Executes during object creation, after setting all properties.
function edit_queryprefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_queryprefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_burstOffset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_burstOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_burstOffset as text
%        str2double(get(hObject,'String')) returns contents of edit_burstOffset as a double
newval=str2num(get(hObject,'string'));
newval=round(newval*handles.usr.in.EEG.srate);
burstnumber=handles.usr.burstnumber;

bursts=handles.usr.in.bursts;
tbursts=handles.usr.in.tmpdata.bursts;

for i=1:numel(bursts)
    tmp=bursts{i};
    tmpind=find([tmp.burstnumber]==burstnumber);
    if tmpind>0
        bursts{i}(tmpind).et=newval;
    end
end
for i=1:numel(tbursts)
    tmp2=tbursts{i};
    tmp2ind=find([tmp2.burstnumber]==burstnumber);
    if tmp2ind>0
        tbursts{i}(tmp2ind).et=newval;
    end
end

handles.usr.in.bursts=bursts;
handles.usr.in.tmpdata.bursts=tbursts;
guidata(hObject,handles);

update_axes(handles,burstnumber);


% --- Executes during object creation, after setting all properties.
function edit_burstOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_burstOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton_printBursts.
function pushbutton_printBursts_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_printBursts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ExportModelLump_Callback(hObject, eventdata, handles)
% hObject    handle to ExportModelLump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pathname=handles.usr.pathname;
pathname=[regexprep(pathname,'(^.*)(emg.*)','$1') 'results/'];


% keyboard;
resname=get(handles.edit_resultsDir,'string');

if sum(strcmp(resname(end),{'/','\'}))==0
    resname=[resname '/'];
end
directory_name=[pathname resname];



handles.usr.in.savedir=directory_name;


% once the dirname is known, fill it with:
% a) a model.mat file, with the block model(defined by markers in it).
% first get all of the options.

% select from bursts:
% which muscle?
% edit_musclesExportQuery
whichmucles=str2num(get(handles.edit_musclesExportQuery,'string'));

% which conditions?
% edit_conditionsExportQuery
whichconds=str2num(get(handles.edit_conditionsExportQuery,'string'));

% which verdict?
% edit_useVerdict
whichverdict=str2num(get(handles.edit_useVerdict,'string'));

% for the selected bursts:
% which modulation --> store to temporary mat.
% edit_modulations
modulations=str2num(get(handles.edit_modulations,'string'));

% start at the manipulated 'bursts' data, in tmpdata.mat.
bursts=handles.usr.in.tmpdata.bursts;


% make the parametric modulation.
mod=struct('name',[],'param',[],'poly',[]);
pmod=struct('name',{''},'param',{},'poly',{});
% keyboard;
mod(1)=[];
% pmod(1)=[];
onsets={};
durations={};
names={};

% also do something with fcontrasts and tconstrasts.
fcontrasts={};
tcontrasts={};

for i=1:numel(whichmucles)
    for j=1:numel(whichconds)
        
        


        % now make a matrix for use with parametric modulations.
        % 1st column = the time, in seconds
        % 2nd column = parametric mod. 1
        btmp=bursts{whichmucles(i)}(find([bursts{whichmucles(i)}.cond]==whichconds(j)));
        
        % and those which match (!!) the verdict.
        
        btmp=btmp(find([btmp.verdict]==whichverdict));
        
        mat=[[btmp.bt]/handles.usr.in.EEG.srate; [btmp.dur]; [btmp.amp]; [btmp.area]]';
        
        
        % do it if you actually have anything!
        if size(mat,1)>0
        
            mat=sortrows(mat,1);
        
            names{end+1}=['M_' handles.usr.in.EEG.chanlocs(whichmucles(i)).labels '_C' num2str(whichconds(j))];
            onsets{end+1}=double([btmp.bt]/handles.usr.in.EEG.srate);
            durations{end+1}=zeros(size(onsets{end}));
            % find the bursts...
            modnames={'durmod','ampmod','areamod'};
            
            mod(end+1).name=modnames{find(modulations)};
            pmod(end+1).name={modnames{find(modulations)}};
            % mod(end).param=[];
            % mod(end).poly=[];

            disp('you can only have ONE modulation!!!');
            for k=1:numel(modulations)
                if modulations(k)

                    mod(end).param=double(detrend(mat(:,k+1),'constant'));
                    pmod(end).param{1}=double(detrend(mat(:,k+1),'constant'));
                    mod(end).poly=1;
                    pmod(end).poly{1}=1;
                end
            end
        end
    end
    
    % fcontrasts{end+1,1:2}=''
    
    
end

% fix row-or-columns...
if size(names,1)>1
    names=names';
end
if size(onsets,1)>1
    onsets=onsets';
end
if size(durations,1)>1
    durations=durations';
end


% make the model --> save to model.mat
% add the model LATEST!
% the 0.6 at the end == a 'shifting' of markers, because I 'misplaced' them
% by about 0.6 secs. It gives the beginning and the end of the
% uncorrected artifact-due-to-movement (see placing of markers.)
if get(handles.checkbox_useBlock,'value')
    
    % keyboard;
    [model_names model_onsets model_durations] = emg_markers_2_design_gui(handles.usr.in.b,handles.usr.in.e,handles.usr.in.EEG.srate,0.00001);

    % fix row-or-columns...
    if size(model_names,1)>1
        model_names=model_names';
    end
    if size(model_onsets,1)>1
        model_onsets=model_onsets';
    end
    if size(model_durations,1)>1
        model_durations=model_durations';
    end
    
    names=[model_names names];
    onsets=[model_onsets onsets];
    durations=[model_durations durations];
    % keyboard;
    prepmod=pmod(1);
    prepmod(1).name{1}='';prepmod(1).param{1}=[];prepmod(1).poly{1}=[];
    for i=1:numel(model_names)
        mod=[struct('name','','param',[],'poly',[]) mod];
        pmod=[prepmod pmod];
        
    end
end

% mod=de_mean_pmod(mod);

% do the LUMP!
% welke hebben allemaal _C1 -what-you-specified op t einde??
tconds=str2num(get(handles.edit_conditionsExportQuery,'string'));


lumps={};
newnames={};
for ti=1:numel(tconds)
    
    
    
    tmp=regexpi(names,['_C' num2str(tconds(ti)) '$']);
    mark=[];
    for j=1:numel(tmp);if numel(tmp{j})>0;mark=[mark j];end;end
    
    % als er iets is... doe t dan!
    if mark>0
        newnames{end+1}=['M_ALL_C' num2str(tconds(ti))];
        lumps{end+1}=mark;
    end
    
end


% keyboard;

% this isn't yet compatible with the pmod & mod structs, unfort...
keep=[1 2]; % keep the standardized block design!.
[names onsets durations]=emg_lump_model(names,onsets,durations,keep,lumps,newnames);
    

% keyboard;
if ~exist(directory_name,'dir')
    mkdir(directory_name);
    disp(['creating results dir: ' directory_name]);
end
% then make a job_model.mat file --> store it to the results directory.
save([directory_name 'model.mat'],'names','onsets','durations','mod','pmod');



% b) a tr.txt file
% c) an nvol.txt file
if exist([directory_name '../../parameters'],'file')
    load([directory_name '../../parameters']);
    tr=parameters(1);
    nvol=parameters(3);
    save([directory_name 'tr.txt'],'tr','-ascii');
    save([directory_name 'nvol.txt'],'nvol','-ascii');
else
    error(sprintf('i can\''t find the parameters file!'));
end


% d) a filenames.txt file, indicating where the files are supposed to be
if exist([directory_name '../../fmri'],'dir');
    datadir=regexprep(pathname,'results','fmri','once');
    save([directory_name 'datadir.mat'],'datadir');
else
    error(sprintf('i can\''t find the EPI files!'));
end

disp('making a job_model.mat file.');

study=regexprep(directory_name,'.*fMRI.(.*).pp.[\d]{1}.*','$1');disp(['study = ' study]);
pp=regexp(directory_name,'\d{4}','match');pp=pp{1};disp(['pp = ' pp]);
analysis=regexprep(directory_name,'(.*results.)(.*).','$2');disp(['analysis = ' analysis]);
taak=regexprep(directory_name,'(.*)(\d{4}).([^\/\\]*).(results).*','$3');disp(['task = ' taak]);
prefix=get(handles.edit_queryprefix,'string');disp(['prefix = ' prefix]);
derivs=get(handles.edit_hrfDerivatives,'string');disp(['derivs = ' num2str(derivs)]);

% keyboard;
% make a jobfile.. and save it.

jobs={job_model(study,pp,taak,analysis,prefix,derivs)};
save([directory_name 'job_model.mat'],'jobs');

    
    
% e) a contrasts.mat file, with some (basic) contrasts
% g) for now... for quickness sake, the easiest solution!
% 
% h) add the directory_name to the stack, for later crunching!!!
% i) incorporate auto-reporting upon completion... but not yet!!!





function edit_resultsDir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_resultsDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_resultsDir as text
%        str2double(get(hObject,'String')) returns contents of edit_resultsDir as a double


% --- Executes during object creation, after setting all properties.
function edit_resultsDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_resultsDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
