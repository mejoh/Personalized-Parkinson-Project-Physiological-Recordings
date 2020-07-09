function varargout=my_mode(varargin)

    v=varargin{1};
    
    % keyboard;
    
    if numel(varargin)>2
        verbosity=varargin{3};
    else
        verbosity=0;
    end
    
        
    % hilbert transform
    h=hilbert(v);
    
    
    % empirical bin-size.
    
    % keyboard;
    totbins=numel(v)/250/3*median(abs(h));
    % totbins=100;
    if totbins>500
        totbins=500;
    end
    
    

    
    % define edges with res of 0.01.
    steps=3*median(abs(h))/totbins;
    edges=0:steps:3*median(abs(h));
    
    % do histogram-count
    count=histc(abs(h),edges);
        
    % keyboard;

    ps(1) = find(count==max(count),1); % bin of the highest count.
    
    ps(2) = sum(count); % this'll rescale the wimpy pdf to the right order of magnitude.
    
    
    P=fminsearch(@(p) my_rayl_diff_function(p,count,ps),ps./ps);
    P=P.*ps;
    
    x0int=P(1);
    mode=(x0int-1)*steps;
    
    
    
	if verbosity==1
        
        fh=figure;
        
        if numel(varargout)>1
            set(fh,'visible','off');
            varargout{2}=fh;
        end
        
        plot(count,'color',[0.5 0.5 0.5],'linewidth',2);
        hold on;
        p=P(2)*raylpdf(1:numel(count),x0int);
        tmp=find(count==max(count));
        
        plot(p,'color',[0 0 0],'linewidth',1.5);
        line(x0int*[1 1],get(gca,'ylim'),'color','k');
        % line(median(abs(h))/steps*[1 1],get(gca,'ylim'),'color','k');
        legend({['experimental data, median = ' num2str(median(abs(h)))],['rayleigh fit, mode = ' num2str(mode)]});
        % set(gca,'xticklabel',{num2str(0*steps),num2str(100*steps),num2str(200*steps),num2str(300*steps),num2str(400*steps),num2str(500*steps),num2str(600*steps)});
        % plot(boundaries(1)-1+(1:numel(expdata)),expdata,'r','linewidth',2);
        
        moddata=P(2)*raylpdf(1:numel(count),P(1));
        point=round(median(find(count>0.85*max(count))));
        points2=round(point*[0.5 1.5]);
        line([1 1]*min(points2),get(gca,'ylim'),'color',[0 0 0],'linewidth',1);
        line([1 1]*max(points2),get(gca,'ylim'),'color',[0 0 0],'linewidth',1);

        
        set(gca,'xlim',[0 numel(count)]);
        title(['numel(v) = ' num2str(numel(v))]);
%         totbins
%         set(gca,'xtick',round([0:1:floor(steps*totbins)]/steps));
%         set(gca,'xticklabel',num2cell((round([0:1:floor(steps*totbins)]'))));
        
        
    end



        
        
    
    

    
    
    