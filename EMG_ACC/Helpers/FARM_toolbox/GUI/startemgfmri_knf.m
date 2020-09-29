function startemgfmri_knf

KNF_toolboxes_path = 'G:\divd\knf\ICT\Software\mltoolboxes';
EEGfMRI_path = [KNF_toolboxes_path '\emgfmri-20101208_ET'];

% het path voor spm8
addpath([KNF_toolboxes_path '\spm8']);

% het path voor de nifti software
addpath([KNF_toolboxes_path '\NIFTI_20090325']);

% het path voor de r2agui software
addpath([KNF_toolboxes_path '\r2agui_v251']);

% het path voor de transformatie van TRC files (EMG data)
addpath([EEGfMRI_path '\conversion\emg']);

% het path voor emg_add_labels.m enz. bestanden, voor de transformatie van
% EMG data
addpath([EEGfMRI_path '\preprocessing\emg']);

% het path voor de verwerking van logfiles
addpath([EEGfMRI_path '\conversion\log']);

% het path voor de preprocessing fMRi batch_fmri_preprocessing
addpath([EEGfMRI_path '\preprocessing\fmri']);

% het path voor de EMG design
addpath([EEGfMRI_path '\modeling\ingredients']);

% het path voor de artifact filtering
addpath([EEGfMRI_path '\preprocessing\artifact_clustering']);

% het path voor de parrec->analyze conversie
addpath([EEGfMRI_path '\conversion\fmri']);

% en de GUI
addpath([EEGfMRI_path '\GUI\EMG_fMRI']);

% start eeglab
cd([KNF_toolboxes_path '\eeglab']);
% eeglab
