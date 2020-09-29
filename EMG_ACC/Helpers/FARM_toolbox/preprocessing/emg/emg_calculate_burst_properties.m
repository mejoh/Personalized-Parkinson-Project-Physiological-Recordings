% function bursts=emg_calculate_burst_properties(bursts,data)


function bursts=emg_calculate_burst_properties(bursts,data,mode,srate)


    % apply averaging filter on d, for the 'amp'!
    for i=1:size(data,1);
        data(i,:)=abs(hilbert(data(i,:)));
    end
    % keyboard;
    

    for i=1:numel(bursts)
        
        for j=1:numel(bursts{i})
            
            b=bursts{i}(j).bt;
            e=bursts{i}(j).et;
            
            d=data(i,b:e);
            m=mode(i,b:e);
            % keyboard;
            
            
            bursts{i}(j).amp = max(d);
            bursts{i}(j).dur = numel(d)/srate;
            bursts{i}(j).area = sum(d)/srate;
            bursts{i}(j).mode = mean(m);
            
        end
    end
    