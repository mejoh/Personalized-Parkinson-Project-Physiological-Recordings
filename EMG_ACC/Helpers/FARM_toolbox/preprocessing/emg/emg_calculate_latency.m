function l=emg_calculate_latency(m)

    % this is for a new function.
    % and now, we impose our THIRD condition for it to be a myoclonus... a
    % condition which specifies how much area there has to be.    %
    % thresholding-in-action; remove areas that aren't large enough.
    % keyboard;
    lat=[];
    % keyboard;
    for i=1:numel(m.b)
       
        % keyboard;
        lat(end+1)=numel(m.b(i):m.e(i));
        % what is a good threshold for area? % thr3*median(v)!
    end
    
    l=lat;