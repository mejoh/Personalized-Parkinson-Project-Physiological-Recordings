function L=my_rayl_diff_function(p,expdata,ps)

    % re-scale, for fminsearch works best with values 0-1.
    p=p.*ps;

    % this function uses TWO parameters.
    % the first one, the 'mode' of the rayleigh distribution.
    % the second one, how much the raylpdf needs to be re-scaled to fit the
    % count experimental data the best way.
    b=p(1);         % starting value; 2.
    scale=p(2);     % starting value; 1.


    % define model and experimental data.
    moddata=scale*raylpdf(1:numel(expdata),b);
    
        
    % now define a way to tell how good the fit is, using least-squares.
    % i don't find the tail or the beginning interesting, only the peak.
    % so find in our DATA (not the model), the counts which are 50% >
    % max(counts). % rather arbitrary.
    % fit on the 25 % highest value-ed points of your model-ed data.
    % may not be that robust.
    % points=find(expdata>max(expdata)*0.75);
    % keyboard;
    % points2=(min(points)-1):(max(points)+1);
    % another way... 
    point=round(median(find(expdata>0.80*max(expdata))));
    points2=round(point*[0.4 1.3]);
    
    figure;plot(moddata);hold on;plot(expdata,'r');
    
    L=sum((expdata(points2)-moddata(points2)).^2);
    
    % keyboard;
    % disp(L);