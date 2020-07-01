function idx = pf_numcmp(A,B)
% pf_numcmp compares of numeric values stored in b are also present in the
% array of a and returns the logical index of the numbers in b in array a.
%
% Example:
% a = [1 2 3 4 5];
% b = [3 5];
% Q = pf_numcmp(a,b)
% Q = [0 0 1 0 1];

% ©Michiel Dirkx, 2015
% $ParkFunC, version 20150506

%--------------------------------------------------------------------------

%% Initialize 
%--------------------------------------------------------------------------

sA  =   size(A);
nA  =   length(A);
if sA(1)
    idx =   zeros(1,sA(2));
else
    idx =   zeros(sA(2),1);
end

%--------------------------------------------------------------------------

%% Check everything
%--------------------------------------------------------------------------

for a = 1:nA
   
   sel =    A(a)==B;
   
   if ~isempty(find(sel, 1))
       idx(a)   =   1;
   end
   
end

idx = logical(idx);

