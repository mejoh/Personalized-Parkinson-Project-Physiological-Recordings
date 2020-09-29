function varargout = postprocess_regressors(varargin)
% postprocess_regressors M-file for postprocess_regressors.fig
%      postprocess_regressors, by itself, creates a new postprocess_regressors or raises the existing
%      singleton*.
%
%      H = postprocess_regressors returns the handle to a new postprocess_regressors or the handle to
%      the existing singleton*.
%
%      postprocess_regressors('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in postprocess_regressors.M with the given input arguments.
%
%      postprocess_regressors('Property','Value',...) creates a new postprocess_regressors or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before postprocess_regressors_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to postprocess_regressors_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help postprocess_regressors

% Last Modified by GUIDE v2.5 03-Nov-2009 15:49:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @postprocess_regressors_OpeningFcn, ...
                   'gui_OutputFcn',  @postprocess_regressors_OutputFcn, ...
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


% --- Executes just before postprocess_regressors is made visible.
function postprocess_regressors_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    if isempty(EMG_fMRI_study_dir) || ~isdir(EMG_fMRI_study_dir)
        errordlg('First select ''Select dataset''','Initialization error','modal'); 
        error('First select ''Select dataset'''); 
    end

    % Choose default command line output for postprocess_regressors
    handles.output = hObject;

    if isempty(varargin)
        handles.mode = 1; % convolve mode
    elseif isnumeric(varargin{1})
        handles.mode = varargin{1};
    elseif strmatch('convolve',varargin{1})
        handles.mode = 1; % convolve mode
    elseif strmatch('model',varargin{1})
        handles.mode = 2; % model selection mode
    end
    
    if handles.mode==1
        % convolve mode
        set(handles.panel_model,'Visible','off');

        msg = [ 'This dialog offers a standardized way to apply a hemodynamic response ' ...
                'function to the regressor files in the protocol directories.' ...
                sprintf('\n\n') ...
                'Select available protocols and files from the lists on the left. ' ...
                'Then select the appropriate hemodynamic response function and click ' ...
                'on the Convolve Button. Convolved regressor files will be prefixed with conv_.' ...
                sprintf('\n\n') ];

        % check SPM availability (required for hrf function)
        if exist('spm.m','file')
            handles.spm_version = spm('Ver');
            msg = [msg handles.spm_version ' available'];

            kernels = {
                'hrf',...
                'hrf (with time derivative)',...
                'hrf (with time and dispersion derivatives)' ...
    %           'Fourier set',...
    %           'Fourier set (Hanning)',...
    %           'Gamma functions',...
    %           'Finite Impulse Response' ...
             };

        else
            handles.spm_version = [];
            msg = [msg 'Warning: SPM HRF function not available'];

            kernels = {};
        end
        % and initialize the list with kernel descriptions
        set(handles.lst_hrf_kernel, 'String', kernels);
        set(handles.lst_hrf_kernel, 'Value', 1);
    else
        % model mode
        set(handles.panel_hrf,'Visible','off');
        set(handles.btn_convolve,'String','Create'); % replace button text with Create
        set(handles.lbl_title,'String','Compose new model (i.e. SPM multiple regressor file)'); % replace title
        set(handles.chk_create_info_file,'Value',1);

        msg = [ 'Select available protocols and regressors from the lists on the left that should be added to the model. ' ...
                'Then click on the Create Button to merge the regressors into one file and save it with the specified name. ' ...
                sprintf('\n\n') ];
    end
    
    % Update handles structure
    guidata(hObject, handles);

    % fill the protocol list and select all by default
    protocols = EMG_fMRI_proto_answer; % no need to copy this one to handles
    protocols(cellfun(@isempty,protocols)) = [];
    set(handles.lst_protocols,'value',[]); % first deselect everything
    set(handles.lst_protocols,'String', protocols);
    set(handles.lst_protocols,'value',1:length(protocols)); % then select all
    
    % initialize the file list
    UpdateList(handles);
    
    set(handles.lbl_message, 'String', msg);
    
    % UIWAIT makes postprocess_regressors wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

function UpdateList(handles)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    pattern = get(handles.txt_file_filter,'String');
    ppdir = fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient);
    protocols = get(handles.lst_protocols,'String');
    selection = get(handles.lst_protocols,'Value');
    filelist = [];
    % walk trough all selected protocol directories and compose a file list
    for iSelection=1:length(selection)
        iProtocol = selection(iSelection);
        protocol = protocols{iProtocol};
        regressordir = fullfile(ppdir,protocol,'regressor');
        files = dir(fullfile(regressordir,pattern));
        % remove directories from the list
        files = {files(~[files.isdir]).name}; 
        % remove files that start with 'conv' when mode is convolve
        if handles.mode==1
            files(strmatch('conv',files)) = [];
        end
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
    set(handles.lst_files,'Value',[]); % first deselect everything
    set(handles.lst_files,'String',filelist);
    set(handles.lst_files,'Value',1:length(filelist)); 
