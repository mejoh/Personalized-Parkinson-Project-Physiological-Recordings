% cluster_diagnostic(EEG,i,j,interpfactor,sl)
% a function to keep track of how the clustering went.
% i = the artifact.
% j = the channel
% sl = the slice-housekeeping 'struct'.
% interpfactor = 20.

function [fh fh2]=cluster_diagnostic(d,i,j,interpfactor,sl,o)


    mv=o.cl.mojenavalues;

    % keyboard;
    [samples adjust]=marker_helper(i,sl,interpfactor);
    iv=interp(d.original(samples,j),interpfactor);


    fh=figure;
    Z=sl(i).Tmat(:,:,j);
    mojena_stopping_rule(Z,mv(1),mv(2),mv(3),0,mv(4),fh,1);
    % keyboard;
    figure;dendrogram(Z);

    % clustermat_scaled=zeros(numel(sl(j).b:sl(j).e),numel(sl(j).others));
    clustermat_unscaled=zeros(numel(sl(i).b:sl(i).e),numel(sl(i).others));
    for k=1:numel(sl(j).others)
        


        tmp_b=sl(sl(i).others(k)).b-adjust;
        tmp_e=sl(sl(i).others(k)).e-adjust;
        % keyboard;
        otherdata=iv(tmp_b:tmp_e)';

        % alpha=curdata'*otherdata/(otherdata'*otherdata);

        % clustermat_scaled(:,k)=alpha*otherdata;
        clustermat_unscaled(:,k)=otherdata;

        
        % keep track of the 'scalings'.
        % we also keep track of the clusterdata.
        % as well as the principal components... for for that,
        % later.
        % sl(j).scalingdata(i,k)=alpha;

        
        % keyboard;
    end
    
    % keyboard;
    
    template=helper_slice(iv,adjust,i,j,sl,[]);



    fh=figure;
    hold on;
    colors={'b','r','g','m','y','c','k'};
    % keyboard;
    
    curdata=iv((sl(i).b-adjust):(sl(i).e-adjust))';
    
    T=sl(i).clusterdata(j,:);
    for i=1:max(T)
        vec=find(T==i);
        if numel(vec)>6
            for j=1:numel(vec)
                plot(mean(clustermat_unscaled(:,vec),2),'color',colors{mod(i,7)+1});
                hold on;
                plot(curdata,'k','linewidth',2);
                plot(template,'r','linewidth',2);
            % keyboard;
            end
        end
    end
    % keyboard;


    fh2=figure;
    pd=ceil(sqrt(double(max(T))));

    for i=1:max(T)
        vec=find(T==i);
        try
        subplot(pd,pd,double(i));
        catch
            keyboard;
        end
        hold on;
        for j=1:numel(vec)
            plot(clustermat_unscaled(:,vec));
            title(['cluster ' num2str(i) ', numel = ' num2str(numel(vec))]);
        end
    end
    
    
    
    
    % keyboard;
    