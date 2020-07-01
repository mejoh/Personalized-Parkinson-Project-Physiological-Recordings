function cost=cost_slicetiming2(param,v,c,paramstart)


    nvol      = c.nvol;
    nslices   = c.nslices;
    fs        = c.fs;
    m_begin   = c.m_begin;
    m_end     = c.m_end;
    


    dtime=param(1)*paramstart(1);
    etime=param(2)*paramstart(2);
    
    
    % first... form dtime and etime, we are going to calculate sdur!
    
    % from dtime and baggage, calculate... sdur!
    ttime=(m_end-m_begin)/fs;
    rtime=ttime-etime;
    sdur=(rtime-nvol*dtime)/nvol/nslices;
   
    
    % re-calculate slice begin-markers.
    sb=zeros(nvol*nslices,1);
    se=zeros(nvol*nslices,1);

    
    % make up our own slice-markers, all wrt m_begin.
    for i=1:nvol*nslices
        tmp_time    = (i-1)*sdur*fs+floor((i-1)/nslices)*dtime*fs;
        sb(i)       = m_begin   + round(tmp_time);
        se(i)       = sb(i)     + round(sdur*fs)-1;
    end
    
    
    
    % now, 'phase-shift' all of the segments according to the round-off
    % error.
    

    
%     rounderr=zeros(nvol*nslices,1);
%     for i=1:nvol*nslices
%        
%         tmp_time    = (i-1)*sdur*fs+floor((i-1)/nslices)*dtime*fs;
%         rounderr(i) = sb(i) - m_begin - tmp_time;
%         
%     end
% 
%     disp('applying phase-shift to all templates');
%     extra=20;
%     
%     % extra samples = extended slice duration = multiply sdur with a
%     % factor.
%     % dur = time of one slice-segment with extra boudary pieces. 
%     % maybe do just ONE volume?
%     dur=sdur*(extra*2+numel(sb(1):se(1)))/numel(sb(1):se(1));
% 
%     for j=1:numel(sb)
% 
%         curdata=v((sb(j)-extra):(se(j)+extra));     % data piece to modify.
% 
%         dt=rounderr(j)/fs;      % round-off err.
% 
%         curdata2=helper_phaseshifter2(curdata,dur,dt);  % do ph-shift.
% 
%         if ~isreal(curdata2)    % a double-check.
%             keyboard;
%         end
% 
%         v(sb(j):se(j))=curdata2((extra+1):(end-extra))';  % replace shifted data.
%     end
    
    
    
    
    
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
    % do cost-function. sum of variance-sum per volume.
    % keep the volume-artifact out of it. we're removing it later,
    % anyway.
    cost=0;
    for i=1:nvol
        selection=((i-1)*nslices+2):(i*nslices-1);
        cost=cost+mean(std(mat(:,selection),0,2));
    end
            
    
    % keep track of changes:
    disp(sprintf('cost = %f',cost));
    
    % disp(sprintf('%.11f\t%.11f\t%.11f',o.sdur,o.dtime,cost));
    
    if ~exist('costs2.txt','file')
        fid=fopen('costs2.txt','w+');
    else
        fid=fopen('costs2.txt','a+');
    end
    
    fprintf(fid,'%.11f\t%.11f\t%.11f\n',dtime,etime,cost);
    
    
    fclose(fid);
    
    
    
    
    
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
    

    
    