function age = pf_returnage(birthday)
% pf_returnage(birthday) returns the age in years for the date specified in
% birthday. Birthday may be cell. Only works when each date is specified by
% a string where D,M,Y are separated by '-'.

% Michiel Dirkx, 2015
% %ParkFunC, version 20151221

%% Calculate
%--------------------------------------------------------------------------

if ~iscell(birthday)
    birthday = {birthday};
end

nDate   =   length(birthday);
age     =   nan(nDate,1);
today   =   now;

for a = 1:nDate
    
   CurBD = birthday{a};  
   sep   = strfind(CurBD,'-');
   D     = str2double(CurBD(1:sep(1)-1));
   M     = str2double(CurBD(sep(1)+1:sep(2)-1));
   Y     = str2double(CurBD(sep(2)+1:end));
   
   thisage = datevec(today-datenum(Y,M,D));
   age(a)  = thisage(1);
    
end
