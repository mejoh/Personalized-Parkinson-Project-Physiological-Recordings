% nclusters=mojena_stopping_rule(zin,k1,k2,n,lag,noffset,verbosity)
%
%
% k1 = customized; a threshold for offset
% k2 = customized; a threshold for the std
% n = window
% lag = extra time lag, smaller window (n-lag ... earlier alpha-values have less std in them)
% noffset = do not take 1st n points in the calculation.. leave at 0.
% verbosity = do you like a graph?



function nclusters=mojena_stopping_rule(zin,k1,k2,n,lag,noffset,verbosity,fh)

    
    current_alpha=zin(:,3);
    estimated_alpha=zeros(size(current_alpha));
    threshold_alpha=zeros(size(current_alpha));
    
    for i=(n+noffset):(numel(current_alpha)-1)
        
        

        slopedata=current_alpha(i-n+1:i);
        % to determine the slope use polyfit.
        slopedata=slopedata(1:end-lag);
        n2=numel(slopedata);
        
        % b_j
        % keyboard;
        slope=6/(n2*(n2^2-1)) * (2*sum((1:n2)'.*slopedata) - (n2+1)*sum(slopedata));

        % alpha_j_mean
        mean_slopedata=mean(slopedata);
        offset_slopedata=mean_slopedata-(n2+1)/2*slope;
        
        expdata=offset_slopedata+(1:n2)'*slope;
        std_slopedata=std(expdata-slopedata);
        
        trend_lag=((n2-1)/2+lag)*slope;
        estimated_alpha(i+1)=mean_slopedata+trend_lag+slope;
        threshold_alpha(i+1)=k1*estimated_alpha(i+1)+k2*std_slopedata;
        
    end
    
    % find the 'i', at where to exactly stop...
    stop_i=n+noffset+find(current_alpha((n+1+noffset):end)>threshold_alpha((n+1+noffset):end));
    

    nclusters=numel(estimated_alpha)-stop_i+1;

    % for if the calculation fails! at least 1 cluster.
    if numel(nclusters)==0
        nclusters=1;
    end

    
    if verbosity
        figure(fh);
        subplot(1,2,1);
        plot(current_alpha);
        hold on;
        plot(estimated_alpha,'r');
        plot(threshold_alpha,'g');
        hold off;
        subplot(1,2,2);
        dendrogram(zin);
        title([num2str(nclusters(1)) ' clusters.']);

    end
    
    
        
        
        
        