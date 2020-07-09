function varargout = create_emg_regressors_select_muscles(varargin)
% CREATE_EMG_REGRESSORS_SELECT_MUSCLES M-file for create_emg_regressors_select_muscles.fig
%      CREATE_EMG_REGRESSORS_SELECT_MUSCLES, by itself, creates a new CREATE_EMG_REGRESSORS_SELECT_MUSCLES or raises the existing
%      singleton*.
%
%      H = CREATE_EMG_REGRESSORS_SELECT_MUSCLES returns the handle to a new CREATE_EMG_REGRESSORS_SELECT_MUSCLES or the handle to
%      the existing singleton*.
%
%      CREATE_EMG_REGRESSORS_SELECT_MUSCLES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_EMG_REGRESSORS_SELECT_MUSCLES.M with the given input arguments.
%
%      CREATE_EMG_REGRESSORS_SELECT_MUSCLES('Property','Value',...) creates a new CREATE_EMG_REGRESSORS_SELECT_MUSCLES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_emg_regressors_select_muscles_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_emg_regressors_select_muscles_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_emg_regressors_select_muscles

% Last Modified by GUIDE v2.5 09-Nov-2009 21:28:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_emg_regressors_select_muscles_OpeningFcn, ...
                   'gui_OutputFcn',  @create_emg_regressors_select_muscles_OutputFcn, ...
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



% --- Executes just before create_emg_regressors_select_muscles is made visible.
function create_emg_regressors_select_muscles_OpeningFcn(hObject, eventdata, handles, varargin)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    % Choose default command line output for create_emg_regressors_select_muscles
    handles.output = hObject;
%   handles.handles_to_close = [];
    handles.image_muscle = 1;
    handles.selected_muscles= [0 0 0 0 0 0 0 0];
    % Update handles structure
    guidata(hObject, handles);

    updateGraph(handles,0);
    
    % UIWAIT makes create_emg_regressors_select_muscles wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = create_emg_regressors_select_muscles_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in btn_previous.
function btn_previous_Callback(hObject, eventdata, handles)
    updateGraph(handles,-1);

% --- Executes on button press in btn_next.
function btn_next_Callback(hObject, eventdata, handles)
    updateGraph(handles,+1);

function updateGraph(handles, increment)
    emg_fmri_globals; % make sure this is the first call in the fn
    
    try
        handles.image_muscle = handles.image_muscle + increment;

        %------------------------------------------------------
        % paul replaced low quality jpeg's with the real thing
        title=['freq_' num2str(EMG_fMRI_freq_band_emg_model(1)) '_to_' num2str(EMG_fMRI_freq_band_emg_model(2))];
        emgreg = load('-ascii', fullfile(EMG_fMRI_study_dir, 'pp', EMG_fMRI_patient, EMG_fMRI_protoname_select_muscle, ['emg_' title '.txt']));
        if handles.image_muscle>size(emgreg,2)
            handles.image_muscle = 1; % just start over...
        elseif handles.image_muscle<1
            handles.image_muscle = size(emgreg,2);
        end
        handles.axes1 = plot(emgreg(:,handles.image_muscle),'m');
        %------------------------------------------------------

        lines = textread(fullfile(EMG_fMRI_study_dir, 'ruw', EMG_fMRI_patient, 'channels.txt'),'%s','delimiter','\n');
        muscle_name = lines{handles.image_muscle};
        muscle_name = [num2str(handles.image_muscle) '  ' muscle_name];
        set(handles.text1,'String',muscle_name);
        % let wel op dat door de vorige 4 regels verplicht moet worden aan de 8
        % regels in channels.txt
        
        guidata(handles.figure1, handles);   % update handles.image_muscle 
    catch
        msgbox('Couldn'' load or display the data','ERROR')
    end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
    % Hint: get(hObject,'Value') returns toggle state of togglebutton1

