% a tryout for full volume correction.

function do_volumecorrection(d,m,o)


    nch                 =o.nch;
    interpfactor        =o.interpfactor;

    sV                  =m.sv;
    
    for i=1:nch
        
        % get interpolated data.
        vi=interp(d.original(:,i),interpfactor);
        
        vdur=ceil(mean(sV(2:end)-sV(1:end-1)));
        
        
        % re-calculate V markers.
        for j=1:numel(sV)
            vol(j).b=sV(j)*interpfactor;
            vol(j).e=(sV(j)+vdur-1)*interpfactor;
        end
        
        
        % make a 'v' matrix
        
        vmat=zeros((vdur-1)*interpfactor+1,numel(vol));
        for j=1:numel(vol)
            vmat(:,j)=vi(vol(j).b:vol(j).e)';
        end
        
        