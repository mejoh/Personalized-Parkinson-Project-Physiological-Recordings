function APATHYout = ScoreApathyScale(cFile)
%Get data in the right format 
cText = fileread (cFile);
cData = jsondecode (cText);
cDataTable = struct2table(cData.crf);

%Loop through all questions to calculate score 
ApathyScaleScore = 0;
for cQuestion = ["01","02","03","04","05","06","07","08","09","10","11","12","13","14"]
    ApathyScaleScore = ApathyScaleScore + str2num(cDataTable.(strcat("Apat", cQuestion))) ;
end

%Save output 
APATHYout.TotalScore = ApathyScaleScore; 
APATHYout.File = cFile; 
APATHYout.rawData = cData; 
end

