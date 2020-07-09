% van emg en van mov, regressors builden en in een .txt file dumpen

% clear all;



function emgreg=extract_frequency_band(EEG,fmin,fmax)

% keyboard;
load parameters

% mkdir emg_check
emgmat=EEG.data';


volTrigs=find(strcmp({EEG.event(:).type},'V')==1);
if numel(volTrigs)==0
    volTrigs=find(strcmp({EEG.event(:).type},'65535')==1);
end

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
    
    % keyboard;
% 
%     

    f_ind=round([fmin fmax]/(EEG.srate/size(emg,1)));
    f_ind=[f_ind(1):f_ind(2) (size(emg,1)-f_ind(2)+2):(size(emg,1)-f_ind(1)+2)];
%     L=4096;%script Natasha
%     NFFT = 2^nextpow2(L);%script Natasha
%     EMG=fft(emg,NFFT);%script Natasha
    EMG=fft(emg);
    
    emgreg(:,i)=sum(abs(EMG(f_ind,:)));
    
%     
%     
%     fh=figure;
%     set(fh,'visible','off');
%     % plot(movreg,'g');
%     % hold on;
%     plot(emgreg(:,i),'m');
% 
%     
%     title=['freq_' num2str(fmin) '_to_' num2str(fmax)];
%     if ~isdir('emg_check')
%         mkdir emg_check
%     end
%     if ~isdir(['emg_check/' title '/']);
%         mkdir(['emg_check/' title '/']);
%     end
%     saveas(fh,['emg_check/' title '/spier_' num2str(i)],'jpg');
%     close(fh);
%     
%     
%     

    
end
    

save(['emg_' title '.txt'],'emgreg','-ascii');
    


% % indices of volumes.
% n_vol=[EEG.event(find(strcmp({EEG.event(:).type},'65535'))).latency];
% 
% % duration of 1 volume.
% dur=n_vol(2)-n_vol(1);
% 
% % matrixify the data
% 
% for i=1:numel(n_vol)
%     
% 
% EEG.data(i,
