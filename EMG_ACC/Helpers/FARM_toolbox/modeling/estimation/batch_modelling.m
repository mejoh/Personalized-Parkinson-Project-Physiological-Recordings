% the folow of the modelling step is as follows:
% first you set everything up ready to go.

% then you build the jobs
% and then you estimate!

study='Loops';
pp='1102';
taak='gonogo';
analyse='eventmp';
prefix='swa';




% dit wordt de workflow voor 1 model-analyse.
prepare_gonogo_eventmp(study,pp)
jobs={};
jobs{end+1} = job_model(study,pp,taak,analyse,prefix);
jobs{end+1} = job_estimate(study,pp,taak,analyse);
jobs{end+1} = job_contrasts_gonogo_eventmp(study,pp);

rdir=['x:\Onderzoek\fMRI\Loops\results\' pp '\' taak '\' analyse '\'];
save([rdir 'jobs_modelling.mat'],'jobs');
spm_jobman('run',jobs);




