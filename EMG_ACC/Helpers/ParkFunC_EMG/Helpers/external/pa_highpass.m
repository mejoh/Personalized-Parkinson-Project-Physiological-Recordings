function Signal = pa_highpass(Signal, Fc, Fs, Norder)
%  PA_HIGHPASS(SIGNAL, FC, FN, NORDER)
%
%    Highpass filtering of time sequence.
% 
%    SIGNAL - Time sequence
%    FC     - Cutoff frequency (default 3 kHz)
%    Fs     - Sampling frequency (default 1000 Hz)
%    NORDER - Order of filter (default 100)
%
% See also FIR1, FILTFILT, PA_LOWPASS, PA_BANDPASS, PA_GETPOWER

% (c) 2011 Marc van Wanrooij
% Minor adjustments (Fs instead of Fn) by Michiel Dirkx, 2015

%% Initialization
if nargin<2
    Fc      = 3000; % Cut-off frequency (Hz)
end
if nargin<3
    Fs      = 1000; % Nyquist frequency (Hz)
end
if nargin<4
    Norder  = 100;  % Filter order
end

%% Filter
Fn          = Fs/2;
f           = Fc/Fn;
b           = fir1(Norder,f,'high');
Signal      = filtfilt (b, 1, Signal);