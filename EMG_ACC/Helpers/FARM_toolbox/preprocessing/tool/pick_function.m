% Make a function that gives you a set of í's, with a given imax and a
% window. the objective is to make a selection of artifacts to use.
% used in slice-correction.
%
% rules: with i=100, and window 10, take slices 90-99 and 101-110.
% if i approaches 1 or imax, pick extra slices accordingly. (to fix the
% endings).

function out = pick_function(i,imax,window)

    out=[(i-ceil(window/2)):(i-1) (i+1):(i+floor(window/2))];

    % keyboard;
    % fix beginning.
    count=numel(find(out<1));
    out=[out((count+1):end) out(end)+(1:count)];
    
    % fix ending.
    count=numel(find(out>imax));
    out=[-1*(count:-1:1)+min(out) out(1:(numel(out)-count))];
    
    out(out>imax)=[];
    out(out<1)=[];
    
    