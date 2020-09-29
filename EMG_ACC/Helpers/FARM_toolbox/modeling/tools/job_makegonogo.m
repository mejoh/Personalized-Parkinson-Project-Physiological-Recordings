% this is the way to do it.
% per subject and per task, define 1 function which makes the model.
% this is easiest.

function prepare_gonogomp(study,pp);


    % subjects dir.
    ppdir=['x:/Onderzoek/fMRI/' study '/pp/' pp '/'];
    
    % results dir.
    rdir=['x:/Onderzoek/fMRI/' study '/results/' pp '/' taak '/eventmp/'];


    d=dir('gonogo*');
    
    model{1:numel(d)}=[];
    scans{1:numel(d)}={};
    
    % voorbereiden van input
    % the body of the work.
    for i=1:numel(d)
        
        
        taak=d(i).name;
    
        wdir=['x:/Onderzoek/fMRI/' study '/pp/' pp '/' taak '/'];
        disp(wdir);

        % load all of the stuff
        load([wdir 'parameters']);
        load event.mat
        load rp_a4D.txt

        % make our matrix
        nvol=parameters(3);
        tr=parameters(1);
        % to get our model
        m=mat_build_matrix(onsets,durations,tr,nvol,srate);
        m=mat_convolve_hrf(m,tr,srate,'hrf1');
        mat=mat_desample_matrix(m,nvol,srate);
        
        % moet altijd goed gaan. Maar als je model korter is door aanpassen
        % van de parameters file, dan moet deze correctie ook gebeuren.
        rp_a4D=rp_a4D(1:nvol);
        
        m=[mat rp_a4D];
        model{i}=m;

        for j=1:nvol
            scans{i}{j,1}=[wdir 'a4D.img, ' num2str(i)];
        end
        
        save([rdir taak '.txt'],'m','-ascii');
        
        % fraai figuurtje poetsen.
        fh=figure;
        set(fh,'visible','off');
        imagesc(m);
        saveas(fh,[rdir taak '.jpg'],'jpg');
        
        
    end

    
    
    %%%%
    % de struct invullen.
    f.dir = rdir;
    
    f.timing.units      = 'secs';
    f.timing.RT         = tr;       % deze is wel belangrijk!!!
    f.timing.fmri_t     = 16;
    f.timing.fmri_t0 	= 1;
    
    

    for i=1:numel(d)
        f.sess(i).cond      = struct('name',{},'onset',{},'duration',{},'tmod',{},'mod',{});
        f.sess(i).multi     = {''};
        f.sess(i).regress   = struct('name',{},'val',{});
        f.sess(i).multi_reg = {[rdir d(i).name '.txt']};
        f.sess(i).hpf       = 128;
    end
    
    f.fact = struct('name',{},'levels',{});
    
    f.bases.bases.hrf.derivs = [0 0];
    
    f.volt      = 1;
    f.global    = 'None';
    f.mask      = {''};
    f.cvi       = 'AR(1)';
    
    % en dan nu verder je jobfile maken gaan.
    jobout.stats{1}.fmri_spec=f;

    