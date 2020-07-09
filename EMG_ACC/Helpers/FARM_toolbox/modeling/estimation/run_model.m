function run_model(study,pp,task,analysis,filetype)


    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
    tdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/results/' analysis '/'];

    
    if isdir(tdir)
        cd(tdir)
        
        
        jobs={};
        
        % keyboard;
        % definieer het model...
        jobs{end+1}=job_model(study,pp,task,analysis,filetype);

        % 'estimate' de modellen...
        jobs{end+1}=job_estimate(study,pp,task,analysis);

        % reken al je contrasts uit...
        jobs{end+1}=job_contrasts(study,pp,task,analysis);
        
        % en poep die plaatjes uit in .ps formaat!!!, voor elk van je
        % contrasten!
        % jobs{end+1}=job_results(study,pp,task,analysis,Inf,'None',0.005,0);

        
        % jobs=dir_fix(jobs);
        save([tdir 'job_model.mat'],'jobs');
        cd(tdir);
        dir_fix job_model
        
        spm_jobman('run',jobs);
   
    end
