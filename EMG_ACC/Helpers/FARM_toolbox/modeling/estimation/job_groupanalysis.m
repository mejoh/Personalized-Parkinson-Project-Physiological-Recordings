% function jobout=job_groupanalysis(study,taskexp,ppexp,analysisexp,contrast,targettask,targetpp,targetanalysis)
% 
% this'll just make a model.mat AND an SPM.mat file in your results folder,
% ready for evaluation.
%
% exp means regular expressions. you can give up patterns that'll match
% some parts of your directory tree. in this way the function will search
% for specific directories, which happen to be exactly the directories
% where your results are saved !!
%
% I think i'll also let this function run the model and estimate t and f
% contrasts '1'.
%
% J


function jobout=job_groupanalysis(study,ppexp,taskexp,analysisexp,contrast,targetpp,targettask,targetanalysis)


    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');

    ddir=[base 'Onderzoek/fMRI/' study '/pp/' targetpp '/' targettask '/results/' targetanalysis '_' num2str(contrast,'%.2d') '/'];

    if exist(ddir,'dir')
        rmdir(ddir,'s');
        mkdir(ddir);
    else
        mkdir(ddir);
    end

    % groups and analyses are regular expressions. they indicate which
    % directories are eligible for inclusion into our group.
    % beware: selecting the same individual twice does not cause your
    % design matrix to adapt accordingly (a 00001000001 regressor extra to compensate for the double measurement).
    
    % first... we make into a nice cell array, ALL the results directories
    % that exist into our study folder with this certain task.
    
    pdir=[base 'Onderzoek/fMRI/' study '/pp/'];
    
    % index all the directories of our study.
    tmp=regexp(genpath(pdir),'[^:]*','match');

    % keyboard;
    if ispc
        % dirty trick for windows machines: replace the slashes.
        regexprep(tmp,'\\','/');
    end
    
    % and now search for patterns!


    dirs={};
    for i=1:numel(tmp);
        tmp2=regexp(tmp{i},[pdir ppexp '/' taskexp '/results/' analysisexp],'match');
        if numel(tmp2)>0
            dirs{end+1}=tmp2;
        end
    end
    
    % keyboard;
    % test this one later.
    if ispc
        dirs=regexprep(tmp,'/','\\');
    end
    
    
    
    if numel(dirs)>0
        for i=1:numel(dirs)
            dirs{i}=dirs{i}{1};
        end
    end
    dirs=dirs';
    

    scans={};
    for i=1:numel(dirs);
        scans{i}=[dirs{i} '/con_' num2str(contrast,'%.4d') '.img,1'];
    end
    scans=scans';
    % and we're done! we've now got all of the nessecary directies for the
    % group-analysis.
    
    
    
    f.des.t1.scans=scans;
    
    f.cov=struct('c',[],'cname',[],'iCFT',[],'iCC',[]);
    % keyboard;
    % to make it a 0 by 0 struct.
    f.cov(:)=[];

      m.tm.tm_none=[];
      m.im=1;
      m.em={''};
    f.masking=m;
    
    
    f.globalc.g_omit=[];
    
    
    f.globalm.gnsca.gmsca_no=[];
    f.globalm.glonorm=1;
    
    f.dir={ddir};
    
    
    
    
    
    jobout.stats{1}.factorial_design=f;
    
    jobs{1}=jobout;
    
    

    jobs{2}=job_estimate(study,targetpp,targettask,targetanalysis);
    
    
    
    save([ddir 'spm_model.mat'],'jobs');
    spm_jobman('run',jobs);

    
    