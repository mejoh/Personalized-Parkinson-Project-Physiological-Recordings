function out=build_block_models(taak,tr)


    
    onsets={};
    names={};


    if strcmp(taak,'motor_tappen')%if strcmp(taak,'motor_tappen') CHANGED 11-07-2012
        
        
        % dit is een ABAC model, 7x, 10/block.
        names={'tappen','strekken','rust'};
        
        onsets{1}=(0:6)*40+1+10;
        onsets{2}=(0:6)*40+1+30;
        onsets{3}=(0:14)*20+1;
              
    end
    
    
    
    if strcmp(taak,'tremor2')
        
        % dit is een AB model, 10x, 10/block.
        names={'nadoen','rust'};
        
        onsets{1}=(0:6)*20+11;
        onsets{2}=(0:7)*20+1;
        
        
    end
    
    
    
    if strcmp(taak,'tapping')
        
        % dit is een AB model, 7x, 10/block.
        names={'stop','go'};
        
        onsets{1}=(0:8)*20+11;
        onsets{2}=(0:9)*20+1;
        
        
    end
    
    
    if strcmp(taak,'tremor1')
        
        % dit is een AB model, 7x, 10/block.
        names={'links_strekken','rechts_strekken','beide_strekken','rust'};
        
        onsets{1}=(0:3)*60+11;
        onsets{2}=(0:3)*60+31;
        onsets{3}=(0:3)*60+51;
        onsets{4}=(0:11)*20+1;
        
        
    end
    
    if strcmp(taak,'tremor2')
        
        % dit is een AB model, 7x, 10/block.
        names={'links_bewegen','rechts_bewegen','rust'};
        
        onsets{1}=(0:3)*40+11;
        onsets{2}=(0:3)*40+31;
        onsets{3}=(0:7)*20+1;
        
        
    end
    
    
    
    
    
    
    
        
    durations=cell(size(onsets));
        
    % en dan x de tr doen... om mooie 'seconden' te krijgen.
    % en de durations gaan fixen.
    for i=1:numel(onsets)
        onsets{i}=(onsets{i}-1)*tr;
        durations{i}=10*ones(size(onsets{i}))*tr;
    end       
    
    
    
    % saven inclusief rust (maar niet 'goede' fmri-werkwijze (??)
    % iig niet met 1 conditie...
    
    disp(pwd);
    
    save block.mat names onsets durations
    out='block.mat';
