function UPDRS3out = ScoreUPDRS3_ON(cUPDRS3files)
%Loop through parts
for cPart = 1:3
    cPartName = strcat("Part", string(cPart));
    
    %Format data
    cFile = cUPDRS3files.(cPartName);
    cText = fileread (cFile);
    cData = jsondecode (cText);
    cData = struct2table(cData.crf);
    
    if cPart == 1
        SubScore1 = sum([str2double(cData.Up3OnProSYesDev), str2double(cData.Up3OnGait), str2double(cData.Up3OnHaMoNonDev), str2double(cData.Up3OnHaMoYesDev), ...
            str2double(cData.Up3OnRigLue), str2double(cData.Up3OnToTaYesDev), str2double(cData.Up3OnRigRue), str2double(cData.Up3OnSpeech), str2double(cData.Up3OnFiTaYesDev)...
            str2double(cData.Up3OnArise), str2double(cData.Up3OnLAgiYesDev), str2double(cData.Up3OnFacial), str2double(cData.Up3OnFiTaNonDev), str2double(cData.Up3OnClinStat), ...
            str2double(cData.Up3OnRigRle), str2double(cData.Up3OnRigNec), str2double(cData.Up3OnRigLle), str2double(cData.Up3OnLAgiNonDev), str2double(cData.Up3OnProSNonDev),...
            str2double(cData.Up3OnToTaNonDev)]);
        
        %Save
        UPDRS3out.(cPartName).SubScore = SubScore1;
        UPDRS3out.(cPartName).File = cFile;
        UPDRS3out.(cPartName).rawData = cText;
    elseif cPart == 2
        SubScore2 = sum([str2double(cData.Up3OnStaPos), str2double(cData.Up3OnFreez)]);
        
        %Save
        UPDRS3out.(cPartName).SubScore = SubScore2;
        UPDRS3out.(cPartName).File = cFile;
        UPDRS3out.(cPartName).rawData = cText;
    elseif cPart == 3
        SubScore3  = sum([str2double(cData.Up3OnPostur), str2double(cData.Up3OnSpont), str2double(cData.Up3OnKinTreNonDev), str2double(cData.Up3OnPosTYesDev), ...
            str2double(cData.Up3OnKinTreYesDev), str2double(cData.Up3OnRAmpLegYesDev), str2double(cData.Up3OnConstan), str2double(cData.Up3OnPosTNonDev), str2double(cData.Up3OnRAmpArmNonDev), ...
            str2double(cData.Up3OnRAmpArmYesDev), str2double(cData.Up3OnPresDysKin), str2double(cData.Up3OnRAmpJaw), str2double(cData.Up3OnRAmpLegNonDev)]);
        RestScore  = sum([str2double(cData.Up3OnRAmpArmNonDev), str2double(cData.Up3OnRAmpArmYesDev), str2double(cData.Up3OnRAmpLegNonDev), ...
            str2double(cData.Up3OnRAmpLegYesDev), str2double(cData.Up3OnRAmpJaw)]);
        TotalScore  = sum([str2double(cData.Up3OnPosTNonDev), str2double(cData.Up3OnPosTYesDev), str2double(cData.Up3OnKinTreNonDev), ...
            str2double(cData.Up3OnKinTreYesDev), str2double(cData.Up3OnRAmpArmNonDev), str2double(cData.Up3OnRAmpArmYesDev), str2double(cData.Up3OnRAmpLegNonDev), ...
            str2double(cData.Up3OnRAmpLegYesDev), str2double(cData.Up3OnRAmpJaw), str2double(cData.Up3OnConstan)]);
        
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