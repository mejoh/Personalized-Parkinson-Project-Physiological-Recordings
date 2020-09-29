% de laatste 'selectie'.

function EEGOUT=emg_threshold(EEG)

    for i=1:EEG.nbchan
        
        v=EEG.data(i,:);
        
        % maak een v2 met alles op 0 wat te klein is.
        tmp=find(v>10*median(v));
        v2=zeros(size(v));
        v2(tmp)=1;
        v2=v.*v2;
        
        burst_mean=mean(v2(tmp));
        burst_sd=std(v2(tmp));
        
        % en dan... apply threshold.
        thr=burst_mean+burst_sd;

        v3=v2;
        v3(find(v2<thr))=0;
        
        % v3 is your 'myoclonus', or 'myoclonus-approximation'.
        % let's see if it is really something interesting.
        
        EEG.data(i,:)=v3;
        
    end
    
    EEGOUT=EEG;
    
    
        
        
        
        % verdere 'pruning'.
        % 'load' de onsets en durations.
        
        
        
        
        

% stap 1: selecteer eerst alle punten > 10*median(v).
% zet de rest op 0.


% daarna, van alles wat > 0 is, bepaal de mean en de SD.
% haal daarna alles weg wat < 2*
