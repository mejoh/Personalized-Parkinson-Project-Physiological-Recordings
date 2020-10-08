%TODO
%Get current setup to work

%Load in the conversion table
cConversionFile = fullfile("P:", "3022026.01", "scripts", "jortic", "LEDD_conversion_factors.xlsx");
cConversionTable = readtable(cConversionFile);
cConversionTable.mgRelfecting100mgL_dopa = str2double(cConversionTable.mgRelfecting100mgL_dopa);
cConversionTable.ConversionFactor_LEDD = str2double(cConversionTable.ConversionFactor_LEDD);

%Retrieve subs and initiate table and struct 
subTable = getSubjects("PEP");
numberOfSubjects = size(subTable, 1);
demographicsTable = table('size', [numberOfSubjects, 18], ...
    'VariableTypes', ["double", "double", "cell", "double", "string", "double", "double", "double", "string", "double", "string", "double", "double", "double", "double", "double", "double", "double"], ...
    'VariableNames', ["LEDD", "medUser", "Med_Class", "BDI", "BDI_classification", "ApathyScale", "QUIPRS", "Age", "Gender", "isPD", "CSFpresent", "YearsSinceDiagnosis", "YearsSinceSymptoms", "HandY_ON", "HandY_OFF", "STAI", "UPDRS3_ON", "UPDRS3_OFF"]);
subjects = struct(); 

%Go over all subjects
cCounter = 0;
for cSub = subTable.SubjectNumber'
    cCounter = cCounter + 1; 
    disp(strcat(string(cCounter), "/", string(numberOfSubjects), " currently processing: ", cSub, "..."));
    [clinometricStruct, clinometricTable] = retrieveClinometrics(cSub, cConversionTable);
    demographicsTable(cCounter, :) = clinometricTable; 
    subjects.(cSub) = clinometricStruct.(cSub);     
end