function varargout = pf_emg_raw2regr_mkregressor_gui(varargin)
% PF_EMG_RAW2REGR_MKREGRESSOR_GUI MATLAB code for pf_emg_raw2regr_mkregressor_gui.fig
%      PF_EMG_RAW2REGR_MKREGRESSOR_GUI, by itself, creates a new PF_EMG_RAW2REGR_MKREGRESSOR_GUI or raises the existing
%      singleton*.
%
%      H = PF_EMG_RAW2REGR_MKREGRESSOR_GUI returns the handle to a new PF_EMG_RAW2REGR_MKREGRESSOR_GUI or the handle to
%      the existing singleton*.
%
%      PF_EMG_RAW2REGR_MKREGRESSOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PF_EMG_RAW2REGR_MKREGRESSOR_GUI.M with the given input arguments.
%
%      PF_EMG_RAW2REGR_MKREGRESSOR_GUI('Property','Value',...) creates a new PF_EMG_RAW2REGR_MKREGRESSOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pf_emg_raw2regr_mkregressor_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pf_emg_raw2regr_mkregressor_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%=========================================================================%
%=========================== USER INFO ===================================%
%=========================================================================%
% pf_emg_raw2regr_mkregressor_gui is part of the pf_emg_raw2regr batch
% function. Specifically, it will give you a GUI that let's you
% interactively select tremor frequency and create corresponding
% regressors us pf_emg_raw2regr_mkregressor. For this, it will need
% frequency analysed data created using the 'prepemg' function of
% pf_emg_raw2regr. The output of this function (which is a .mat file) can
% be loaded using this GUI. 
%
% The GUI is organized as follows: 
%   - 2 upper subplots: 
%   -- left subplot: plotting the power spectrum of channels 1:8
%   (which in my case corresponded to the EMG channels)
%   -- right subplot: plotting the power spectrum of channels 11:13 (which
%   in my case corresponded to the accelerometry channels)
%   
%   - 2 lower subplots:
%   -- left subplot: corresponds to upper left subplot. Specifically, once
%   a frequency is selected, the corresponding time-frequency
%   representation is plotted here. Subsequently this regressor (and
%   transformations can be saved). 
%   -- right subplot: corresponds to upper right subplot. Same story for
%   this
%
%   - One singular plot on the right of the GUI: this is reserved for
%   showing coherence analysis (if performed) between channels from the
%   left plot and right plot. 
%
% If you want the left and right subplot to plot different channels, you
% can edit this under the function openfile_Callback in this script. 
%
% Prior to creating regressors, one must specify
% the options of pf_emg_raw2regr_mkregressor (same as specified in the main
% pf_emg_raw2regr file). These options are located in the following
% function in this GUI file: 'create_regr_acc_callback' and
% 'create_regr_emg_callback'. Change the configuration under 
% "% --- Initiate Configuration structure --- %"
% 
% In general, the GUI should consist of the following steps:
% Step 1): Open file (will let you select the the prepemg file)
% Step 2): Press the 'select' button. You can now select a frequency in
% your power spectrum (upper rows). Only one channel can be selected, but
% multiple frequencies per channel can be selected (wich will be averaged).
% Step 3): Once a selection has been made, press the "Show TFR" button.
% Now, the time-frequency representation corresponding to the specified
% frequency will be plotted here. Check if this TFR makes sense, does it
% really represent tremor fluctuapathtions?
% Step 4): If the TFR looks satisfactory to be used as a regressor, press
% the "create regressor" drop down menu. Four options are displayed:
% 'power', 'amplitude', 'log', 'all'. Power will simply use the power,
% amplitude is sqrt(power) and log is log10(power). Then regressors
% suitable for your fMRI GLM will be created and stored in .mat files with
% 'R' (containing the values, unconvolved and convolved) and 'names'. This
% file is recognized by SPM.
%
% (C) Michiel Dirkx, 2015
% $ParkFunc, version 20150211
% Updated 20181210
%=========================================================================%
%=========================================================================%
%=========================================================================%

% Last Modified by GUIDE v2.5 16-Dec-2018 13:26:53

% May 20th 2020 - Start modification - Directory and paths added by kevvdber
scriptdir = '/project/3022026.01/analyses/kevin/Scripts/EMG-ACC';
addpath(fullfile(scriptdir,'ParkFunC_EMG','EMG'));
addpath(fullfile(scriptdir,'ParkFunC_EMG','Helpers'));
addpath('/home/common/matlab/spm12');
% May 20th 2020 - End modification 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
whitebg([0.2 0.2 0.2])
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pf_emg_raw2regr_mkregressor_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pf_emg_raw2regr_mkregressor_gui_OutputFcn, ...
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

% --- Executes just before pf_emg_raw2regr_mkregressor_gui is made visible.
function pf_emg_raw2regr_mkregressor_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pf_emg_raw2regr_mkregressor_gui (see VARARGIN)

