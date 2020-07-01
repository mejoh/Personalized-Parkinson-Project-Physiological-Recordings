function Signal = pa_bandpass(Signal, Fc, Fn, Norder)
%  PA_BANDPASS(SIGNAL, FC, FN, NORDER)
%
%    Bandpass filtering of time sequence.
% 
%    SIGNAL - Time sequence
%    FC     - Cutoff frequencies (default 4 and 16 kHz)
%    FN     - Nyquist Frequency (default 25 kHz)
%    NORDER - Order of filter (default 100)
%
% See also FIR1, FILTFILT, PA_LOWPASS, PA_HIGHPASS, PA_GETPOWER

% (c) 2011 Marc van Wanrooij

if nargin<2
    Fc      = [500 20000];
end
if nargin<3
    Fn      = 25000;
end
if nargin<4
    Norder  = 100;
end
f           = Fc/Fn;
b           = fir1(Norder,f);
Signal      = filtfilt (b, 1, Signal);