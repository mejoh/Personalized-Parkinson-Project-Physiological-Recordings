% do our own emg artefact removal.

% starting point: emg_2


load emg_2.mat

slices=50;

% i_v = lijst van alle vol triggers
i_v=find(strcmp({EEG.event(:).type},'65535')==1);

for ch=1 %:EEG.nbchan


for i=1 %:numel(i_v)
    
    tmp=find([EEG.event(:).latency]==EEG.event(iv(i)).latency);
    
    indices=tmp(2):(tmp(2)+slices-1);
    
    m=[];

    length=EEG.event(indices(2)).latency-EEG.event(indices(1)).latency;
    
    for j=1:slices
        b=EEG.event(indices(j)).latency;
        e=b+length;
        
        m(:,j)=EEG.data(1,b:e)
        
        
    end
    
end
    
    