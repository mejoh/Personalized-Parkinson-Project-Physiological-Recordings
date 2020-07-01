function sessname    =   pf_pmg_sessname(sesscode)
% Function to retrieve the name corresponding to the sessioncode. All
% these codes are arbitrarily chosen and registered in an excel file filed
% under Evernote 'DRDR-PMG-POSTPD sess-cond-chan-type decoding'

if sesscode==1
    sessname = 'OFF';
elseif sesscode==2
    sessname = 'ON';
else
    sessname = 'UNKNOWN';
end

%--------------------------------------------------------------------------