function BDIout = ScoreBDI (cFile)
%Get data in right format
cText = fileread (cFile);
cData = jsondecode (cText);
cDataTable = struct2table(cData.crf);

%Remove non question Vars
for cVar = ["Bdi2Cag", "Bdi2Who", "Bdi2CsiPos"]
    if contains(cVar, string(cDataTable.Properties.VariableNames))
        cDataTable = removevars(cDataTable, cVar);
    end
end

%Calculate total BDI 
BDITotal = sum(str2double(table2cell(cDataTable))); 

%Check classification
if BDITotal <14
    cClassification = "minimal";
elseif BDITotal>13 && BDITotal<20
    cClassification = "light";
elseif BDITotal>19 && BDITotal<29
    cClassification = "moderate";
elseif BDITotal>28
    cClassification = "severe";
end

%Save
BDIout.TotalScore = BDITotal; 
BDIout.Classification = cClassification;
BDIout.File = cFile; 
BDIout.rawData = cText; 
end


