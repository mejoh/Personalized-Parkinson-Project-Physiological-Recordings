function varargout = compose_conditions(varargin)
% COMPOSE_CONDITIONS M-file for compose_conditions.fig
%      COMPOSE_CONDITIONS, by itself, creates a new COMPOSE_CONDITIONS or raises the existing
%      singleton*.
%
%      H = COMPOSE_CONDITIONS returns the handle to a new COMPOSE_CONDITIONS or the handle to
%      the existing singleton*.
%
%      COMPOSE_CONDITIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPOSE_CONDITIONS.M with the given input arguments.
%
%      COMPOSE_CONDITIONS('Property','Value',...) creates a new COMPOSE_CONDITIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before compose_conditions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to compose_conditions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help compose_conditions

% Last Modified by GUIDE v2.5 09-Mar-2011 14:28:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @compose_conditions_OpeningFcn, ...
                   'gui_OutputFcn',  @compose_conditions_OutputFcn, ...
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


% --- Executes just before compose_conditions is made visible.
function compose_conditions_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn

    if isempty(EMG_fMRI_study_dir) || ~isdir(EMG_fMRI_study_dir)
        errordlg('First select ''Select dataset''','Initialization error','modal'); 
        error('First select ''Select dataset'''); 
    end

    % Choose default command line output for compose_conditions
    handles.output = hObject;

    % varargin should contain two arguments: a protocol(s) cell array and the selected filename
    handles.protocols = varargin{1};
    handles.original_block_file = varargin{2};

    if CountScanNullingDesigns(handles)>0
        set(handles.chk_scan_nulling,'Enable','on');
    end
    
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes compose_conditions wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = compose_conditions_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);

    % Get default command line output from handles structure
    varargout{1} = handles.output;

function [n missing] = CountScanNullingDesigns(handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    n = 0;
    if nargout>=2
        missing = 0;
    end
    for iProtocol=1:length(handles.protocols)
        regressordir = fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient, handles.protocols{iProtocol}, 'regressor');
        fn = fullfile(regressordir,'nulling_design.mat');
        if exist(fn,'file')
            n = n + 1;
        elseif nargout>=2
            missing = missing+1;
        end
    end
    
% --- Executes on button press in btn_save_as.
function btn_save_as_Callback(hObject, eventdata, handles)
    % this will load the onsets, durations and names cell array's
    emg_fmri_globals; % make sure this is the first call in the fn
    
    for iProtocol=1:length(handles.protocols)
        protocol = handles.protocols{iProtocol};
        regressordir = fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient, protocol, 'regressor');
        load(fullfile(regressordir,handles.original_block_file)); % this will load into var's: names, onsets and durations

        % need TR
        ppdir = fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient);
        protocoldir = fullfile(ppdir,protocol);
        load(fullfile(protocoldir,'parameters'));
        TR = parameters(1);
        nvols = parameters(3);
        
        durations2 = {};
        onsets2 = {};
        names2 = {};
        postfix = '';
        bKeepL = false;
        bKeepR = false;
        iBeideStrekken = [];
        iLinksStrekken = [];
        iRechtsStrekken = [];
        iRust = [];

        %TODO: instead of a fixed condition list I should fill a dynamic list with the names stored in the file(s)
        for iCondition=1:numel(names)
            switch lower(names{iCondition})
                case 'links_strekken'
                    keep = get(handles.chk_ls,'Value');
                    iLinksStrekken = iCondition; % need it below for scan nulling
                    if keep
                        bKeepL = true;
                        postfix = [postfix '-ls'];
                    end
                case 'rechts_strekken'
                    keep = get(handles.chk_rs,'Value');
                    iRechtsStrekken = iCondition; % need it below for scan nulling
                    if keep
                        bKeepR = true;
                        postfix = [postfix '-rs'];
                    end
                case 'beide_strekken'
                    keep = get(handles.chk_bs,'Value');
                    iBeideStrekken = iCondition; % need it below if this condition should be removed by scan nulling
                    if keep
                        postfix = [postfix '-bs'];
                    end
                case 'rust'
                    keep = get(handles.chk_rest,'Value');
                    iRust = iCondition; % need it below for scan nulling
                    if keep
                        postfix = [postfix '-rest'];
                    end
                otherwise
                    keep = 1;
                    if keep
                        postfix = [postfix '-' names{iCondition}];
                    end
            end
            if keep
                durations2{end+1}=durations{iCondition};
                onsets2{end+1}=onsets{iCondition};
                names2{end+1}=names{iCondition};
            end
        end

        % create scan nulling info if bs is not included in model
        if get(handles.chk_bs,'Value')==0 && ~isempty(iBeideStrekken)

            durations_bs=durations{iBeideStrekken};
            onsets_bs=onsets{iBeideStrekken};
                
            if get(handles.chk_bs_sn,'Value')>0 % include scan nulling in model itself if selected
                % add this as part of model (which will be convolved by SPM)
                N=ceil(durations_bs./TR);
                onsets3=cell(1,sum(N));
                names3=cell(size(onsets3));
                durations3=cell(size(onsets3));
                iSN=0;
                for iTrial=1:length(N)
                    for iVolume=1:N(iTrial)
                        iSN = iSN + 1;
                        onsets3{iSN} = onsets_bs(iTrial) + (iVolume-1) * TR;
                        names3{iSN} = sprintf('N-bs-%d-%d',iTrial,iVolume);
                        durations3{iSN} = TR;
                    end
                end
                names2 = { names2{:} names3{:} };
                onsets2 = { onsets2{:} onsets3{:} };
                durations2 = { durations2{:} durations3{:} };
                postfix = [postfix '-SNbs'];
            else  % add this as separate regressor instead of in model
                T=zeros(nvols,1,'int8');
                onsetVols=floor(onsets_bs./TR); % zero-based indices
                offsetsVols=ceil((onsets_bs+durations_bs)./TR) - 1;
                for iOnset=1:length(onsetVols)
                    for iVolume=onsetVols(iOnset):offsetsVols(iOnset)
                        T(iVolume+1) = 1; % iVolume is zero-based
                    end
                end
                regressor=zeros(nvols,sum(T),'int8');
                tmp=find(T);
                for i=1:length(tmp);
                    regressor(tmp(i),i)=1;
                end
                disp('saving scan-nulling info both condition: nulling_bs.txt');
                dlmwrite(fullfile(regressordir,'nulling_bs.txt'),regressor,' ');
            end
        end
