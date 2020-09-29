function idx = pf_find(A,B)
% pf_find(A,B) returns the indices of the strings stored in A corresponding
% with those in B. It will return a length(A) array containing the indices
% of the corresponding strings in B, if there are strings present in A but
% not in B it will leave it unchanged.
%
% See also pf_strcmp(A,B), pf_numcmp(A,B)

% © Michiel Dirkx, 2015
% $ParkFunC, version 20150625

%% Initialize

nIdx    =   length(B);
idx     =   1:1:length(A);

%% Get indices

for a = 1:nIdx
   CurStr   = B{a}; 
   idx(a)   = find(strcmp(A,CurStr));
end
