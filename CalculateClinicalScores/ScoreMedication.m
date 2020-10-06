%In order to use this function, you need a conversionTable, add the
%following code, to where you call the function or make your own;) 
%Load in the conversion table
% cConversionFile = fullfile("P:", "3022026.01", "scripts", "jortic", "LEDD_conversion_factors.xlsx");
% cConversionTable = readtable(cConversionFile);
% cConversionTable.mgRelfecting100mgL_dopa = str2double(cConversionTable.mgRelfecting100mgL_dopa);
% cConversionTable.ConversionFactor_LEDD = str2double(cConversionTable.ConversionFactor_LEDD);

function MEDout = ScoreMedication(cFile, cConversionTable)
cSubText = textscan(fopen(cFile), '%s');
cSubJson = jsondecode(string(cSubText));

%Check if patient is on medication
if strcmp(cSubJson.crf.ParkinMedUser, '1')
    
    %If report is still empty, give warning and skip subject
    if isempty(cSubJson.reports)
        warning(strcat("Empty report but is marked as med user for sub: ", cFile));
        MEDout.medUser = false;
        MEDout.LEDD = 0;
        MEDout.rawData = cSubText;
        MEDout.medicationTable = missing;
        return
    end
    
    %Find medications & and remove empty names
    cMeds = str2double({cSubJson.reports.MedicatieParkinson.MediName});
    cMedsTimesPerDay = str2double({cSubJson.reports.MedicatieParkinson.MedTimesDaily});
    
    %Remove meds without name
    removeMed = isnan(cMeds);
    cMeds = cMeds(~removeMed);
    cMedsTimesPerDay = cMedsTimesPerDay(~removeMed);
    if sum(removeMed)>0; warning(strcat("Removed medication without name for: ", cFile)); end
    
    %Loop through each medication to get a good overview
    medication=table('size', [0 10], ...
        'VariableTypes', ["double", "string", "string", "double", "double", "string", "double", "double", "double", "double"], ...
        'VariableNames', ["Medication_Number", "Medication_Name", "Medication_Class", "Number_of_components", "Component_Number", "Component_Name", "Total_Doses", "Dose", "Amount", "LED"]);
    for cMedCounter = 1:size(cMeds,2)
        %Find data for the medication
        cMedNumber = cMeds(cMedCounter);
        cMedName = string(cConversionTable.Medication_Name(cMedNumber));
        cMedComponents = cConversionTable.Components(cMedNumber);
        cMedTimesPerDay = cMedsTimesPerDay(cMedCounter);
        cMedClass = cConversionTable.Classification(cMedNumber);
        
        %Find all doses (CHANGE TO TABLE)
        cRowCounter = 0;
        for cComponent = 1:cMedComponents
            cComponent_Name = string(cConversionTable{cMedNumber, strcat("Comp_Name_", string(cComponent))});
            for cMedTime = 1:cMedTimesPerDay
                cRowCounter = cRowCounter + 1;
                
                %Retrieve Dose
                cFieldName = strcat("MedDosis", string(cMedTime), string(cComponent));
                cDosis = str2double({cSubJson.reports.MedicatieParkinson.(cFieldName)});
                cDosis = cDosis(~removeMed); %Remove dosis with NaN med name
                cDosis = cDosis(cMedCounter); %Get only dosis of current Medication
                
                %Calculate LDD if first component
                if cComponent == 1
                    cConversionFactor = cConversionTable.ConversionFactor_LEDD(cMedNumber);
                    if isnan(cConversionFactor)
                        cLED = 0; %If there is no conversion number, LED does not have to be calculated (see conversiontable notes)
                    else
                        cLED = cConversionFactor * cDosis;
                    end
                else
                    cLED = 0; %The second component of medication does not need to be translated
                end
                
                %Save to struct and convert to table
                cDose.Medication_Number = cMedNumber;
                cDose.Medication_Name = cMedName;
                cDose.Medication_Class = cMedClass;
                cDose.Number_of_components = cMedComponents;
                cDose.Component_Number = cComponent;
                cDose.Component_Name = cComponent_Name;
                cDose.Total_Doses = cMedTimesPerDay;
                cDose.Dose = cMedTime;
                cDose.Amount = cDosis;
                cDose.LED = cLED;
                medication = [medication; struct2table(cDose)];
            end
        end
    end
    
    %Save output
    medUser = true;
    LEDD = sum(medication.LED);
    rawData = cSubText;
    medicationTable = medication;
    
else %No medication
    %Save output
    medUser = false;
    LEDD = 0;
    rawData = cSubText;
    medicationTable = missing;
end

MEDout.medUser = medUser; 
MEDout.LEDD = LEDD; 
MEDout.rawData = rawData; 
MEDout.medicationTable = medicationTable; 
end