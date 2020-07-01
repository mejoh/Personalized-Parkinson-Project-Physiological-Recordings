% this is the way to do it.
% per subject and per task, define 1 function which makes the model.
% this is easiest.

function prepare_gonogo_eventmp(study,pp)



    
    ppdir=['x:/Onderzoek/fMRI/' study '/pp/' pp '/'];
    cd(ppdir);
    disp(pwd);
    
    % results dir.
    rdir=['x:/Onderzoek/fMRI/' study '/results/' pp '/gonogo/eventmp/'];
    if ~isdir(rdir)
        mkdir(rdir);
    else
        disp('hmm... directory bestaat al?? .. dit staat erin:');
        ls(rdir);
    end
    

    d=dir('gonogo*');
    
    
    % voorbereiden van input
    % the body of the work.
    for i=1:numel(d)
        
        
        taak=d(i).name;
    
        wdir=['x:/Onderzoek/fMRI/' study '/pp/' pp '/' taak '/'];
        disp(wdir);

        % load all of the stuff
        load([wdir 'parameters']);
        load([wdir 'event.mat']);
        load([wdir 'rp_a4D.txt']);

        
        
        
        % for the modelling.
        nvol=parameters(3);
        tr=parameters(1);
        srate=256;
        
        % to get our model
        m=mat_convert_onsets_durations(onsets,durations,tr,nvol,srate);
        
        % kill the first 'GoRespond' column (that's done... HERE!).
        m(:,1)=[];
        
        m=mat_convolve_hrf(m,tr,srate,'hrf1');
        m=mat_desample_matrix(m,nvol,srate);
        
        % moet altijd goed gaan. Maar als je model korter is door aanpassen
        % van de parameters file, dan moet deze correctie ook gebeuren.
        rp_a4D=rp_a4D(1:nvol,:);
        
        % motion parameters adden.
        m=[m rp_a4D/max(max(rp_a4D))*max(max(m))];

        % save commando.
        save([rdir 'model' num2str(i) '.txt'],'m','-ascii');

        % ook nog n plaatje schieten.
        mat_make_snapshot(rdir,['model' num2str(i)],m);
        
    end

% en save ook gelijk maar dan... de tr.
save([rdir 'tr.txt'],'tr','-ascii');
    
    