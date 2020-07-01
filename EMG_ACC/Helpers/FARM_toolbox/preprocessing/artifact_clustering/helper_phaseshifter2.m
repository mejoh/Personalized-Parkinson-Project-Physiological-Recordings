function out=helper_phaseshifter2(data,dur,dt)

    % data  = de data
    % dur   = slice-duration
    % dt    = time to shift.

    % keyboard;
    DATA=fft(data);
    
    % first a vector 1 2 3 4 ... -4 -3 -2 -1. N times the frequency
    % resolution (1/sdur) of the fft of the data.

    adjusti=zeros(size(data));
    tmp=floor(numel(adjusti)/2);

    adjusti(2:tmp+1)=1:tmp;
    adjusti(end:-1:end-tmp+1)=-1*(1:tmp);
    % keyboard;
    
    if ~rem(numel(data),2)
        adjusti(numel(data)/2+1)=0;
    end

    rotationfactor=exp(1j*2*pi*dt/dur*adjusti);
    
    out=ifft(DATA.*rotationfactor);