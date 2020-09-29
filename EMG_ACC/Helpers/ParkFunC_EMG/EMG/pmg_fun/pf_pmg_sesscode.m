function sesscodes    =   pf_pmg_sesscode(str)
% Function to retrieve the code corresponding to the session. All
% these codes are arbitrarily chosen and registered in an excel file filed
% under Evernote 'DRDR-PMG-POSTPD sess-cond-chan-type decoding'

if iscell(str)
    nString   =   length(str);
else
    nString   =   1;
end
sesscodes =   nan(nString,1);

for a = 1:nString
    if strcmp(str,'OFF')
        sesscode = 1;
    elseif strcmp(str,'ON')
        sesscode = 2;
    else
        sesscode = nan;
    end
    sesscodes(a) = sesscode;
end

%--------------------------------------------------------------------------