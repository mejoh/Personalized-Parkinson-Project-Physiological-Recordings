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


function jobout=run_groupanalysis(study,ppexp,taskexp,analysisexp,contrast,targetpp,targettask,targetanalysis)


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
    
    
    tmp=regexp(dirs,'[\d]{4}','match');
    tmp=[tmp{:}];
    tmp=str2double(tmp);

    % i grow smarter!!!!
    % solve issue of the same subjects in this group-analysis.
    tmp=clusterdata(tmp','distance','hamming','linkage','single','cutoff',0.1);
    tmat=[(1:numel(tmp))' tmp];
    for i=1:size(tmat,1);
        tmp=regexp(dirs{i},'','match');
        tmat(i,3)=str2double(regexprep(dirs{i},'.*_[^\d]*_(\d*)','$1'));
    end
    
    % en dan nu dingen gaan weggooien.
    remove=[];
    for i=1:max(tmat(:,2))
        
        ind=find(tmat(:,2)==i);
        count=tmat(ind,3);
        remove=[remove ind(find(count<max(count)))];
    end
    
    dirs(remove)=[];
    if numel(remove)>0
        disp(['i removed these due to double entries: ' num2str(remove)]);
    end
    

    
    
    disp('taking scans in...');
    scans={};
    for i=1:numel(dirs);
        
        disp(dirs{i});
        
        % keyboard;
        if exist([dirs{i} '\dovec.txt'],'file')
            load([dirs{i} '\dovec.txt']);
            disp('loaded dovec.txt, could be that some conditions have 0 events in them.');
            
        else
            dovec=[1 1 1];
        end
        
        % keyboard;
        if contrast==1

            name=[dirs{i} '/spmF_' num2str(contrast,'%.4d') '.img'];
            if exist(name,'file');
                scans{end+1}=[name ',1'];
            end
        elseif contrast>1&&dovec(contrast-1)
            tmp=1+sum(dovec(1:contrast-1));
            name=[dirs{i} '/spmF_' num2str(tmp,'%.4d') '.img'];
            if exist(name,'file');
                scans{end+1}=[name ',1'];
            end
        elseif contrast>1&&~dovec(contrast-1)
            disp('0-events detected');
            % do nothing
        end
            
    end
    scans=scans';
    disp('these are the scans:');
    for i=1:numel(scans)
        disp(scans{i});
    end
    % and we're done! we've now got all of the nessecary directies for the
    % group-analysis.
    
    
    
    f.des.t1.scans=scans;
    
    f.cov=struct('c',[],'cname',[],'iCFI',[],'iCC',[]);
    % keyboard;
    % to make it a 0 by 0 struct.
    f.cov(:)=[];

      m.tm.tm_none=[];
      m.im=1;
      m.em={''};
    f.masking=m;
    
    
    f.globalc.g_omit=[];
    
    
    f.globalm.gmsca.gmsca_no=[];
    f.globalm.glonorm=1;
    
    f.dir={ddir};
    
    
    
    jobout.stats{1}.factorial_design=f;
    
    % make the model.
    jobs={};
    
    jobs{1}=jobout;
    
    % estimate it.

    jobs{2}=job_estimate(study,targetpp,targettask,[targetanalysis '_' num2str(contrast,'%.2d')]);
    
    fcontrasts={'F group',[1]};
    tcontrasts={'T group',[1]};
    save([ddir 'contrasts.mat'],'tcontrasts','fcontrasts');
    % keyboard;
    jobs{3}=job_contrasts(study,targetpp,targettask,[targetanalysis '_' num2str(contrast,'%.2d')]);
    
    save([ddir 'spm_model.mat'],'jobs');
    % keyboard;
    
    spm_jobman('run',jobs);

    
    