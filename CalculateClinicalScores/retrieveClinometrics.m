function [clinometricStruct, clinometricTable] = retrieveClinometrics(cSub, cConversionTable)
%CLINEMETRICSSINGLESUB Summary of this function goes here
%   Detailed explanation goes here

%FileStart
cFileStart = fullfile("P:", "3022026.01", "pep", "ClinVars", strcat("sub-", cSub));

%Medication
cMedFile = fullfile(cFileStart, "ses-Visit1", "Castor.Visit1.Demografische_vragenlijsten.Parkinson_medicatie.json");
if exist(cMedFile, 'file')
    MEDout = ScoreMedication(cMedFile, cConversionTable);
    clinometricStruct.(cSub).Medication = MEDout;
    clinometricStruct.(cSub).summary.LEDD = MEDout.LEDD;
    clinometricStruct.(cSub).summary.medUser = MEDout.medUser;
    
    %Add med classification to summary
    if MEDout.medUser
        clinometricStruct.(cSub).summary.Med_Class = {unique(MEDout.medicationTable.Medication_Class)};
    else
        clinometricStruct.(cSub).summary.Med_Class = {''};
    end
else
    clinometricStruct.(cSub).Medication = missing;
    clinometricStruct.(cSub).summary.LEDD = missing;
    clinometricStruct.(cSub).summary.medUser = missing;
    clinometricStruct.(cSub).summary.Med_Class = {''};
    warning(strcat("No medication file for: ", cSub));
end

%BDI
cBDIFile = fullfile(cFileStart, "ses-HomeQuestionnaires1", "Castor.HomeQuestionnaires1.13_Stemming_BDI2.Stemming.json");
if exist(cBDIFile, 'file')
    BDIout = ScoreBDI(cBDIFile);
    clinometricStruct.(cSub).BDI = BDIout;
    
    clinometricStruct.(cSub).summary.BDI = BDIout.TotalScore;
    clinometricStruct.(cSub).summary.BDI_classification =  BDIout.Classification;
else
    clinometricStruct.(cSub).BDI = missing;
    
    clinometricStruct.(cSub).summary.BDI = missing;
    clinometricStruct.(cSub).summary.BDI_classification =  missing;
    warning(strcat("No BDI file for: ", cSub));
end

%Apathy
cApathyFile = fullfile(cFileStart, "ses-HomeQuestionnaires1", "Castor.HomeQuestionnaires1.05_Apathieschaal.Apathie.json");
if exist(cApathyFile, 'file')
    APATHYout = ScoreApathyScale(cApathyFile);
    clinometricStruct.(cSub).ApathyScale = APATHYout;
    clinometricStruct.(cSub).summary.ApathyScale = APATHYout.TotalScore;
else
    clinometricStruct.(cSub).ApathyScale = missing;
    clinometricStruct.(cSub).summary.ApathyScale = missing;
    warning(strcat("No ApathyScale file for: ", cSub));
end

%ICD
cQuipFileStart = fullfile(cFileStart, "ses-HomeQuestionnaires1", "Castor.HomeQuestionnaires1.04_Vragenlijst_stoornissen_in_de_impulscontrole_bij_de_ziekte_van_Parkinson_QUIPRS.");
cQuipFiles.file1 = strcat(cQuipFileStart, "Voortzetten_van_gedrag.json");
cQuipFiles.file2 = strcat(cQuipFileStart, "Denken_aan_gedragingen.json");
cQuipFiles.file3 = strcat(cQuipFileStart, "Controle_over_gedragingen.json");
cQuipFiles.file4 = strcat(cQuipFileStart, "Aandrang_of_verlangen.json");
if exist(cQuipFiles.file1, 'file') && exist(cQuipFiles.file2, 'file') && exist(cQuipFiles.file3, 'file') && exist(cQuipFiles.file4, 'file')
    QUIPout = ScoreImpulseControl (cQuipFiles);
    clinometricStruct.(cSub).QUIPRS = QUIPout;
    clinometricStruct.(cSub).summary.QUIPRS = QUIPout.TotalScore;
