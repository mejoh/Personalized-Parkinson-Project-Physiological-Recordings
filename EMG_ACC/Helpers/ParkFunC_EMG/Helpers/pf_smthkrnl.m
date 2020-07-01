function s = pf_smthkrnl(s1,s2)
% pf_avgsmthkrnl calculates the resulting smoothing kernel when your data
% has been smoothed twice with smoothing kernel s1 and s2.

% © Michiel Dirkx, 2016
% $ParkFunC, version 20160902

%--------------------------------------------------------------------------

%% Calculate 
%--------------------------------------------------------------------------

s = sqrt((s1^2+s2^2));





