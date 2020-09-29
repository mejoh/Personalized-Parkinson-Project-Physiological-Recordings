function EEGOUT=emg_filter_wavelet2(EEG)

% deze functie gebruikt de laatste en smerigste truuk om artefact != EMG te
% bereiken.

    W='coif4';
    n=8;
    
    
    segsize=2^n; % this has to divide the total length of the signal.
    extend=mod(EEG.pnts,segsize); % this needs to be added to the vector data.

    
    
    for i=1:EEG.nbchan




        s=EEG.data(i,:);

        if extend>0
            s=[s zeros(1,(2^n-extend))];
        end


        [c l]=wavedec(s,n,W); % de-compose
        thr=wthrmngr('dw1ddenoLVL','rigrsure',c,l,'mln'); % determine thr (8)
        sd=wdencmp('lvd',c,l,W,n,thr,'s'); % apply thr and compose

        sd=sd(1:EEG.pnts);
        
        EEG.data(i,:)=sd;
        
    end
    
    EEGOUT=EEG;
        
    

    
% %%
% load v
% s=v';
% 
% n=8;
% % decompose it...
% 
% 
% % get all of the decomposition parameters.
% 
% 
% %%
% 
% % and build up again... but do not use certain wavelet components.
% 
% keyboard;
% 
% for i=7:-1:1
%     
%     
%     if sum(i==[1 2 4 5])
%         D{i}=zeros(size(D{i}));
%     end
% 
%     A{i}=idwt(A{i+1},D{i+1},W,L(numel(L)-i));
%         
% end
% 
% sd=idwt(A{1},D{1},W,numel(s));