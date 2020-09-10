function [QUIPRS, QUIPRSError] = ScoresImpulseControl (Subs, filedir)
% This function lists the demographics part1 of each subject and Visit1.
% Note the reports are not loaded, if you are interested in further
% information some parts then a report might be available (especially in cData2)
% In that case, study the raw data!


QUIPRSError = [];

for ii = 1:length(Subs)
    cSub = Subs{ii};
    %% ---------------- Start Age and Gender
    QUIP_RS = "Castor.HomeQuestionnaires1.04_Vragenlijst_stoornissen_in_de_impulscontrole_bij_de_ziekte_van_Parkinson_QUIPRS.";
    
    cFile1 = fullfile(filedir, cSub, strcat(QUIP_RS, "Voortzetten_van_gedrag"));
    cFile2 = fullfile(filedir, cSub, strcat(QUIP_RS, "Denken_aan_gedragingen"));
    cFile3 = fullfile(filedir, cSub, strcat(QUIP_RS, "Controle_over_gedragingen"));
    cFile4 = fullfile(filedir, cSub, strcat(QUIP_RS, "Aandrang_of_verlangen"));
    % Check if file exists
    
    try
        cText1 = fileread (cFile1);
        cData1 = jsondecode (cText1);
        cText2 = fileread (cFile2);
        cData2 = jsondecode (cText2);
        cText3 = fileread (cFile3);
        cData3 = jsondecode (cText3);
        cText4 = fileread (cFile4);
        cData4 = jsondecode (cText4);
        
        
        cData1 = struct2table(cData1.crf);
        cData2 = struct2table(cData2.crf);
        cData3 = struct2table(cData3.crf);
        cData4 = struct2table(cData4.crf);
        cData = [cData1, cData2, cData3, cData4];
        
        %% Why does 07 not exist????
        
        QUIPRS.Score(ii) = 0
        
        for cQuestion = ["01", "02", "03", "04", "05", "06", "08", "09", "10", ...
                "11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28"]
            QUIPRS.Score(ii) = QUIPRS.Score(ii) + str2num(cData.(strcat("QuipIt", cQuestion)));
        end
        
    catch
       QUIPRSError = [QUIPRSError; cSub];

    end
    
end
end

