function [catcell] = pf_horzcatcell(cell1,str)
% pf_horzcatcell(cell1,cell2) horizontally concatenates the strings that
% are stored in cell1 with str in a horizontal manner. Cell1 must be a
% vector.

% © Michiel Dirkx, 2015 
% $ParkFunC, version 20150928

%--------------------------------------------------------------------------

%% Here we go
%--------------------------------------------------------------------------

nCell   =   length(cell1);
catcel  =   cell(nCell,1);

for a = 1:nCell
   catcell{a} = horzcat(cell1{a},str); 
end
