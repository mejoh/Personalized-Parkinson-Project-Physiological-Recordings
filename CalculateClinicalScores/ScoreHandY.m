function HANDYout = ScoreHandY(cFile, cState)
%Format data
cText = fileread (cFile);
cData = jsondecode (cText);
cData = struct2table(cData.crf);

%Retrieve data
if strcmp(cState, 'ON')
    HANDYout.TotalScore = str2double(cData.Up3OnHoeYah);
else
    HANDYout.TotalScore = str2double(cData.Up3OfHoeYah);
end

%save raw
HANDYout.File = cFile;
HANDYout.rawData = cText;
end