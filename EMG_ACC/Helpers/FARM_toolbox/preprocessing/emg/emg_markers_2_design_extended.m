
function [names onsets durations] = emg_markers_2_design_extended(b,e,srate,tr)


    % there is always an 'end' marker!
    % see below.
    
    % keyboard;
    % piece where you make a block design.

    if isfield(b,'end');
        b=rmfield(b,'end');
    end
    if isfield(e,'end');
        e=rmfield(e,'end');
    end
    
    
    
    % do it all....
    names=fieldnames(b)';
    
    onsets={};
    durations={};
    
    
    for i=1:numel(names)
        
        onsets{i}=b.(names{i})/srate;
        durations{i}=(e.(names{i})-b.(names{i}))/srate;
    end
    
    
    % remove the rest condition from this block-design!
    mark=[];
    v=regexpi(names,'r[a-z]st','match');
    for i=1:numel(v)
        if numel(v{i})>0
            mark=i;
        end
    end
    
            
    names(mark)=[];
    onsets(mark)=[];
    durations(mark)=[];
    
    % and now, for each 'active condition', model the onset and offset
    % separately. To search for areas where the initiation and halting of the
    % motor control is processed.
    tn=numel(names);
    
    % do the onsets of all the tasks...
    names{end+1}='motor onset';
    onsets{end+1}=sort([onsets{1:tn}]);
    durations{end+1}=zeros(size(onsets{end}));
    
    
    % and... do the offsets!
    
    names{end+1}='motor offset';
    onsets{end+1}=sort([onsets{1:tn}] + [durations{1:tn}]);
    durations{end+1}=zeros(size(onsets{end}));
    
    

    % insert markers at every time-point where the projection of the screen
    % changes.
    names{end+1}='stimulus change';
    onsets{end+1}=sort([(0:6)*40+1+10 (0:6)*40+1+30 (0:15)*20+1]-1)*tr;
    durations{end+1}=zeros(size(onsets{end}));
    
    % at the beginning, the stimulus just stays the same!!
    onsets{end}(1)=[];
    durations{end}(1)=[];
    
    save usr_block_no_rest_extended.mat names onsets durations
    movefile usr_block_no_rest_extended.mat ../regressor/.
    
    
    