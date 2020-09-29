function outv=custom_filter_250(inv,srate)

    % 25 Hz filter.
    Wn=250/srate/2;
    ftype='high';
    n=round(4*srate/250);
    if mod(n,2)
        n=n+1;
    end

    b=fir1(n,Wn,ftype);
    
    outv=filtfilt(b,1,inv);
    
    
    
    