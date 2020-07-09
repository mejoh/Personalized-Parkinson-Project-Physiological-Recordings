function d=filter_lowfrequency(d,o)

% extract some parameters
hpf=o.filter.hpf;
fac=o.filter.hpffac;
nyq=o.fs/2;
trans=o.filter.trans;
fs=o.fs;


% build the filter using fir-least squares
filtorder=round(fac*fs/(hpf*(1-trans)));
if rem(filtorder,2)
    filtorder=filtorder+1;
end

a=[0 0 1 1];
f=[0 hpf*(1-trans)/nyq hpf/nyq 1];

b=firls(filtorder,f,a);

% and apply.
for i=1:o.nch
    d.original(:,i)=filtfilt(b,1,d.original(:,i));
end