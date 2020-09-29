function S = pf_concatfields(S1,S2)
% pf_concatfields(S1,S2) concatenates the fields of S1 and S2 into one
% structure S.

% ©Michiel Dirkx, 2015
% $ParkFunC, 20150501

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

S   = S1;
if ~isempty(S2)
    Fn  = fieldnames(S2);
    nFn = length(Fn);
else
    nFn = 0;
end

%--------------------------------------------------------------------------

%% Concatenate
%--------------------------------------------------------------------------

for a = 1:nFn
   
    CurFn       =   Fn{a};
    S.(CurFn)   =   S2.(CurFn);
    
end



