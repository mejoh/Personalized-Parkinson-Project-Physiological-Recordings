function varargout = convert_and_preprocess(varargin)
% CONVERT_AND_PREPROCESS M-file for convert_and_preprocess.fig
%      CONVERT_AND_PREPROCESS, by itself, creates a new CONVERT_AND_PREPROCESS or raises the existing
%      singleton*.
%
%      H = CONVERT_AND_PREPROCESS returns the handle to a new CONVERT_AND_PREPROCESS or the handle to
%      the existing singleton*.
%
%      CONVERT_AND_PREPROCESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONVERT_AND_PREPROCESS.M with the given input arguments.
%
%      CONVERT_AND_PREPROCESS('Property','Value',...) creates a new CONVERT_AND_PREPROCESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before convert_and_preprocess_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to convert_and_preprocess_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help convert_and_preprocess

% Last Modified by GUIDE v2.5 02-Nov-2009 11:09:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @convert_and_preprocess_OpeningFcn, ...
                   'gui_OutputFcn',  @convert_and_preprocess_OutputFcn, ...
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


% --- Executes just before convert_and_preprocess is made visible.
function convert_and_preprocess_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % Choose default command line output for convert_and_preprocess
    handles.output = hObject;

    if isempty(EMG_fMRI_study_dir) || ~isdir(EMG_fMRI_study_dir)
        errordlg('First select ''Select dataset''','Initialization error','modal'); 
        error('First select ''Select dataset'''); 
    end

    % cd to study_dir
    cd(EMG_fMRI_study_dir);
    wdir=([EMG_fMRI_study_dir '/ruw/' EMG_fMRI_patient '/trc']);
    cd(wdir);

	update_convert_emg_message(handles);
	update_convert_log_message(handles);
    update_preprocess_fmri_message(handles);
    update_convert_mri_message(handles);
    
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes convert_and_preprocess wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = convert_and_preprocess_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

    
function EnableButtons(handles, status) 
    % enable/disable using status='on' (default) or 'off'
    if nargin<1
        status = 'on';
    end
    H = [ ...
            handles.btn_convert_emg, ...
            handles.btn_convert_log, ...
            handles.btn_convert_mri, ...
            handles.btn_preprocess_fmri, ...
            handles.pushbutton4 ...
        ];
	set(H,'Enable',status);

function [exist_count, missing_count] = count_files(subpath,filename)
    emg_fmri_globals; % make sure this is the first call in the fn
    missing_count = 0;
    exist_count = 0;
    for i=1:length(EMG_fMRI_proto_answer)
        if ~isempty(EMG_fMRI_proto_answer{i})
            if exist(fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient,EMG_fMRI_proto_answer{i},subpath,filename),'file')
                exist_count=exist_count+1;
            else
                missing_count=missing_count+1;
            end
        end
    end

function update_file_count_message(handle,subpath,filename)
    [exist_count, missing_count] = count_files(subpath,filename);
    if missing_count>0
        msg = sprintf('<-- require %d %s files',missing_count,filename);
    elseif exist_count>0
        msg = sprintf('%d %s files available',exist_count,filename);
    else
        msg = 'no studies defined';
    end
    set(handle,'String', msg);
    
function update_convert_emg_message(handles)
    update_file_count_message(handles.msg_convert_emg,'emg','emg.mat');

% --- Executes on button press in btn_convert_emg: convert TRC to EEG (mat).
function btn_convert_emg_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    try
        set(handles.msg_convert_emg,'String', 'executing script...');
        EnableButtons(handles, 'off');
        drawnow update;
        h = waitbar(0,'Wait until EMG conversion is ready...');
        % must go to study directory because batch relies on it
        cd(EMG_fMRI_study_dir);
        batch_emg_to_mat(EMG_fMRI_study,EMG_fMRI_patient);
        waitbar(1);
        set(handles.msg_convert_emg,'String', 'Transformation of trc files completed');
    catch
        ME = lasterror();
        set(handles.msg_convert_emg,'String', ['<-- ', ME.message]);
    end
    close(h);
    EnableButtons(handles, 'on');

function update_convert_log_message(handles)
    update_file_count_message(handles.msg_convert_log,'regressor','block.mat');

% --- Executes on button press in btn_convert_log.
function btn_convert_log_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    try
        set(handles.msg_convert_log,'String', 'executing script...');
        EnableButtons(handles, 'off');
        drawnow update;
        h = waitbar(0,'Wait until LOG conversion is ready...');
        % must go to study directory because batch relies on it
        cd(EMG_fMRI_study_dir);
        batch_log_to_mat(EMG_fMRI_study,EMG_fMRI_patient);
        waitbar(1);
        set(handles.msg_convert_log,'String', 'Transformation of log files completed');
    catch
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        % getReport(ME) %only works with R2007+ in combination with catch ME
        set(handles.msg_convert_log,'String', ['<-- ', ME.message]);
    end
    close(h);
    EnableButtons(handles, 'on');
        
function update_convert_mri_message(handles)
    emg_fmri_globals; % make sure this is the first call in the fn

    % check if T1 is available
    if exist(fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient,'t1','t1.img'),'file')
        msgT1 = 'T1 available';
    else
        msgT1 = '<-- T1 not available';
    end
    
    % check if 4D images are available
    missing = 0;
    available = 0;
    for iStudy=1:length(EMG_fMRI_proto_answer)
        if ~isempty(EMG_fMRI_proto_answer{iStudy})
            if exist(fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient,EMG_fMRI_proto_answer{iStudy},'fmri','4D.img'),'file')
                available = available + 1;
            else
                missing = missing + 1;
            end
        end
    end
    if missing>0 && available>0
        msg4D = sprintf('\n<-- %d fMRI (4D) images missing (%d done)',missing,available);
    elseif missing>0
        msg4D = sprintf('\n<-- %d fMRI (4D) images missing',missing);
    elseif available>0
        msg4D = sprintf('\nAll (%d) fMRI (4D) images available',available);
    else
        msg4D = '\nNo studies defined!';
    end
    set(handles.msg_convert_mri,'String', [msgT1,msg4D]);
    
