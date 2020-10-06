function MOCAout = ScoreMoca(cFile)
%Load data
cText = fileread (cFile);
cData = jsondecode (cText);
cDataTable = struct2table(cData.crf);

%Sum up sub scores
TotalScore = sum([str2double(cDataTable.NpsMocVisExe), str2double(cDataTable.NpsMocOrient), ...
    str2double(cDataTable.NpsMocNaming), str2double(cDataTable.NpsMocLangu1), str2double(cDataTable.NpsMocLangu2), ...
    str2double(cDataTable.NpsMocAtten2), str2double(cDataTable.NpsMocAtten1), str2double(cDataTable.NpsMocAtten3), ...
    str2double(cDataTable.NpsMocDelRec), str2double(cDataTable.NpsMocAbstra)]); 


% NpsMocVisExe = total score of the visuo- executive domain.
% NpsMocNaming = total score of the naming domain.
% NpsMocOrient = total score of the orientation domain.
% psMocAtten2 + NpsMocAtten1 + NpsMocAtten3 = total score of the
% attention domain
% NpsNpsMocLangu1 + NpsMocLangu2 = total score of the language
% domain
% NpsMocAbstra = total score of the abstrant domain.
% NpsMocDelRec total score of the recall/memory domain

%Add additional points
if str2double(cDataTable.NpsEducYears) <13 %if education is above 13 years
    TotalScore = TotalScore + 1;
end
if str2double(cDataTable.NpsMocPhoFlu) >10 %?f number of named words starting with letter D is above 10
    TotalScore = TotalScore + 1;
end

%Save output 
MOCAout.TotalScore = TotalScore; 
MOCAout.File = cFile; 
MOCAout.rawData = cData; 
end


