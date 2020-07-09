% out=helper_phaseshifter(template,data,o)
% subsample-precision fit of a template on some data.

% bepaal dt.
% eerst MRi parameters.

% this could be a function that accepts a template and a data piece, and
% subsequently changes the template to even better match the artifact.
% both pieces need to be detrended first.


function [out dt]=helper_phaseshifter(template,data,points,o)

    fs              =o.fs;
    interpfactor    =o.interpfactor;
    

    peaki=points(1):points(end);

    da=[template(2:end)-template(1:end-1);0];

    % all points that have > 90 % of the maximum slope will be evaluated.
    gthalfi=find(abs(da(peaki))>max(abs(da(peaki)))*0.400)-1+points(1);

    evali=intersect(peaki,gthalfi);


    % first, we determine the time-step delta-t.
    % see scriblings on how to do this; when the direction is high enough,
    % it is possible to calculate from a delta-y and a direction of one of
    % the two, the time difference between them delta-x.
   
    % another alternative is to optimize or do a sweep to calculate dt.
    % But I like calculated guesses better. They are also faster.
   
    % determination of delta t.
    % keyboard;
    dt=mean((data(evali)-template(evali))./da(evali))/fs/interpfactor;

    % keyboard;

    % next step is to adjust -in frequency space- the phases of all of the
    % frequencies... so that in time domain, we can accomplish a shift with
    % sub-sample precision.
    TEMPLATE=fft(template);
    
    % first a vector 1 2 3 4 ... -4 -3 -2 -1. N times the frequency
    % resolution (1/sdur) of the fft of the template.

    adjusti=zeros(size(template));
    tmp=floor(numel(adjusti)/2);

    adjusti(2:tmp+1)=1:tmp;
    adjusti(end:-1:end-tmp+1)=-1*(1:tmp);

    sdur=o.sdur;
    rotationfactor=exp(1j*2*pi*dt/sdur*adjusti);
    
    out=ifft(TEMPLATE.*rotationfactor);
    
    




