function [sl o]=do_new_slicetiming(d,sl,o,m,whichchannel)


    % first determine best-guess (starting) values for both sdur and dtime.
    fs              =double(o.fs);
    sv              =double(m.sv);
    nslices         =double(o.nslices);
    nvol            =double(o.nvol);
    interpfactor    =double(o.interpfactor);
    beginshift      =o.beginshift;
    window          =o.window;
    
    bFirstV = sv(1);
    
    
    if exist('costs.txt','file');
        delete('costs.txt');
    end
   
    
    sdur=[];
    for i=1:nvol
        sdur=[sdur m.ss((nslices*(i-1)+2):nslices*i)-m.ss((nslices*(i-1)+1):(nslices*i-1))];
    end
    % keyboard;
       
    svdur=[];
    for i=1:nvol-1
        svdur=[svdur m.ss(nslices*i+1)-m.ss(nslices*i)];
    end
    
    dtime=(mean(svdur)-mean(sdur))/fs;
    sdur=mean(sdur)/fs;
    
    % keyboard;
    
    % keyboard;

    % the following IS an attempt to even further polish the dtime and
    % sdur. turns out, that the amount by which sdur and dtime need to be
    % polished is about   1.0e-016 * [0.9779    0.9377], or rather: about
    % one tenth of one millionth of one nanosecond.
    
    % so.. the following is not really that necessary. If you determine the
    % slicetriggers like I do already, and calculate from that the dtime
    % and sduration, that will be enough!
    
    
    % than nanoseconds. This allows me to 
    v=d.original(:,whichchannel);
    
    % > 250 Hz = capture all of the higher frequency components... and do
    % not capture emg.
    v=helper_filter(v,250,fs,'high');
    
    % v=abs(hilbert(v));
    v=interp(v,interpfactor);
    % keyboard;
    
    
    
    % the starting point is a difference between my sdur and dtime, and the
    % real sdur and dtime. this difference is about equal to the time
    % itself /nslices/nvol/100 (to be safe.)
    % in this (hopefully safe) interval, I allow my fminsearch to play
    % around with vertices (2-D search space).
    ps=[sdur/nslices/nvol dtime/nvol];
    
    sdur_begin=sdur-ps(1);
    dtime_begin=dtime-ps(2);
    % tb=bFirstV*interpfactor;
    
    
    [P fval]=fminsearch(@(p) cost_slicetiming(p,v,fs*interpfactor,bFirstV*interpfactor,nslices,nvol,dtime_begin,sdur_begin,ps),ps./ps);
    % P=P.*ps;
    
    
    % keyboard;
    % sdur_diff=P(1)*ps(1);
    % dtime_diff=P(2)*ps(2);
    
    sdur_old=sdur;
    dtime_old=dtime;
    
    sdur=sdur_begin+P(1)*ps(1);
    dtime=dtime_begin+P(2)*ps(2);
    
    disp('improved sdur and dtime parameters.')
    disp(sprintf('sdur = old sdur (%0.9f [s]) %+0.6f [us] = %0.9f [s].',sdur_old,(sdur-sdur_old)*1000000,sdur));
    disp(sprintf('dtime = old dtime (%0.9f [s]) %+0.6f [us]= %0.9f [s].',dtime_old,(dtime-dtime_old)*1000000,dtime));
    
    o.sdur = sdur;
    o.dtime = dtime;
    

    costs=[];
    load costs.txt
    fh=figure;

    subplot(1,2,1);
    plot(costs(:,1)*1000,costs(:,3),'k-*');
    ylabel('cost');
    xlabel('sdur (ms)');
    % t=get(gca,'ylim');ylim([0 t(2)]);
    title(sprintf('%.3f ms --> %.3f ms',costs(1,1)*1000,costs(end,1)*1000));
    

    subplot(1,2,2);
    plot(costs(:,2)*1000,costs(:,3),'k-*');
    ylabel('cost');
    xlabel('dtime (ms)');
    % t=get(gca,'ylim');ylim([0 t(2)]);
    title(sprintf('%.3f ms --> %.3f ms',costs(1,2)*1000,costs(end,2)*1000));
    
    saveas(fh,'optimalization of sdur and dtime','fig');
    saveas(fh,'optimalization of sdur and dtime','jpg');
    

    fname='../../../../../sdur_dtime_times.txt';
    if exist(fname,'file')
        fid=fopen(fname,'a+');
    else
        fid=fopen(fname,'w+');
    end
    strdir=pwd;
    
    fprintf(fid,'%.10f\t%.10f\t%s',o.sdur,o.dtime,strdir);
    fclose(fid);
    
    
    % and now... determine exactly, where our markers lie, in interpolated
    % space.
    tb=bFirstV*interpfactor;
    
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
    
