function prep_task(study,pp,task,parsefile)

    % keyboard;

    % go to the subject's directory...
    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
    ppdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' task '/'];

    if isdir(ppdir)

        % include the folder where data is stored.
        datadir=[ppdir 'fmri/'];

        % copy de tr, en ook... de hoeveelheid volumes uit de parameters file.
        load([ppdir 'parameters']);
        nvol=parameters(3);
        tr=parameters(1);


        % load all of the regressors that you have...
        regdir=[ppdir 'regressor/'];

        matregs=dir([regdir '*.mat']);
        txtregs=dir([regdir '*.txt']);


        % load alle available regressors.
        for i=1:numel(matregs)

            m_in.(regexprep(matregs(i).name,'.mat',''))=load([regdir matregs(i).name]);

        end

        for i=1:numel(txtregs)

            t_in.(regexprep(txtregs(i).name,'.txt',''))=load([regdir txtregs(i).name]);

        end


        % parse iedere regel van parsefile!
        parsefiledir=[base 'Onderzoek/fMRI/' study '/analyses/'];
        if strcmp(parsefile(end-1:end),'.m');
            parsefile=parsefile(1:end-2);
            disp('dont fill in .m next time!');
        end
        
        % evaluate the analysis file.
        addpath(parsefiledir);
        eval(parsefile);
        
        
        
        
        % save gedeelte...
        % make the results dir for SPM.mat.
        resdir=[ppdir 'results/' analysis '/'];
        if isdir(resdir)
            rmdir(resdir,'s');
        end
        mkdir(resdir);
        
        % save regressors...
        if numel(names)>0
            save([resdir 'model.mat'],'names','onsets','durations');
        end
        if numel(regressors)>0
            save([resdir 'regressors.txt'],'regressors');
        end
        
        save([resdir 'datadir'],'datadir');
        save([resdir 'nvol.txt'],'nvol','-ascii');
        save([resdir 'tr.txt'],'tr','-ascii');
        
        % and contrasts...
        save([resdir 'contrasts.mat'],'fcontrasts','tcontrasts');




    end