%% ------------------------------------------------------------------------------------------------------------
% inserted script for creating two scannulling files that exclude everything bu a specific condition
        L(1).name = 'ls';
        L(1).index = iLinksStrekken;
        L(2).name = 'rs';
        L(2).index = iRechtsStrekken;
        L(3).name = 'rest';
        L(3).index = iRust;
        for iL=1:length(L)
            condition_index = L(iL).index;
            if ~isempty(condition_index)
                durations_L=durations{condition_index};
                onsets_L=onsets{condition_index};
                T=ones(nvols,1,'int8'); % null everything except where condition is active
                onsetVols=floor(onsets_L./TR); % zero-based indices
                offsetsVols=ceil((onsets_L+durations_L)./TR) - 1;
                for iOnset=1:length(onsetVols)
                    for iVolume=onsetVols(iOnset):offsetsVols(iOnset)
                        T(iVolume+1) = 0; % iVolume is zero-based
                    end
                end
                regressor=zeros(nvols,sum(T),'int8');
                tmp=find(T);
                for i=1:length(tmp);
                    regressor(tmp(i),i)=1;
                end
                filename_L = sprintf('nulling_all_but_%s.txt', L(iL).name);
                fprintf('saving scan-nulling info %s-only condition: %s\n', L(iL).name, filename_L);
                dlmwrite(fullfile(regressordir,filename_L),regressor,' ');
            end
        end
%% ------------------------------------------------------------------------------------------------------------
        % overwrite the cells we loaded before
        durations=durations2;
        onsets=onsets2;
        names=names2;
        
        % append scan nulling info if required and available
        if get(handles.chk_scan_nulling,'Value')
            nulling_filename = fullfile(regressordir,'nulling_design.mat');
            sm_filename = fullfile(regressordir,'selected_muscles.mat');

            if exist(nulling_filename,'file')
                load(nulling_filename); % load D
                if exist(sm_filename,'file')
                    contents = load(sm_filename);
                    if isfield(contents,'SM')
                        SM = contents.SM;
                    else
                        SM = [];
                    end
                    if length(SM)~=2 || ~isnumeric(SM)
                        warndlg(sprintf('muscles selection file should SM vector contain two indices: %s',sm_filename),'Warning!');
                    else
                        K = [bKeepR bKeepL]; % mind the L-R order. it would be saver to use string ID's...
                        for iMuscle=1:length(SM)
                            if K(iMuscle)
                                names = { names{:} D{SM(iMuscle)}.names{:} };
                                onsets = { onsets{:} D{SM(iMuscle)}.onsets{:} };
                                durations = { durations{:} D{SM(iMuscle)}.durations{:} };
                            end
                        end
                        postfix = [postfix '-SN'];
                    end
                else
                    warndlg(sprintf('no muscles selection available: %s',sm_filename),'Warning!');
                end
            else
                warndlg(sprintf('no scan nulling available: %s',nulling_filename),'Warning!');
            end
        end
        
        if iProtocol==1
            [dummy, filename, ext] = fileparts(handles.original_block_file);
            default_file = fullfile(regressordir,[filename postfix ext]);
            [filename, dummy] =  uiputfile('*.mat','Select the block_emg or block mat-file',default_file);
        end
        if filename
            saveas = fullfile(regressordir,filename);
            save(saveas,'durations','onsets','names');
            disp(['saved new SPM multiple conditions file to as ' saveas]);
        else
            disp('aborted creation of SPM multiple conditions file');
            break;
        end
    end
    close

% --- Executes on button press in chk_bs.
function chk_bs_Callback(hObject, eventdata, handles)
    if get(hObject,'Value')>0
        set(handles.chk_bs_sn,'Enable','Off','Value',0);
    else
        set(handles.chk_bs_sn,'Enable','On','Value',1);
    end
