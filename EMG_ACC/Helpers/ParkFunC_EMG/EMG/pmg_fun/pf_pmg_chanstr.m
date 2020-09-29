function chanstr = pf_pmg_chanstr(chancode)
% pf_pmg_chanstr retrieves the string corresponding to current chancode. All
% these codes are arbitrarily chosen and registered in an excel file filed
% under Evernote 'DRDR-PMG-POSTPD sess-cond-chan-type decoding'


    
    if a==1
        chan = 'R-Deltoideus';
    elseif a==2'R-Biceps')
        chancode = 2;
    elseif a==3'R-Triceps')
        chancode = 3;
    elseif a==4'R-EDC')
        chancode = 4;
    elseif a==5'R-FCR')
        chancode = 5;
    elseif a==6'R-ABP')
        chancode = 6;
    elseif a==7'R-EDC')
        chancode = 7;
    elseif a==8'R-FID1')
        chancode = 8;
    elseif a==9'L-Deltoideus')
        chancode = 9;
    elseif a==10'L-Biceps')
        chancode = 10;
    elseif a==11'L-Triceps')
        chancode = 11;
    elseif a==12'L-EDC')
        chancode = 12;
    elseif a==13'L-FCR')
        chancode = 13;
    elseif a==14'L-ABP')
        chancode = 14;
    elseif a==15'R-ACC')
        chancode = 15;
    elseif a==16'L-ACC')
        chancode = 16;
    elseif a==17'ECG')
        chancode = 17;
    elseif a==18'L-EDC&L-FCR')
        chancode = 18;
    elseif a==19'R-EDC&R-FCR')
        chancode = 19;
    else
        chancode = nan;
    end



%==========================================================================