% zoiets: geen regexps op, en geef tegelijk ook op waar je precies wilt
% saven.
%
% function jobout=job_groupanalysis(study,taskexp,ppexp,analysisexp,contrast,targettask,targetpp,targetanalysis)


function jobout=job_groupanalysis(study,taskexp,ppexp,analysisexp,contrast,targettask,targetpp,targetanalysis)


    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');

    ddir=[base 'Onderzoek/fMRI/' study '/pp/' targetpp '/' targettask '/results/' targetanalysis '/'];
    

    % groups and analyses are regular expressions. they indicate which
    % directories are eligible for inclusion into our group.
    % beware: selecting the same individual twice does not cause your
    % design matrix to adapt accordingly (a 00001000001 regressor extra to compensate for the double measurement).
    
    % first... we make into a nice cell array, ALL the results directories
    % that exist into our study folder with this certain task.
    
    pdir=[base 'Onderzoek/fMRI/' study '/pp/'];
    ddir=[base 'Onderzoek/fMRI/' study '/pp/' 
    
    % index all the directories of our study.
    tmp=regexp(genpath(pdir),'[^:]*','match');

    if ispc
        % dirty trick for windows machines: replace the slashes.
        regexprep(tmp,'\','/');
    end
    
    % and now search for patterns!

    dirs={};
    for i=1:numel(tmp);
        tmp2=regexp(tmp{i},[pdir groups '/' tasks '/results/' analyses],'match');
        if numel(tmp2)>0
            dirs{end+1}=tmp2;
        end
    end
    if numel(dirs)>0
        for i=1:numel(dirs)
            dirs{i}=dirs{i}{1};
        end
    end
    dirs=dirs';
    
    
    
    
    f.des.t1.scans=dirs;
    
    f.cov=struct('c',[],'cname',[],'iCFT',[],'iCC',[]);
    % to make it a 0 by 0 struct.
    d.cov(:)=[];

      m.tm.tm_none=[];
      m.im=1;
      m.em={''};
    f.masking=m;
    
    
    f.globalc.g_omit=[];
    
    
    f.globalm.gnsca.gmsca_no=[];
    f.globalm.glonorm=1;
    
    f.dir={ddir};
    
    
    
    
    
    jobout.stats{1}.factorial_design=f;