function [TremorScore, UPDRSIII, UPDRSIIIError] = ScoresUPDRSPartIII(filedir)
% Function to calculate sum of UPDRSIII per part and total for visit 1 and
% visit 2 subs.

% Create empty matrices to save subs that have show an error
UPDRSIIIError.ON_PartI = []; UPDRSIIIError.OFF_PartI = [];
UPDRSIIIError.ON_PartIII  = []; UPDRSIIIError.OFF_PartIII  = [];
UPDRSIIIError.MakeTable = [];
TremorScore = []

UPDRSIII.start = [] 

Subs = ClincialScores_Error.UPDRSIII.MakeTable
% Start per subject analysis
for ind = 1:length(Subs)
    cSub = Subs{ind};
    for cState = ["OFF", "ON"]
        for cVisit =["Visit1", "Visit2"]
            for cPart = 1:3
                cFile = findCorFile (cState, cPart, cVisit,  cSub, filedir);
                if ~exist (cFile, "file") % Check if file exists
                    UPDRSIII.(cVisit).(strcat(cState, "_SumPartI"))(ind) =  nan;
                    UPDRSIII.(cVisit).(strcat(cState, "_SumPartII"))(ind) =  nan;
                    UPDRSIII.(cVisit).(strcat(cState, "_SumPartIII"))(ind) =  nan;
                    TremorScore.(cState).Rest.(cVisit)(ind) = nan;
                    TremorScore.(cState).Total.(cVisit)(ind) = nan;
                else % if file exists, continue with analysis
                    cText = fileread (cFile);
                    cData = jsondecode (cText);
                    if strcmp(cState, 'ON')
                        [TremorScore, UPDRSIII] = analysisOn (cData, cPart, UPDRSIII, TremorScore, cSub, ind, cVisit);
                    elseif strcmp(cState, 'OFF')
                        [TremorScore, UPDRSIII] = analysisOff (cData, cPart, UPDRSIII, TremorScore, cSub, ind, cVisit);
                    end
                    
                end
            end
        end
    end
end
%% end analysis per part

%% Start analysis of final scores
UPDRSIII = ChangeStruct2table (UPDRSIII);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                   %%
%% -------------------Subfunctions-------------------%%
%%                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Function to search the correct filename

    function cFile = findCorFile (cState, cPart, cVisit, cSub, filedir)
        if strcmp(cState, "ON")
            cScore = strcat("Castor.", cVisit, ".Motorische_taken_", cState, ".Updrs3_deel_", string(cPart));
        elseif strcmp (cState, "OFF")
            cScore = strcat("Castor.", cVisit, ".Motorische_taken_", cState, ".Updrs_3_deel_", string(cPart));
        end
        cFile = fullfile(filedir, cSub, cScore);
    end

