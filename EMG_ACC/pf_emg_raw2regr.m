function pf_emg_raw2regr(subject, conf)
% pf_emg_raw2regr(conf,cfg,varargin) is a batch like function with the 
% main goal to transform a raw EMG or Accelerometry signal into a regressor 
% describing tremor fluctuations to be used in a general linear model for 
% fMRI analyses. The input is usually EMG signal after fMRI artifact 
% reduction (e.g. FARM, for example via pf_emg_farm_ext). 

% For fMRI artifact reduction of EMG signal see pf_emg_farm_ext

% ?????? Michiel Dirkx, 2015
% $ParkFunC, version 20150702
% Updated 20181210
tic; 

%--------------------------------------------------------------------------
% Add packages
%--------------------------------------------------------------------------
if isempty(which('ft_defaults')) %check if fieldtrip is installed
    addpath(path.Fieldtrip); %Add fieldtrip
    ft_defaults
end
addpath(path.SPM); %Add SPM12
addpath(fullfile(path.Fieldtrip, 'qsub'));
addpath(genpath(path.ParkFunc));  %Add ParkFunc
addpath(conf.dir.eeglab); eeglab; %Add eeglab
addpath(genpath(conf.dir.Farm)); %Add FARM

%--------------------------------------------------------------------------
% Frequency analysis ('prepemg')
%--------------------------------------------------------------------------
if conf.todo.prepemg 
    pf_emg_raw2regr_prepemg(conf,cfg);
end

%--------------------------------------------------------------------------
% Create regressor of frequency analyzed data ('mkregressor')
%--------------------------------------------------------------------------
if conf.todo.mkregressor
    pf_emg_raw2regr_mkregr(conf);
end

%--------------------------------------------------------------------------
% Cooling Down
%--------------------------------------------------------------------------
T   =   toc;
fprintf('\n%s\n',['Mission accomplished after ' num2str(T/60) ' minutes!!'])