% Choose default command line output for pf_emg_raw2regr_mkregressor_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pf_emg_raw2regr_mkregressor_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pf_emg_raw2regr_mkregressor_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in openfile.
function openfile_Callback(hObject, eventdata, handles)
% hObject    handle to openfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Clear previous datasets --- %

cla(handles.EMG);cla(handles.ACC);cla(handles.COH);
cla(handles.Regressor1);cla(handles.Regressor2);
if isfield(handles,'data'); handles =   rmfield(handles,{'data';'psall'}); end
if isfield(handles,'tfr') ; handles =   rmfield(handles,{'tfr'}); end

% --- Get File --- %

[file,path]    =   uigetfile;
cd(path)
disp('Opening file (this can take a few seconds)...');
F              =   open(fullfile(path,file));
fn             =   fieldnames(F);
data           =   F.(fn{1});

if length(size(data.powspctrm)) > 2
    psall          =   nanmean(data.powspctrm(:,:,round(data.prestart_sec):end),3);
else
    psall          =   data.powspctrm;
end
disp('Plotting data...')

% --- Plot EMG --- %

% chan        =   inputdlg('Specify channels to be plotted in the LEFT subplots (e.g. 1:8)','Channel selection',[1 40],{'1:8'});
% chan        =   str2num(chan{1});
chan        =   1:4;
data.chanleft   =   chan; % store for later

col         =   distinguishable_colors(length(chan));

subplot(handles.EMG);cla;legend(handles.EMG,'off');
for a = chan
    plot(data.freq,psall(a,:),'color',col(a,:));
    hold on
end
set(gca,'Xtick',round(data.freq(1:2:end)*100)/100,'Xticklabel',round(data.freq(1:2:end)*100)/100);
xlabel('Frequency (Hz)');
ylabel('Nanmean Power (uV^2)');
title(['Powerspectrum ' data.sub '-' data.sess '-' data.run]);
legend(handles.EMG,data.label(chan),'interpreter','none')
legend('boxoff')

% --- Plot ACC --- %

% chan             =   inputdlg('Specify channels to be plotted in the RIGHT subplots (e.g. 9:12)','Channel selection',[1 40],{'9:12'});
% chan             =   str2num(chan{1});
chan        =   5:8;

data.chanright   =   chan; % store for later
col              =   distinguishable_colors(length(chan));
cnt              =   1;

subplot(handles.ACC);cla;
for a = chan
    plot(data.freq,psall(a,:),'color',col(cnt,:));
    hold on
    cnt = cnt+1;
end
set(gca,'Xtick',round(data.freq(1:2:end)*100)/100,'Xticklabel',round(data.freq(1:2:end)*100)/100);
xlabel('Frequency (Hz)');
ylabel('Nanmean Power (uV^2)');
title(['Powerspectrum ' data.sub '-' data.sess '-' data.run]);
legend(handles.ACC,data.label(chan),'interpreter','none')
legend('boxoff')

% --- Plot coherence if present --- %

if isfield(data,'coh')
    
    subplot(handles.COH);cla;
    imagesc(data.coh.cohspctrm);
    
    % --- Create recognizable xlabel --- %
    
    uFreq = unique(round(data.coh.freq));
    for d = 1:length(uFreq)
        iFreq      = find(floor(data.coh.freq)==uFreq(d));
        xtik(d)    = iFreq(1);
        xtiklab(d) = uFreq(d);
    end
    set(gca,'Xtick',xtik,'Xticklabel',xtiklab)
    
    % --- Create recognizable ylabel --- %
    
    for d = 1:length(data.coh.labelcmb)
        ytik(d)      = d;
        ytiklab{d,1} = data.coh.labelcmb{d,1};
    end
    set(gca,'Ytick',ytik,'Yticklabel',ytiklab);
    
    % --- Rest of graphics --- %
    
    xlabel('Frequency (Hz)','fontweight','b')
    title(['Coherence analysis (' data.coh.labelcmb{1,2} ')'])
    colorbar
end

handles.data        =   data;
handles.data.path   =   path;
handles.psall       =   psall;

guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns openfile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from openfile

% --- Executes during object creation, after setting all properties.
function openfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to openfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showtfr_acc.
function showtfr_acc_Callback(hObject, eventdata, handles)
% hObject    handle to showtfr_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Retrieve selected data --- %

chanidx           = handles.data.chanright;

bh      =   findobj(handles.ACC,'-property','BrushData');
bval    =   get(bh,'BrushData');
bval    =   flipud(bval); % Because everything is loaded in inverse order

if ~iscell(bval)
    bval = {bval};
end

ChanI   =   find(cellfun(@(x) any(x),bval));  % Logical index of selected channel
nChanI  =   length(ChanI);
if nChanI>1
    error('mkregressor:showtfr','Please only select one channel')
end

% --- Retrieve channel/frequency selected --- %

CurFreq           = handles.data;
CurFreq.label     = CurFreq.label(chanidx);
CurFreq.powspctrm = CurFreq.powspctrm(chanidx,:,:);
FreqI             =   logical(bval{ChanI});       % Logical index of selected frequency

