% function [namesout onsetsout durationsout]=emg_lump_model(names,onsets,durations,lumpi,name)
%
% this creates a new model. keep specifies the regs you wish to keep.
%
% lump specifies a couple of different regs that should be lumped and
% catonated to the ones you wish to keep. lumoi can be a matrix, and
% therefore can create 2 extra regs from N others. names is a cell array,
% specifying the lump-ed regressor names.
%
% both lump,& newnames, are CELL-arrays. as their # of elements might
% change from 1 to the next.


function [namesout onsetsout durationsout]=emg_lump_model(names,onsets,durations,keep,lump,newnames)



namesout=names(keep);
durationsout=durations(keep);
onsetsout=onsets(keep);

% vectorize onsets.



for i=1:numel(lump)
    
    vec=[];
    dur=[];
    
    lumpi=lump{i};
    
    vec=[onsets{lumpi}];
    dur=[durations{lumpi}];
    
    % for certainty's sake, reshape!
    
    vec=reshape(vec,numel(vec),1);
    dur=reshape(dur,numel(dur),1);
    
    vecdur=sortrows([vec dur],1);
    
    
    onsetsout{end+1}=reshape(vecdur(:,1),1,numel(vec));
    durationsout{end+1}=reshape(vecdur(:,2),1,numel(dur));
    namesout{end+1}=newnames{i};
    
end


    
    
    
    
    
    
    
    
    
    
end

