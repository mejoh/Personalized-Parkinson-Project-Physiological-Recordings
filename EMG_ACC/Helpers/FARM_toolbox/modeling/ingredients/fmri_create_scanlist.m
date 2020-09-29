% function out=fmri_create_scanlist(study,pp,task,analysis,contrast)
%
% pp = a double vector! (or an int... but matlab's default is double, so.)

function out=fmri_create_scanlist(study,pp,taak,analysis,contrast)

    nowdir=pwd;

    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
    

    out={};
    
    
    for i=1:numel(pp)
        
        
        rdir=[base 'Onderzoek/fMRI/' study '/pp/' num2str(pp(i)) '/' taak '/results/'];
        
        
        annames=dir([rdir analysis '*']);
        
        if numel(annames)>0
            
            % keyboard;
            anname=annames(1).name;
            
            rdir2=[base 'Onderzoek/fMRI/' study '/pp/' num2str(pp(i)) '/' taak '/results/' anname '/'];
            
            cd(rdir2)
            load SPM.mat
            allnames={SPM.xCon.name};
            ind=find(strcmp(allnames,contrast));
            
            if numel(ind)==0
                disp(['contrast doesnt exist! --pp=' num2str(pp(i)) ', analysis=' analysis]);
               
            else
            
                % keyboard;
                img_name=SPM.xCon(ind).Vcon.fname;
                out{end+1}=[rdir2 img_name];
                disp(['adding scan to list: ' out{end}]);
            end
            
            

        end
        
    end
    
    if numel(out)>1
        out=reshape(out,numel(out),1);
    end
    
    cd(nowdir);
    
    
    
    
        
    
    
       
    
    
    
    
