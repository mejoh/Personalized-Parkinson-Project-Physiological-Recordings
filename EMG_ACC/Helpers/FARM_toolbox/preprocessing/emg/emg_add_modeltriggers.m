% converts onsets in your model, to triggers in your EMG trace
% (so you can know where you are in BVA !!)

function EEGOUT = emg_add_modeltriggers(EEG)

% keyboard;
regDir='../regressor/';

if numel(dir([regDir 'block.mat']))>0
    load([regDir 'block.mat']);
end
if numel(dir([regDir 'event.mat']))>0
    load([regDir 'event.mat']);
end
if numel(dir([regDir 'block.mat']))*numel(dir([regDir 'event.mat']))>0
    
    load([regDir 'block.mat']);
    disp('there is both a block and an event.mat file... i loaded the block.mat!');
    
    b_onsets=onsets;
    b_names=names;
    b_durations=durations;
    
    load([regDir 'event.mat']);
    disp('... and also the event.mat! -- both will be markered in the trace.');
    e_onsets=onsets;
    e_names=names;
    e_durations=durations;
    
    onsets=[b_onsets e_onsets];
    names=[b_names e_names];
    durations=[b_durations e_durations];
    
end


% keyboard;

tmp=find(strcmp({EEG.event(:).type},'V'));
if numel(tmp)==0 % dan moet ik nog triggers vervangen...
    tmp=find(strcmp({EEG.event(:).type},'65535'));
    % dan had ik nog niet 65535 voor V vervangen!
    i_wrongname=find(strcmp({EEG.event(:).type},'65535'));
    for i=1:numel(i_wrongname);EEG.event(i_wrongname(i)).type='V';end
end


firstVlat=EEG.event(tmp(1)).latency;

for i=1:numel(names)
    
    trigName=names{i};

    trigOnsets=onsets{i};
    
    for j=1:numel(trigOnsets)
 
        trigOnset=floor(EEG.srate*trigOnsets(j)+firstVlat);
        
        if (trigOnset<EEG.pnts)
            
        
            if isfield(EEG.event,'duration')&&isfield(EEG.event,'urevent')
                
                EEG.event(end+1)=struct(...
                    'type',trigName,...
                    'latency',trigOnset,...
                    'urevent',[],...
                    'duration',1);
            end
            
            if isfield(EEG.event,'duration')&&~isfield(EEG.event,'urevent')
                
                EEG.event(end+1)=struct(...
                    'type',trigName,...
                    'latency',trigOnset,...
                    'duration',1);
            end
            
            if ~isfield(EEG.event,'duration')&&~isfield(EEG.event,'urevent')
                EEG.event(end+1)=struct(...
                    'type',trigName,...
                    'latency',trigOnset);
                
            end

            
                
                
        else
            disp(['Trigger ' trigName ', ' num2str(trigOnset) ' seems to be outside the EMG trace, EEG length = ' num2str(EEG.pnts/EEG.srate)]);
        end
        
    end
end

EEGOUT=EEG;