fprintf('%s\n',['- You selected channel "' CurFreq.label{ChanI} '" with frequency "' num2str(CurFreq.freq(FreqI)) '" Hz'])

if length(find(FreqI))>2
    tfrs    =   CurFreq.powspctrm(ChanI,FreqI,:);
    tfr     =   squeeze(mean(tfrs,2));
    fi      =   find(FreqI);
    freqlab =   [num2str(CurFreq.freq(fi(1))) '-' num2str(CurFreq.freq(fi(end)))];
else
    tfr     =   squeeze(CurFreq.powspctrm(ChanI,FreqI,:));
    freqlab =   num2str(CurFreq.freq(FreqI));
end

% --- Plot the TFR --- %

subplot(handles.Regressor2);cla;
plot(CurFreq.time,tfr);
title([handles.data.sub '-' handles.data.sess '-' handles.data.run ' '  CurFreq.label{ChanI} ' (' freqlab ' Hz)'])
xlabel('Time (seconds)');ylabel('Power (uV^2)');
axis([min(CurFreq.time)-1 max(CurFreq.time)+1 0 max(tfr)*1.05])

% --- Save selected channel/frequency for CreateRegressor callback --- %

handles.tfr.acc.powspctrm      =   tfr;
handles.tfr.acc.label          =   CurFreq.label(ChanI);
handles.tfr.acc.freq           =   CurFreq.freq(FreqI);
handles.tfr.acc.freqlab        =   freqlab;
handles.tfr.acc.time           =   CurFreq.time;
handles.tfr.acc.cfg            =   CurFreq.cfg;
handles.tfr.acc.startscan_sec  =   CurFreq.startscan_sec;
handles.tfr.acc.startscan_sca  =   CurFreq.startscan_sca;
handles.tfr.acc.prestart_sec   =   CurFreq.prestart_sec;
handles.tfr.acc.prestart_sca   =   CurFreq.prestart_sca;
handles.tfr.acc.tr             =   CurFreq.tr;
handles.tfr.acc.mtr            =   CurFreq.mtr;
handles.tfr.acc.scanid         =   CurFreq.scanid;
handles.tfr.acc.fs             =   CurFreq.fs;
handles.tfr.acc.meth           =   CurFreq.meth;
handles.tfr.acc.createdate     =   CurFreq.createdate;
handles.tfr.acc.sub            =   CurFreq.sub;
handles.tfr.acc.sess           =   CurFreq.sess;
handles.tfr.acc.run            =   CurFreq.run;

handles.curtfr.acc.tc          =   handles.tfr.acc.powspctrm(~isnan(handles.tfr.acc.powspctrm));
handles.curtfr.acc.time        =   handles.tfr.acc.time(~isnan(handles.tfr.acc.powspctrm));
% handles.curtfr.acc(isnan(handles.curtfr.acc)) =   0;

% --- Save to guidata --- %

guidata(hObject, handles);

% --- END --- %


% --- Executes on selection change in create_regr_acc.
function create_regr_acc_Callback(hObject, eventdata, handles)
% hObject    handle to create_regr_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns create_regr_acc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from create_regr_acc

contents    =   cellstr(get(hObject,'String'));
sel         =   contents{get(hObject,'Value')};
breakflag   =   0;

switch sel
    case 'All'
        conf.mkregr.meth    =   {'power';'amplitude';'log'};
    case 'Power'
        conf.mkregr.meth    =   {'power';};
    case 'Amplitude'
        conf.mkregr.meth    =   {'amplitude'};
    case 'Log'
        conf.mkregr.meth    =   {'log'};
    otherwise
        breakflag = 1;
end

% --- Checking --- %

if ~isfield(handles.tfr,'acc')
   error('seltremgui:crearegr','Please press the "Show TFR" button first') 
end

%=========================================================================%
% ------------------------- Configuration ------------------------------- %
%=========================================================================%

% --- Directories --- %

conf.dir.prepemg      =   handles.data.path;                                                % Directory of the loaded file
conf.dir.regr         =   fullfile(conf.dir.prepemg,'Regressors'); % This is where regressors will be saved (in subfolder ZSCORED, or NOTZSCORED)
conf.dir.fmri.root    = '';                           % fMRI root directory (containing all subject folders), necessary to detect amount of scans (for building regressor)
conf.dir.fmri.preproc = {'CurSub' 'func' 'CurSess' 'CurRun' 'preproc' 'norm'};              % The subfolder of the root directory where scans are stored. IN this case: fullfile(conf.dir.fmri.root,CurSub,func,CurSess,CurRun,preproc,norm), which results in: /home/action/micdir/data/DRDR_MRI/fMRI/s01/func/SESS1/RS/preproc/norm
conf.dir.event        =   '';                     % Event directory (usually your .vmrk file), if you want to plot the conditions in mkregr

% --- Rest of mkregr configuration --- %

