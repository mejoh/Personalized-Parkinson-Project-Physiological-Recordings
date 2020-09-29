function EEGOUT=emg_filter_wavelets(EEG)

% deze functie gebruikt de laatste en smerigste truuk om artefact != EMG te
% bereiken.

    % keyboard;
    W='coif4';
    n=8; % level of decomposition
    segsize=2^n; % this has to divide the total length of the signal.
    extend=mod(EEG.pnts,segsize); % this needs to be added to the vector data.

    remove_levels=[1 2 4 5];
    
    
    for i=1:EEG.nbchan




        s=EEG.data(i,:);

        if extend>0
            s=[s zeros(1,(2^n-extend))];
        end

        [C L]=wavedec(s,n,W);


        A=cell(1,n);
        D=cell(1,n);

        A{n} = appcoef(C,L,W,n);

        for j=1:n
            D{j}=detcoef(C,L,j);
        end
        
        
        for j=(n-1):-1:1


            if sum(j==remove_levels)
                D{j}=zeros(size(D{j}));
            end

            A{j}=idwt(A{j+1},D{j+1},W,L(numel(L)-j));
        
        end

        sd=idwt(A{1},D{1},W,numel(s));
        
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