%% Function to search for data in the on state and sum them properly
    function [TremorScore, UPDRSIII] = analysisOn (cData, cPart, UPDRSIII, TremorScore, cSub, ind, cVisit)
        cData = struct2table(cData.crf);
        if cPart == 1
            try
                UPDRSIII.(cVisit).ON_SumPartI(ind)= sum([str2double(cData.Up3OnProSYesDev), str2double(cData.Up3OnGait), str2double(cData.Up3OnHaMoNonDev), str2double(cData.Up3OnHaMoYesDev), ...
                    str2double(cData.Up3OnRigLue), str2double(cData.Up3OnToTaYesDev), str2double(cData.Up3OnRigRue), str2double(cData.Up3OnSpeech), str2double(cData.Up3OnFiTaYesDev)...
                    str2double(cData.Up3OnArise), str2double(cData.Up3OnLAgiYesDev), str2double(cData.Up3OnFacial), str2double(cData.Up3OnFiTaNonDev), str2double(cData.Up3OnClinStat), ...
                    str2double(cData.Up3OnRigRle), str2double(cData.Up3OnRigNec), str2double(cData.Up3OnRigLle), str2double(cData.Up3OnLAgiNonDev), str2double(cData.Up3OnProSNonDev),...
                    str2double(cData.Up3OnToTaNonDev)]);
            catch
                warning ('PartI ON field is not as expected %s', cSub)
                UPDRSIIIError.ON_PartI = [UPDRSIIIError.ON_PartI ;  cSub];
                UPDRSIII.(cVisit).ON_SumPartI(ind) = nan;
            end
            
        elseif cPart == 2
            UPDRSIII.(cVisit).ON_SumPartII(ind) = sum([str2double(cData.Up3OnStaPos), str2double(cData.Up3OnFreez)]);
            
            
        elseif cPart == 3
            try
                UPDRSIII.(cVisit).ON_SumPartIII(ind)  = sum([str2double(cData.Up3OnPostur), str2double(cData.Up3OnSpont), str2double(cData.Up3OnKinTreNonDev), str2double(cData.Up3OnPosTYesDev), ...
                    str2double(cData.Up3OnKinTreYesDev), str2double(cData.Up3OnRAmpLegYesDev), str2double(cData.Up3OnConstan), str2double(cData.Up3OnPosTNonDev), str2double(cData.Up3OnRAmpArmNonDev), ...
                    str2double(cData.Up3OnRAmpArmYesDev), str2double(cData.Up3OnPresDysKin), str2double(cData.Up3OnRAmpJaw), str2double(cData.Up3OnRAmpLegNonDev)]);
                
                
                TremorScore.ON.Rest.(cVisit)(ind)  = sum([str2double(cData.Up3OnRAmpArmNonDev), str2double(cData.Up3OnRAmpArmYesDev), str2double(cData.Up3OnRAmpLegNonDev), ...
                    str2double(cData.Up3OnRAmpLegYesDev), str2double(cData.Up3OnRAmpJaw)]);
                TremorScore.ON.Total.(cVisit)(ind)  = sum([str2double(cData.Up3OnPosTNonDev), str2double(cData.Up3OnPosTYesDev), str2double(cData.Up3OnKinTreNonDev), ...
                    str2double(cData.Up3OnKinTreYesDev), str2double(cData.Up3OnRAmpArmNonDev), str2double(cData.Up3OnRAmpArmYesDev), str2double(cData.Up3OnRAmpLegNonDev), ...
                    str2double(cData.Up3OnRAmpLegYesDev), str2double(cData.Up3OnRAmpJaw), str2double(cData.Up3OnConstan)]);
            catch
                warning ('PartIII ON field is not as expected %s', cSub)
                UPDRSIIIError.ON_PartIII = [UPDRSIIIError.ON_PartIII;  cSub];
                UPDRSIII.(cVisit).ON_SumPartIII(ind) = nan;
            end
        end
    end

%% Function to search for data in the off state and sum them properly
    function [TremorScore, UPDRSIII] = analysisOff (cData, cPart, UPDRSIII, TremorScore, cSub, ind, cVisit)
        
        % To solve error issue due to an empty variable.
        try
            cData = struct2table(cData.crf);
        catch
            UPDRSIIIError.MakeTable = [UPDRSIIIError.MakeTable; cSub];
        end
        
        if cPart == 1
            try
                UPDRSIII.(cVisit).OFF_SumPartI(ind)= sum([str2double(cData.Up3OfParkMedic),  str2double(cData.Up3OfArise), str2double(cData.Up3OfGait), str2double(cData.Up3OfRigRue),...
                    str2double(cData.Up3OfRigLle), str2double(cData.Up3OfLAgiYesDev), str2double(cData.Up3OfFacial), str2double(cData.Up3OfFiTaYesDev), str2double(cData.Up3OfRigLue), ...
                    str2double(cData.Up3OfRigNec), str2double(cData.Up3OfHaMoNonDev), str2double(cData.Up3OfLAgiNonDev), str2double(cData.Up3OfRigRle), str2double(cData.Up3OfToTaYesDev), ...
                    str2double(cData.Up3OfToTaNonDev), str2double(cData.Up3OfFiTaNonDev), str2double(cData.Up3OfProSYesDev), str2double(cData.Up3OfSpeech), str2double(cData.Up3OfHaMoYesDev),...
                    str2double(cData.Up3OfProSNonDev)]);
            catch
                warning ('PartI OFF  field is not as expected %s', cSub)
                UPDRSIIIError.OFF_PartI = [UPDRSIIIError.OFF_PartI;  cSub];
                UPDRSIII.(cVisit).OFF_SumPartI(ind) = nan;
            end
        elseif cPart == 2
            UPDRSIII.(cVisit).OFF_SumPartII(ind) = sum([str2double(cData.Up3OfStaPos), str2double(cData.Up3OfFreez)]);
        elseif cPart == 3
            try
                UPDRSIII.(cVisit).OFF_SumPartIII(ind) = sum([str2double(cData.Up3OfPostur), str2double(cData.Up3OfRAmpLegYesDev), str2double(cData.Up3OfRAmpJaw),str2double(cData.Up3OfRAmpLegNonDev), ...
                    str2double(cData.Up3OfPosTYesDev),str2double(cData.Up3OfKinTreYesDev),str2double(cData.Up3OfKinTreNonDev),str2double(cData.Up3OfPosTNonDev),str2double(cData.Up3OfPresDysKin), ...
                    str2double(cData.Up3OfConstan),str2double(cData.Up3OfRAmpArmNonDev),str2double(cData.Up3OfRAmpArmYesDev),str2double(cData.Up3OfSpont)]);
                
                TremorScore.OFF.Rest.(cVisit)(ind) = sum([str2double(cData.Up3OfRAmpArmNonDev), str2double(cData.Up3OfRAmpArmYesDev), str2double(cData.Up3OfRAmpLegNonDev), ...
                    str2double(cData.Up3OfRAmpLegYesDev), str2double(cData.Up3OfRAmpJaw)]);
                TremorScore.OFF.Total.(cVisit)(ind) = sum([str2double(cData.Up3OfPosTNonDev), str2double(cData.Up3OfPosTYesDev), str2double(cData.Up3OfKinTreNonDev), ...
                    str2double(cData.Up3OfKinTreYesDev), str2double(cData.Up3OfRAmpArmNonDev), str2double(cData.Up3OfRAmpArmYesDev), str2double(cData.Up3OfRAmpLegNonDev), ...
                    str2double(cData.Up3OfRAmpLegYesDev), str2double(cData.Up3OfRAmpJaw), str2double(cData.Up3OfConstan)]);
                
                
            catch
                warning ('PartIII OFF field is not as expected %s', cSub)
                UPDRSIIIError.OFF_PartIII = [UPDRSIIIError.OFF_PartIII;  cSub];
                UPDRSIII.(cVisit).OFF_SumPartIII(ind) = nan;
            end
        end
    end

