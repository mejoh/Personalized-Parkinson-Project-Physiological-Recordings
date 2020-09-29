function [sl o]=do_new_slicetiming2(d,sl,o,m,whichchannel)

    fs              =double(o.fs);
    sv              =double(m.sv);
    nslices         =double(o.nslices);
    nvol            =double(o.nvol);
    interpfactor    =double(o.interpfactor);
    beginshift      =double(o.beginshift);

    
    % calculate all durs wrt this one.
    m_begin = sv(1);
    
    % make a reasonable guess at where the trace should end.
    % use the _final_ 
    m_end   = m.ss(end)+(m.ss(3)-m.ss(1)); % one sdur after finished recording.

    
    if exist('costs2.txt','file');
        delete('costs2.txt');
    end
    
    % optimize two parameters. 
    % the first parameters is... dtime (again!)
    % the secon parameters is... baggage (extra unneeded time, wrt m_end)
    % baggage can also be negative (which means taking extra time)
    % our initial estimate for... dtime!
    sdur=[];
    for i=1:nvol
        sdur=[sdur m.ss((nslices*(i-1)+2):nslices*i)-m.ss((nslices*(i-1)+1):(nslices*i-1))];
    end

       
    svdur=[];
    for i=1:nvol-1
        svdur=[svdur m.ss(nslices*i+1)-m.ss(nslices*i)];
    end
    
    % dtime=(mean(svdur)-mean(sdur))/fs;
    etime=mean(sdur)/fs;
    
    % improve my estimate for dtime, plz?
    sdur=mean(sdur)/fs;
    dtime=(double(m_end-m_begin)/fs-nvol*nslices*sdur)/nvol;
    
    
    % now, take care of v.
    v=d.original(:,whichchannel);
    v=helper_filter(v,250,fs,'high');
    v=interp(v,interpfactor);
    
    
    ps=[dtime etime];
    
    const.nvol      = nvol;
    const.nslices   = nslices;
    const.fs        = fs*interpfactor;
    const.m_begin   = double(m_begin*interpfactor);
    const.m_end     = double(m_end*interpfactor);
    
    
    [P fval]=fminsearch(@(p) cost_slicetiming2(p,v,const,ps),ps./ps);
    
    

    
    
    etime=P(2)*ps(2);
    dtime=P(1)*ps(1);
    
    % keyboard;
    
    
    % from dtime and baggage, calculate... sdur!
    ttime=double(m_end-m_begin)/fs;
    rtime=ttime-etime;
    sdur=(rtime-nvol*dtime)/nvol/nslices;
    
    
    o.sdur=sdur;
    o.dtime=dtime;
    
    
    
    % make a nice figure.
    costs2=[];
    load costs2.txt
    fh=figure;

    subplot(1,2,1);
    plot(costs2(:,1)*1000,costs2(:,3),'k-*');
    ylabel('cost');
    xlabel('dtime (ms)');
    % t=get(gca,'ylim');ylim([0 t(2)]);
    title(sprintf('%.3f ms --> %.3f ms',costs2(1,1)*1000,costs2(end,1)*1000));
    

    subplot(1,2,2);
    plot(costs2(:,2)*1000,costs2(:,3),'k-*');
    ylabel('cost');
    xlabel('sdur (ms)');
    % t=get(gca,'ylim');ylim([0 t(2)]);
    title(sprintf('%.3f ms --> %.3f ms',costs2(1,2)*1000,costs2(end,2)*1000));
    
    saveas(fh,'optimalization of sdur and dtime','fig');
    saveas(fh,'optimalization of sdur and dtime','jpg');
    

    
    
    
    
    % and insert markers!
    % and now... determine exactly, where our markers lie, in interpolated
    % space.
    tb=m_begin*interpfactor;
    
    % to determine the markers in interpolated space.
    for i=1:nvol*nslices
        sl(i).b=round((i-1)*sdur*fs*interpfactor+floor((i-1)/nslices)*dtime*fs*interpfactor)+tb;
        sl(i).e=sl(i).b+round(sdur*fs*interpfactor)-1;
    end
    
    % and now, adjust the beginning and ends of the slice-markers.
    for i=1:nvol*nslices
        sl(i).b=sl(i).b-round(beginshift*sdur*fs*interpfactor);
        sl(i).e=sl(i).e-round(beginshift*sdur*fs*interpfactor);
        
        % make a tiny crossover;
        % sl(i).b=sl(i).b-round((sl(i).b:sl(i).e)*0.01);
    end
    
    for i=1:nvol*nslices
        
        sl(i).b_calculated=(i-1)*sdur*fs*interpfactor+floor((i-1)/nslices)*dtime*fs*interpfactor+tb-round(beginshift*sdur*fs*interpfactor);
        sl(i).b_rounderr=sl(i).b_calculated-double(sl(i).b);
        
        % keyboard;
    end
    
    
    
    
    
    
    
    
    