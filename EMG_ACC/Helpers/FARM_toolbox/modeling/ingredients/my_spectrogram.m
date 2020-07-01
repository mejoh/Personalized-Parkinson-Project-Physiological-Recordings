% see to it that the data is ordered so as to have exactly integer data
% points for each volume.
% this will help with the spectrogram function.

function [fh Mnew]=my_spectrogram(v_in,event_data,fs,name)

% keyboard;
mV=[event_data(find(strcmp({event_data(:).type},'V'))).latency];
if numel(mV)==0
    mV=[event_data(find(strcmp({event_data(:).type},'65535'))).latency];
end
nscans=numel(mV);
fmax=300;


% rig segment length so that FFT spectrum has 1 data point / Hz.
lengthv=min(mV(2:end)-mV(1:end-1));

% fix the segment length to an exact multiple of fs.
fixfactor=floor(lengthv/fs);
lengthv=fixfactor*fs;

fres=fs/lengthv;



% make the data matrix from scratch.

m=[];
for i=1:nscans
    m(1:lengthv,i)=v_in(mV(i):(mV(i)-1+lengthv))';
end

M=abs(fft(m));

Mnew=[];
for i=1:fixfactor
    Mnew=1/fixfactor*M(i:fixfactor:size(M,1),:);
end

% apply hanning window
% keyboard;
% Mnew=hanning(size(Mnew,1))*ones(1,size(Mnew,2)).*Mnew;

fres=fres*fixfactor;
fpoints=round(fmax/fres);

% make a nice plot.
fh=figure;
imagesc(1:nscans,1:fpoints,double(10*log10((Mnew(1:fpoints,:)))),[0 45]);
axis xy; axis tight; colormap(jet); view(0,90);
xlabel('Time');
ylabel('Frequency (Hz)');



set(gca,'tickdir','out');
set(gca,'xtick',[15 25 45 55 75 85 105 115 135 145]);
set(gca,'xticklabel',{'DN','DA','TN','TA','MN','MA','T','TS','UD','LR'});
xlim([1 nscans]);
ylim([1 fpoints]);

colorbar

% keyboard;
title(name);

xlabel('Scan');
box off



