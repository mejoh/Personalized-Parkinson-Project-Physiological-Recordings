%Load in the conversion table
cConversionFile = fullfile("P:", "3022026.01", "scripts", "jortic", "LEDD_conversion_factors.xlsx");
cConversionTable = readtable(cConversionFile);
cConversionTable.mgRelfecting100mgL_dopa = str2double(cConversionTable.mgRelfecting100mgL_dopa);
cConversionTable.ConversionFactor_LEDD = str2double(cConversionTable.ConversionFactor_LEDD);

%Loop through all subjects to retrieve the data
subTable = getSubjects("PEP");
MedicationForPEP = struct;
for cSub = subTable.SubjectNumber'
    cSubFile = fullfile("P:", "3022026.01", "pep", "ClinVars", strcat("sub-", cSub), "ses-Visit1", "Castor.Visit1.Demografische_vragenlijsten.Parkinson_medicatie.json");
    if exist(cSubFile, 'file')
        [medUser, LEDD, rawData, medicationTable] = ScoreMedication(cSubFile, cConversionTable);
        subjects.(cSub).Medication.medUser = medUser;
        subjects.(cSub).Medication.LEDD = LEDD;
        subjects.(cSub).Medication.rawData = rawData;
        subjects.(cSub).Medication.MedicationTable = medicationTable;
    else
        warning(strcat("No file for: ", cSub));
    end
end