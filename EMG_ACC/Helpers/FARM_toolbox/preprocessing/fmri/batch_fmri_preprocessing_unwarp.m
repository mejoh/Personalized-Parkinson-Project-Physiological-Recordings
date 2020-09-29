% usage: batch_preprocessing('Loops','1001','gonogo1','gonogo2',...,'motorx')
% 
% 

function batch_fmri_preprocessing_unwarp(varargin)

    study=varargin{1};
    pp=varargin{2};
    taken=varargin(3:end);
    
    % om zeker van te zijn dat je niet taken{1}{i} moet doen...
    if ~isstr(taken{1});taken=taken{1};end
    
    
    %% Motion Parameters/Unwarp + rotation of 4D's (!).
    if strcmpi(study,'Loops')
        sagax='sag';
    else
        sagax='ax';
    end
    
    
    spm fmri;
    


    wdir=([regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/pp/' pp '/']);
    cd(wdir);
    disp('current directory is now:');
    disp(pwd);


    % als T1 al gedaan is --> niet opnieuw!
    
    if ~exist([wdir '/t1/t1_old.img'],'file')

        %% t1 manipulaties
        % stap 1: de t1 juiste orientatie draaien.
        fmri_t1rotate(study,pp); % wel doen.

        % stap 2: de t1 co-registreren op de standaard t1
        jobs={};
        jobs{end+1}=job_t1coreg(study,pp);
        
        % keyboard;
        % al er geen t1 is, returned job_t1coreg {[]}.
        if numel(jobs{1})>0
            save spm_t1coreg jobs;
            spm_jobman('run',jobs);
        end

    else
        disp('the t1 already approximately matches the standardized t1 (with rigid body transformation)');
        disp(' so I am skipping this step.');
    end
    
    
    %% 4D manipulaties
    % interleaved/sequence in orde maken.
    option='interleaved';
    
    if strcmpi(study,'Loops')
       if ismember(pp, {'1001','1002','1003','1004','1005','1006',...
               '1101','1102','1103','1104','1105','1106','1107','1108','1109'});
           option='interleaved';
       else
           option='sequence';
       end
    end
    if strcmpi(study,'Tremor')
        option='interleaved';
    end
    

    % stap 1: de 4D's slice-timen.
    jobs={};
    for i=1:numel(taken)
        jobs{end+1}=job_slicetiming(study,pp,taken{i},option);  
    end
    save spm_slicetiming jobs;
    spm_jobman('run',jobs);


    % stap 2: de 4D's in de juiste orientatie draaien.
    % doe dit for 'loops',niet voor 'tremor'
    if strcmpi(sagax,'sag')
        
        disp('rotating your 4D images SAG -> AX');
        for i=1:numel(taken)
            fmri_4Drotate(study,pp,taken{i},'a4D.mat');     
        end
    end
    
    
    %% het grote co-registratie spel.
    % het lijkt me een goed idee om unwarping te gaan doen.. dus dat gaan
    % we dan ook doen. zie http://www.fil.ion.ucl.ac.uk/spm/toolbox/unwarp/
    
    % maar eerst wil ik de 4D's een 'redelijke' overeenstemming hebben met
    % de template t1, via rigid body transformation. dus co-registreren van
    % alle 1e EPI's, maar nog niet re-slicen.
    % daarna gaan we motion correction+unwarpen doen, met daarna nog
    % optioneel warpen naar een t1 of zo houden (voor projectie op de eigen
    % t1.
    
    % co-reg de 4D,1 van de eerste taak (arbitratily chosen) naar t1.
    jobs={};
    jobs{end+1}=job_4Dcoreg1_firstImage(study,pp,taken{1});
    save spm_4Dcoreg1_firstImage jobs;
    spm_jobman('run',jobs);

    % co-reg de andere 4D's op de 4D van de 1e taak (da's makkelijker
    % co-reggen dan alles op de t1 te co-reggen.
    jobs={};
    for i=2:numel(taken)
        jobs{end+1}=job_4Dcoreg2n_firstImage(study,pp,taken{i},taken{1});
    end
    save spm_4Dcoreg2n_firstImage jobs
    spm_jobman('run',jobs);

    
    jobs={};
    for i=1:numel(taken)
        jobs{end+1}=job_realign_unwarp(study,pp,taken{i},sagax);
    end
    save spm_realign_unwarp jobs;
    spm_jobman('run',jobs);

    
    % motion parameters zijn ook regressors...
    for i=1:numel(taken)
        
        disp('copying rp_ file into regressor directory');
        tmpdir=[wdir taken{i} '/'];
        if ~isdir(tmpdir);mkdir(tmpdir);end
        copyfile([tmpdir 'fmri/rp_*.txt'],[tmpdir 'regressor/.']);
    end


    
    % stap 7: warpen naar standaard brein.
    jobs={};
    for i=1:numel(taken)
        jobs{end+1}=job_normalise_unwarp(study,pp,taken{i});
    end
    save spm_normalise_unwarp jobs
    spm_jobman('run',jobs);

    %% smoothing
    % stap 8: smoothen!!
    jobs={};
    for i=1:numel(taken)
        jobs{end+1}=job_smooth_unwarp(study,pp,taken{i});
    end
    save spm_smooth_unwarp jobs
    spm_jobman('run',jobs);
    
    % cleanup.
    if ~isdir('jobs_spm');mkdir('jobs_spm');
        movefile('spm_*','jobs_spm');
    end
    
    