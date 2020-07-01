function chancodes = pf_pmg_chancode(chanstring)
% Function to retrieve the code corresponding to the current channel. All
% these codes are arbitrarily chosen and registered in an excel file filed
% under Evernote 'DRDR-PMG-POSTPD sess-cond-chan-type decoding'

if iscell(chanstring)
    nString   =   length(chanstring);
else
    nString   =   1;
end
chancodes =   nan(nString,1);

for a = 1:nString
    
    if strcmp(chanstring,'R-Deltoideus')
        chancode = 1;
    elseif strcmp(chanstring,'R-Biceps')
        chancode = 2;
    elseif strcmp(chanstring,'R-Triceps')
        chancode = 3;
    elseif strcmp(chanstring,'R-EDC')
        chancode = 4;
    elseif strcmp(chanstring,'R-FCR')
        chancode = 5;
    elseif strcmp(chanstring,'R-ABP')
        chancode = 6;
    elseif strcmp(chanstring,'R-FID1')
        chancode = 7;
    elseif strcmp(chanstring,'L-Deltoideus')
        chancode = 8;
    elseif strcmp(chanstring,'L-Biceps')
        chancode = 9;
    elseif strcmp(chanstring,'L-Triceps')
        chancode = 10;
    elseif strcmp(chanstring,'L-EDC')
        chancode = 11;
    elseif strcmp(chanstring,'L-FCR')
        chancode = 12;
    elseif strcmp(chanstring,'L-ABP')
        chancode = 13;
    elseif strcmp(chanstring,'L-FID1')
        chancode = 14;
    elseif strcmp(chanstring,'R-ACC')
        chancode = 15;
    elseif strcmp(chanstring,'L-ACC')
        chancode = 16;
    elseif strcmp(chanstring,'ECG')
        chancode = 17;
    elseif strcmp(chanstring,'L-EDC&L-FCR')
        chancode = 18;
    elseif strcmp(chanstring,'R-EDC&R-FCR')
        chancode = 19;
    else
        chancode = nan;
    end
    chancodes(a) = chancode;
end


%==========================================================================