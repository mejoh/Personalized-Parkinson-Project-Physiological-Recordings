%% emg script script
% orthoginaliseert een EMG regressor uit een
% model. 
%
% DANGER -- Do NOT use when trying to impress a girl.


function emg_orthogonalize_regressor(selection,regcols,modelfile)

% modelfile='model.mat'
% selection=[1 3 5];
% regcols=[1 2 3];

load(modelfile)
emgreg=[];
load emgreg
emgreg=emgreg(:,selection);


load parameters
rp_a4D=load(ls('rp_*'));

% which columns do we orthogonalize?


% emgreg=load('../voetreg.txt');
% load ../model_voet.mat




% dit veranderen als je andere regressor wilt... maar voor nu.. het
% volstaat.
% emg=load('emgreg_spier_2.txt');


% load rp_a4D.nii

%% init stuff

%
% srate ... de barbatruuk

hrf=spm_hrf(parameters(1));


srate=2^10;
TR=parameters(1);
volumes=parameters(3);



m=zeros(round(volumes*TR*srate),numel(regcols));


%% build our little matrix

% bekijk m voor en m na, 
% zie het verschil (!)
% en vergelijk dit vervolgens met je model dat je had gedefinieerd.
% !! ze zijn hetzelfde.
% dit lijkt dus omslachtig, maar dit script bespaart je de moeite om je
% model nog apart na te zoeken, en je kan ook een willekeurig event-related
% design er dus in stoppen
% Moet je wel zorgen bij het interpoleren dat je durations niet < TR zijn
% (!!!), of zelf er in in proggen.
for i=1:numel(regcols)
    
    for j=1:numel(onsets{regcols(i)})
        
        b=round(onsets{regcols(i)}(j)*srate+1);
        e=round(durations{regcols(i)}(j)*srate)+b;

        m(b:e,i)=1;
        
    end
end

fh=figure;
imagesc(m);
saveas(fh,'emg_check/tmp_sampled_design','jpg');
close(fh);


%% circumvent nasty error messages.
% add another 1s to m
m(end:end+srate*10,:)=1;

%% and ... SAMPLE it!

dm=zeros(volumes,numel(regcols));


for i=1:volumes
    for j=1:numel(regcols)

        b=round((i-1)*TR*srate)+1;
        e=round(i*TR*srate);
    
        tmp=mean(m(b:e,j));
        
        % disp([i j b e tmp]);
        
        if tmp==0
            dm(i,j)=0;
        else
            dm(i,j)=round(mean(m(b:e,j)));
            
        end    
    end
end

fh=figure;
imagesc(dm);
title('resampled design matrix check');
saveas (fh,'emg_check/tmp_resampled_design','jpg');
close(fh);

% clear m;

%% model maken

residueel_totaal=[]; % voor meerdere spieren

% %% een conv_emgreg maken...
% 
% 
% conv_emg=[];
% for i=1:size(emgreg,2)
% 
%     tmp=emgreg(:,i)/std(emgreg(:,i)); % scale
%     tmp2=conv(tmp,hrf); % convolve
%     tmp2=tmp2(1:volumes); % get rid of tail to make 240 volumes
%     conv_emgreg(:,i)=tmp2; % and store it again in new matrix
% 
% end
% 
% fh=figure;
% plot(conv_emgreg);
% legend(num2str(selection));
% title('convolved, scaled, EMG, ready for analysis');
% saveas(fh,['emg_check/conv_sEMG_' strrep(num2str(selection),' ','')],'jpg');
% close(fh);


%% and then... do regressor neat stuff.

for ind2=1:size(emgreg,2)
    
    % scaling...
    emg=emgreg(:,ind2)/std(emgreg(:,ind2));
    % % scale...
    % for i=1:numel(regcols)
    %         emg(:,1)=emg(:,i)/std(emg(:,i));
    % end
    %%
    % emg matrix...
    emgm=emg*ones(1,numel(regcols));
    %%
    % okay... GM orthogonalization ==
    % effectively, remove the mean of 1 column from this column, so that it's
    % sum will be zero (and hence, during 'non-extragenous' movements, will be
    % zero.

    % first..
    emgm=emgm.*dm;
    %% then...

    for i=1:numel(regcols)



        ind=find(dm(:,i)==1)
        emgm(ind,i)
        emgm(ind,i)=emgm(ind,i)-ones(numel(ind,i))*(sum(emgm(ind,i))/numel(ind));
        
    end


    %% snapshot 1
    fh=figure;
    colors={'r','g','b','m','y','c'}; % this shoud be enough...
    ah=axes;
    hold on
    for i=1:numel(regcols)
        plot(emgm(:,i),colors{i});
    end
    legend(names(regcols));
    
    saveas(fh,['emg_check/unconv_GM_sEMG_' num2str(ind2)],'jpg');
    close(fh);


    %% convolved EMG matrix...
    conv_emgm=zeros(size(emgm));

    for i=1:size(emgm,2)

        tmp2=conv(emgm(:,i),hrf);
        tmp2=tmp2(1:volumes);
        conv_emgm(:,i)=tmp2;

    end

    %% snapshot na
    fh=figure;
    colors={'r','g','b','m','y','c'}; % this shoud be enough...
    ah=axes;
    hold on
    for i=1:numel(regcols)

        plot(conv_emgm(:,i),colors{i});
    end
    legend(names(regcols));
    saveas(fh,['emg_check/conv_GM_sEMG_' num2str(ind2)],'jpg');
    close(fh);

    % fh=figure;
    % imagesc(conv_emgm);
    % colormap gray
    % saveas(fh,'EMG_Ortho_Design_Matrix','jpg');
    % close(fh);

    residueel_totaal=[residueel_totaal conv_emgm];

end

% figure;imagesc(residueel_totaal);

%% maak een nieuw model voor orthogonalisatie
% make a fancy new parameters file

% %% add our own regressors
newmat=[residueel_totaal rp_a4D];
save(['orthog_emg_' strrep(num2str(selection),' ','') '_with_mp.txt'],'newmat','-ascii');
save(['orthog_emg_' strrep(num2str(selection),' ','') '.txt'],'residueel_totaal','-ascii');

fh=figure;imagesc(newmat);
title(['Design ORTH emg ' strrep(num2str(selection),' ','')]);
saveas(fh,['emg_check/Design_orthogonalized_emg_' strrep(num2str(selection),' ','')],'jpg');
close(fh);

    
% %% save gelijk ook maar t normale EMG.
% 
% newmat2=[conv_emgreg rp_a4D];
% save (['emg_' strrep(num2str(selection),' ','') '_with_mp.txt'],'newmat2','-ascii');
% save (['emg_' strrep(num2str(selection),' ','') '.txt'],'conv_emgreg','-ascii');
% 
% fh=figure;imagesc(newmat2);
% title(['emg regressors ' num2str(selection) ' with motion parameters']);
% saveas(fh,['emg_check/Design_emg_' strrep(num2str(selection),' ','') '_with mp'],'jpg');
% close(fh);





