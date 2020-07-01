function age = pf_calcage(birthdate)
% pf_calcage(day,month,year) returns someones age given his birthdate as
% specified in birthdate.
% Example: pf_calcage('24-11-2015')

% Michiel Dirkx, 2016
% $ParkFunC, version 20160217

%--------------------------------------------------------------------------

%% Find string seperator
%--------------------------------------------------------------------------

nBirth  =   length(birthdate);
age     =   nan(nBirth,1);

for a = 1:nBirth
    
    CurDate     =   birthdate{a};
    
    if ~isempty(strfind(CurDate,'-')); sep = '-'; end
    if ~isempty(strfind(CurDate,'.')); sep = '.'; end
    if ~isempty(strfind(CurDate,'/')); sep = '/'; end
    
    iSep       =   strfind(CurDate,sep);
    day        =   CurDate(1:iSep(1)-1);
    month      =   CurDate(iSep(1)+1:iSep(2)-1);
    year       =   CurDate(iSep(2)+1:end);
    
    age(a)     =   (datenum(date)-datenum(str2num(year),str2num(month),str2num(day))-1)/365;
        
end











% age = (datenum(date)-datenum([num2str(day) '/' str2num(month) '/' str2num(year)])-1)/365;
% age = round(age);