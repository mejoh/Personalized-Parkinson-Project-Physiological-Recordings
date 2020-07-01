% usage: batch_preprocessing('Loops','1001','gonogo1','gonogo2',...,'motorx')
% 
% 

function batch_fmri_preprocessing(varargin)

    study=varargin{1};
    pp=varargin{2};
    taken=varargin(3:end);
    
    % om zeker van te zijn dat je niet taken{1}{i} moet doen...
    if ~isstr(taken{1});taken=taken{1};end
    
    
    
    
%   spm fmri; paul thinks this is not required, and just conflicting with our GUI
    spm_jobmode = 'run_nogui'; % use 'run' to include graphics
    
    wdir=[regexprep(pwd, '(^.*)([\\/]fMRI[\\/].*)', '$1', 'once', 'ignorecase') '/fMRI/' study '/pp/' pp '/'];
    cd(wdir);
    disp('current directory is now:');
    disp(pwd);


    % als T1 al gedaan is --> niet opnieuw!
    
    if ~exist([wdir '/t1/t1_old.img'],'file')

        %% t1 manipulaties
        % stap 1: de t1 juiste orientatie draaien.
        fmri_t1rotate(study,pp,wdir); % wel doen.

        % stap 2: de t1 co-registreren op de standaard t1
        jobs={};
        jobs{end+1}=job_t1coreg(study,pp,wdir);
        save spm_t1coreg jobs;
        spm_jobman(spm_jobmode,jobs);

    else
        disp('the t1 already approximately matches the standardized t1 (with rigid body transformation)');
        disp(' so I am skipping this step.');
    end
    
    
    %% 4D manipulaties
    % interleaved/sequence in orde maken.
    if strcmpi(study,'Loops')
       if ismember(pp, {'1001','1002','1003','1004','1005','1006',...
               '1101','1102','1103','1104','1105','1106','1107','1108','1109'});
           option='interleaved';
       else
           option='sequence';
       end
    elseif strcmpi(study,'Tremor')
        option='interleaved';
    else
        % 2009-11-16: paul included interleaved as default when study is unknown
        option='interleaved';
        fprintf('Warning: unknown study ''%s''; assuming interleaved EPI sequence\n ',study);
    end
    

    % stap 1: de 4D's slice-timen.
    jobs={};
    for i=1:numel(taken)
        jobs{end+1}=job_slicetiming(study,pp,taken{i},option,wdir);  
    end
    save spm_slicetiming jobs;
    spm_jobman(spm_jobmode,jobs);


    % stap 2: de 4D's in de juiste orientatie draaien.
    % doe dit for 'loops',niet voor 'tremor'
    if strcmpi(study,'Loops')
        
        disp('rotating your 4D images SAG -> AX');
        for i=1:numel(taken)
            fmri_4Drotate(study,pp,taken{i},'a4D.mat',wdir);     
        end
    end
    
    
    %% het grote co-registratie spel.
    
    %% 4D's registreren
    % stap 3: Motion correction (!).
    jobs={};
    for i=1:numel(taken)
        jobs{end+1}=job_realign(study,pp,taken{i},wdir);     
    end
    save spm_realign jobs;
    spm_jobman(spm_jobmode,jobs);

    
    % motion parameters zijn ook regressors...
    for i=1:numel(taken)
        
        disp('copying rp_ file into regressor directory');
        tmpdir=[wdir taken{i} '/'];
        if ~isdir(tmpdir);mkdir(tmpdir);end
        copyfile([tmpdir 'fmri/rp_*.txt'],[tmpdir 'regressor/.']);
    end


    % stap 4: de mean(1e4D) co-registreren op de t1 (en dus de standaard t1
    % eigelijk)
    jobs={};
    jobs{end+1}=job_4Dcoreg1(study,pp,taken{1},wdir);
    save spm_4Dcoreg1 jobs;
    spm_jobman(spm_jobmode,jobs);

    % stap 5: de rest van de taken taken co-registreren op de mean(eerste
    % taak), en dus zo ook op een standaard orientatie komt.
    % je kan ook alle means op de t1 doen... maakt niet zoveel uit.
    jobs={};
    for i=2:numel(taken)
        jobs{end+1}=job_4Dcoreg2n(study,pp,taken{i},taken{1},wdir);
    end
    save spm_4Dcoreg2n jobs
    spm_jobman(spm_jobmode,jobs);

    %% 4D's re-slicen (en/of warpen!)
    % stap 6: (optioneel !?), de a4D reslicen. ze staan al goed.
    jobs={};
    for i=1:numel(taken)
        jobs{end+1}=job_4Dreslice(study,pp,taken{i},wdir);
    end
    save spm_4Dreslice jobs
    spm_jobman(spm_jobmode,jobs);

    
    % stap 7: warpen naar standaard brein.
    jobs={};
    for i=1:numel(taken)
        jobs{end+1}=job_normalise(study,pp,taken{i},wdir);
    end
    save spm_normalise jobs
    spm_jobman(spm_jobmode,jobs);

    %% smoothing
    % stap 8: smoothen!!
    jobs={};
    for i=1:numel(taken)
        jobs{end+1}=job_smooth(study,pp,taken{i},wdir);
    end
    save spm_smooth jobs
    spm_jobman(spm_jobmode,jobs);
    
    % cleanup.
    if ~isdir('jobs_spm')
        mkdir('jobs_spm');
    end
    movefile('spm_*','jobs_spm');
    
    disp(['fMRI preprocessing done for study=', study, ' pp=', pp]);

% just define the following to skip running the jobs (the job files will still be created though!)
%function spm_jobman(a,b)
        