%   set(handles.lst_files,'Value',cellfun(@isempty,filelist));
    CheckButtons(handles);
  
function CheckButtons(handles)
    if handles.mode==1 && (isempty(handles.spm_version) || isempty(get(handles.lst_files,'Value')))
        on_or_off = 'off';
    else
        on_or_off = 'on';
    end
    set(handles.btn_convolve,'Enable',on_or_off);


% --- Outputs from this function are returned to the command line.
function varargout = postprocess_regressors_OutputFcn(hObject, eventdata, handles) 
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

% --- Executes on button press in btn_select_all_files.
function btn_select_all_files_Callback(hObject, eventdata, handles)
    set(handles.lst_files,'value',1:length(get(handles.lst_files,'String'))); 

% --- Executes during object creation, after setting all properties.
function lst_hrf_kernel_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in lst_hrf_kernel.
function lst_hrf_kernel_Callback(hObject, eventdata, handles)
    CheckButtons(handles);

% --- Executes on button press in btn_convolve.
function btn_convolve_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn

    % Note: this function implements two separate functionalities:
    % 1) convolve the selected regressor files
    % 2) compose a new model containing the selected regressors
    % Because of the looping similiarities, these functionalities are combined in this GUI.
    
    message = [];
    nErrors = 0;
    nSkipped = 0;
    nOK = 0;
    upsample_factor = 16; % TODO <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< use >=16
    
    % first check if we are allowed to overwrite existing files
    overwrite_existing = get(handles.chk_overwrite_existing,'Value');
    % get root directory, selected filenames and selected protocols
    ppdir = fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient);
    files = get(handles.lst_files,'String');
    file_selection = get(handles.lst_files,'Value');
    protocols = get(handles.lst_protocols,'String');
    protocol_selection = get(handles.lst_protocols,'Value');
    % walk trough all selected protocol directories
    for iProtocolSelection=1:length(protocol_selection)
        iProtocol = protocol_selection(iProtocolSelection);
        protocol = protocols{iProtocol};
        protocoldir = fullfile(ppdir,protocol);
        regressordir = fullfile(protocoldir,'regressor');
        
        % get TR and #volumes for this protocol
        parameters = load(fullfile(ppdir,protocol,'parameters'));
        tr = parameters(1);
        nvols = parameters(3);
            
        % prepare some protocol specific stuff
        if handles.mode==1 % convolve mode: 

            % get the selected hemodynamic response function from SPM
            kernel_names = get(handles.lst_hrf_kernel, 'String');
            kernel_selection = get(handles.lst_hrf_kernel,'Value');
            xBF.dt     = tr/upsample_factor;                % time bin length (seconds)  <== TODO upsample before conv. and downsample at end !!!!!!!!!!
            xBF.name   = kernel_names{kernel_selection};    % description of basis functions specified
            % length and order must be set for 'Fourier set','Fourier set (Hanning)', 
            %                                  'Gamma functions' and 'Finite Impulse Response'
            %     xBF.length  % window length (seconds)
            %     xBF.order   % order
            xBF = spm_get_bf(xBF); % get xBF.bf (Matrix of basis functions; one BF per column)
            %sum(xBF.bf) TODO: NOTE: spm text indicates this should be orthonormal; however, the derivative BF's seem not to sum to 1
            
        else % model mode
            outputname = get(handles.txt_filename,'String');
            [ path outputbasename ext ] = fileparts(outputname);
            if isempty(ext)
                ext = '.txt';
            end
            outputname = [ outputbasename ext ]; % don't allow any path
