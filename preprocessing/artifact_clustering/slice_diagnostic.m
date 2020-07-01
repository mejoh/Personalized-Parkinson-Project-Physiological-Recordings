% function fh=slice_diagnostic(EEG,i,interpfactor,sl)
%

function fh=slice_diagnostic(EEG,i,interpfactor,sl)


    v=EEG.data(1,:);
    [samples adjust]=marker_helper(i,sl,interpfactor);
    % keyboard;
    iv=interp(v(samples),interpfactor);

    
    corrd=[];
    fh=figure;
    hold on;
    curdata=iv((sl(i).b-adjust):(sl(i).e-adjust))';
    plot(curdata,'linewidth',10,'color',[0 0 0]);
    for j=1:numel(sl(i).others)
        tmp_b=sl(sl(i).others(j)).b + sl(i).adjusts(j)-adjust;
        tmp_e=sl(sl(i).others(j)).e + sl(i).adjusts(j)-adjust;
        otherdata=iv(tmp_b:tmp_e)';
        
        corrd(end+1)=corr(curdata,otherdata);
 
        colors=[j/numel(sl(1).others) 1-j/numel(sl(1).others) 0];
        plot(otherdata,'color',colors);
    end
       