% --- Executes on button press in btn_convert_mri.
function btn_convert_mri_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    try
        set(handles.msg_convert_mri,'String', 'executing script...');
        EnableButtons(handles, 'off');
        drawnow update;
        [result, message] = batch_parrec_to_analyze(EMG_fMRI_study,EMG_fMRI_patient,EMG_fMRI_study_dir,2);  % convert to img/hdr
        set(handles.msg_convert_mri,'String', message);
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        % getReport(ME) %only works with R2007+ in combination with catch ME
        set(handles.msg_convert_mri,'String', ['<-- ', ME.message]);
    end
    EnableButtons(handles, 'on');

function update_preprocess_fmri_message(handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % check if T1 is coregistered
    if exist(fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient,'t1','t1_old.img'),'file')
        msg = 'T1 already coregistered to standardized T1';
    else
        msg = '<-- T1 not coregistered to standardized T1';
    end
    
    % check if resliced 4D images are available
    missing = 0;
    available = 0;
    for iStudy=1:length(EMG_fMRI_proto_answer)
        if ~isempty(EMG_fMRI_proto_answer{iStudy})
            if exist(fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient,EMG_fMRI_proto_answer{iStudy},'fmri','sra4D.img'),'file')
                available = available + 1;
            else
                missing = missing + 1;
            end
        end
    end
    if missing>0 && available>0
        msg4D = sprintf('\n<-- %d fMRI (sra4D) images missing (%d done)',missing,available);
    elseif missing>0
        msg4D = sprintf('\n<-- %d fMRI (sra4D) images missing',missing);
    elseif available>0
        msg4D = sprintf('\nAll (%d) fMRI (sra4D) images available',available);
    else
        msg4D = '\nNo studies defined!';
    end
    set(handles.msg_preprocess_fmri,'String', [msg,msg4D]);
    
% --- Executes on button press in btn_preprocess_fmri.
function btn_preprocess_fmri_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    try
        set(handles.msg_preprocess_fmri,'String', 'executing SPM jobs...');
        EnableButtons(handles, 'off');
        drawnow update;
        
        totaal = 0;
        for iStudy=1:length(EMG_fMRI_proto_answer)
            if ~isempty(EMG_fMRI_proto_answer{iStudy})
                totaal = totaal +1;
            end
        end
        if totaal == 0
            msgbox('No studies defined','ERROR');
            return;
        end
        h = waitbar(0,'Wait until spatial preprocessing is ready...');
        % must go to study directory because batch relies on it
        cd(EMG_fMRI_study_dir);
%         set(handles.msg_preprocess_fmri,'String', 'executing script...');
        switch (totaal)
            case 1
                % 2009-08-17, paul added fmri processing for case N==1 (not sure of coreg between 'taken' handles this properly) 
                batch_fmri_preprocessing(EMG_fMRI_study,EMG_fMRI_patient,EMG_fMRI_proto_answer{1}); % TODO is this OK for only one condition?
            case 2
                batch_fmri_preprocessing(EMG_fMRI_study,EMG_fMRI_patient,EMG_fMRI_proto_answer{1},EMG_fMRI_proto_answer{2});
            case 3
                batch_fmri_preprocessing(EMG_fMRI_study,EMG_fMRI_patient,EMG_fMRI_proto_answer{1},EMG_fMRI_proto_answer{2},EMG_fMRI_proto_answer{3});
            case 4
                batch_fmri_preprocessing(EMG_fMRI_study,EMG_fMRI_patient,EMG_fMRI_proto_answer{1},EMG_fMRI_proto_answer{2},EMG_fMRI_proto_answer{3},EMG_fMRI_proto_answer{4});
            case 5
                batch_fmri_preprocessing(EMG_fMRI_study,EMG_fMRI_patient,EMG_fMRI_proto_answer{1},EMG_fMRI_proto_answer{2},EMG_fMRI_proto_answer{3},EMG_fMRI_proto_answer{4},EMG_fMRI_proto_answer{5});
        end
        waitbar(1);
        set(handles.msg_preprocess_fmri,'String', 'ready!');
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        % getReport(ME) %only works with R2007+ in combination with catch ME
%       errordlg(['fMRI prepocessing failed: ', ME.message ])
        set(handles.msg_preprocess_fmri,'String', ['<-- ', ME.message]);
    end
    close(h);
    EnableButtons(handles, 'on');


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    close
    
% % -----------------------------------------------------------------------
% % Create and update a waitbar.
% function create_update_waitbar
%     h_wait = waitbar(0,'Please wait...',...
%             'Position',[250,320,270,50],...
%             'CloseRequestFcn',@close_waitbar);
%     for i=1:10000,
%         if ishandle(h_wait)
%         waitbar(i/10000,h_wait)
%         else               
%             break
%         end
%     end
%     % When waitbar reaches max, close it.
%     if ishandle(h_wait)        
%        close(h_wait)
%     end
% 
% % -----------------------------------------------------------------------
% % Close the waitbar. Executes in response to BREAK and CLOSE commands.
% function close_waitbar(hObject,eventdata)
%     delete(gcbf)
