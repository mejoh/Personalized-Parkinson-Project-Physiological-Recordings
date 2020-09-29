load emg_fastr.mat

d_fastr=EEG.data';

load emg_corr.mat

d_corr=EEG.data';

load emg_corrph.mat

d_corrph=EEG.data';

for i=1:8
    fh=figure;
    
    mat=[abs(fft(d_fastr(:,i))) abs(fft(d_corr(:,i))) abs(fft(d_corrph(:,i)))];

    % mat=mat(1:round(300*(size(EEG.data,2)/EEG.srate)),:);
    
    for j=1:1000
    
        freqb=round((j-1)/(EEG.srate/size(EEG.data,2)))+1;
        freqe=round(j/(EEG.srate/size(EEG.data,2)));
        newmat(j,:)=mean(mat(freqb:freqe,:));
    
    end
        
    semilogy(newmat);
    
    legend({'FASTR','Correlations','Correlations + phase-shift'},'location','SouthWest');
    % xlim([1 numel(sl)]);
    % ylim([0 1]);
    
    title(sprintf('spectra [0-1] for 3 methods. channel %d',i));
    saveas(fh,sprintf('spectra_%d',i),'fig');
    
    
    
end