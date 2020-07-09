% function mat_orthogonalize_regressor(a,b)
% 
% 
% a and b can be matrices (ie, combinations of row vectors)
% this function orthoginalizes *all* combinations (!)
% this is handy.
% the output is a matrix with all of the combinations orthogonalized
% so if you wanna use the original vectors in the model, you should specify
% them separately.
%
% emg = je emg (mag serie van row vectors zijn)
% d = het block design (serie van row vectors) (mogen meerdere blocks zijn, die.. (BELANGRIJK!) al
% orthogonaal zijn.
% je mag het daarna nog zelf vermendigvuldigen met alle dingen.
% if you want to do some more processing, like introducing the blocks again
% to the orthogonalised emg, be my guest!

function out=mat_orthogonalize_regressor(emg,d)


out=[];

for i=1:size(emg,2);

    e = emg(:,i); % this is your emg...
    
    for j=1:size(d,2);
 
        
        % misschien wil je nog een beter block gaan maken, eentje die beter
        % op je emg past.
        b = d(:,j); % b = block...
 
        % and here is the magic that'll do the trick.
        % this 'cascade' of emg corrections can only be done if the blocks
        % are othogonal! otherwise this won't work.
        innerb = dot(b,b);
        if innerb==0
            fprintf('Warning vector %d of model is empty\n', i);
        else
            e = e - dot(e,b)/innerb*b;
        end
        
    end
    
    out(:,end+1)=e;
    
    % now, 'e' is the extra emg on top of any block protocol. probably.
    
end


