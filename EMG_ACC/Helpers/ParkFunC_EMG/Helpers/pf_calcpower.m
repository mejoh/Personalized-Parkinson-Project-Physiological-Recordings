function pf_calcpower(y,Fs)
%
%
%
%
%

%% Warming up

clc;clear all; close all

file = '/home/action/micdir/data/PMG/p02/OFF/CutFs/p02_R-PMG_SESS1_OFF_CurMont_Fs=128.edf';
[dat,hdr] = ReadEDF(file);

if nargin < 2
    Fs = 128;
end

%% Initiate stuff

startcoco = hdr.annotation.starttime(4)*Fs;
stopcoco  = (hdr.annotation.starttime(4)+hdr.annotation.duration(4))*Fs;

data = dat{1}(startcoco:stopcoco);

T  = 1/Fs;                     % Sample time
L  = length(data);           % Length of signal
t  = (0:L-1)*T;                % Time vector

%% Method 1

% Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
plot(t,data)
title('Raw data CoCo')
xlabel('time (milliseconds)')

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(data,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
subplot(2,1,1)
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

%% Method 2

N = length(data);
xdft = fft(data);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(data):Fs/2;

subplot(2,1,2)
plot(freq,10*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')

