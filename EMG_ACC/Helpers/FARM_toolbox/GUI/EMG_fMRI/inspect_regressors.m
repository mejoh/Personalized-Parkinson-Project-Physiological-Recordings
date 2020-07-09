function varargout = inspect_regressors(varargin)
% inspect_regressors M-file for inspect_regressors.fig
%      inspect_regressors, by itself, creates a new inspect_regressors or raises the existing
%      singleton*.
%
%      H = inspect_regressors returns the handle to a new inspect_regressors or the handle to
%      the existing singleton*.
%
%      inspect_regressors('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in inspect_regressors.M with the given input arguments.
%
%      inspect_regressors('Property','Value',...) creates a new inspect_regressors or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inspect_regressors_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inspect_regressors_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inspect_regressors

% Last Modified by GUIDE v2.5 18-Oct-2010 13:26:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inspect_regressors_OpeningFcn, ...
                   'gui_OutputFcn',  @inspect_regressors_OutputFcn, ...
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


% --- Executes just before inspect_regressors is made visible.
function inspect_regressors_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    if isempty(EMG_fMRI_study_dir) || ~isdir(EMG_fMRI_study_dir)
        errordlg('First select ''Select dataset''','Initialization error','modal'); 
        error('First select ''Select dataset'''); 
    end
    

    % Choose default command line output for inspect_regressors
    handles.output = hObject;

    % copy some relevant parameters from base to gui handles
    handles.pp = EMG_fMRI_patient;
    
    handles.mode = 1;

    % Update handles structure
    guidata(hObject, handles);

    % fill the protocol list and select all by default
    protocols = EMG_fMRI_proto_answer; % no need to copy this one to handles
    protocols(cellfun(@isempty,protocols)) = [];
    set(handles.lst_protocols,'String', protocols);
    set(handles.lst_protocols,'value',1:length(protocols));
    
    % initialize the file list
    UpdateList(handles);
    
   
    % UIWAIT makes inspect_regressors wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

function UpdateList(handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    pattern = get(handles.txt_file_filter,'String');
    ppdir = fullfile(EMG_fMRI_study_dir,'pp',handles.pp);
    protocols = get(handles.lst_protocols,'String');
    selection = get(handles.lst_protocols,'Value');
    filelist = [];
    
    if handles.mode==1 % regressor mode: 
       subdir = 'regressor';
    else % model mode
       subdir = 'regressor';
%       subdir = 'model';
    end
        
    % walk trough all selected protocol directories and compose a file list
    for iSelection=1:length(selection)
        iProtocol = selection(iSelection);
        protocol = protocols{iProtocol};
        activedir = fullfile(ppdir,protocol,subdir);
        files = dir(fullfile(activedir,pattern));
        % remove directories from the list
        files = {files(~[files.isdir]).name}; 
%         % remove files that start with 'conv' when mode is regressor
%         if handles.mode==1
%             files(strmatch('conv',files)) = [];
%         end
        % remove thresholds.txt from files 
        files(strmatch('thresholds.txt',files,'exact')) = [];
%       filelist = cat(2,filelist,{files.name});
        if isempty(filelist)
            filelist = files;
        else
            % only add items that are not already in the list
            for iFilename=1:length(files)
                filename = files{iFilename};
                x = strmatch(filename, filelist,'exact');
                if isempty(x)
                    filelist{end+1} = filename;
                else
                    % skip: filename is already part of the list
                end
            end
        end
    end
    % sort the file list because the order will determine the order of the
    % columns in the composed model.
    sortrows(filelist);
    % fill list and select all
    set(handles.lst_files,'Value',[]); 
    set(handles.lst_files,'String',filelist);
    CheckButtons(handles);
  
function CheckButtons(handles)
    if isempty(get(handles.lst_files,'Value'))
        on_or_off = 'off';
    else
        on_or_off = 'on';
    end
    set(handles.btn_refresh,'Enable',on_or_off);


% --- Outputs from this function are returned to the command line.
function varargout = inspect_regressors_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function txt_file_filter_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
% --- Executes when user enters text in file_filter
function txt_file_filter_Callback(hObject, eventdata, handles)
    % enable the update button
    UpdateList(handles);

% --- Executes during object creation, after setting all properties.
function lst_files_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
% --- Executes on selection change in lst_files.
function lst_files_Callback(hObject, eventdata, handles)
    CheckButtons(handles);
    
% --- Executes on button press in btn_select_all_files.
function btn_select_all_files_Callback(hObject, eventdata, handles)
    set(handles.lst_files,'value',1:length(get(handles.lst_files,'String'))); 

% --- Executes on button press in btn_refresh.
function btn_refresh_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn

    message = [];
    nErrors = 0;
    nSkipped = 0;
    
    % compose regressor matrix
    model = [];
    % build a cell array containing the names of the regressors
    regressor_names = {};
            
    % get root directory, selected filenames and selected protocols
    ppdir = fullfile(EMG_fMRI_study_dir,'pp',handles.pp);
    files = get(handles.lst_files,'String');
    file_selection = get(handles.lst_files,'Value');
    protocols = get(handles.lst_protocols,'String');
    protocol_selection = get(handles.lst_protocols,'Value');
    % walk trough all selected protocol directories
    try
        for iProtocolSelection=1:length(protocol_selection)
            iProtocol = protocol_selection(iProtocolSelection);
            protocol = protocols{iProtocol};
            protocoldir = fullfile(ppdir,protocol);

            % get TR and #volumes for this protocol
            parameters = load(fullfile(protocoldir,'parameters'));
            tr = parameters(1);
            nvols = parameters(3);

            if handles.mode==1 % regressor mode: 
               subdir = 'regressor';
            else % model mode
    %           subdir = 'model';
               subdir = 'regressor';
            end
            activedir = fullfile(protocoldir,subdir);

            % walk trough all selected files
            for iFileSelection=1:length(file_selection)
                % which regressor file?
                iFile = file_selection(iFileSelection);
                inputname = files{iFile};
                inputpath = fullfile(activedir,inputname);

                msg = [];

                if exist(inputpath,'file')

                    % load the regressor
                    R = load(inputpath);
                    if isfield(R,'names')
                        this_regressor_names = R.names;
                    else
                        this_regressor_names = {};
                    end
                    if isfield(R,'onsets')
                        R = mat_convert_onsets_durations(R.onsets,R.durations,tr,nvols,1,0);
                    end
                    if isfield(R,'design')
                        R = R.design;
                    end
                    if size(R,1)==1 && isvector(R)
                        R = R';
                    end
                    if isnumeric(R) && size(R,1)>=1 
                        if size(R,1)~=nvols
                            msg = sprintf('Warning: #samples=%d <> #volumes=%d', size(R,1), nvols);
                        end
                        nRows = size(R,1);
                        nCols = size(R,2);

    %                     if handles.mode==1   % regressor mode
    %                         
    %                     else  % model mode
                            nR = size(R,2);
                            if nR>1 
                                for iR=1:nR
                                    if iR<=length(this_regressor_names)
                                        regressor_names{end+1} = sprintf('%s:%s',inputname,this_regressor_names{iR});
                                    else
                                        regressor_names{end+1} = sprintf('%s:%d',inputname,iR);
                                    end
                                end
                            else
                                regressor_names{end+1} = inputname;
                            end
                            
                            if isempty(model)
                                model = R;
                            else
                                nRowsInModel = size(model,1);
                                nRowsMissing = nRowsInModel - nRows;
                                if nRowsMissing<0
                                    % pad model with zeros if new regressor contains more data
                                    model(nRowsInModel+1:nRows,:) = 0;
                                elseif nRowsMissing>0
                                    % pad regressor with zeros if new regressor contains more data
                                    R(nRows+1:nRowsInModel,:) = 0;
                                end
                                model = [ model R ];
                            end
    %                     end
                    else
                        msg = 'Error: no valid data';
                        nErrors = nErrors + 1;
                    end
                end % if regressor file exists

                % something to report?
                if ~isempty(msg)
                    message = [message sprintf('\n%s, %s\t %s',protocol, inputname, msg)];
                end
            end % for all selected regressor files

        end % for all selected protocols
    catch
        regressor_names = {};
        model = [ ];
        nErrors = nErrors + 1;
    end
    
    switch handles.mode
        case 1 % regressor mode
            bLegendOn = strcmpi(get(handles.toggleLegend,'State'),'on');
            plot(handles.axes1, model);
            if bLegendOn
                % limit the legend (for scan nulling stuff...)
                if length(regressor_names)>10
                    regressor_names = { regressor_names{1:9}, '...' };
                end
                legend(regressor_names,'Interpreter','none'); % without interpreter to prevent underscores from being translated to sub
            end
        case 2 % model mode
            % inverting values seems to work for inverting contrast
            imagesc(-model);%title('Two Blockdesigns');xlabel('tasks');ylabel('time');
            colormap gray
    end
        
    if nSkipped
        message = [message sprintf('\n%d FILES SKIPPED',nSkipped)];
    end
    if nErrors
        message = [message sprintf('\n%d FILES FAILED',nErrors)];
    end
    disp(message);
%     if nErrors==0 && nSkipped==0
%         set(handles.btn_refresh,'Enable','off');
%     end

% --- Executes on button press in btn_cancel.
function btn_cancel_Callback(hObject, eventdata, handles)
    close

% --- Executes on selection change in lst_protocols.
function lst_protocols_Callback(hObject, eventdata, handles)
    % (re)initialize the file list
    UpdateList(handles);

% --- Executes during object creation, after setting all properties.
function lst_protocols_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
% --- Executes during object creation, after setting all properties.
function txt_filename_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function txt_filename_Callback(hObject, eventdata, handles)
    CheckButtons(handles);

% --- Executes when selected object is changed in mode_buttongroup.
function mode_buttongroup_SelectionChangeFcn(hObject, eventdata, handles)
    % hObject    handle to the selected object in mode_buttongroup 
    % eventdata  structure with the following fields (see UIBUTTONGROUP)
    %	EventName: string 'SelectionChanged' (read only)
    %	OldValue: handle of the previously selected object or empty if none was selected
    %	NewValue: handle of the currently selected object
    % handles    structure with handles and user data (see GUIDATA)
    switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
        case 'radio_regressors'
            handles.mode = 1;
        case 'radio_models'
            handles.mode = 2;
        otherwise
            % Code for when there is no match.
            handles.mode = 0;
    end
    % Update handles structure
    guidata(hObject, handles);
%     UpdateList(handles);
    


