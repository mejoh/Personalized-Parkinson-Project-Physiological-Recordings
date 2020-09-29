function cost=cost_slicetiming(param,v,fs,tb,nslices,nvol,dtime_old,sdur_old,paramstart)


    param=param.*paramstart;
    
    sdur=sdur_old+param(1);
    dtime=dtime_old+param(2);
    
    % re-calculate slice begin-markers.
    sb=zeros(nvol*nslices,1);
    se=zeros(nvol*nslices,1);

    rounderr=zeros(nvol*nslices,1);
    for i=1:nvol*nslices
       
        tmp_time=(i-1)*sdur*fs+floor((i-1)/nslices)*dtime*fs;
        sb(i)=round(tmp_time)+tb;
        se(i)=sb(i)+round(sdur*fs)-1;
        rounderr(i)=sb(i)-tb-tmp_time;
        
    end
    
    
    % keyboard;
    
    % aply the phase-shift (with round-off error);
    % apply the 'phase shift' to every template.
%     disp('applying phase-shift to all templates');
%     extra=20;
%     % extra samples = extended slice duration = multiply sdur with a
%     % factor.
%     dur=sdur*(extra*2+numel(sb(1):se(1)))/numel(sb(1):se(1));
% 
%     for j=1:numel(sb)
% 
% 
%         %(20 more samples!)
%         tb=sb(j);
%         te=se(j);
%         curdata=v((tb-extra):(te+extra));
%         
%         % keyboard;
% 
%         dt=rounderr(j)/fs;
%         % phase-shift according to the round-off error.
% 
% %         try
%         curdata2=helper_phaseshifter2(curdata,dur,dt);
% %         catch
% %             keyboard;
% %         end
%         
%         if ~isreal(curdata2)
%             keyboard;
%         end
%         v(tb:te)=curdata2((extra+1):(end-extra))';
%     end


    
    
    
    % make a matrix
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

    cost=sum(std(mat,0,2));
    disp(sprintf('cost = %f',cost));
    
    % disp(sprintf('%.11f\t%.11f\t%.11f',o.sdur,o.dtime,cost));
    
    if ~exist('costs.txt','file')
        fid=fopen('costs.txt','w+');
    else
        fid=fopen('costs.txt','a+');
    end
    
    fprintf(fid,'%.11f\t%.11f\t%.11f\n',sdur,dtime,cost);
    
    
    fclose(fid);
    
    
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
    

    
    