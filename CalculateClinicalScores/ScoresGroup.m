%% Analyses 
% Load Data
load (fullfile("/project", "3022026.01", "analyses", "tessa", "Test", "Clinical_Scores", "ClinicalScoresSub.mat"));

%% Settings
SaveDir         = fullfile("/project", "3022026.01", "analyses", "tessa", "Test","Clinical_Scores" );
Task            = 2;                        %Enter 2 for reward task, enter 1 for motor task, if all should be selected press 0. 
CutOffVar       = "RestTremor_OffV1";
CutOffValue     = 1;
LabelGroup1     = "Tremor_Off"        ;  %Group with scores above cut-off
LabelGroup2     = "NoTremor_Off"      ;  %Group with scores below cut-off
GL_Label        = "PresenceTremorOff" ;  %Group level label

%% Start
if exist (fullfile(SaveDir, "ClinicalScores.mat"), 'file')
    load (fullfile(SaveDir, "ClinicalScores.mat"))
end


%% Make per subcategory
if Task == 2 || Task == 1
SubTable = ClinicalScoresSub(ClinicalScoresSub.Group == Task, :);
elseif Task == 0 
    SubTable = ClinicalScoresSub; 
end


Group1 = SubTable (SubTable.(CutOffVar)>CutOffValue, : ); 
Group2 = SubTable (SubTable.(CutOffVar)<CutOffValue, : ); 

%% Calculate scores
for cVar = ["Age", "HoehnYahr_On", "HoehnYahr_Off", "DiseaseDuration", "YearsWithSympt", "OFF_PartI", "OFF_PartII", ...
        "OFF_PartIII", "ON_PartI", "ON_PartII", "ON_PartIII", "V1_ON", "V1_OFF", "RestTremor_OffV1", "RestTremor_OnV1", ...
        "Tremor_OffTotalV1", "Tremor_OnTotalV1", "MocaScore", "BDI_Score", "QUIPRS_Score", "ApathyScore", "STAI_DispositieTrait", "STAI_ToestandState", "STAI_Total"]
% ======= Age
ClinicalScores.(GL_Label).(cVar).(LabelGroup1).mean = nanmean (Group1.(cVar));
ClinicalScores.(GL_Label).(cVar).(LabelGroup1).standev = nanstd (Group1.(cVar)); 
ClinicalScores.(GL_Label).(cVar).(LabelGroup1).minimum = min (Group1.(cVar)); 
ClinicalScores.(GL_Label).(cVar).(LabelGroup1).maximum = max (Group1.(cVar)); 
ClinicalScores.(GL_Label).(cVar).(LabelGroup2).mean = nanmean (Group2.(cVar)); 
ClinicalScores.(GL_Label).(cVar).(LabelGroup2).standev = nanstd (Group2.(cVar));
ClinicalScores.(GL_Label).(cVar).(LabelGroup2).minimum = min (Group2.(cVar));
ClinicalScores.(GL_Label).(cVar).(LabelGroup2).maximum = max (Group2.(cVar));
ClinicalScores.(GL_Label).(cVar).MeanDiff = ClinicalScores.(GL_Label).(cVar).(LabelGroup1).mean  - ClinicalScores.(GL_Label).(cVar).(LabelGroup2).mean ;

[ClinicalScores.(GL_Label).(cVar).h,ClinicalScores.(GL_Label).(cVar).p,ClinicalScores.(GL_Label).(cVar).ci, ClinicalScores.(GL_Label).(cVar).stats] =  ...
    ttest2(Group1.(cVar), Group2.(cVar));

if ClinicalScores.(GL_Label).(cVar).p <0.05
    disp (strcat(cVar, " is significantly different between groups"))
end 
end


% ======= Gender
ClinicalScores.(GL_Label).Gender.(LabelGroup1).nMales = sum(Group1.Gender == 1) ;
ClinicalScores.(GL_Label).Gender.(LabelGroup1).nFemales = sum(Group1.Gender == 2); 
ClinicalScores.(GL_Label).Gender.(LabelGroup2).nMales = sum(Group2.Gender == 1) ;
ClinicalScores.(GL_Label).Gender.(LabelGroup2).nFemales = sum(Group2.Gender == 2); 

[ClinicalScores.(GL_Label).Gender.h,ClinicalScores.(GL_Label).Gender.p] = ttest2(Group1.Gender, Group2.Gender);
if ClinicalScores.(GL_Label).Gender.p <0.05
    disp ("Gender is significantly different between groups")
end 

% ======= PD MedUse
ClinicalScores.(GL_Label).UsePDMed.(LabelGroup1).nNo = sum(Group1.UsePDMed == 0) ;
ClinicalScores.(GL_Label).UsePDMed.(LabelGroup1).nYes = sum(Group1.UsePDMed == 1); 
ClinicalScores.(GL_Label).UsePDMed.(LabelGroup2).nNo = sum(Group2.UsePDMed == 0) ;
ClinicalScores.(GL_Label).UsePDMed.(LabelGroup2).nYes = sum(Group2.UsePDMed == 1); 

[ClinicalScores.(GL_Label).UsePDMed.h,ClinicalScores.(GL_Label).UsePDMed.p] = ttest2(Group1.UsePDMed, Group2.UsePDMed);
if ClinicalScores.(GL_Label).UsePDMed.p <0.05
    disp ("UsePDMed is significantly different between groups")
end 


%% Save
save (fullfile(SaveDir, "ClinicalScores.mat"), "ClinicalScores")
