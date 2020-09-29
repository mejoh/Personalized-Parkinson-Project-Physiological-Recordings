function idx = pf_closestto(vector,number)
% pf_closessto(vector,number) returns the index of the value in vector that 
% is closest to number

% ©Michiel Dirkx, 2015
% $ParkFunC, version 20150925

%--------------------------------------------------------------------------

%% Calculate
%--------------------------------------------------------------------------

minus = vector-number;
[~,idx] = min(abs(minus));

%==========================================================================

