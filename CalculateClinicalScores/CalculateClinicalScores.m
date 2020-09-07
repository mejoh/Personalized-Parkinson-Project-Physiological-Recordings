%% Main Script CalculateClinicalScores
%  This script can be used to calculate the clincial scores of the
%  Parkinson Op Maat subjects (personalized parkinson project subjects)

%  Currently ; demographic features, depression scores and UPDRSIII scores
% (per part, total and tremor scores seperately) can be calculated using
% this script.

%   Dependencies:
%       (1) Function: ScoresDemographics.m
%       (2) Function: ScoresUPDRSPartIIIV2
%       (3) Function: ScoresBDI


% Demographics contain; age, gender
%% Settings
% Set directories
filedir =   fullfile("/project", "3022026.01","pep","pulled-data");         % Directory with raw data
savedir = ('/project/3022026.01/analyses/tessa/Test/Clinical_Scores/');     % Directory were the variables should be saved in

% GetSubs
Files = struct2table(dir(filedir));
Subs = Files.name (4:end-1);

% What to do
Todo.CalcDemographics    =   true;
Todo.CalcUPDRSIII        =   true;
Todo.CalcDepression      =   true;
Todo.CalcMocaScore       =   true;
Todo.CalcQUIPRS          =   true; 
Todo.CalcApathyScore     =   true; 
Todo.CalcSTAI            =   true; 

Todo.SubjectMatrix       =   true; % NOTE; only possible if all scores are calculated or code is adjusted. 
Todo.ErrorStruct         =   true; % NOTE; only possible if all scores are calculated or code is adjusted. 
Todo.SaveVars            =   true;

if Todo.CalcDemographics
    [Demographics, DemographicsError] = ScoresDemographics (Subs, filedir);
end

if Todo.CalcUPDRSIII
    [TremorScore, UPDRSIII, UPDRSIIIError] = ScoresUPDRSPartIII(Subs, filedir);
end

if Todo.CalcDepression
    [BDIScore, BDIError] = ScoresBDI (filedir, Subs)
    
end

if Todo.CalcMocaScore
    [MocaScore, MocaError] = ScoresMoca (Subs, filedir) 
end

if Todo.CalcQUIPRS
    [QUIPRS, QUIPRSError] = ScoresImpulseControl (Subs, filedir)
end

if Todo.CalcApathyScore 
    [ApathyScaleScore, ApathyScaleError] = ScoreApathyScale (Subs, filedir)
end

if Todo.CalcSTAI
    [STAIScore, STAIError] = ScoresSTAI (filedir, Subs)
end

%% ------ Make subject matrix

if Todo.SubjectMatrix   
    
    SubsDemo = splitvars(table([Demographics.MriNeuroPsychTask, Demographics.Age, Demographics.Gender, Demographics.HoehnandYahr.ON, Demographics.HoehnandYahr.OFF, Demographics.DiseaseDuration, Demographics.YearsWithSympt, Demographics.PD_med]));
    SubsDemo = splitvars(table(SubsDemo));
    SubsDemo.Properties.VariableNames{'Var1_1'} = 'Group';
    SubsDemo.Properties.VariableNames{'Var1_2'} = 'Age';
    SubsDemo.Properties.VariableNames{'Var1_3'} = 'Gender';
    SubsDemo.Properties.VariableNames{'Var1_4'} = 'HoehnYahr_On';
    SubsDemo.Properties.VariableNames{'Var1_5'} = 'HoehnYahr_Off';
    SubsDemo.Properties.VariableNames{'Var1_6'} = 'DiseaseDuration';
    SubsDemo.Properties.VariableNames{'Var1_7'} = 'YearsWithSympt';
    SubsDemo.Properties.VariableNames{'Var1_8'} = 'UsePDMed';
    SubsDemo = [SubsDemo, table(Demographics.MriMoment)]; 
    SubsDemo.Properties.VariableNames{'Var1'} = 'MRIMoment';
    
    SubsUPDRSIII = [UPDRSIII.Visit1(:,2:end), UPDRSIII.Total_Visit1(:,2:end), splitvars(table([TremorScore.OFF.Rest.Visit1', TremorScore.ON.Rest.Visit1', TremorScore.OFF.Total.Visit1', TremorScore.ON.Total.Visit1']))]; 
    SubsUPDRSIII.Properties.VariableNames{'Var1_1'} = 'RestTremor_OffV1';
    SubsUPDRSIII.Properties.VariableNames{'Var1_2'} = 'RestTremor_OnV1';
    SubsUPDRSIII.Properties.VariableNames{'Var1_3'} = 'Tremor_OffTotalV1';
    SubsUPDRSIII.Properties.VariableNames{'Var1_4'} = 'Tremor_OnTotalV1';
    
    SubsBDI = table(BDIScore.PerSub.Visit1, 'VariableNames', { 'BDI_Score'} );
    
    SubsMoca = table(MocaScore.SubScore,   'VariableNames', { 'MocaScore'}); 
    SubsSTAI_DispositieTrait = table(STAIScore.Dispositie_Trait', 'VariableNames', { 'STAI_DispositieTrait'}) ; 
    SubsSTAI_ToestandState = table(STAIScore.Toestand_State', 'VariableNames', {  'STAI_ToestandState'}) ; 
    SubsSTAI_Total = table(STAIScore.Total', 'VariableNames', { 'STAI_Total'}) ; 
    
    
    SubsApathy = table(ApathyScaleScore', 'VariableNames', { 'ApathyScore'}); 
    SubsQUIPRS = table(QUIPRS.Score','VariableNames', { 'QUIPRS_Score'} ) ;  

    ClinicalScoresSub = [table(Subs),SubsDemo, SubsUPDRSIII, SubsMoca, SubsBDI, SubsQUIPRS, SubsApathy,SubsSTAI_DispositieTrait,  SubsSTAI_ToestandState, SubsSTAI_Total];

end 

% ------- End subject matrix

%% ------ Make error struct
if Todo.ErrorStruct
ClincialScores_Error.Demographics   = DemographicsError;
ClincialScores_Error.UPDRSIII       = UPDRSIIIError;
ClincialScores_Error.BDI            = BDIError;
ClincialScores_Error.Moca           = MocaError;
ClincialScores_Error.QUIPRS         = QUIPRSError;
ClincialScores_Error.Apathy         = ApathyScaleError; 
ClinicalScores_Error.STAI           = STAIError;
end
% ------- End error struct

%% ------ Start save vars
if Todo.SaveVars
    try
        save(fullfile(savedir, 'TremorScore.mat'), 'TremorScore');
        save(fullfile(savedir, 'UPDRSIII.mat'), 'UPDRSIII');
    catch
        warning ('TremorScore and UPDRSII are not calculated and/or not saved')
    end
    
    try
        save(fullfile(savedir, 'Demographics.mat'), 'Demographics');
    catch
        warning ('Demographics are not calculated and/or not saved')
    end
    try
        save(fullfile(savedir, 'BDIScore.mat'), 'BDIScore');
        save(fullfile(savedir, 'Error_cData.mat'), 'Error_cData');
    catch
        warning ('Demographics are not calculated and/or not saved')
    end
    
    try
        save(fullfile(savedir, 'ClinicalScoresSub.mat'), 'ClinicalScoresSub');    
    catch
        warning ('Clincial scores per sub are not calculated and/or not saved')
    end   
    try
        save(fullfile(savedir, 'ClincialScores_Error.mat'), 'ClincialScores_Error') 
    catch
        warning ('Errors per questionnaire were not calculated and/or not saved')
    end      
    
end
% ------- End Save vars