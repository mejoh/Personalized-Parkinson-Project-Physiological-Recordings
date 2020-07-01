function jobout = job_estimate(study,pp,taak,analysis)


    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
    rdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' taak '/results/' analysis '/'];

    
    f.spmmat = {[rdir 'SPM.mat']};
    
    f.method.Classical = 1;


    jobout.stats{1}.fmri_est=f;
    
    