function handleMuscleSelection(handles, handle, musclenr)
    emg_fmri_globals; % make sure this is the first call in the fn
    handles.selected_muscles(musclenr) = get(handle,'Value');
    guidata(handle, handles);   % update handles.selected_muscles 

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
    handleMuscleSelection(handles, handles.checkbox1,1);

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
    handleMuscleSelection(handles, handles.checkbox2,2);

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
    handleMuscleSelection(handles, handles.checkbox3,3);

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
    handleMuscleSelection(handles, handles.checkbox4,4);

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
    handleMuscleSelection(handles, handles.checkbox5,5);

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
    handleMuscleSelection(handles, handles.checkbox6,6);

% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
    handleMuscleSelection(handles, handles.checkbox7,7);

% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
    handleMuscleSelection(handles, handles.checkbox8,8);

% --- Executes on button press in btn_make_regressors.
function btn_make_regressors_Callback(hObject, eventdata, handles)
    emg_fmri_globals; % make sure this is the first call in the fn

    if sum(handles.selected_muscles) == 2 
%         minmax = EMG_fMRI_freq_band_emg_model;
%         min = minmax(1);
%         max = minmax(2);

        % welk protocol?
        protocoldir = fullfile(EMG_fMRI_study_dir,'pp',EMG_fMRI_patient,EMG_fMRI_protoname_select_muscle);
        regressordir = fullfile(protocoldir,'regressor');

        % get the two selected EMG powers
        iLeftMuscle = 0;
        iRightMuscle = 0;
        for i=1:length(handles.selected_muscles)
            if (handles.selected_muscles(i) == 1)
                if (iRightMuscle == 0)
                    iRightMuscle = int32(i);
                    r_r = EMG_fMRI_freqreg(:,iRightMuscle);
                elseif (iLeftMuscle == 0)
                    iLeftMuscle = int32(i);
                    r_l = EMG_fMRI_freqreg(:,iLeftMuscle);
                end
            end
        end
        if iLeftMuscle==0 || iRightMuscle==0
            error('oops... didn''t find the two muscles!');
        end

        % select and load block design (links strekken, rechts strekken, beide strekken, rust)
        default_file = fullfile(regressordir,'block_emg.mat');
        if ~exist(default_file,'file')
            default_file = fullfile(regressordir,'block.mat');
            if ~exist(default_file,'file')
                default_file = regressordir;
            end
        end
        [filename, pathname] =  uigetfile('*.mat','Select the block_emg or block mat-file',default_file);
        % this will load the onsets, durations and names cell array's
        load(fullfile(pathname,filename));

        % load fMRI parameters
        parameters = load(fullfile(protocoldir,'parameters'));
        nvol = parameters(3);
        tr = parameters(1);
        
        % convert the onsets and durations to a matrix containing boxcar's
        % [nvolx4]
        m = mat_convert_onsets_durations(onsets,durations,tr,nvol,16);
        % you will now have a boxcar with 16 samples per volume, and an additional tail of about 10 volumes filled with zero's
        % downsample by calculating mean per volume
        m = round(mat_desample_matrix(m,nvol,16)); % TODO: what about the upsampling factor (16)
