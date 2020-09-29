function varargout = preprocessing_emg_corr(varargin)
% PREPROCESSING_EMG_CORR M-file for preprocessing_emg_corr.fig
%      PREPROCESSING_EMG_CORR, by itself, creates a new PREPROCESSING_EMG_CORR or raises the existing
%      singleton*.
%
%      H = PREPROCESSING_EMG_CORR returns the handle to a new PREPROCESSING_EMG_CORR or the handle to
%      the existing singleton*.
%
%      PREPROCESSING_EMG_CORR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCESSING_EMG_CORR.M with the given input arguments.
%
%      PREPROCESSING_EMG_CORR('Property','Value',...) creates a new PREPROCESSING_EMG_CORR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preprocessing_emg_corr_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preprocessing_emg_corr_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help preprocessing_emg_corr

% Last Modified by GUIDE v2.5 02-Nov-2009 16:04:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @preprocessing_emg_corr_OpeningFcn, ...
                   'gui_OutputFcn',  @preprocessing_emg_corr_OutputFcn, ...
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


% --- Executes just before preprocessing_emg_corr is made visible.
function preprocessing_emg_corr_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % Choose default command line output for preprocessing_emg_corr
    handles.output = hObject;

    set(handles.method,'SelectionChangeFcn',@method_SelectionChangeFcn);
    set(handles.txt_title,'String', sprintf('Preprocessing EMG: %s, %s, %s',EMG_fMRI_study,EMG_fMRI_patient,EMG_fMRI_protoname_select_muscle));

    % Update handles structure
    guidata(hObject, handles);
    


    % UIWAIT makes preprocessing_emg_corr wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = preprocessing_emg_corr_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in quit.
function quit_Callback(hObject, eventdata, handles)
    close
    
% --- Executes on button press in save_data.
function save_data_Callback(hObject, eventdata, handles)
% NO need to include the following (emg_corr saves to emg_correcte.mat)
%     emg_fmri_globals; % make sure this is the first call in the fn
%     
%     wdir=([EMG_fMRI_study_dir '/pp/' EMG_fMRI_patient '/' EMG_fMRI_protoname_select_muscle '/emg']);
%     cd(wdir);
%     % check if emg_preprocessed directory is there
%     if ~isdir('emg_preprocessed')
%         mkdir emg_preprocessed
%     end
%     %go to that directory
%     cd emg_preprocessed
% 
%     % save EMG data
%     %EEG = evalin('base','EEG');
%     savefile = ['emg_nieuwe_methode_' datestr(now,'yyyy.mm.dd__HH.MM.SS') '.mat'];
%     save(savefile, 'EEG');


% --- Executes on button press in inspect_data.
function inspect_data_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn; for EEG
    try
        %EEG = evalin('base','EEG');
        pop_eegplot(EEG, 1, 1, 1);
    catch
        msgbox('EEGPlot could not been displayed','Error');
    end
    try 
        %EEG = evalin('base','EEG');
        pop_spectopo(EEG);
    catch
        msgbox('spectoplot could not been displayed','Error');
    end
   

% --- Executes on button press in new_method.
function new_method_Callback(hObject, eventdata, handles)

% --- Executes on button press in radio_personalised.
function radio_personalised_Callback(hObject, eventdata, handles)

% --- Executes on button press in execute.
function execute_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % 2009-08-19: (Paul) this routine requires the Signal Processing Toolbox, so better check it now...
    if ~license('checkout','signal_toolbox')
        errordlg('This function requires the Signal Processing Toolbox')
        return
    end

    % go to desired directory
    wdir=([EMG_fMRI_study_dir '/pp/' EMG_fMRI_patient '/' EMG_fMRI_protoname_select_muscle '/emg' ]);
    cd(wdir);
    % Start new correction method
    try
        show_waitbar = true; % this will be read by the emg_corr script....
        emg_corr
        msgbox('EMG correction succeeded','Succes');
    catch % ME <= this constuct is not available before R2007, use lasterror instead
        ME = lasterror();
        disp(ME.message);
        disp(ME.stack(1));
        errordlg('EMG correction failed');
    end

function method_SelectionChangeFcn(hObject, eventdata)

    %retrieve GUI data, i.e. the handles structure
    handles = guidata(hObject); 

    % Code for the bullet choices and give the workspace variable
    % EMG_fMRI_arti_channel the value of the bullet.
    switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
         case 'new_method'
            %execute this code when radiobutton1 is selected
%             preprocessing_emg_corr
%             close(preprocessing_emg_personalised)
         case 'radio_personalised'
            %execute this code when radiobutton1 is selected
            preprocessing_emg_personalised
            close(preprocessing_emg_corr)
         otherwise
            % Code for when there is no match.
            msgbox('Choose a method!','Error');
    end
