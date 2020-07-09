% van emg en van mov, regressors builden en in een .txt file dumpen

% clear all;



function emgreg=extract_meanabs(EEG)


% mkdir emg_check
emgmat=EEG.data';


volTrigs=find(strcmp({EEG.event(:).type},'65535')==1);

volB=[EEG.event(volTrigs).latency]; % array van beginsamples.
volS=EEG.event(volTrigs(2)).latency-EEG.event(volTrigs(1)).latency; % scalar (hoeveel samples/vol)


%% maak voor elke spier een apart model.
%
% eentje voor mov, en eentje voor emg.

% keyboard
emgreg=[];
for i=1:size(emgmat,2);
        
    disp(['processing muscle... ' num2str(i)]);
    % maak het model voor emg en voor 'mov'...
    emg=zeros(volS,numel(volB));
    
    for j=1:numel(volB)
        
        b=volB(j);
        e=b+volS-1;
        
        emg(:,j)=emgmat(b:e,i);
        
        
    end

    % onze EMG regressor... wordt gemiddelde van abs EMG.
    emgreg(:,i)=mean(abs(emg))';
    
%     % onze MOV regressor... wordt een som van fourier power.
%     MOV=fft(mov);
%     MOV([1:10 end-8:end],:)=0;
%     movreg=sum(abs(MOV));
    
    
    fh=figure;
    set(fh,'visible','off');
    % plot(movreg,'g');
    % hold on;
    plot(emgreg(:,i),'m');

    if ~isdir('emg_check')
        mkdir emg_check
    end
    if ~isdir('emg_check/meanabs')
        mkdir emg_check/meanabs
    end
    saveas(fh,['emg_check/meanabs/spier_' num2str(i)],'jpg');
    close(fh);
    
    
    

    
end
    
    

    
