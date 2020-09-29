% this function ensures that the model obeys the restrictions of total
% scanning Time.
function [onsets durations]=apply_scanTime_contraint(onsets,durations,scanTime)

    % STAP 1
    % nu nog compenseren voor te (kleine?) scanTime...
    % onset > scanTime ?? --> verwijder onset en duration.

    disp(['max logtime is ' num2str(scanTime) '... adjusting onsets and durations...']);
    
    for i=numel(onsets):-1:1
        for j=numel(onsets{i}):-1:1
            
            % disp([i j onsets{i}(j)]);


            if onsets{i}(j)>scanTime
                disp(['..LogTime>ScanTime! -- LogTime = ' num2str(onsets{i}(j)) ', scanTime = ' num2str(scanTime) '...removing onset!']);
                onsets{i}(j)=[];
                durations{i}(j)=[];
            end
            
        end
    end
            

       
    
    
    % STAP 2
    % onset + duration > scanTime ?? --> verkort duration tot
    % scanTime-onset.
    for i=numel(onsets):-1:1
        for j=numel(onsets{i}):-1:1

            if (onsets{i}(j)+durations{i}(j))>scanTime
                disp(['..LogTime>ScanTime! -- LogTime = ' num2str(onsets{i}(j)+durations{i}(j)) ', scanTime = ' num2str(scanTime) '...adjusting duration!']);
                durations{i}(j)=scanTime-onsets{i}(j);
            end
        end
    end
    
    
    %% and yet another check.
    
    % disp(['max time in log~: ' num2str(max([onsets{:}])) ', max time in scans~: ' num2str(scanTime)]);

