% function [b e]=vector_walker(in)
% this function goes through a 010101011101 vector and gives you back the
% b's and the e's.

function [b e]=vector_walker(in)


    % prevents a signal starting with 1 and ending with 1 from messing up
    % the detection.
    in(1)=0;
    in(end)=0;
    
    b=[];
    e=[];
    for i=2:numel(in)-1
        if in(i-1)~=in(i)&&in(i)==1
            b=[b i];
        end
        if in(i+1)~=in(i)&&in(i)==1
            e=[e i];
        end
    end
    
    
    % kill 1-point-markers.
    delete=[];
    if numel(b)>1&&numel(e)>1
        for i=1:numel(b)
            if e(i)==b(i)
                delete=[delete i];
            end
        end
        b(delete)=[];
        e(delete)=[];
    end
    
    if numel(b)~=numel(e)
        disp('hmm.. what gives? The bees and ees are messed up.');
    end
    
            