else
    clinometricStruct.(cSub).ICD_QUIPRS = missing;
    clinometricStruct.(cSub).summary.QUIPRS = missing;
    warning(strcat("No QUIP file for: ", cSub));
end

%MOCA
cMocaFile = fullfile(cFileStart, "ses-Visit1", "Castor.Visit1.Neuropsychologische_taken.MOCA.json");
if exist(cMocaFile, 'file')
    MOCAout = ScoreMoca(cMocaFile);
    clinometricStruct.(cSub).MOCA = MOCAout;
else
    clinometricStruct.(cSub).MOCA = missing;
    warning(strcat("No MOCA file for: ", cSub));
end

%Demographics 1
cDEMO1File = fullfile(cFileStart, "ses-Visit1", "Castor.Visit1.Demografische_vragenlijsten.Deel_1.json");
if exist(cDEMO1File, 'file')
    DEMO1out = ScoreDEMO1(cDEMO1File);
    clinometricStruct.(cSub).Demographics1 = DEMO1out;
    clinometricStruct.(cSub).summary.Age = DEMO1out.Age;
    clinometricStruct.(cSub).summary.Gender = DEMO1out.Gender;
else
    clinometricStruct.(cSub).Demographics1 = missing;
    clinometricStruct.(cSub).summary.Age = missing;
    clinometricStruct.(cSub).summary.Gender = missing;
    warning(strcat("No Demographics1 file for: ", cSub));
end

%General
cGENfile = fullfile(cFileStart, "ses-Visit1", "Castor.Visit1.Motorische_taken_OFF.Algemeen.json");
if exist(cGENfile, 'file')
    GENout = ScoreMotorOffGeneral(cGENfile);
    clinometricStruct.(cSub).MotorOffGeneral = GENout;
    clinometricStruct.(cSub).summary.isPD = GENout.isPD;
else
    clinometricStruct.(cSub).MotorOffGeneral = missing;
    clinometricStruct.(cSub).summary.isPD = missing;
    warning(strcat("No Motor OFF General file for: ", cSub));
end

%MeasurementsOutsideCastor
cMOCfile = fullfile(cFileStart, "ses-Visit1", "Castor.Visit1.Checklist_metingen_en_bloeddruk.Checklist_metingen_buiten_Castor.json");
if exist(cMOCfile, 'file')
    OUTCASTout = ScoreMeasOutsideCastor(cMOCfile);
    clinometricStruct.(cSub).MeasurementsOutsideCastor = OUTCASTout;
    clinometricStruct.(cSub).summary.CSFpresent = OUTCASTout.LumpStatus;
else
    clinometricStruct.(cSub).MeasurementsOutsideCastor = missing;
    clinometricStruct.(cSub).summary.CSFpresent = missing;
    warning(strcat("No Measurements Outside Castor file for: ", cSub));
end

%Additional Demographic calculations
if isfield(clinometricStruct.(cSub).MeasurementsOutsideCastor, "MriDate") && isfield(clinometricStruct.(cSub).MotorOffGeneral, "DiagParkDate") && isfield(clinometricStruct.(cSub).MotorOffGeneral, "FirstSympYear")
    clinometricStruct.(cSub).YearsSinceDiagnosis = years(OUTCASTout.MriDate - GENout.DiagParkDate);
    clinometricStruct.(cSub).YearsSinceSymptoms = years(OUTCASTout.MriDate - GENout.FirstSympYear); %NOTE SINCE SYMPTOMS IS ONLY A YEAR, I'M NOT SURE WHAT POINT IN THAT YEAR IT TAKES> I BELIEVE JANUARY FIRST
    clinometricStruct.(cSub).summary.YearsSinceDiagnosis = clinometricStruct.(cSub).YearsSinceDiagnosis;
    clinometricStruct.(cSub).summary.YearsSinceSymptoms = clinometricStruct.(cSub).YearsSinceSymptoms;
else
    clinometricStruct.(cSub).YearsSinceDiagnosis = missing;
    clinometricStruct.(cSub).YearsSinceSymptoms = missing;
    clinometricStruct.(cSub).summary.YearsSinceDiagnosis = missing;
    clinometricStruct.(cSub).summary.YearsSinceSymptoms = missing;
