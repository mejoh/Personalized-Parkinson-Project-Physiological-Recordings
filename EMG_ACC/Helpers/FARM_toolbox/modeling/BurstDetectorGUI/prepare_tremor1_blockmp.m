% this is the way to do it.
% per subject and per task, define 1 function which makes the model.
% this is easiest.

function prepare_tremor1_blockmp(study,pp)



    
    ppdir=['x:/Onderzoek/fMRI/' study '/pp/' pp '/'];
    cd(ppdir);
    disp(pwd);
    
    % results dir.
    rdir=['x:/Onderzoek/fMRI/' study '/results/' pp '/tremor1/blockmp/'];
    if ~isdir(rdir)
        mkdir(rdir);
    else
        disp('hmm... directory bestaat al?? .. dit staat erin:');
        ls(rdir);
    end
    

    taak='tremor1';

    wdir=['x:/Onderzoek/fMRI/' study '/pp/' pp '/' taak '/'];
    % ruwdir=['x:/Onderzoek/fMRI/' study '/ruw/' pp '/'];
    disp(wdir);

    % load all of the stuff
    load([wdir 'parameters']);
    load([wdir 'block.mat']);
    load([wdir 'rp_a4D.txt']);
    load([wdir 'emg_meanabs.txt']);
    load([wdir '../muscles.mat']);




    % for the modelling.
    nvol=parameters(3);
    tr=parameters(1);
    srate=256;

    % to get our model
    m=mat_convert_onsets_durations(onsets,durations,tr,nvol,srate);
    m(:,end)=[]; % remove the rest condition.
    

    
    b=mat_convolve_hrf(m,tr,srate,'hrf1'); % block maken.
    b=mat_desample_matrix(b,nvol,srate);
    
    
    
    
%     m=mat_desample_matrix(m,nvol,srate);   % verder met emg gaan.
% 
%     % remove 1st and last '1' of m...
%     m2=m;
%     % weghaal truuk van voor emg regressor...
%     for j=1:2
%         for k=2:numel(m(:,j))
%             if m(k-1,j)~=m(k,j)
%                 m2(k,j)=0;
%                 m2(k-1:k-2,j)=0;
%             end
%         end
%     end
%     
% 
% 
%     % what's the extensor?? --> dig in 'ruw', and get the regressor.
%     % vuile truuks voor emg orthogonalisatie.
%     % nog ff schalen met sd
%     emgstd=std(emg_meanabs);
%     emgscaled=emg_meanabs.*(ones(size(emg_meanabs,1),1)*(1./emgstd));
% 
%     ind_extL=find(strcmp(muscles,'ExtensorL'),1);
%     ind_extR=find(strcmp(muscles,'ExtensorR'),1);
%     ind_flexL=find(strcmp(muscles,'FlexorL'),1);
%     ind_flexR=find(strcmp(muscles,'FlexorR'),1);
%     
%     emg_extL=mat_orthogonalize_regressor(emgscaled(:,ind_extL),m2);
%     emg_extR=mat_orthogonalize_regressor(emgscaled(:,ind_extR),m2);
%     emg_flexL=mat_orthogonalize_regressor(emgscaled(:,ind_flexL),m2);
%     emg_flexR=mat_orthogonalize_regressor(emgscaled(:,ind_flexR),m2);
%     emg1=emg_extL.*m2(:,1);
%     emg2=emg_flexL.*m2(:,1);
%     emg3=emg_extR.*m2(:,2);
%     emg4=emg_flexR.*m2(:,2);
%     
% 
%     emg=[emg1 emg2 emg3 emg4];
%     cemg=mat_convolve_hrf(emg,tr,1,'hrf1'); % block maken.

    % keyboard;


    % bouwen van het model... als eerste de block regressors.




    % moet altijd goed gaan. Maar als je model korter is door aanpassen
    % van de parameters file, dan moet deze correctie ook gebeuren.
    % rp_a4D=rp_a4D(1:nvol,:);

    % motion parameters adden.
    out=[b rp_a4D];

    % save commando.
    save([rdir 'model1.txt'],'out','-ascii');

    % ook nog n plaatje schieten.
    mat_make_snapshot(rdir,'model1',out);



% en save ook gelijk maar dan... de tr.
save([rdir 'tr.txt'],'tr','-ascii');
    
    