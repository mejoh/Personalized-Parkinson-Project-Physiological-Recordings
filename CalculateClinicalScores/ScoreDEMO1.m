function DEMO1out = ScoreDEMO1(cFile)
%Get data in the right format
cText = fileread (cFile);
cData = jsondecode (cText);
cDataTable = struct2table(cData.crf);

%Return Age
DEMO1out.Age = str2double(cDataTable.Age);

%Gender
if strcmp(cDataTable.Gender, '1')
    DEMO1out.Gender = 'Male'; 
else
    DEMO1out.Gender = 'Female'; 
end

%Payed job
if strcmp(cDataTable.PayedJob, '0')
    DEMO1out.PayedJob = 'No'; 
else
    DEMO1out.PayedJob = 'Yes'; 
end

%These need to be added later when the codebook is update and they can be
%interpreted: 
DEMO1out.Race = missing;
DEMO1out.LivingSituat = missing;
DEMO1out.DailyActivity = missing;

%Return meta
DEMO1out.File = cFile; 
DEMO1out.rawData = cText; 
end