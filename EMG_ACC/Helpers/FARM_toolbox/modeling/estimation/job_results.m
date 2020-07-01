% ! contrast can either be an 'int', in which case the nth contrast will be
% reported.
% OR, it can be a 'string', in which case the appropriate contrast will be
% estimated, OR, it can be 'Inf', or 0, in which case ALL contrasts will be
% estimated.
% the contrasts are dumped into a .ps file inside the results section.
%
% function out=job_results(study,pp,taak,analysis,contrast,threshtype,threshval,threshextent)
% study         'Loops'
% pp            '1115'
% taak          'gonogo'
% analysis      'event'
% contrast      'StopInhibit-GoRespond'
% threshtype    'FDR','FWE','None'
% threshval     0.05
% threshextent  0


function out=job_results(study,pp,taak,analysis,contrast,threshtype,threshval,threshextent,title,print)



    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
    rdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' taak '/results/' analysis '/'];
    rdir=regexprep(rdir,'\\','/');
    
    % truuk om empty string te maken.
    % emptystring='thiswillbeempty!';
    % emptystring(1:end)=[];
    
    % load SPM.mat
    % load contrasts.mat
    
    selection=contrast;

    
    r.spmmat= {[rdir 'SPM.mat']};
    r.print= print;


        c.titlestr= title;
        c.contrasts= selection(1);
        c.threshdesc= threshtype;
        c.thresh= threshval;
        c.extent= threshextent;

        
            % create an empty struct.
            m.contrasts=[];
            m.thresh=[];
            m.mtype=[];
            m(:)=[];
        c.mask=m;

    r.conspec=c;

    out.stats{1}.results=r;
    
    % en meer dan 1 contrast... conjunctie andere keer.
    if numel(selection)>1
        for i=2:numel(selection)
            
            c.contrasts=selection(i);
            out.stats{1}.results.conspec(i)=c;
        end
    end
    
    
        
        

