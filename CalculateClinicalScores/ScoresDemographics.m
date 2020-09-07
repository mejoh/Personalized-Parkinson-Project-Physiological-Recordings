function [Demographics, DemographicsError] = ScoresDemographics (Subs, filedir)
% This function lists the demographics part1 of each subject and Visit1.
% Note the reports are not loaded, if you are interested in further
% information some parts then a report might be available (especially in cData2)
% In that case, study the raw data!


DemographicsError = [];

for ii = 1:length(Subs)
    cSub = Subs{ii};
    %% ---------------- Start Age and Gender
    cFile = fullfile(filedir, cSub, "Castor.Visit1.Demografische_vragenlijsten.Deel_1");
    % Check if file exists
    if exist (cFile, "file")
        cText = fileread (cFile);
        cData = jsondecode (cText);
        try
            cData = struct2table(cData.crf);
            Demographics.Age(ii,1) = str2double(cData.Age);
            Demographics.Gender(ii,1) = str2double(cData.Gender);
        catch
            DemographicsError = [DemographicsError; cSub];
            Demographics.Age(ii,1) = nan;
            Demographics.Gender(ii,1) = nan;
        end
        
    else
        Demographics.Age(ii,1) = nan;
        Demographics.Gender(ii,1) = nan;
    end
    
    % ----------------- End Age and Gender
    %% ---------------- Start H&Y stage
    for cState = ["ON", "OFF"]
        cFile = fullfile(filedir, cSub, strcat("Castor.Visit1.Motorische_taken_", cState, ".Hoehn__Yahr_stage"));
        if exist (cFile, "file")
            cText = fileread (cFile);
            cData = jsondecode (cText);
            try
                cData = struct2table(cData.crf);
                if strcmp(cState, "ON")
                    Demographics.HoehnandYahr.(cState) (ii,1) = str2double(cData.Up3OnHoeYah);
                else
                    Demographics.HoehnandYahr.(cState) (ii,1) = str2double(cData.Up3OfHoeYah);
                end
            catch
                DemographicsError = [DemographicsError; cSub];
                Demographics.HoehnandYahr.(cState) (ii,1) = nan;
            end
            
        else
            DemographicsError = [DemographicsError; cSub];
            Demographics.HoehnandYahr.(cState) (ii,1) =  nan;
        end
    end
    % ----------------- End H&Y stage
    %% ---------------- Start Algemeen
    cFile = fullfile(filedir, cSub, "Castor.Visit1.Motorische_taken_OFF.Algemeen");
    if exist (cFile, "file")
        cText = fileread (cFile);
        cData = jsondecode (cText);
        try
            cData = struct2table(cData.crf);
            Demographics.YearDiagnosis (ii,1) = str2double(cData.DiagParkYear);
            Demographics.YearFirstSympt (ii,1) = str2double(cData.FirstSympYear);
        catch
            Demographics.YearDiagnosis (ii,1) = nan;
            Demographics.YearFirstSympt (ii,1) = nan;
            DemographicsError = [DemographicsError; cSub];
            
        end
    else
        DemographicsError = [DemographicsError; cSub];
        Demographics.YearDiagnosis (ii,1) = nan;
        Demographics.YearFirstSympt (ii,1) = nan;
    end
    
    % ----------------- End Algemeen
    %% ---------------- Start PD med
    cFile = fullfile(filedir, cSub, "Castor.Visit1.Demografische_vragenlijsten.Parkinson_medicatie");
    if exist (cFile, "file")
        cText = fileread (cFile);
        cData = jsondecode (cText);
        try
            cData_med = struct2table(cData.crf);
            Demographics.PD_med (ii,1) = str2double(cData_med.ParkinMedUser);
        catch
            Demographics.PD_med (ii,1) = nan;
            DemographicsError = [DemographicsError; cSub];
        end
    else
        Demographics.PD_med (ii,1) = nan;
        DemographicsError = [DemographicsError; cSub];
    end
    
    % ----------------- End PD Med
    %% ---------------- Start MRIdata
    cFile = fullfile(filedir, cSub, "Castor.Visit1.Checklist_metingen_en_bloeddruk.Checklist_metingen_buiten_Castor");
    if exist (cFile, "file")
        cText = fileread (cFile);
        cData = jsondecode (cText);
        try
            cData = struct2table(cData.crf);
            Demographics.MriNeuroPsychTask (ii,1) = str2double(cData.MriNeuroPsychTask);
            Demographics.MriMoment {ii,1} = cData.MriMoment;
        catch
            Demographics.MriMoment {ii,1} = nan;
            DemographicsError = [DemographicsError; cSub];
        end
    else
        Demographics.MriMoment {ii,1} = nan;
        DemographicsError = [DemographicsError; cSub];
    end
    
end
% ----------------- End MRIdata

% ---------------- Start calculating the disease duration and years with
% symptoms. 
for ind = 1:length(Demographics.MriMoment)
    moment   = Demographics.MriMoment{ind};
    try
        moment = str2double(moment(end-3:end));
        MRI_year(ind) = moment;
    catch
        MRI_year(ind) = nan;
    end
end

Demographics.MRI_year = MRI_year; 
Demographics.DiseaseDuration  = MRI_year'- Demographics.YearDiagnosis;
Demographics.YearsWithSympt = MRI_year'- Demographics.YearFirstSympt;

% ---------------- end
    
end