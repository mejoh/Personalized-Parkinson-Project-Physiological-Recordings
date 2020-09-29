function [f,mx,ph,h]=pa_getpower(x,Fs,varargin)
% [F,A,PH] = PA_GETPOWER(X,FS)
%
% Get power A and phase PH spectrum of signal X, sampled at FS Hz.
%
% PA_GETPOWER(...,'PARAM1',val1,'PARAM2',val2) specifies optional
% name/value pairs. Parameters are:
%	'display'	- display graph. Choices are:
%					0	- no graph (default)
%					>0	- graph
%	'color'	- specify colour of graph. Colour choices are the same as for
%	PLOT (default: k - black).


% 2011  Modified from Mathworks Support:
% http://www.mathworks.com/support/tech-notes/1700/1702.html
% by: Marc van Wanrooij

%% Initialization
if nargin<2
	Fs = 50000;
end
% Optional display arguments
disp         = pa_keyval('display',varargin);
if isempty(disp)
	disp	= 0;
end
orient         = pa_keyval('orientation',varargin);
if isempty(orient)
	orient	= 'x'; % Freq = x-axis
else
	disp = 1;
end
col         = pa_keyval('color',varargin);
if isempty(col)
	col = 'k';
end

%%
% Time vector of 1 second
% Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
nfft = pa_keyval('nfft',varargin);
if isempty(nfft)
	nfft			= 2^(nextpow2(length(x)));
end
% Take fft, padding with zeros so that length(fftx) is equal to nfft
fftx			= fft(x,nfft);
% Calculate the numberof unique points
NumUniquePts	= ceil((nfft+1)/2);
% FFT is symmetric, throw away second half
fftx			= fftx(1:NumUniquePts);
% Take the magnitude of fft of x and scale the fft so that it is not a function of
% the length of x
mx				= abs(fftx)/length(x);
ph				= angle(fftx);

% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% The DC component and Nyquist component, if it exists, are unique and should not
% be mulitplied by 2.
if rem(nfft, 2) % odd nfft excludes Nyquist point
	mx(2:end)	= mx(2:end)*2;
else
	mx(2:end -1) = mx(2:end -1)*2;
end
% This is an evenly spaced frequency vector with NumUniquePts points.
f		= (0:NumUniquePts-1)*Fs/nfft;

% Take the square of the magnitude of fft of x -> magnitude 2 power
% mx				= mx.^2;
mx		= 20*log10(mx);
sel		= isinf(mx);
mx(sel) = min(mx(~sel));

%% Display option
if disp
	if strcmpi(orient,'x')
		h = semilogx(f,mx);
		set(h,'Color',[.7 .7 .7]);
		hold on
		
		h = semilogx(f,smooth(mx,100));
		set(h,'Color',col);
% 		ax = axis;
% 		xax = ax([1 2]);
% 		
% 		set(gca,'XTick',[0.05 1 2 3 4 6 8 10 14]*Fs);
% 		set(gca,'XTickLabel',[0.05 1 2 3 4 6 8 10 14]);
		title('Power Spectrum');
		xlabel('Frequency (Hz)');
		ylabel('Power (dB)');
	elseif strcmpi(orient,'y');
		h = semilogy(mx,f);
		set(h,'Color',col);
% 		set(gca,'YTick',[0.05 1 2 3 4 6 8 10 14]*Fs);
% 		set(gca,'YTickLabel',[0.05 1 2 3 4 6 8 10 14]);
		title('Power Spectrum');
		ylabel('Frequency (Hz)');
		xlabel('Power (dB)');
		% 	axis square;
	end
	
end