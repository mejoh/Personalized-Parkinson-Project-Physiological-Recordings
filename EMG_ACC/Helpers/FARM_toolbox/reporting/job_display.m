function out=job_display(study,pp,task,prefix,num)


    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
    
    pdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/fmri/'];
    d=[pdir prefix '4D.img, ' num2str(num)];

    out.util{1}.disp.data{1}=d;