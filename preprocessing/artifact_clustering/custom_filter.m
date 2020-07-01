function outv=custom_filter_25(inv,srate)

    % 25 Hz filter.
    Wn=25/srate/2;
    ftype='high';
    n=4*srate/25;

    b=fir1(n,Wn,ftype);
    
    outv=filtfilt(b,1,inv);
    
    
    
    