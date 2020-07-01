function varargout = inspect_spectrograms(varargin)
% INSPECT_SPECTROGRAMS M-file for inspect_spectrograms.fig
%      INSPECT_SPECTROGRAMS, by itself, creates a new INSPECT_SPECTROGRAMS or raises the existing
%      singleton*.
%
%      H = INSPECT_SPECTROGRAMS returns the handle to a new INSPECT_SPECTROGRAMS or the handle to
%      the existing singleton*.
%
%      INSPECT_SPECTROGRAMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSPECT_SPECTROGRAMS.M with the given input arguments.
%
%      INSPECT_SPECTROGRAMS('Property','Value',...) creates a new INSPECT_SPECTROGRAMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inspect_spectrograms_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inspect_spectrograms_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inspect_spectrograms

% Last Modified by GUIDE v2.5 17-Jun-2011 17:27:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inspect_spectrograms_OpeningFcn, ...
                   'gui_OutputFcn',  @inspect_spectrograms_OutputFcn, ...
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

% --- Executes just before inspect_spectrograms is made visible.
function inspect_spectrograms_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % varargin   command line arguments to inspect_spectrograms (see VARARGIN)

    % Choose default command line output for inspect_spectrograms
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using inspect_spectrograms.
    if strcmp(get(hObject,'Visible'),'off')
        set(handles.lstSignals, 'Value', 1);
        lstSignals_Callback(handles.lstSignals,eventdata,handles);
    end

    % UIWAIT makes inspect_spectrograms wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = inspect_spectrograms_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);

    % Get default command line output from handles structure
    varargout{1} = handles.output;

% --- Executes on button press in btnClose.
function btnClose_Callback(hObject, eventdata, handles)
    close

  
function RefreshSpectrogram(handles)
% Hints: contents = get(hObject,'String') returns lstSignals contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstSignals

    emg_fmri_globals; % make sure this is the first call in the fn

    axes(handles.axes1);
    cla;

    popup_sel_index = get(handles.lstSignals, 'Value');
    if ~isempty(popup_sel_index)

        [ onsetSamples nSamplesPerEpoch ] = get_volume_onset_indices(EEG);
        if nSamplesPerEpoch>0
            NFFT=nSamplesPerEpoch;
        else
            NFFT=3*EEG.srate;
            warning('No Volume events available. Chopping signal into epochs of 3 seconds.')
        end
        EMG = EEG.data(popup_sel_index,:);
        
        % filter high-pass @25Hz...
        [b a]=butter(5,25/(EEG.srate/2),'high');
        EMG=filter(b,a,EMG);
        % rectify
        if get(handles.chkRectify,'Value')
            EMG = abs(EMG);
        end
        [Y,F,T,P] = spectrogram(double(EMG),NFFT,0,NFFT,EEG.srate);
        fFromFreq = 2;
        fToFreq   = 15;
        if fFromFreq>0 
            % Get first index >=2Hz to be able to skip lowest frequencies in plot.
            % This was included to test if the lowest frequencies disturbed the autoscaling of the plot (but didn't help).
            iFrom = find(F>=fFromFreq,1,'first'); 
            F = F(iFrom:end,:);   
            Z = 20*log10(abs(P(iFrom:end,:)));  % Z = abs(Y(iFrom:end,:));
%           Z = P(iFrom:end,:);  % Z = abs(Y(iFrom:end,:));
        else
            Z = 20*log10(abs(P));
        end
        
%         % sneaky stuff;;;;we don't like large negative logs that spoil our plot 
%         DIT IS OORSPRONKELIJK ACTIEF 20110824_sarvi
%          clipLow = str2double(get(handles.txtClipLow,'String'));
%         Z(Z<clipLow)=clipLow; 
%%
% fh=figure('visible','off');
% iTo = find(F<=15,1,'last'); 
% Z15 = Z(1:iTo,:);
% F15 = F(1:iTo,:);
% % for iTime=1:size(Z15,2)
% %     plot(F15,Z15(:,iTime));
% %     saveas(fh, sprintf('d:/temp/log_spec_spier_%02d_%03d.jpg', popup_sel_index, iTime), 'jpg');
% % end
% iFrom = find(F>=2,1,'first'); 
% iTo = find(F<=5,1,'last'); 
% Ztemp = Z(iFrom:iTo,:);
% plot(mean(Ztemp,1));
% saveas(fh, sprintf('d:/temp/log_spec_spier_%02d_sum.jpg', popup_sel_index), 'jpg');
% plot(mean(Ztemp,1)-mean(Z15,1));
% saveas(fh, sprintf('d:/temp/log_spec_spier_%02d_sum_base.jpg', popup_sel_index), 'jpg');
% close(fh)
%%
        surf(T,F,Z,'EdgeColor','none');
        axis xy; axis([1 T(end) fFromFreq fToFreq ]); colormap(jet); view(0,90); % autoscale colors
        caxis auto
        xlabel('Time (sec)');
        ylabel('Frequency (Hz)');
        colorbar;
    end
        
% --- Executes on selection change in lstSignals.
function lstSignals_Callback(hObject, eventdata, handles)
    RefreshSpectrogram(handles);
    
% --- Executes during object creation, after setting all properties.
function lstSignals_CreateFcn(hObject, eventdata, handles)

    emg_fmri_globals; % make sure this is the first call in the fn
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
         set(hObject,'BackgroundColor','white');
    end

    % load all signal names into drop-down list
    set(hObject, 'String', { EEG.chanlocs.labels });


% --- Executes on button press in chkRectify.
function chkRectify_Callback(hObject, eventdata, handles)
    RefreshSpectrogram(handles);
    



function txtClipLow_Callback(hObject, eventdata, handles)
    RefreshSpectrogram(handles);


% --- Executes during object creation, after setting all properties.
function txtClipLow_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
