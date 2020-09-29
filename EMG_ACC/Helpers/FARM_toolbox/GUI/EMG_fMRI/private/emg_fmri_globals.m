%% emg_fmri_globals
% global variables used by EMG_fMRI
% 2009-10-06, created by Paul Groot
% ----------------

% start with global EEGlab stuff...
global EEG;                                 % current EEGlab dataset 
global ALLEEG;                              % all EEGlab datasets
global CURRENTSET;                          % index of current set: EEG == ALLEEG[CURRENTSET]

global EMG_fMRI_study;
global EMG_fMRI_study_dir;                  % current root of study directory
global EMG_fMRI_patient;                    % current patient identifier
global EMG_fMRI_proto_answer;               % cell array containing protocol names
global EMG_fMRI_freq_band_emg_model;        % [low high]
global EMG_fMRI_freqreg;                    % << extract_frequency_band()
global EMG_fMRI_steps_emgpre;
global EMG_fMRI_profile;
global EMG_fMRI_protoname_select_muscle;
%global EMG_fMRI_image_muscle;               % create_emg_regressors_select_muscles
%global EMG_fMRI_selected_muscles;           % create_emg_regressors_select_muscles