% this function makes the model for spm. it has two arguments: one being
% the directory where the model should be estimated (and the SPM.mat file
% should be written), and the other being swa or sra; ie, the extension of
% the fmri data.

function jobout = job_model(study,pp,taak,analysis,prefix,derivs)

    
    base=regexprep(pwd,'(^.*)(Onderzoek.*)','$1');
    rdir=[base 'Onderzoek/fMRI/' study '/pp/' pp '/' taak '/results/' analysis '/'];
    cd(rdir);
    pwd
    
    % keyboard;
    % de struct invullen.
    f.dir = {rdir};

    
    % count the # of models.
    dm=dir([rdir 'model*']);
    dr=dir([rdir 'regressors*']);
    dd=dir([rdir 'datadir*']);
    imax=max([numel(dm) numel(dr)]);
    
    
    tr=load([rdir 'tr.txt']);
    nvol=load([rdir 'nvol.txt']);

    
    % hier nog iets voor model -> taak
    % model1 -> taak1
    % model2 -> taak2, etc.
    
    % keyboard;
    
    for i=1:imax
        
        load(dd(i).name);

        for j=1:nvol(i)
            % keyboard;
            f.sess(i).scans{j,1}=[datadir prefix '4D.img, ' num2str(j)];
        end

        f.sess(i).cond      = struct('name',{},'onset',{},'duration',{},'tmod',{},'mod',{});

        % zie boven... vul alleen wat in als er model.mat bestanden staan
        % in de dir.
        if numel(dm)>0
            f.sess(i).multi     = {[rdir dm(i).name]};
        else
            f.sess(i).multi     = {''};
        end
        
        f.sess(i).regress   = struct('name',{},'val',{});

        % zie boven... vul alleen wat in als er regressor.mat bestanden 
        % staan in de dir.
        if numel(dr)>0
            f.sess(i).multi_reg = {[rdir dr(i).name]};
        else
            f.sess(i).multi_reg = {''};
        end
        
        f.sess(i).hpf       = 128;
    end
    
        
    f.timing.units      = 'secs';
    f.timing.RT         = tr;       % deze is wel belangrijk!!!
    f.timing.fmri_t     = 16;
    f.timing.fmri_t0 	= 1;
    
    
    f.fact = struct('name',{},'levels',{});

    if ischar(derivs)
        derivs=str2num(derivs);
    end
    if derivs==0
        derivsval=[0 0];
    elseif derivs==1
        derivsval=[1 0];
    elseif derivs==2
        derivsval=[1 1];  
    elseif derivs==3
        derivsval=[0 1];
    end
        
    f.bases.hrf.derivs = derivsval; % derivative-information.

    
    f.volt      = 1;
    f.global    = 'None';
    f.mask      = {''};
    f.cvi       = 'AR(1)';
    
    % en dan nu verder je jobfile maken gaan.
    jobout.stats{1}.fmri_spec=f;
