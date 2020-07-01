function fields = pf_fieldselect(strct)
%
% pf_fieldselect interactively returns the fields present in strct.

% ©Michiel Dirkx, 2014
% $ParkFunC

%% Explore struct

fn      =   fieldnames(strct);

%% Choose fields

disp(['Structure ' var2str(strct) ' contains followining fields:'])
for a = 1:length(fn)
    disp([num2str(a) '. ' fn{a}])
end
in        = input('Which fields do you want to include?');
fields    = fn(in);    
    

