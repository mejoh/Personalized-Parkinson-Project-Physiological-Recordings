%% Exampleruncluster
% Run FARM and Frequnecy analysis on cluster, after those peak frequency
% and channel selection should be done. See end of this script.

%% Settings
cluster_outputdir = '/project/3022026.01/analyses/tessa/Test/EMG_ACCprocessing/Task/Clusteroutput'; %directory where job info and output is stored
processing_dir = '/project/3022026.01/analyses/tessa/Test/EMG_ACCprocessing/Task';

subTable = getSubjects('PD_on_study');
subjects = cellstr(subTable.SubjectNumber); 
%subject = subjects {1}

todo = {
%    'FARM'
    'Frequency_analysis'
    };

%% Main script
addpath('/home/common/matlab/fieldtrip/qsub');
addpath(genpath('/project/3022026.01/analyses/tessa/Scripts/EMG_ACC/TremorRegressor'));
addpath(genpath('/project/3022026.01/analyses/tessa/Scripts/EMG_ACC/Helpers/ParkFunC_EMG/Helpers'))
startdir = pwd;
cd(cluster_outputdir)

FARMjobs = {}; FREQjobs = {};
for sb=1:length(subjects)
    
    if isempty(pf_findfile(fullfile(processing_dir,'FARM'),['/' subjects{sb} '/&/task1/'])) && any(contains(todo,'FARM'))
        fprintf(['\n --- Submitting FARM-job for subject ' subjects{sb} ' ---\n']);
        FARMjobs{sb} = qsubfeval('pf_emg_farm_Task',subjects{sb},'memreq',10^10,'timreq',12*3600);  % Run on cluster ;
    elseif isempty(pf_findfile(fullfile(processing_dir,'prepemg'),['/' subjects{sb} '/&/task1/'])) && any(contains(todo,'Frequency_analysis'))
        fprintf(['\n --- Submitting frequency analysis-job for subject ' subjects{sb} ' ---\n']);
        FREQjobs{sb} = qsubfeval('pf_emg_raw2regr_Task',subjects{sb},'memreq',10^10,'timreq',12*3600);  % Run on cluster
    else
        fprintf(['\n --- FARM and frequency analysis already done for ' subjects{sb} ' or not selected as task ---\n']);
    end
end

jobs = [FARMjobs FREQjobs];

% Save clusterjobs
if ~isempty(jobs)
    task.jobs = jobs;
    task.submittime = datestr(clock);
    task.mfile = mfilename;
    task.mfiletext = fileread([task.mfile '.m']);
    save([cluster_outputdir '/jobs_' task.mfile  '_' datestr(clock) '.mat'],'task');
end

fprintf(['\n --- Done ---\n']);

%% Final step: select peak frequency and channel, create regressor
% Use pf_emg_raw2regr_mkregressor_gui in matlab2014a with paths:
% scriptdir = '/project/3011164.01/TEMP/Scripts/EMG-ACC/';
% addpath(fullfile(scriptdir,'ParkFunC_EMG','EMG'));
% addpath(fullfile(scriptdir,'ParkFunC_EMG','Helpers'));
% addpath('/home/common/matlab/spm12');
% spm fmri