%           modeldir = fullfile(protocoldir,'model');
            modeldir = fullfile(protocoldir,'regressor'); % don't use a separate directory yet
            % write models to model directory, so check for existence
            if ~exist(modeldir,'dir')
                [status, msg ] = mkdir(modeldir);
                if ~status
                    message = [message sprintf('\nERROR: %s', msg)];
                    set(handles.lbl_message,'String',message);
                    drawnow expose;
                    nSkipped = nSkipped + 1;
                    continue; % with next protocol
                end
            end

            outputpath = fullfile(modeldir, outputname);
            model = [];
            if exist(outputpath,'file') && ~overwrite_existing
                message = [message sprintf('\n%s, %s\t Skip (output file exists)', protocol, outputname)];
                set(handles.lbl_message,'String',message);
                drawnow expose;
                nSkipped = nSkipped + 1;
                continue; % with next protocol
            end
            
            % build a cell array containing the names of the regressors
            regressor_names = {};
        end
        
        % walk trough all selected files
        for iPass=1:2
            % do it twice: once for all non-nulling regressors, and then for the nulling; just to make sure those come at the end
            for iFileSelection=1:length(file_selection)
                % which regressor file?
                iFile = file_selection(iFileSelection);
                inputname = files{iFile};
                isnulling = ~isempty(findstr(inputname,'null'));
                if (iPass==1 && isnulling) || (iPass==2 && ~isnulling)
                    continue; % nulling regressors in second pass
                end
                inputpath = fullfile(regressordir,inputname);
                msg = [];

                if exist(inputpath,'file')

                    % load the regressor
                    R = load(inputpath);
                    if isnumeric(R) && size(R,1)>=1 
                        if size(R,1)~=nvols
                            msg = sprintf('Warning: #samples(%d) <> #volumes(%d)', size(R,1), nvols);
                        end
                        nRows = size(R,1);
                        nCols = size(R,2);

                        if handles.mode==1   % convolve mode
                            outputpath = fullfile(regressordir,['conv_' inputname]);
                            if ~exist(outputpath,'file') || overwrite_existing
                                % so far for the GUI, start the conversion
                                nBF = size(xBF.bf,2);           % length of convolution kernel
                                CR = zeros(nRows,nBF.*nCols);   % preallocate room for Convolved Regressor
                                % convolve all regressors, one by one
                                for iCol=1:nCols
                                    % convolve separately with all basis functions
                                    for iBF=1:nBF
                                        U = series_upsample(R(:,iCol),upsample_factor);
                                        C = conv(U, xBF.bf(:,iBF)); % convolve with bf kernel
                                        C = series_downsample(C,upsample_factor);
                                        CR(:,iCol+iBF-1) = C(1:nRows); % convolving lengthens the vector, so ignore tail
                                    end
                                end
                                save(outputpath,'CR','-ASCII');  % save results
                                nOK = nOK + 1;
                            else
                                msg = 'Skip (output file exists)';
                                nSkipped = nSkipped + 1;
                            end

                        else  % model mode
                            regressor_names{end+1} = inputname;
                            model = [ model R ];
                            nOK = nOK + 1;
                        end
                    else
                        msg = 'Error: no valid data';
                        nErrors = nErrors + 1;
                    end
                end % if regressor file exists

                % something to report?
                if ~isempty(msg)
                    message = [message sprintf('\n%s, %s\t %s',protocol, inputname, msg)];
                    set(handles.lbl_message,'String',message);
                    drawnow expose;
                end
            end % for all selected regressor files
        end % for two passes
        
        if handles.mode==2 % model mode
            if ~isempty(model)
                % save model 
                save(outputpath,'model','-ASCII');  
                % also save a model info file containing the names of all regressor columns
                if get(handles.chk_create_info_file,'Value')
                    outputpath = fullfile(modeldir, outputname);
                    info_filename = [outputbasename '.info'];
                    info_filepath = fullfile(modeldir, info_filename);
                    f = fopen(info_filepath,'wt');
                    if f==-1
                        nErrors = nErrors + 1;
                        message = [message sprintf('\n%s, ERROR: couldn;t create %s',protocol, info_filename)];
                        set(handles.lbl_message,'String',message);
                        drawnow expose;
                    else
                        for iName=1:length(regressor_names)
                            fprintf(f,'%d %s\n',iName, regressor_names{iName});
                        end
                        fclose(f);
                    end
%                    save([outputpath '.info'],'regressor_names','-ASCII');  % save column info
                    regressor_names = {};
                end
            end
        end
        
    end % for all selected protocols
    
    if nOK
        message = [message sprintf('\nProcessed %d regressors of %d protocol(s)',nOK, length(protocol_selection))];
        if handles.mode==1 % convolve mode
            message = [message sprintf('\nNew files are prefixed with conv_')];
        else
            message = [message sprintf('\nModel files are saved as %s',outputname)];
        end
    end
    if nSkipped
        message = [message sprintf('\n%d FILES SKIPPED',nSkipped)];
    end
    if nErrors
        message = [message sprintf('\n%d FILES FAILED',nErrors)];
    end
    set(handles.lbl_message,'String',message);
    if nErrors==0 && nSkipped==0
        set(handles.btn_convolve,'Enable','off');
    end
%    close

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
    
% --- Executes on button press in chk_overwrite_existing.
function chk_overwrite_existing_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function txt_filename_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function txt_filename_Callback(hObject, eventdata, handles)
    CheckButtons(handles);

% --- Executes on button press in chk_create_info_file.
function chk_create_info_file_Callback(hObject, eventdata, handles)
