function adjustment=find_adjustment(a,b,samples,speedup)

%     find adjustent on higher-frequeny information in the emg
%     so first filter it with high-pass filter.
%     bf=[0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0001,0.0001,0.0001,0.0001,0.0001,0,0,-0,-0.0001,-0.0001,-0.0002,-0.0002,-0.0003,-0.0003,-0.0004,-0.0005,-0.0006,-0.0007,-0.0008,-0.0009,-0.001,-0.0011,-0.0012,-0.0013,-0.0015,-0.0016,-0.0018,-0.0019,-0.0021,-0.0023,-0.0025,-0.0027,-0.0029,-0.0031,-0.0033,-0.0035,-0.0037,-0.0039,-0.0042,-0.0044,-0.0047,-0.0049,-0.0052,-0.0054,-0.0057,-0.0059,-0.0062,-0.0065,-0.0067,-0.007,-0.0073,-0.0076,-0.0078,-0.0081,-0.0084,-0.0086,-0.0089,-0.0091,-0.0094,-0.0097,-0.0099,-0.0101,-0.0104,-0.0106,-0.0108,-0.011,-0.0112,-0.0114,-0.0116,-0.0118,-0.0119,-0.0121,-0.0122,-0.0124,-0.0125,-0.0126,-0.0127,-0.0128,-0.0129,-0.0129,-0.013,-0.013,-0.013,0.9868,-0.013,-0.013,-0.013,-0.0129,-0.0129,-0.0128,-0.0127,-0.0126,-0.0125,-0.0124,-0.0122,-0.0121,-0.0119,-0.0118,-0.0116,-0.0114,-0.0112,-0.011,-0.0108,-0.0106,-0.0104,-0.0101,-0.0099,-0.0097,-0.0094,-0.0091,-0.0089,-0.0086,-0.0084,-0.0081,-0.0078,-0.0076,-0.0073,-0.007,-0.0067,-0.0065,-0.0062,-0.0059,-0.0057,-0.0054,-0.0052,-0.0049,-0.0047,-0.0044,-0.0042,-0.0039,-0.0037,-0.0035,-0.0033,-0.0031,-0.0029,-0.0027,-0.0025,-0.0023,-0.0021,-0.0019,-0.0018,-0.0016,-0.0015,-0.0013,-0.0012,-0.0011,-0.001,-0.0009,-0.0008,-0.0007,-0.0006,-0.0005,-0.0004,-0.0003,-0.0003,-0.0002,-0.0002,-0.0001,-0.0001,-0,0,0,0.0001,0.0001,0.0001,0.0001,0.0001,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002,0.0002];
% 
%     high-pass filter, 500 Hz (if you should believe...).
%     a2=filtfilt(bf,1,a);
%     b2=filtfilt(bf,1,b);
%     
%     envelope.
%     a3=abs(hilbert(a2));
%     b3=abs(hilbert(b2));
%     
%     a4=filtfilt(bf,1,a3);
%     b4=filtfilt(bf,1,b3);
%     
%     a high-pass frequency filter... to remove some of the low-frequency
%     stuff.
%     
%     a=a3;
%     b=b3;
% trimming beforehand... doesn't really work. the objective was to make a
% 'default' artifact waveform from different waveform by means of filtering
% and rectification. summary: it works 'a little bit', but worse than
% leaving the waveforms as they are.


    apiece=a((1+samples):(end-samples));
    % bpiece=b((1+samples):(end-samples));
    
    
    % keyboard;
    % construct the matrix
    mat=zeros(numel(apiece),samples*2+1);
    for i=1:samples
        
        % delayed = towards the back (high i in matrix)
        % hastened = towards the front (low i)
        mat(:,end+1-i)=b(i:(end-samples-samples-1+i));
        mat(:,i)=b((samples+samples+2-i):(end-i+1));
        
    end
    mat(:,samples+1)=b((1+samples):(end-samples));
    

    % programming for 'speed'. you don't need to calculate * every *
    % rho-value. Sufficient is also to calculate aboout 1/8th, and then
    % interpolate that.
    % use niazy's helpful prcorr2 .dll function.
    
    %     keyboard
    
    do_points=1:speedup:(2*samples)+1;
    % keyboard;

    % try 1.
    rho=zeros(1,numel(do_points));
    for i=1:numel(do_points)
        rho(i)=prcorr2(apiece,mat(:,do_points(i)));
    end
    
    % rhoi=zeros(1,numel(do_points)*speedup);
    % keyboard;
    rhoi=interp(rho,speedup);
    rhoi((end-speedup+2):end)=[];
    % keyboard;
    
    %     % try 2.
    %         
    %     rho2=zeros(1,numel(2*samples+1));
    %     for i=1:(2*samples+1) 
    %         rho2(i)=prcorr2(apiece,mat(:,i));
    %     end
    %     
    

    
    % rho=corr(apiece,mat);
    
    [dummy index]=max(rhoi);
    % keyboard;

    
    adjustment=samples+1-index;
    % keyboard;


    
%     figure;
%     plot(mat);
%     hold on;
%     plot(apiece,'color',[0.5 0.5 0.5],'linewidth',10);
%     plot(b((1+samples):(end-samples)),'color',[0 0 0],'linewidth',5);
%     title(['adjustment: ' num2str(adjustment)]);
