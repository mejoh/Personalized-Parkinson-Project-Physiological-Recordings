
function [names onsets durations] = emg_markers_2_design(b,e,srate)


    % there is always an 'end' marker!
    % see below.
    
    
    % piece where you make a block design.
    names=fieldnames(b);
    names=names(1:end-1)';
    
    onsets={};
    durations={};
    
    for i=1:numel(names)
        
        onsets{i}=b.(names{i})/srate;
        durations{i}=(e.(names{i})-b.(names{i}))/srate;
    end
    
%     for i=1:numel(names)
%         
%         if strcmpi(names{i},'rust')||strcmpi(names{i},'rest')||strcmpi(names{i},'usr_rest')||strcmpi(names{i},'usr_rust')
%        
%             % if rest, then remove some of the duration. AND also, 
%             onsets{i}=onsets{i}+[0 -1*ones(1,numel(onsets{i})-1)*dt];
%             durations{i}=durations{i}+[ones(1,numel(durations{i})-1) (1/2-0.001)]*2*dt;
%             
%         else
%             
%             onsets{i}=onsets{i}+ones(1,numel(onsets(i)))*dt;
%             durations{i}=durations{i}-ones(1,numel(durations{i}))*2*dt;
%             
%         end
%     end
    
    outfile='usr_block.mat';
    disp(outfile);
    
    % keyboard;
    save usr_block.mat names onsets durations
    movefile usr_block.mat ../regressor/.
    
    
    
    outfile='usr_block_no_rest.mat';
    disp(outfile);
    
    % get out, the rest condition.
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
    save usr_block_no_rest.mat names onsets durations
    movefile usr_block_no_rest.mat ../regressor/.
    
    
    
    