end

%H&Y
for cState = ["ON", "OFF"]
    cHANDYfile = fullfile(cFileStart, "ses-Visit1", strcat("Castor.Visit1.Motorische_taken_", cState, ".Hoehn__Yahr_stage.json"));
    if exist(cHANDYfile, 'file')
        HANDYout = ScoreHandY(cHANDYfile, cState);
        clinometricStruct.(cSub).HandY.(cState) = HANDYout;
        clinometricStruct.(cSub).summary.(strcat("HandY_", cState)) = HANDYout.TotalScore;
    else
        clinometricStruct.(cSub).HandY.(cState) = missing;
        warning(strcat("No H&Y file for: ", cSub, " in the state: ", cState));
        clinometricStruct.(cSub).summary.(strcat("HandY_", cState)) = missing;
    end
end

%STAI
cQuipFile1 = fullfile(cFileStart, "ses-HomeQuestionnaires1", "Castor.HomeQuestionnaires1.06_Zelfbeoordeling_STAI.Dispositie_Trait.json");
cQuipFile2 = fullfile(cFileStart, "ses-HomeQuestionnaires1", "Castor.HomeQuestionnaires1.06_Zelfbeoordeling_STAI.Toestand_State.json");
if exist(cQuipFile1, 'file') && exist(cQuipFile2, 'file')
    STAIout= ScoreSTAI(cQuipFile1, cQuipFile2);
    clinometricStruct.(cSub).Fear_STAI = STAIout;
    clinometricStruct.(cSub).summary.STAI = STAIout.TotalScore;
else
    clinometricStruct.(cSub).Fear_STAI = missing;
    clinometricStruct.(cSub).summary.STAI = missing;
    warning(strcat("No STAI file for: ", cSub));
end

%UPDRS3
for cState = ["ON", "OFF"]
    %Get files
    switch cState
        case "ON"
            %Find files
            for cPart = 1:3
                cUPDRS3files.(strcat("Part", string(cPart))) = fullfile(cFileStart, "ses-Visit1", strcat("Castor.Visit1.Motorische_taken_", cState,".Updrs3_deel_", string(cPart), ".json"));
            end
            
            %Analyse files
            if exist(cUPDRS3files.Part1, 'file') && exist(cUPDRS3files.Part2, 'file') && exist(cUPDRS3files.Part3, 'file')
                UPDRS3out = ScoreUPDRS3_ON(cUPDRS3files);
                clinometricStruct.(cSub).UPDRS3.(cState) = UPDRS3out;
                clinometricStruct.(cSub).summary.(strcat("UPDRS3_", cState)) = UPDRS3out.TotalScore;
            else
                clinometricStruct.(cSub).UPDRS3.(cState) = missing;
                clinometricStruct.(cSub).summary.(strcat("UPDRS3_", cState)) = missing;
                warning(strcat("No UPDRS file for sub: ", cSub, " in the state: ", cState));
            end
        case "OFF"
            %Find files
            for cPart = 1:3
                cUPDRS3files.(strcat("Part", string(cPart))) = fullfile(cFileStart, "ses-Visit1", strcat("Castor.Visit1.Motorische_taken_", cState,".Updrs_3_deel_", string(cPart), ".json"));
            end
            
            %Analyse files
            if exist(cUPDRS3files.Part1, 'file') && exist(cUPDRS3files.Part2, 'file') && exist(cUPDRS3files.Part3, 'file')
                UPDRS3out = ScoreUPDRS3_OFF(cUPDRS3files);
                clinometricStruct.(cSub).UPDRS3.(cState) = UPDRS3out;
                clinometricStruct.(cSub).summary.(strcat("UPDRS3_", cState)) = UPDRS3out.TotalScore;
            else
                clinometricStruct.(cSub).UPDRS3.(cState) = missing;
                clinometricStruct.(cSub).summary.(strcat("UPDRS3_", cState)) = missing;
                warning(strcat("No UPDRS file for sub: ", cSub, " in the state: ", cState));
            end
    end
end

%Append summary to table
clinometricTable = struct2table(clinometricStruct.(cSub).summary);
end