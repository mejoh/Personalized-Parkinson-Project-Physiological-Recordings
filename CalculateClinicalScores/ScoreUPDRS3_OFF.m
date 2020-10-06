function UPDRS3out = ScoreUPDRS3_OFF(cUPDRS3files)
%Loop through parts
for cPart = 1:3
    cPartName = strcat("Part", string(cPart));
    
    %Format data
    cFile = cUPDRS3files.(cPartName);
    cText = fileread (cFile);
    cData = jsondecode (cText);
    cData = struct2table(cData.crf);
    
    if cPart == 1
        SubScore1 = sum([str2double(cData.Up3OfParkMedic),  str2double(cData.Up3OfArise), str2double(cData.Up3OfGait), str2double(cData.Up3OfRigRue),...
            str2double(cData.Up3OfRigLle), str2double(cData.Up3OfLAgiYesDev), str2double(cData.Up3OfFacial), str2double(cData.Up3OfFiTaYesDev), str2double(cData.Up3OfRigLue), ...
            str2double(cData.Up3OfRigNec), str2double(cData.Up3OfHaMoNonDev), str2double(cData.Up3OfLAgiNonDev), str2double(cData.Up3OfRigRle), str2double(cData.Up3OfToTaYesDev), ...
            str2double(cData.Up3OfToTaNonDev), str2double(cData.Up3OfFiTaNonDev), str2double(cData.Up3OfProSYesDev), str2double(cData.Up3OfSpeech), str2double(cData.Up3OfHaMoYesDev),...
            str2double(cData.Up3OfProSNonDev)]);
        
        %Save
        UPDRS3out.(cPartName).SubScore = SubScore1;
        UPDRS3out.(cPartName).File = cFile;
        UPDRS3out.(cPartName).rawData = cText;
    elseif cPart == 2
        SubScore2 = sum([str2double(cData.Up3OfStaPos), str2double(cData.Up3OfFreez)]);
        
        %Save
        UPDRS3out.(cPartName).SubScore = SubScore2;
        UPDRS3out.(cPartName).File = cFile;
        UPDRS3out.(cPartName).rawData = cText;
    elseif cPart == 3
        SubScore3 = sum([str2double(cData.Up3OfPostur), str2double(cData.Up3OfRAmpLegYesDev), str2double(cData.Up3OfRAmpJaw),str2double(cData.Up3OfRAmpLegNonDev), ...
            str2double(cData.Up3OfPosTYesDev),str2double(cData.Up3OfKinTreYesDev),str2double(cData.Up3OfKinTreNonDev),str2double(cData.Up3OfPosTNonDev),str2double(cData.Up3OfPresDysKin), ...
            str2double(cData.Up3OfConstan),str2double(cData.Up3OfRAmpArmNonDev),str2double(cData.Up3OfRAmpArmYesDev),str2double(cData.Up3OfSpont)]);   
        RestScore = sum([str2double(cData.Up3OfRAmpArmNonDev), str2double(cData.Up3OfRAmpArmYesDev), str2double(cData.Up3OfRAmpLegNonDev), ...
            str2double(cData.Up3OfRAmpLegYesDev), str2double(cData.Up3OfRAmpJaw)]);
        TotalScore = sum([str2double(cData.Up3OfPosTNonDev), str2double(cData.Up3OfPosTYesDev), str2double(cData.Up3OfKinTreNonDev), ...
            str2double(cData.Up3OfKinTreYesDev), str2double(cData.Up3OfRAmpArmNonDev), str2double(cData.Up3OfRAmpArmYesDev), str2double(cData.Up3OfRAmpLegNonDev), ...
            str2double(cData.Up3OfRAmpLegYesDev), str2double(cData.Up3OfRAmpJaw), str2double(cData.Up3OfConstan)]);
        
        %Save
        UPDRS3out.(cPartName).SubScore = SubScore3;
        UPDRS3out.(cPartName).RestScore = RestScore;
        UPDRS3out.(cPartName).TotalScore = TotalScore;
        UPDRS3out.(cPartName).File = cFile;
        UPDRS3out.(cPartName).rawData = cText;
    end
end

UPDRS3out.TotalScore = SubScore1 + SubScore2 + SubScore3;
end
