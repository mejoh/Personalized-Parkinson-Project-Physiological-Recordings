function out=emg_triggers_add(in)


    v=find(strcmp({in.event.type},'65535'));
    
    for i=1:numel(v)
        
        
        in.event(end+1).type = ['  ' num2str(i,'%.3d')];
        in.event(end).latency = in.event(i).latency;
        in.event(end).duration= 0;
        in.event(end).urevent = [];
        
        
        in.event(v(i)).type='V';
        
        
        
    end
    
    
    s=find(strcmp({in.event.type},'sliceTrigger'));
    
    for i=1:numel(s)
        
        in.event(s(i)).type=' s';
        
    end
    
    out=in;
 
    