% 
% % beide armen de taak uitvoeren => also set left and right activation???
% for i=1:nvol
%     if m(i,3)>0
%         % still dicussion of what to do: activate L&R if both are active ???
%         m(i,1) = 1;
%         m(i,2) = 1;
%     end
% end

        
        applyChipping = false; % since we are using horn removal/scan nulling, we should not chip anymore
        if applyChipping
            % chop off spikes at begin and end of 'active EMG blocks'
            % [nvol x 4]
            nm = mat_chip_regressor(m,2);
            nm = mat_chip_regressor(nm,-2);
        else
            nm = m; % keep model as it is...
        end

        % normalize variance
        % [nvol x 1]
        r_l = r_l / std(r_l);
        r_r = r_r / std(r_r);
        
        
        % apply [chipped] model (all 4 conditions) to original but normalized regressors
        % [nvol x 4]
        model_l = r_l*ones(1,size(nm,2)).*nm;
        model_r = r_r*ones(1,size(nm,2)).*nm;

        % save regressors for 4 different situations L/R and non-ortho/ortho
        for mode=1:4
            switch (mode)
                case 1
                    P = 'emg_L_';
                    M = model_l;
                    
                case 2
                    P = 'emg_R_';
                    M = model_r;
                    
                case 3
                    P = 'ortho_emg_L_';
                    % remove condition factors from EMG signals; [nvol x 1]
                    o_r_l = mat_orthogonalize_regressor(r_l,nm);
                    % apply model (all 4 conditions) to ortogonalized&normalized regressor; [nvol x 4]
                    model_l = o_r_l*ones(1,size(nm,2)).*nm;
                    M = model_l;
                    
                case 4
                    P = 'ortho_emg_R_';
                    % remove condition factors from EMG signals; [nvol x 1]
                    o_r_r = mat_orthogonalize_regressor(r_r,nm);
                    % apply model (all 4 conditions) to ortogonalized&normalized regressor; [nvol x 4]
                    model_r = o_r_r*ones(1,size(nm,2)).*nm;
                    M = model_r;
            end
            
            % save all results of selected EMG muscle
            R = M(:,1);
            save(fullfile(regressordir, [P 'rs.txt']),   'R',  '-ascii'); % L/R selected muscle: links strekken
            %R = M(:,2);
            %save(fullfile(regressordir, [P 'rs.txt']),   'R',  '-ascii'); % L/R selected muscle: rechts strekken
            %R = M(:,3);
            %save(fullfile(regressordir, [P 'bs.txt']),   'R',  '-ascii'); % L/R selected muscle: beide strekken
            %R = M(:,4);
            %save(fullfile(regressordir, [P 'r.txt']),    'R',  '-ascii'); % L/R selected muscle: rust
            % and save the combined regressor containing chipped versions of both and left
            %R = M(:,1) + M(:,3);
            %save(fullfile(regressordir, [P 'ls_bs.txt']),   'R',  '-ascii'); % L/R selected muscle: both and left conditions
            % and save the combined regressor containing chipped versions of both and right
            %R = M(:,2) + M(:,3);
            %save(fullfile(regressordir, [P 'rs_bs.txt']),   'R',  '-ascii'); % L/R selected muscle: both and right conditions
            % and save the combined regressor containing chipped versions of all conditions except rest
            %R = M(:,1) + M(:,2) + M(:,3);
            %save(fullfile(regressordir, [P 'ls_rs_bs.txt']),   'R',  '-ascii'); % L/R selected muscle: all conditions except rest
            % and save the same including rest
            %R = R + M(:,4);
            %save(fullfile(regressordir, [P 'ls_rs_bs_r.txt']), 'R',  '-ascii'); % L/R selected muscle: all conditions incl. rest
        end
        %DIT HEB IK AANGEPAST HIERBOVEN:!!!
            % save all results of selected EMG muscle
            %R = M(:,1);
            %save(fullfile(regressordir, [P 'ls.txt']),   'R',  '-ascii'); % L/R selected muscle: links strekken
            %R = M(:,2);
            %save(fullfile(regressordir, [P 'rs.txt']),   'R',  '-ascii'); % L/R selected muscle: rechts strekken
            %R = M(:,3);
            %save(fullfile(regressordir, [P 'bs.txt']),   'R',  '-ascii'); % L/R selected muscle: beide strekken
            %R = M(:,4);
            %save(fullfile(regressordir, [P 'r.txt']),    'R',  '-ascii'); % L/R selected muscle: rust
            % and save the combined regressor containing chipped versions of both and left
           % R = M(:,1) + M(:,3);
           % save(fullfile(regressordir, [P 'ls_bs.txt']),   'R',  '-ascii'); % L/R selected muscle: both and left conditions
           % % and save the combined regressor containing chipped versions of both and right
           % R = M(:,2) + M(:,3);
           % save(fullfile(regressordir, [P 'rs_bs.txt']),   'R',  '-ascii'); % L/R selected muscle: both and right conditions
           % % and save the combined regressor containing chipped versions of all conditions except rest
            %R = M(:,1) + M(:,2) + M(:,3);
            %save(fullfile(regressordir, [P 'ls_rs_bs.txt']),   'R',  '-ascii'); % L/R selected muscle: all conditions except rest
           % % and save the same including rest
           % R = R + M(:,4);
           % save(fullfile(regressordir, [P 'ls_rs_bs_r.txt']), 'R',  '-ascii'); % L/R selected muscle: all conditions incl. rest
       % end

        
        save(fullfile(regressordir,'freqreg_R.txt'),            'r_r',      '-ascii');
        save(fullfile(regressordir,'freqreg_L.txt'),            'r_l',      '-ascii');
        save(fullfile(regressordir,'ortho_freqreg_L.txt'),      'o_r_l',    '-ascii');
        save(fullfile(regressordir,'ortho_freqreg_R.txt'),      'o_r_r',    '-ascii');

        if applyChipping
            [dummy, name, ext] = fileparts(filename);
            [onsets, durations] = mat_convert_to_onsets_durations(nm,tr);
            save(fullfile(pathname,[name '_chipped' ext]),'onsets','durations','names');
        end

        % also save the selected muscles
        SM = [iRightMuscle iLeftMuscle];
        save(fullfile(regressordir,'selected_muscles.mat'), 'SM');
        
        % show results in one figure containing 2x3 plots
