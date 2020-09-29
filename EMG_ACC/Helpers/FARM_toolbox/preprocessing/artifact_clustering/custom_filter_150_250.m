function outv=custom_filter_150_250(inv,srate)

    % 25 Hz filter.
    W1=150/srate/2;
    W2=250/srate/2;
    ftype='stop';
    n=round(4*srate/150);
    if mod(n,2)
        n=n+1;
    end

    b=fir1(n,[W1 W2],ftype);
    
    outv=filtfilt(b,1,inv);
    
    
    
    