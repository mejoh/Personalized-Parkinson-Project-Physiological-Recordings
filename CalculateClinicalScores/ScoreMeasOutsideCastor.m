function OUTCASTout = ScoreMeasOutsideCastor(cFile)
cText = fileread (cFile);
cData = jsondecode (cText);
cData = struct2table(cData.crf);

%Moment of MRI
switch cData.MriAccToProtocol
    case '1'
        OUTCASTout.MriAccToProtocol= "Yes - ?????? CODEBOOK DOES NOT PROPERLY DESCRIBE IT";
    case '2'
        OUTCASTout.MriAccToProtocol= "Yes - ?????? CODEBOOK DOES NOT PROPERLY DESCRIBE IT";
    case '3'
        OUTCASTout.MriAccToProtocol= "No";
end

%Date of MRI
OUTCASTout.MriDate = datetime(cData.MriMoment, 'InputFormat', 'dd-MM-yyyy');

%Type of task (ACCORDING TO TESSA
switch cData.MriNeuroPsychTask
    case '1'
        OUTCASTout.MriNeuroPsychTask= "Motor - ?????? CODEBOOK DOES NOT PROPERLY DESCRIBE IT";
    case '2'
        OUTCASTout.MriNeuroPsychTask= "Reward - ?????? CODEBOOK DOES NOT PROPERLY DESCRIBE IT";
end

%CSF
switch cData.LumpStatus
    case '1'
        OUTCASTout.LumpStatus= "1 - ?????? CODEBOOK DOES NOT PROPERLY DESCRIBE IT";
    case '2'
        OUTCASTout.LumpStatus= "2 - ?????? CODEBOOK DOES NOT PROPERLY DESCRIBE IT";
    case '3'
        OUTCASTout.LumpStatus= "3 - ?????? CODEBOOK DOES NOT PROPERLY DESCRIBE IT";
    case '4'
        OUTCASTout.LumpStatus= "4 - ?????? CODEBOOK DOES NOT PROPERLY DESCRIBE IT";
end

%Volume CSF
if ~(strcmp(cData.LumpStatus, '3') || strcmp(cData.LumpStatus, '4')); OUTCASTout.LumpVolumeMilliLiter = str2double(cData.LumpVolume); end

%CSF date 
if ~(strcmp(cData.LumpStatus, '3') || strcmp(cData.LumpStatus, '4')); OUTCASTout.LumpDate = datetime(cData.LumpMoment, 'InputFormat', 'dd-MM-yyyy;HH:mm'); end
end