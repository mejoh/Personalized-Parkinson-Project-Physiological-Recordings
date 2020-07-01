function m=emg_calculate_area(v,thr)

    % this is for a new function.
    % and now, we impose our THIRD condition for it to be a myoclonus... a
    % condition which specifies how much area there has to be.    %
    % thresholding-in-action; remove areas that aren't large enough.
    % keyboard;
    

    marked=[];
    sums=[];
    % keyboard;
    for i=1:numel(m.b)
       
        % keyboard;
        av=sum(v(m.b(i):m.e(i)));

        % what is a good threshold for area? % thr3*median(v)!
        % if av < thr3*median(v)
        %     marked(end+1)=i;
        % end
        sums(end+1)=av;
    end
    keyboard;
    
            
    for i=1:numel(m.b)
        
        if sums(i)<thr_area
            marked(end+1)=i;
        end
    end
    
    if numel(marked)>0
        m.b(marked)=[];
        m.e(marked)=[];
    end