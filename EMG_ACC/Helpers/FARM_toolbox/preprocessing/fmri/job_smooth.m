function jobout=job_smooth(study,pp,taak,wdir)

    if nargin<4
        wdir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/' taak '/'];
    else
        wdir=[regexprep(wdir, '(^.*)([\\/]fMRI[\\/].*)', '$1', 'once', 'ignorecase') '/fMRI/' study '/pp/' pp '/' taak '/'];
    end
    disp(wdir);

    load([wdir 'parameters']);

    %tr=parameters(1);
    %ts=parameters(2);
    dyn=parameters(3);
    
    
    s.data={};
    
    for i=1:dyn
        s.data{i,1}    = [wdir 'fmri/wa4D.img, ' num2str(i)];
    end
    
    
    s.fwhm= [8 8 8];
    s.dtype= 0;
    
    jobout.spatial{1}.smooth=s;
    
    for i=1:dyn
        s.data{i,1}    = [wdir 'fmri/ra4D.img, ' num2str(i)];
    end
    
    s.fwhm= [6 6 6];
    s.dtype= 0;
    
    
    jobout.spatial{2}.smooth=s;
    