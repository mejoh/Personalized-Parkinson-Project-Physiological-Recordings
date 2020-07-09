% Make a function that gives you a set of í's, with a given imax and a
% window. the objective is to make a selection of artifacts to use.
% used in slice-correction.
%
% rules: with i=100, and window 10, take slices 90-99 and 101-110.
% if i approaches 1 or imax, pick extra slices accordingly. (to fix the
% endings).

function out = pick_function(i,nslices,nvol,window)

    % exclude multiples of this 
    v=1:nslices*nvol;
    voltrigs=find(rem(v,nslices)==0);
    voltrigs=[0 voltrigs];
    voltrigs=[voltrigs voltrigs+1];
    voltrigs=sort(voltrigs);
    voltrigs([1 end])=[];
    
    exclude=sort(union(voltrigs,i));
    
    v(exclude)=[];
    
    t=sortrows([1:numel(v);abs(v-i)]',2);
    ind=sort(t(1:window,1));
    out=v(ind);
    
    