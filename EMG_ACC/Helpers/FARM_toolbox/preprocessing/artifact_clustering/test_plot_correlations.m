

load sl

for i=1:8
    
    fh=figure;
    ah=axes('parent',fh);
    
    corr=zeros(1,numel(sl));


    for j=1:numel(sl)
        corr_fastr(j)=sl(j).FASTR.templateCorrelation(i);
        corr_corr(j)=sl(j).CORR.templateCorrelation(i);
        corr_corrph(j)=sl(j).CORRPH.templateCorrelation(i);
    end
    
    mat=[corr_fastr;corr_corr;corr_corrph]';
    semilogy(mat);
    
    legend({'FASTR','Correlations','Correlations + phase-shift'},'location','best');
    xlim([1 numel(sl)]);
    ylim([0 1]);
    
    title(sprintf('correlation [0-1] between uncorrected data and template, channel %d',i));
    saveas(fh,sprintf('figure_%d',i),'fig');
    
end


       