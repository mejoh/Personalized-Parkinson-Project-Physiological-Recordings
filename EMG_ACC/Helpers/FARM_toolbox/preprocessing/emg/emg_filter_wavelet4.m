function EEGOUT=emg_filter_wavelet4(EEG,method,thrmultiplier,secs)

% deze functie gebruikt de laatste en smerigste truuk om artefact != EMG te
% bereiken.

    W='coif4';
    n=8;
    % secs=2; % use 4-second windows to do this.
    
    
    segsize=2^n; % this has to divide the total length of the signal.
    extend=mod(EEG.pnts,segsize); % this needs to be added to the vector data.

    
    % keyboard;
    
    for i=1:EEG.nbchan

        
        



        s=EEG.data(i,:);

        if extend>0
            s=[s zeros(1,(2^n-extend))];
        end

        % keyboard;
        extend2=mod(size(s,2),EEG.srate*secs);
        if extend2>0
            s=[s zeros(1,EEG.srate*secs-extend2)];
        end
        % keyboard;
        
        str=['processing muscle ' num2str(i)];
        disp(sprintf(str));
        
        % proceed wavelet analysis in 4-sec windows.
        for j=1:numel(s)/EEG.srate/secs
        
            b=(j-1)*EEG.srate*secs+1;
            e=j*EEG.srate*secs;
            
            
            % diagnostics
            % str=['processing muscle ' num2str(i) ', points b=' num2str(b) ' tru e=' num2str(e)];
            % disp(sprintf(str));
            
            
            
            s2=s(b:e);
            

            [c l]=wavedec(s2,n,W); % de-compose
            thr=wthrmngr('dw1ddenoLVL',method,c,l,'mln'); % determine thr (8)
            thr=thr*thrmultiplier;
            s2d=wdencmp('lvd',c,l,W,n,thr,'s'); % apply thr and compose
            
            sd(b:e)=s2d;
            
        end

        % keyboard;
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