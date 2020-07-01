function Signal = pa_lowpass(Signal, Fc, Fn, Norder)
%  PA_LOWPASS(SIGNAL, FC, FN, NORDER)
%
%    Lowpass filtering of time sequence.
% 
%    SIGNAL - Time sequence
%    FC     - Cutoff frequency (default 3 kHz)
%    FN     - Nyquist Frequency (default 25 kHz)
%    NORDER - Order of filter (default 100)
%
% See also FIR1, FILTFILT, PA_HIGHPASS, PA_GETPOWER

% (c) 2011 Marc van Wanrooij

%% Initialization
if nargin<2
    Fc      = 1500; % Cut-off frequency (Hz)
end
if nargin<3
    Fn      = 25000; % Nyquist frequency (Hz)
end
if nargin<4
    Norder  = 100;  % Filter order
end

%% Filter
f           = Fc/Fn;
b           = fir1(Norder,f);
Signal      = filtfilt (b, 1, Signal);