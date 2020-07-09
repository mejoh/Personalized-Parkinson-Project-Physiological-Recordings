function cost=cost_slicetiming3(param,v,c,paramstart)



    nvol        = c.nvol;
    nslices     = c.nslices;
    fs          = c.fs;
    m_begin     = c.m_begin;
    m_end       = c.m_end;
    beginshift  = c.beginshift;
    


    % keyboard;
    dtime=param(1)*paramstart(1);
    etime=param(2)*paramstart(2);
    
    
    
    % first... form dtime and etime, we are going to calculate sdur!    
    
    % from dtime and baggage, calculate... sdur!
    
    ttime=double(m_end-m_begin)/fs;
    rtime=ttime-etime;
    
    sdur=(rtime-nvol*dtime)/nvol/nslices;
   
    
    % re-calculate slice begin-markers.
    sb=zeros(nvol*nslices,1);
    se=zeros(nvol*nslices,1);
    rounderr=zeros(nvol*nslices,1);

    
    % make up our own slice-markers, all wrt m_begin.
    for i=1:nvol*nslices
        tmp_time    = (i-1)*sdur*fs+floor((i-1)/nslices)*dtime*fs;
        sb(i)       = m_begin   + round(tmp_time) - round(beginshift*sdur*fs);
        se(i)       = sb(i)     + ceil(sdur*fs);
        rounderr(i) = m_begin   + tmp_time - round(beginshift*sdur*fs) - sb(i);
    end
    
    

    % disp('applying phase-shift to all templates');
    
    % extra samples = extended slice duration = multiply sdur with a
    % factor.
    % dur = time of one slice-segment with extra boudary pieces. 
    % maybe do just ONE volume?
    
    extra=20;
    dur=(numel(sb(1):se(1))+extra)/fs;

    for j=1:numel(sb)


        curdata=v((sb(j)-extra/2):(se(j)+extra/2));         % data piece to modify.

        
        dt=rounderr(j)/fs;              % round-off err.

        curdata2=helper_phaseshifter2(curdata,dur,dt);  % do ph-shift.

        if ~isreal(curdata2)            % a double-check.
            keyboard;   
        end

        % if j==2;keyboard;end
        v(sb(j):se(j))=curdata2((1+extra/2):(end-extra/2))';       % replace shifted data.

    end
    
    % keyboard;
    
    
	% now return some kind of a cost function, but first matrixify the
	% stuff.
    % keyboard;
    mat=zeros(round(sdur*fs),nvol*nslices);
    for i=1:(nvol*nslices)

        if (sb(end)+round(sdur*fs)-1)>numel(v)
            
            mat(:,i)=rand(size(mat,1),1)*max(abs(v)); 
            % keyboard;

        else
            mat(:,i)=v(sb(i):(sb(i)+round(sdur*fs)-1));
        end
           
            
    end
    
    
    % keyboard;
    % do cost-function, per volume.
    % keep the volume-artifact out of it. we're removing it later,
    % anyway.
    cost=0;
    for i=4:2:nvol-3
        selection=[((i-4)*nslices+1):((i-3)*nslices) ((i+2)*nslices+1):((i+3)*nslices)];
        % selection=[selection selection+1*nslices selection+2*nslices selection+3*nslices selection+4*nslices];

        % minimize a) overlap between segments, by checking the slope
        % if not a lot of common high-slope points are found, control for
        % that too.

        % weigh stuff that descends/ascends fastly, more vigorously.
        tmp_std=std(mat(:,selection),0,2);
        tmp_mean=mean(mat(:,selection),2);
        
        weight=[abs(tmp_mean(2:end)-tmp_mean(1:end-1));0];
        
        weight=weight/mean(weight);
        
        cost=cost+mean(tmp_std.*weight);
        
        
    end
    
    cost = cost / nvol;
    

            
    
    % figure;plot(mat(:,[1:45]));
    % title(num2str(cost));
    
    % keep track of changes:
    % disp(sprintf('cost = %f',cost));
    
    % disp(sprintf('%.11f\t%.11f\t%.11f',o.sdur,o.dtime,cost));
    
    if ~exist('costs3.txt','file')
        fid=fopen('costs3.txt','w+');
    else
        fid=fopen('costs3.txt','a+');
    end
    % keyboard;
    
    fprintf(fid,'%.11f\t%.11f\t%.11f\t%.11f\t%.11f\n',ttime,dtime,etime,sdur,cost);
    
    fclose(fid);
        
    disp(sprintf('ttime\tdtime\tetime\tsdur\tcost\n'));
    disp(sprintf('%.11f\t%.11f\t%.11f\t%.11f\t%.11f\n',ttime,dtime,etime,sdur,cost));
    
%     i=1;
%     selection=((i-1)*nslices+2):(i*nslices-1);
%     selection=[selection selection+1*nslices selection+2*nslices selection+3*nslices selection+4*nslices];
%     out=mat(:,selection);

    


%     oldfh=findobj('type','figure');
%     if oldfh>0
%         oldfh=oldfh(end);
%     end
%     
%     figure;plot(out);
%     close(oldfh);
    
    
    

    
    
    
    
    
    % keyboard;
    



    
    
    

    
    
    % keyboard;
    % reken alle kruistermen uit.
%     cost=0;
%     % speedup=nslices;
%     % m=[];
%     for i=1:size(mat,2)-20
% 
%         curr=mat(:,i);
%         templ=mean(mat(:,i+1:i+20),2);
% 
%         cost=sum(abs(curr-templ));
% 
% 
%     end
        
        
    % keyboard;

    % keyboard;

    
    

    
    
%     angles=zeros(1,nvol*nslices-1);
%     for i=1:nvol*nslices-1
%         vp=mat(:,i);
%         vn=mat(:,i+1);
%         
%         angles(i)=1-vp'*vn/sqrt(vp'*vp)/sqrt(vn'*vn);
%         
%     end
    
    % cost=sum(angles)
    
    % keyboard;
    
    
    
    % keyboard;
    

    
    