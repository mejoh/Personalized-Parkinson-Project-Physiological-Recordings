function s2 = pf_getsmthkrnl(s,s1)
% pf_getsmthkrnl calculates the right smoothing kernel s2 if you smoothed
% once with s1 and want the resulting smoothing kernel to be s.

% © Michiel Dirkx, 2016
% $ParkFunC, version 20160902

%--------------------------------------------------------------------------

%% Calculate 
%--------------------------------------------------------------------------

s2 = sqrt((s^2)-(s1^2));







