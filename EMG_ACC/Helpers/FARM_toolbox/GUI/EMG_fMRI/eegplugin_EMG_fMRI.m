%% EMG_fMRI plugin for EEGLab

function vers = eegplugin_EMG_fMRI( fig, trystrs, catchstrs)

vers = 'EMG_fMRI';
  if nargin < 3
      error('eegplugin_EMG_fMRI requires 3 arguments');
  end;


%% create menu
%toolsmenu = findobj(fig, 'tag', 'tools');
mainmenu = findobj(fig, 'tag', 'EEGLAB');
submenu = uimenu( mainmenu, 'label', 'EMG_fMRI Analysis', 'tag', 'EMG_fMRI');

% add new submenu's
uimenu( submenu, 'label', '1 Select Dataset', 'callback', 'select_dataset');
uimenu( submenu, 'label', '2 Convert and Preprocess', 'callback', 'convert_and_preprocess');
uimenu( submenu, 'label', '3 EMG Artefact Correction', 'callback', 'preprocessing_emg_protocol_selection');
uimenu( submenu, 'label', '4 Remove Movement Artefacts', 'callback', 'remove_horns_protocol_selection'); 
uimenu( submenu, 'label', '5 Create EMG-based Conditions', 'callback', 'create_emg_based_conditions_protocol_selection');
uimenu( submenu, 'label', '6 Create EMG Regressors', 'callback', 'create_emg_regressors');
uimenu( submenu, 'label', '7 Convolve Regressors', 'callback', 'postprocess_regressors');
uimenu( submenu, 'label', '8 Inspect Regressors', 'callback', 'inspect_regressors');
uimenu( submenu, 'label', '9 Compose Model', 'callback', 'postprocess_regressors(''model'')');
uimenu( submenu, 'label', 'A Compose Conditions', 'callback', 'compose_conditions_wrapper');
uimenu( submenu, 'label', 'B Start SPM fMRI', 'callback', 'start_spm');
uimenu( submenu, 'label', '0 About...', 'callback', 'emg_fmri_about');

