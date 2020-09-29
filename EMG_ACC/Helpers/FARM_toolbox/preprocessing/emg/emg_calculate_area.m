function [s mins]=emg_calculate_area(v,m,noise)

    % this is for a new function.
    % and now, we impose our THIRD condition for it to be a myoclonus... a
    % condition which specifies how much area there has to be.    %
    % thresholding-in-action; remove areas that aren't large enough.
    % keyboard;
    sums=[];
    mins=[];
    % keyboard;
    
    for i=1:numel(m.b)
       
        % keyboard;
        
        av=sum(v(m.b(i):m.e(i))); %-noise(m.b(i):m.e(i)));
        
        if av<0
            av=0;
            disp('area < 0??');
        end

        % what is a good threshold for area? % thr3*median(v)!
        % if av < thr3*median(v)
        %     marked(end+1)=i;
        % end
        sums(end+1)=av;
    end
    
    s=sums;