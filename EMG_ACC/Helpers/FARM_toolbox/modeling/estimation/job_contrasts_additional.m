function job=job_contrasts_additional(study,pp,taak,analysis)


    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
    rdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' taak '/results/' analysis '/'];

    % if exist([rdir 'contrasts.mat'],'file')
    load([rdir 'contrasts.mat']);
%     else
%         tcontrasts={[1],'T 1'};
%         fcontrasts={[1],'F 1'};
%         warning('unless youre doing group-analysis, you should check your contrast defenitions... now only processing first column.');
%     end
%     
    
    c.spmmat    = {[rdir 'SPM.mat']};
    c.delete    = 0;
    c.consess   = {};
    
    for sessrep={'none'}
    
        for i=1:size(tcontrasts,1)

            t.name      = tcontrasts{i,1};
            t.convec    = tcontrasts{i,2};
            t.sessrep   = sessrep{1};
            c.consess{end+1}.tcon=t;

        end

        for i=1:size(fcontrasts,1)

            f.name      = fcontrasts{i,1};
            f.convec    = {fcontrasts{i,2}};
            f.sessrep   = sessrep{1};
            c.consess{end+1}.fcon=f;

        end 

%         % inversen (!)
%         for i=1:size(tcontrasts,1)
% 
%             t.name      = ['Inv [ ' tcontrasts{i,1} ' ]'];
%             t.convec    = tcontrasts{i,2}*-1;
%             t.sessrep   = sessrep{1};
%             c.consess{end+1}.tcon=t;
% 
%         end
% 
%         for i=1:size(fcontrasts,1)
% 
%             f.name      = ['Inv [ ' fcontrasts{i,1} ' ]'];
%             f.convec    = {fcontrasts{i,2}*-1};
%             f.sessrep   = sessrep{1};
%             c.consess{end+1}.fcon=f;
% 
%         end 
    end
        
        
    job.stats{1}.con=c;