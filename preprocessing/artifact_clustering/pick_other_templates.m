% Make a function that gives you a set of í's, with a given imax and a
% window. the objective is to make a selection of artifacts to use.
% used in slice-correction.
%
% pick other slices according to the rules: you can't pick your own, and
% you can't pick volume-end or volume-begin slices, and you must pick
% exactly window, and the other slices should be in the vincinity.
% and also, there should at least 1 unchosen slice between each chosen
% slice.

function sl = pick_other_templates(sl,o)

    nslices     =o.nslices;
    nvol        =o.nvol;
    window      =o.window;

    % exclude multiples of this 
    v=1:nslices*nvol;
    voltrigs=find(rem(v,nslices)==0);
    voltrigs=[0 voltrigs];
    voltrigs=[voltrigs voltrigs+1];
    voltrigs=sort(voltrigs);
    voltrigs([1 end])=[];
    
    v(voltrigs)=[];
    % keyboard;
    
    

    skip=o.skip;
    windowfac=skip*2;
    
    for i=1:nvol*nslices
        

        % keyboard;
        
        % matrix of a) v, and b) 'distance' relative to i.
        % for determining which v has 'lowest' distance.
        tmp=find(abs((v-i))<window*windowfac);
        tmp(find(v(tmp)==i))=[];
        tmp=[tmp' abs(v(tmp)-i)'];
        tmp=sortrows(tmp,2);
        
        mat=[v(tmp(:,1))' tmp(:,2)];
        
        % v which you may keep.
        minv2=min(mat(:,1));
        maxv2=max(mat(:,1));
        v2=[i:-skip:minv2 i:skip:maxv2];
        
        % incorporate the vol triggers...
        % indices of v2 which fall into the 'volume' trigger.
        % needchange=sort([find(rem(v2/nslices,1)==0) find(rem((v2-1)/nslices,1)==0)]);        

        % nieuwe truuk van 'intersect'. t geeft je ook de indices terug!!
        [c imat iv2]=intersect(mat(:,1),v2);

        % this gives a) eligible 'v', and b) distance, sorted by distance!!
        mat=sortrows(mat(imat,:),2);

        % keyboard;
        
        sl(i).others=sort(mat(1:window,1));
        
    end