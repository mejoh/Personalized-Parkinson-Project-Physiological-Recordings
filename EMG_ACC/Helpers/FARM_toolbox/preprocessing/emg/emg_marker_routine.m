function m=emg_marker_routine(v,thr,thr2)

    % dts = (in samples, neighbourhood of prospective myoclonus, 
    % to look in, for the mean and std values.
    % thr3 = some usr-specified threshold to compare neighbourhood with
    % myoclonus.
    % firstly, we create the (temporal) derivative of v.
    
    % i can do the derivative this way, for the signal has already been
    % smoothed by the 40 Hz lowpass filter (previously);
    vt=v(2:end)-v(1:end-1);
    vt(end+1)=mean(vt);
    

    % walk the vector, make a 'b' if the signal > thr, and the vt is
    % positive.
    % keep on walking until the signal < thr2, and vt negative, and place a
    % marker there too.
    
    
    m.b=[];
    m.e=[];
    mode=1; % switches marker and walker modes.
    
    
    for i=1:numel(v)
        
        % mode=1; i need to place a b marker
        % mode=2; i need to place an e marker.
        
        if mode
            
            if v(i)>thr(i)&&vt(i)>0
                
                mode=0;
                m.b(end+1)=i;
                
            end
            
        end
        

        
        if ~mode
            
            if v(i)<thr2(i)&&vt(i)<0
                
                mode=1;
                m.e(end+1)=i;
            end
        end
        
    end
    
    % failsafe for not getting the last marker < thr2.
    if numel(m.b)>numel(m.e)
        m.b=m.b(1:numel(m.e));
    end
        
        
    
    % keyboard;
    % shift b markers to backwards...

    for i=1:numel(m.b)

        tv=v(m.b(i):-1:1);
        tthr2=thr2(m.b(i):-1:1);
        % find the 1st neg value?
        % keyboard;
        
        if numel(find(tv<tthr2))==0
            m.b(i)=m.b(i)-find(tv==min(tv))+1;
        else
            m.b(i)=m.b(i)-find(tv<tthr2,1)+1;
        end
    end

    
    
    
    
%     tx=1:floor(numel(sums)/2);
%     tsums=sort(sums);
%     tsums=tsums(tx);
%     fit=polyfit(tx,tsums,1);
%     tthresh=fit(2)+numel(sums)*fit(1);
%     marked=find(sums<tthresh);
%     if numel(marked)>0
%         m.b(marked)=[];
%         m.e(marked)=[];
%     end
%     
%     
%     % second stage... in the nearest neighbourhood... excluding marked
%     % areas, determine the mean and the std of the activity. use that, for
% 
%     % make a 010010 vector from the available b and e's.
%     mv=zeros(size(v));
%     for i=1:numel(m.b)
%         mv(m.b(i):m.e(i))=1;
%     end
% 
%     % keyboard;
%     
%     meanm=[];
%     stdm=[];
%     means=[];
%     stds=[];
%     for i=1:numel(m.b)
%         
%         % keyboard;
%         v_before=v((m.b(i)-1):-1:1);
%         v_after=v(m.e(i)+1:1:end);
%         i_before=mv((m.b(i)-1):-1:1);
%         i_after=mv(m.e(i)+1:1:end);
%         
%         % use the magic to determine which points to take.
%         i2_before=find(cumsum(~i_before).*~i_before);
%         i2_after=find(cumsum(~i_after).*~i_after);
%         
%         if dts<numel(i2_before)
%             i2_before=i2_before(1:dts);
%         else
%             i2_before=i2_before(1:numel(i2_before));
%         end
%         
%         if dts<numel(i2_after)
%             i2_after=i2_after(1:dts);
%         else
%             i2_after=i2_after(1:numel(i2_after));
%         end
%         
%         tvec=[v_before(i2_before) v_after(i2_after)];
%         
%         meanm(end+1)=mean(v(m.b(i):m.e(i)));
%         stdm(end+1)=std(v(m.b(i):m.e(i)));
%         
%         means(end+1)=mean(tvec);
%         stds(end+1)=std(tvec);
%         
%     end
%     
%     % keyboard;
%     
%     marked=find(meanm<means+thr3*stds);
%     if numel(marked)>0
%         m.b(marked)=[];
%         m.e(marked)=[];
%     end
    

            
            
            
    
            
    
    
    