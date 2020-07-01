function cond = pf_pmg_selcond(conf,annotation,Fs)
%
% pf_mpg_selcond will return the event name, event starttime and event 
% duration of the conditions you want to select. It thereby corrects for 
% the start of the events and the samplerate. This is useful because 
% FieldTrip does not recognize the annotations (at least in my
% case), so this is a workaround where you use ReadEDF to retrieve your
% annotations.

% © Michiel Dirkx, 2014
% $ParkFunC

%--------------------------------------------------------------------------

%% Select condition(s) based on options
%--------------------------------------------------------------------------

nEvent   =   length(annotation.event);
try 
    speccond    =   conf.fa.cond;
catch
    speccond    =   conf.ft.fa.cond;
end

if ischar(speccond)
    
    switch speccond
        
        case 'all'
            
            fprintf('%s\n','- Using whole file')
            
            cond.event      =   annotation.event;
            cond.starttime  =   (annotation.starttime - annotation.starttime(1))*Fs;
            cond.duration   =   annotation.duration*Fs;

        case 'allcond'
            
            fprintf('%s\n','- Selecting all conditions')
            
            % --- Find first condition and select from there --- %
            
            Ci = find(strcmp(annotation.event,conf.fa.cond1));
            cond.event      =   annotation.event(Ci:end);
            cond.starttime  =   (annotation.starttime(Ci:end) - annotation.starttime(1) )*Fs;
            cond.duration   =   annotation.duration(Ci:end)*Fs;
            
        case 'intersel'
            
            fprintf('%s\n','- File contains following conditions:')
            
            for a = 1:nEvent; fprintf('%s\n',[num2str(a) '. ' annotation.event{a}]); end
            Ci  =   input('\n Which conditions do you want to select? \n');
            
            cond.event      =   annotation.event(Ci);
            cond.starttime  =   (annotation.starttime(Ci) - annotation.starttime(1))*Fs;
            cond.duration   =   annotation.duration(Ci)*Fs;
    end
    
else
    
    fprintf('%s\n','- Selecting predefined conditions')
    
    % --- Find specified conditions --- %
    
    nCond   =   length(speccond);
    cnt     =   1;
    cnt2    =   1;
    note    =   0;
    
    for a= 1:nCond
        i =  find(strcmp(annotation.event,speccond{a}));
        if ~isempty(i) && length(i) == 1
            Ci(cnt) = i;
            cnt     = cnt+1;
        elseif ~isempty(i) && length(i) > 1
            fprintf('-- Found multiple conditions for "%s"\n',speccond{a})
            for b = 1:length(i)
                fprintf('%s\n',[num2str(b) '. Event: "' annotation.event{i(b)} '". Starttime: ' num2str(((annotation.starttime(i(b))-annotation.starttime(1)))/60) ' min. Duration: ' num2str((annotation.duration(i(b)))/60) ' min.'])
            end
            in = input('Which event do you want to include ? \n');
            Ci(cnt:cnt+length(in)-1) = i(in);
            idbl{cnt2}    =   cnt:cnt+length(in)-1;
            cnt  = cnt+length(in);
            cnt2 = cnt2+1;
            note = 1;
        else
            fprintf('-- Could not find condition "%s"\n',speccond{a})
            keyboard
        end
    end
    
    % --- Select the right conditions --- %
    
    cond.event      =   annotation.event(Ci);
    cond.starttime  =   ( annotation.starttime(Ci) - annotation.starttime(1) )*Fs;
    cond.duration   =   annotation.duration(Ci)*Fs;
    
    % --- Change names double events --- %
    
    if note == 1
        for b = 1:length(idbl)
            CurIdbl = idbl{b};
            for c = 1:length(CurIdbl)-1
                cond.event{CurIdbl(c+1)} = [cond.event{CurIdbl(c+1)} '_' num2str(c+1)];
            end
        end
    end
        
end

cond.first  =   annotation.starttime(1);        % Sometimes the first condition does not start at time zero, so thats why you need this to correct for that

%==========================================================================