%% Function to make the data struct readable in a table
    function [UPDRSIII] = ChangeStruct2table (UPDRSIII)
        V1_ON = sum([UPDRSIII.Visit1.ON_SumPartI; UPDRSIII.Visit1.ON_SumPartII ; UPDRSIII.Visit1.ON_SumPartIII])';
        V1_OFF = sum([UPDRSIII.Visit1.OFF_SumPartI; UPDRSIII.Visit1.OFF_SumPartII ; UPDRSIII.Visit1.OFF_SumPartIII])';
        
        V2_ON = sum([UPDRSIII.Visit2.ON_SumPartI; UPDRSIII.Visit2.ON_SumPartII ; UPDRSIII.Visit2.ON_SumPartIII])';
        V2_OFF = sum([UPDRSIII.Visit2.OFF_SumPartI; UPDRSIII.Visit2.OFF_SumPartII ; UPDRSIII.Visit2.OFF_SumPartIII])';
        SubsTable = table(Subs);
        UPDRSIII.Total_Visit1 = [SubsTable, table(V1_ON), table(V1_OFF)];
        UPDRSIII.Total_Visit2 = [SubsTable, table(V2_ON), table(V2_OFF)];
        
        
        for cVisit = ["Visit1", "Visit2"]
            Visit_AllData = [UPDRSIII.(cVisit).OFF_SumPartI', UPDRSIII.(cVisit).OFF_SumPartII', UPDRSIII.(cVisit).OFF_SumPartIII', ...
                UPDRSIII.(cVisit).ON_SumPartI', UPDRSIII.(cVisit).ON_SumPartII', UPDRSIII.(cVisit).ON_SumPartIII'];
            VisitTable = splitvars(table(Visit_AllData));
            VisitTable.Properties.VariableNames{'Visit_AllData_1'} = 'OFF_PartI';
            VisitTable.Properties.VariableNames{'Visit_AllData_2'} = 'OFF_PartII';
            VisitTable.Properties.VariableNames{'Visit_AllData_3'} = 'OFF_PartIII';
            VisitTable.Properties.VariableNames{'Visit_AllData_4'} = 'ON_PartI';
            VisitTable.Properties.VariableNames{'Visit_AllData_5'} = 'ON_PartII';
            VisitTable.Properties.VariableNames{'Visit_AllData_6'} = 'ON_PartIII';
            VisitTable = [SubsTable, VisitTable];
            UPDRSIII.(cVisit)  = VisitTable;
        end
    end

end



