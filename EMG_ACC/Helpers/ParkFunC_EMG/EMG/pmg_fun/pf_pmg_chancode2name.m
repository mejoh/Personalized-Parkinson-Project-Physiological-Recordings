function channame = pf_pmg_chancode2name(chancode)
% Function to retrieve the name corresponding to the channel code. All
% these codes are arbitrarily chosen and registered in an excel file filed
% under Evernote 'DRDR-PMG-POSTPD sess-cond-chan-type decoding'

if chancode==1
    channame = 'R-Deltoideus';
elseif chancode==2
    channame = 'R-Biceps';
elseif chancode==3
    channame = 'R-Triceps';
elseif chancode==4
    channame = 'R-EDC';
elseif chancode==5
    channame = 'R-FCR';
elseif chancode==6
    channame = 'R-ABP';
elseif chancode==7
    channame = 'R-FID1';
elseif chancode==8
    channame = 'L-Deltoideus';
elseif chancode==9
    channame = 'L-Biceps';
elseif chancode==10
    channame = 'L-Triceps';
elseif chancode==11
    channame = 'L-EDC';
elseif chancode==12
    channame = 'L-FCR';
elseif chancode==13
    channame = 'L-ABP';
elseif chancode==14
    channame = 'L-FID1';
elseif chancode==15
    channame = 'R-ACC';
elseif chancode==16
    channame = 'L-ACC';
elseif chancode==17
    channame = 'ECG';
elseif chancode==18
    channame = 'L-EDC&L-FCR';
elseif chancode==19
    channame = 'R-EDC&R-FCR';
else
    channame = 'UNKNOWN';
end

%==========================================================================