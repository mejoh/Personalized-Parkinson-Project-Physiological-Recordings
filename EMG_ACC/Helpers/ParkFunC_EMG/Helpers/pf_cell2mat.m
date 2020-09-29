function mat = pf_cell2mat(cl)
%
% variant to the original cell2mat. Difference is that it doesn't matter
% here if the vectors are incosistent, a nanXnan matrix will be built and
% filled, if vectors are smaller than the biggest one there will just be
% nans left

% Michiel Dirkx, 2014
% $ParkFunC

%% Initialize
%--------------------------------------------------------------------------

sz  =   cell2mat(cellfun(@size,cl,'uniformoutput',0));
ln  =   length(cl);
mat =   nan(sum(sz(:,1)),max(sz(:,2)));
cnt =   1;

%--------------------------------------------------------------------------

%% Fill matrix
%--------------------------------------------------------------------------

for a = 1:ln
    mat(cnt:cnt+size(cl{a},1)-1,1:size(cl{a},2))    =   cl{a};
    cnt = cnt+size(cl{a},1);
end

%--------------------------------------------------------------------------