conf.mkregr.file            = '';                       % Name of prepemg data (leave empty for gui).
conf.mkregr.data            = handles.tfr.acc;          % The field 'data' is reserved for regressors selected through the GUI. Instead of searching for a file it will use the data defined in handles.tfr.emg which is defined when the 'Show TFR' button is pressed.

conf.mkregr.nscan     = 'detect';                       % Amount of scans your regressor should contain ('detect' to detect the amount in conf.dir.fmri.preproc)
conf.mkregr.scanname  = '|w*';                          % Search criterium for images (only if conf.mkregr.nscan = 'detect'; uses pf_findfile);
conf.mkregr.sample    = 1;                              % Samplenr of every scan which will be used to represent the tremor during scan (if you used slice time correction, use the reference slice timing here)
conf.mkregr.zscore    = 'yes';                          % If yes, than the data will first be z-normalized
conf.mkregr.trans     = {'deriv1'};                     % Transformation of made regressors ('deriv1': first temporal derivative)
conf.mkregr.save      = 'yes';                          % Save regressors/figures

conf.mkregr.plotcond  = 'no';                          % If you want to plot the condition (will use the conditions from conf.dir.event)
conf.mkregr.evefile   = '/CurSub/&/CurSess/&/CurRun/&/.vmrk/';   % Event file (if you want to plot the conditions
conf.mkregr.mrk.scan  = 'R  1';                         % Scan marker (if you want to plot scanlines)
conf.mkregr.mrk.onset = 'S 11';                         % Onset marker of condition (if you want to plot events)
conf.mkregr.mrk.offset= 'S 12';                         % Offset marker of condition (if you want to plot events)                                     
conf.mkregr.plotscanlines = 'no';                       % If yes then it will plot the scanlines in the original resolution.

% --- save figure if desired --- %

savefig = 1;
if savefig
    q = gcf;
    name    =   ['PowSpct_selectedACC_' handles.tfr.acc.sub '-' handles.tfr.acc.sess];
    if ~exist(conf.dir.regr,'dir'); mkdir(conf.dir.regr); end
    print(q,'-dtiff','-r800',fullfile(conf.dir.regr,name))
    fprintf('%s\n',['Saved figure to ' fullfile(conf.dir.regr,name)])
end

if ~breakflag
    pf_emg_raw2regr(conf,[],'mkregressor');
end


% --- Executes during object creation, after setting all properties.
function create_regr_acc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to create_regr_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showtfr_emg.
function showtfr_emg_Callback(hObject, eventdata, handles)
% hObject    handle to showtfr_emg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Retrieve selected data --- %

chanidx           = handles.data.chanleft;

bh      =   findobj(handles.EMG,'-property','BrushData');
bval    =   get(bh,'BrushData');
bval    =   flipud(bval); % Because everything is loaded in inverse order

if ~iscell(bval)
    bval = {bval};
end

ChanI   =   find(cellfun(@(x) any(x),bval));  % Logical index of selected channel
nChanI  =   length(ChanI);
if nChanI>1
    error('mkregressor:showtfr','Please only select one channel')
end

% --- Retrieve channel/frequency selected --- %

CurFreq           = handles.data;
CurFreq.label     = CurFreq.label(chanidx);
CurFreq.powspctrm = CurFreq.powspctrm(chanidx,:,:);
FreqI             =   logical(bval{ChanI});       % Logical index of selected frequency

fprintf('%s\n',['- You selected channel "' CurFreq.label{ChanI} '" with frequency "' num2str(CurFreq.freq(FreqI)) '" Hz'])

if length(find(FreqI))>2
    tfrs    =   CurFreq.powspctrm(ChanI,FreqI,:);
    tfr     =   squeeze(mean(tfrs,2));
    fi      =   find(FreqI);
    freqlab =   [num2str(CurFreq.freq(fi(1))) '-' num2str(CurFreq.freq(fi(end)))];
else
    tfr     =   squeeze(CurFreq.powspctrm(ChanI,FreqI,:));  
    freqlab =   num2str(CurFreq.freq(FreqI));
end

% --- Plot the TFR --- %

subplot(handles.Regressor1);cla;
plot(CurFreq.time,tfr);
title([handles.data.sub '-' handles.data.sess '-' handles.data.run ' '  CurFreq.label{ChanI} ' (' freqlab ' Hz)'])
xlabel('Time (seconds)');ylabel('Power (uV^2)');
axis([min(CurFreq.time)-1 max(CurFreq.time)+1 0 max(tfr)*1.05])

% --- Save selected channel/frequency for CreateRegressor callback --- %

handles.tfr.emg.powspctrm      =   tfr;
handles.tfr.emg.label          =   CurFreq.label(ChanI);
handles.tfr.emg.freq           =   CurFreq.freq(FreqI);
handles.tfr.emg.freqlab        =   freqlab;
handles.tfr.emg.time           =   CurFreq.time;
handles.tfr.emg.cfg            =   CurFreq.cfg;
handles.tfr.emg.startscan_sec  =   CurFreq.startscan_sec;
handles.tfr.emg.startscan_sca  =   CurFreq.startscan_sca;
handles.tfr.emg.prestart_sec   =   CurFreq.prestart_sec;
handles.tfr.emg.prestart_sca   =   CurFreq.prestart_sca;
handles.tfr.emg.tr             =   CurFreq.tr;
handles.tfr.emg.mtr            =   CurFreq.mtr;
handles.tfr.emg.scanid         =   CurFreq.scanid;
handles.tfr.emg.fs             =   CurFreq.fs;
handles.tfr.emg.meth           =   CurFreq.meth;
handles.tfr.emg.createdate     =   CurFreq.createdate;
handles.tfr.emg.sub            =   CurFreq.sub;
handles.tfr.emg.sess           =   CurFreq.sess;
handles.tfr.emg.run            =   CurFreq.run;

handles.curtfr.emg.tc          =   handles.tfr.emg.powspctrm(~isnan(handles.tfr.emg.powspctrm));
handles.curtfr.emg.time        =   handles.tfr.emg.time(~isnan(handles.tfr.emg.powspctrm));

% --- Save to guidata --- %

guidata(hObject, handles);

% --- END --- %

% --- Executes on selection change in create_regr_emg.
function create_regr_emg_Callback(hObject, eventdata, handles)
% hObject    handle to create_regr_emg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns create_regr_emg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from create_regr_emg

contents    =   cellstr(get(hObject,'String'));
sel         =   contents{get(hObject,'Value')};
breakflag   =   0;

switch sel
    case 'All'
        conf.mkregr.meth    =   {'power';'amplitude';'log'};
    case 'Power'
        conf.mkregr.meth    =   {'power';};
    case 'Amplitude'
        conf.mkregr.meth    =   {'amplitude'};
    case 'Log'
        conf.mkregr.meth    =   {'log'};
    otherwise
        breakflag = 1;
end

% --- Checking --- %

if ~isfield(handles.tfr,'emg')
   error('seltremgui:crearegr','Press the "Show TFR" button first') 
end

%=========================================================================%
% ------------------------- Configuration ------------------------------- %
%=========================================================================%

% --- Directories --- %

conf.dir.prepemg      =   handles.data.path;                                                % Directory of the loaded file
conf.dir.regr         =   fullfile(conf.dir.prepemg,'Regressors'); % This is where regressors will be saved (in subfolder ZSCORED, or NOTZSCORED)
conf.dir.fmri.root    = '';                           % fMRI root directory (containing all subject folders), necessary to detect amount of scans (for building regressor)
conf.dir.fmri.preproc = {'CurSub' 'func' 'CurSess' 'CurRun' 'preproc' 'norm'};              % The subfolder of the root directory where scans are stored. IN this case: fullfile(conf.dir.fmri.root,CurSub,func,CurSess,CurRun,preproc,norm), which results in: /home/action/micdir/data/DRDR_MRI/fMRI/s01/func/SESS1/RS/preproc/norm
conf.dir.event        =   '';                     % Event directory (usually your .vmrk file), if you want to plot the conditions in mkregr

conf.dir.prepemg      =   handles.data.path;                                                % Directory of the loaded file
conf.dir.regr         =   fullfile(conf.dir.prepemg,'Regressors'); % This is where regressors will be saved (in subfolder ZSCORED, or NOTZSCORED)
conf.dir.fmri.root    = '';                           % fMRI root directory (containing all subject folders), necessary to detect amount of scans (for building regressor)
conf.dir.fmri.preproc = {'CurSub' 'func' 'CurSess' 'CurRun' 'preproc' 'norm'};              % The subfolder of the root directory where scans are stored. IN this case: fullfile(conf.dir.fmri.root,CurSub,func,CurSess,CurRun,preproc,norm), which results in: /home/action/micdir/data/DRDR_MRI/fMRI/s01/func/SESS1/RS/preproc/norm
conf.dir.event        =   '';                     % Event directory (usually your .vmrk file), if you want to plot the conditions in mkregr


% --- Rest of mkregr configuration --- %

conf.mkregr.file            = '';                       % Name of prepemg data (leave empty for gui).
conf.mkregr.data            = handles.tfr.emg;          % The field 'data' is reserved for regressors selected through the GUI. Instead of searching for a file it will use the data defined in handles.tfr.emg which is defined when the 'Show TFR' button is pressed.

conf.mkregr.nscan     = 800;                       % Amount of scans your regressor should contain ('detect' to detect the amount in conf.dir.fmri.preproc)
conf.mkregr.scanname  = '|w*';                          % Search criterium for images (only if conf.mkregr.nscan = 'detect'; uses pf_findfile);
conf.mkregr.sample    = 1;                              % Samplenr of every scan which will be used to represent the tremor during scan (if you used slice time correction, use the reference slice timing here)
conf.mkregr.zscore    = 'yes';                          % If yes, than the data will first be z-normalized
conf.mkregr.trans     = {'deriv1'};                     % Transformation of made regressors ('deriv1': first temporal derivative)
conf.mkregr.save      = 'yes';                          % Save regressors/figures

conf.mkregr.plotcond  = 'no';                          % If you want to plot the condition (will use the conditions from conf.dir.event)
conf.mkregr.evefile   = '/CurSub/&/CurSess/&/CurRun/&/.vmrk/';   % Event file (if you want to plot the conditions
conf.mkregr.mrk.scan  = 'R  1';                         % Scan marker (if you want to plot scanlines)
conf.mkregr.mrk.onset = 'S 11';                         % Onset marker of condition (if you want to plot events)
conf.mkregr.mrk.offset= 'S 12';                         % Offset marker of condition (if you want to plot events)                                     
conf.mkregr.plotscanlines = 'no';                       % If yes then it will plot the scanlines in the original resolution.

% --- First save figure if desired --- %

savefig = 1;
if savefig
    q = gcf;
    name    =   ['PowSpct_selectedEMG_' handles.tfr.emg.sub '-' handles.tfr.emg.sess];
    if ~exist(conf.dir.regr,'dir'); mkdir(conf.dir.regr); end
    print(q,'-dtiff','-r800',fullfile(conf.dir.regr,name))
    fprintf('%s\n',['Saved figure to ' fullfile(conf.dir.regr,name)])
end

if ~breakflag        
    pf_emg_raw2regr(conf,[],'mkregressor');
end


% --- Executes during object creation, after setting all properties.
function create_regr_emg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to create_regr_emg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_emg.
function select_emg_Callback(hObject, eventdata, handles)
% hObject    handle to select_emg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_emg
subplot(handles.EMG);
brush on

% --- Executes on button press in select_acc.
function select_acc_Callback(hObject, eventdata, handles)
% hObject    handle to select_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_acc
subplot(handles.ACC);
brush on

% --- Executes on selection change in linkaxis.
function linkaxis_Callback(hObject, eventdata, handles)
% hObject    handle to linkaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns linkaxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from linkaxis

contents = cellstr(get(hObject,'String'));
sel =   contents{get(hObject,'Value')};

switch sel
    case 'LinkX'
        linkaxes([handles.Regressor1,handles.Regressor2],'x');
    case 'LinkY'
        linkaxes([handles.Regressor1,handles.Regressor2],'y');
    case 'LinkXY'
        linkaxes([handles.Regressor1,handles.Regressor2],'xy');
    case 'LinkOFF'
        linkaxes([handles.Regressor1,handles.Regressor2],'off');
end

% --- Executes during object creation, after setting all properties.
function linkaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linkaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in emg_zscore.
function emg_zscore_Callback(hObject, eventdata, handles)
% hObject    handle to emg_zscore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of emg_zscore
if get(hObject,'Value')    
    [handles.curtfr.emg.tc,handles.curtfr.emg.avg,handles.curtfr.emg.stdev] =   zscore(handles.curtfr.emg.tc);
else
    handles.curtfr.emg.tc  =   handles.curtfr.emg.tc*handles.curtfr.emg.avg+handles.curtfr.emg.stdev;    
end

% --- Plot the TFR --- %

subplot(handles.Regressor1);cla
plot(handles.curtfr.emg.time,handles.curtfr.emg.tc);
axis([min(handles.curtfr.emg.time)-1 max(handles.curtfr.emg.time)+1 min(handles.curtfr.emg.tc) max(handles.curtfr.emg.tc)*1.05] )

% --- Save to guidata --- %

guidata(hObject, handles);

% --- END --- %

% --- Executes on button press in emg_amp.
function emg_amp_Callback(hObject, eventdata, handles)
% hObject    handle to emg_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of emg_amp
if get(hObject,'Value')
    handles.curtfr.emg.tc             =   sqrt(handles.curtfr.emg.tc);
else    
    handles.curtfr.emg.tc             =   handles.curtfr.emg.tc.^2;    
end

% --- Plot the TFR --- %

subplot(handles.Regressor1);delete(get(handles.Regressor2,'Children'));
plot(handles.curtfr.emg.time,handles.curtfr.emg.tc);
axis([min(handles.curtfr.emg.time)-1 max(handles.curtfr.emg.time)+1 min(handles.curtfr.emg.tc) max(handles.curtfr.emg.tc)*1.05] )

% --- Save to guidata --- %

guidata(hObject, handles);

% --- END --- %

% --- Executes on button press in emg_log.
function emg_log_Callback(hObject, eventdata, handles)
% hObject    handle to emg_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of emg_log
if get(hObject,'Value')
    handles.curtfr.emg.tc             =   log10(handles.curtfr.emg.tc);
else
    handles.curtfr.emg.tc             =   10.^handles.curtfr.emg.tc;    
end

% --- Plot the TFR --- %
    
subplot(handles.Regressor1);delete(get(handles.Regressor1,'Children'));
plot(handles.curtfr.emg.time,handles.curtfr.emg.tc);
axis([min(handles.curtfr.emg.time)-1 max(handles.curtfr.emg.time)+1 min(handles.curtfr.emg.tc) max(handles.curtfr.emg.tc)*1.05] )

% --- Save to guidata --- %

guidata(hObject, handles);

% --- END --- %


% --- Executes on button press in acc_zscore.
function acc_zscore_Callback(hObject, eventdata, handles)
% hObject    handle to acc_zscore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acc_zscore
if get(hObject,'Value')    
    [handles.curtfr.acc.tc,handles.curtfr.acc.avg,handles.curtfr.acc.stdev] =   zscore(handles.curtfr.acc.tc);
else
    handles.curtfr.acc.tc  =   handles.curtfr.acc.tc*handles.curtfr.acc.avg+handles.curtfr.acc.stdev;    
end

% --- Plot the TFR --- %

subplot(handles.Regressor2);delete(get(handles.Regressor2,'Children'));
plot(handles.curtfr.acc.time,handles.curtfr.acc.tc);
axis([min(handles.curtfr.acc.time)-1 max(handles.curtfr.acc.time)+1 min(handles.curtfr.acc.tc) max(handles.curtfr.acc.tc)*1.05] )

% --- Save to guidata --- %

guidata(hObject, handles);

% --- END --- %

% --- Executes on button press in acc_amp.
function acc_amp_Callback(hObject, eventdata, handles)
% hObject    handle to acc_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acc_amp
if get(hObject,'Value')
    handles.curtfr.acc.tc             =   sqrt(handles.curtfr.acc.tc);
else    
    handles.curtfr.acc.tc             =   handles.curtfr.acc.tc.^2;    
end

% --- Plot the TFR --- %

subplot(handles.Regressor2);delete(get(handles.Regressor2,'Children'));
plot(handles.curtfr.acc.time,handles.curtfr.acc.tc);
axis([min(handles.curtfr.acc.time)-1 max(handles.curtfr.acc.time)+1 min(handles.curtfr.acc.tc) max(handles.curtfr.acc.tc)*1.05] )

% --- Save to guidata --- %

guidata(hObject, handles);

% --- END --- %


% --- Executes on button press in acc_log.
function acc_log_Callback(hObject, eventdata, handles)
% hObject    handle to acc_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acc_log
if get(hObject,'Value')
    handles.curtfr.acc.tc             =   log10(handles.curtfr.acc.tc);
else
    handles.curtfr.acc.tc             =   10.^handles.curtfr.acc.tc;    
end

% --- Plot the TFR --- %
    
subplot(handles.Regressor2);delete(get(handles.Regressor2,'Children'));
plot(handles.curtfr.acc.time,handles.curtfr.acc.tc);
axis([min(handles.curtfr.acc.time)-1 max(handles.curtfr.acc.time)+1 min(handles.curtfr.acc.tc) max(handles.curtfr.acc.tc)*1.05] )

% --- Save to guidata --- %

guidata(hObject, handles);

% --- END --- %


% --- Executes on button press in corrbutton.
function corrbutton_Callback(hObject, eventdata, handles)
% hObject    handle to corrbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[rho,p] = corr(handles.curtfr.acc.tc,handles.curtfr.emg.tc);
disp(['Correlation: rho = ' num2str(rho) ' | p = ' num2str(p)])


% --- Executes on button press in increase_regressor1.
function increase_regressor1_Callback(hObject, eventdata, handles)
% hObject    handle to increase_regressor1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subplot(handles.Regressor1);
ylim_pre = get(handles.Regressor1,'ylim');
ylim([ylim_pre(1) ylim_pre(2)*0.5]);

% --- Executes on button press in decrease_regressor1.
function decrease_regressor1_Callback(hObject, eventdata, handles)
% hObject    handle to decrease_regressor1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subplot(handles.Regressor1);
ylim_pre = get(handles.Regressor1,'ylim');
ylim([ylim_pre(1) ylim_pre(2)*2]);


% --- Executes on button press in increase_regressor2.
function increase_regressor2_Callback(hObject, eventdata, handles)
% hObject    handle to increase_regressor2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subplot(handles.Regressor2);
ylim_pre = get(handles.Regressor2,'ylim');
ylim([ylim_pre(1) ylim_pre(2)*0.5]);

% --- Executes on button press in decrease_regressor2.
function decrease_regressor2_Callback(hObject, eventdata, handles)
% hObject    handle to decrease_regressor2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
subplot(handles.Regressor2);
ylim_pre = get(handles.Regressor2,'ylim');
ylim([ylim_pre(1) ylim_pre(2)*2]);

% --- Executes on button press in save_ps_emg.
function save_ps_emg_Callback(hObject, eventdata, handles)
% hObject    handle to save_ps_emg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Retrieve selected data --- %

chanidx           = handles.data.chanleft;

bh      =   findobj(handles.EMG,'-property','BrushData');
bval    =   get(bh,'BrushData');
bval    =   flipud(bval); % Because everything is loaded in inverse order

if ~iscell(bval)
    bval = {bval};
end

ChanI   =   find(cellfun(@(x) any(x),bval));  % Logical index of selected channel
nChanI  =   length(ChanI);
if nChanI>1
    error('mkregressor:showtfr','Please only select one channel')
end

% --- Retrieve channel/frequency selected --- %

CurFreq           = handles.data;
CurFreq.label     = CurFreq.label(chanidx);
CurFreq.powspctrm = CurFreq.powspctrm(chanidx,:,:);
FreqI             =   logical(bval{ChanI});       % Logical index of selected frequency

fprintf('%s\n',['- You selected channel "' CurFreq.label{ChanI} '" with frequency "' num2str(CurFreq.freq(FreqI)) '" Hz'])

if length(find(FreqI))>2
    disp('debug me...based on tfr still'); keyboard;
    tfrs    =   CurFreq.powspctrm(ChanI,FreqI,:);
    tfr     =   squeeze(mean(tfrs,2));
    fi      =   find(FreqI);
    freqlab =   [num2str(CurFreq.freq(fi(1))) '-' num2str(CurFreq.freq(fi(end)))];
else
    pow     =   CurFreq.powspctrm(ChanI,FreqI);
    freqlab =   num2str(CurFreq.freq(FreqI));
end

% --- Save now --- %

savedir = fullfile(handles.data.path,'PS_save');
if ~exist(savename,'dir'); mkdir(savename); end

CurSub    = handles.data.sub;
CurSess   = handles.data.sess;    
CurRun    = handles.data.run;

%            Subcode                Sesscode             Chancode    Freq                 Power
mat       = [str2num(CurSub(2:end)) str2num(CurSess(5))  ChanI       CurFreq.freq(FreqI)       ];
data.sub  = CurSub;
data.sess = CurSess;
data.run  = CurRun;
data.chan = CurFreq.label{ChanI};
data.freq = CurFreq.freq(FreqI);

savename = fullfile(savedir,[CurSub '_' CurSess '_' CurRun '_ps-save_emg.mat']);
save(savename,'data','mat')

% --- Executes on button press in save_ps_acc.
function save_ps_acc_Callback(hObject, eventdata, handles)
% hObject    handle to save_ps_acc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Retrieve selected data --- %

chanidx           = handles.data.chanright;

bh      =   findobj(handles.ACC,'-property','BrushData');
bval    =   get(bh,'BrushData');
bval    =   flipud(bval); % Because everything is loaded in inverse order

if ~iscell(bval)
    bval = {bval};
end

ChanI   =   find(cellfun(@(x) any(x),bval));  % Logical index of selected channel
nChanI  =   length(ChanI);
if nChanI>1
    error('mkregressor:showtfr','Please only select one channel')
end

% --- Retrieve channel/frequency selected --- %

CurFreq           = handles.data;
CurFreq.label     = CurFreq.label(chanidx);
CurFreq.powspctrm = CurFreq.powspctrm(chanidx,:,:);
FreqI             =   logical(bval{ChanI});       % Logical index of selected frequency

fprintf('%s\n',['- You selected channel "' CurFreq.label{ChanI} '" with frequency "' num2str(CurFreq.freq(FreqI)) '" Hz'])

if length(find(FreqI))>2
    disp('debug me...based on tfr still'); keyboard;
    tfrs    =   CurFreq.powspctrm(ChanI,FreqI,:);
    tfr     =   squeeze(mean(tfrs,2));
    fi      =   find(FreqI);
    freqlab =   [num2str(CurFreq.freq(fi(1))) '-' num2str(CurFreq.freq(fi(end)))];
else
    pow     =   CurFreq.powspctrm(ChanI,FreqI);
    freqlab =   num2str(CurFreq.freq(FreqI));
end

% --- Save now --- %

savedir = fullfile(handles.data.path,'PS_save');
if ~exist(savedir,'dir'); mkdir(savedir); end

CurSub    = handles.data.sub;
CurSess   = handles.data.sess;    
CurRun    = handles.data.run;

%            Subcode                Sesscode             Chancode    Freq            Power
mat       = [str2num(CurSub(2:end)) str2num(CurSess(5))  ChanI       CurFreq.freq(FreqI)    pow  ];
data.sub  = CurSub;
data.sess = CurSess;
data.run  = CurRun;
data.chan = CurFreq.label{ChanI};
data.freq = CurFreq.freq(FreqI);
data.pow  = pow;

savename = fullfile(savedir,[CurSub '_' CurSess '_' CurRun '_ps-save_acc_' CurFreq.label{ChanI} '_' freqlab(1) '.mat']);
save(savename,'data','mat')

savefig = 1;
if savefig
    q = gcf;
    name    =   ['PowSpct_selectedACC_' CurSub '-' CurSess];
    print(q,'-dtiff','-r800',fullfile(savedir,name))
    fprintf('%s\n',['Saved figure to ' fullfile(savedir,name)])
end
