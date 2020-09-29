function [present,idx] = pf_strcmp(A,B)
% pf_strcmp(A,B) compares if strings stored in B are also present in the
% array of A. It will then return an MxN (same as A) array:
%           - present: logical array indicating if string in A is also
%           present in B
%           - idx: If present, the index of the corresponding string in A,
%           otherwise NaN.
% See also pf_numcmp(A,B)

% ©Michiel Dirkx, 2015
% $ParkFunC, version 20150506

%--------------------------------------------------------------------------

%% Initialize 
%--------------------------------------------------------------------------

sA  =   size(A);
nA  =   length(A);
if sA(1)==1
    present =   zeros(1,nA);
else
    present =   zeros(nA,1);
end

cnt  = 1; % For idx

%--------------------------------------------------------------------------

%% Check everything
%--------------------------------------------------------------------------

for a = 1:nA
   
   sel =    strcmp(B,A(a));
   if any(find(sel, 1))
       present(a)   =   1;  % 1 to indicate that it was found.
       idx(cnt)     =   find(strcmp(B,A(a)),1);
       cnt          =   cnt+1;
   end
   
end

present = logical(present); % transform into logical present


