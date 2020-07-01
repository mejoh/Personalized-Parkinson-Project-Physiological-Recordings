% this function chips away at your vector, or matrix of 0's and 1's that
% encode for activity.
%
% in is the matrix
% direction is any integer number, which says which direction 1's should
% become 0's.
% write this maybe to a 'better, cleaner' function... in the future!
%
% 2010-01-26: paul changed some lines:
%                 - remove all point between onset and onset+d, not only at onset+d
%                 - set points at start of vector to zero if v(1)==1 (i.e. force an onset there)
% 2010-03-05: paul: hmmm... fixed a glitch in the indexing syntax, which was introduced by the 'fix' above
% 2010-05-10: paul: v() can be set to zero outside the original boundary when an onset is found at the end
%                   so included additional check for indexing; also tweaked the code to remove the
%                   duplex code for forward and backward direction

function out=mat_chip_regressor(in,direction)

    out=zeros(size(in));
    len = size(in,1);
    if direction==0
        disp('nothing to chip away!');
        absdir = 0;
    elseif direction>0
        absdir = direction;          
    elseif direction<0
        absdir = -direction;
    end
    
    for i=1:size(in,2)
        
        v=in(:,i);
        
        if direction<0
            % mirror it...
            v=v(end:-1:1);
        end
        
        if direction~=0
            % index_just_before_the_just_to_1...
            i_ch=find(v(2:end)-v(1:end-1)>0);
            for j=1:length(i_ch)
                iBegin = i_ch(j) + 1;
                if iBegin<=len
                    iEnd = i_ch(j) + absdir;
                    if iEnd>len; iEnd=len; end
                    v(iBegin:iEnd)=0;
                end
            end
            if v(1)>0
                v(1:absdir)=0;
            end
        end
        
        if direction>=0
            % straight copy
            out(:,i)=v;
        else
            % mirror it backwards...
            out(:,i)=v(end:-1:1);
        end
        
    end