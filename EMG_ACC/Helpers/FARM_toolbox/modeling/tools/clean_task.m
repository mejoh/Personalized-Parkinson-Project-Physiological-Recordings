% function clean_task(study,pp,task,analysis)
%
% This completely deletes any results-directory.
% J

function clean_task(study,pp,task,analysis)

    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
    rdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/results/' analysis '/'];
    
    if isdir(rdir)
        rmdir(rdir,'s')
    end
    