%       handles.handles_to_close = zeros(3,1);
%       handles.handles_to_close(1) = 
        figure();
        
        subplot(2,3,1);
        plot(r_l);title('Regressor L');xlabel('scans');ylabel('mV');
        subplot(2,3,2);
        plot(o_r_l,'r');title('Orthogonalized Regressor L (r-EMG)');xlabel('scans');ylabel('mV');
        subplot(2,3,3);
        imagesc([m nm]);title('Block design and chipped design');xlabel('tasks');ylabel('time');
        
        subplot(2,3,4);
        plot(r_r);title('Regressor R');xlabel('scans');ylabel('mV');
        subplot(2,3,5);
        plot(o_r_r,'r');title('Orthogonalized Regressor R (r-EMG)');xlabel('scans');ylabel('mV');
        subplot(2,3,6);
        imagesc([model_l model_r]);title('Orthogonalized models L+R');xlabel('tasks');ylabel('time');
        colormap gray
        cmap = colormap;
        cmap = 1.-cmap;
        colormap(cmap);
        
% skip the convolution step because this is now handled by apply_hrf
%         c_r_l = mat_convolve_hrf(r_l,tr,1,'hrf1');
%         c_r_r = mat_convolve_hrf(r_r,tr,1,'hrf1');
%         c_o_r_l = mat_convolve_hrf(o_r_l,tr,1,'hrf1');
%         c_o_r_r = mat_convolve_hrf(o_r_r,tr,1,'hrf1');
%         %figure; plot(c_o_r_l);
%         c_model_l = mat_convolve_hrf(model_l,tr,1,'hrf1');
%         c_model_r = mat_convolve_hrf(model_r,tr,1,'hrf1');
%         handles.handles_to_close(4) = figure();
%         imagesc(c_model_r);title('Blockmodel convolved with HRF');xlabel('tasks');ylabel('time')
%         save conv_freqreg_L.txt c_r_l -ascii;
%         save conv_freqreg_R.txt c_r_r -ascii;
%         save conv_ortho_freqreg_L.txt c_o_r_l -ascii;
%         save conv_ortho_freqreg_R.txt c_o_r_r -ascii;
%         save conv_ortho_all_blocks_L.txt c_model_l -ascii;
%         save conv_ortho_all_blocks_R.txt c_model_r -ascii;

        guidata(hObject, handles); % save handles_to_close in handles for later
    else
        msgbox('Please select two muscles','ERROR');
    end

    
% --- Executes on button press in btn_close.
function btn_close_Callback(hObject, eventdata, handles)
    close

    % This will close figures created by
    % the ready and make models  button.
%     for handle_index=1:size(handles.handles_to_close,2)
%         try
%             close(handles.handles_to_close(handle_index));
%         catch
%         end
%     end


% --- Executes on button press in btn_inspect_emg.
function btn_inspect_emg_Callback(hObject, eventdata, handles)
    global EEG;
    pop_eegplot(EEG, 1, 1, 1);
