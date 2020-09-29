function [ApathyScaleScore, ApathyScaleError] = ScoreApathyScale (Subs, filedir)
%% Subject level
ApathyScaleError = [];
for ind = 1:length(Subs)
    cSub = Subs{ind};
    try
        ApathyScaleScore(ind) = 0;
        cFile = fullfile(filedir, cSub, "Castor.HomeQuestionnaires1.05_Apathieschaal.Apathie");
        cText = fileread (cFile);
        cData = jsondecode (cText);
        cData = struct2table(cData.crf);
        
        for cQuestion = ["01","02","03","04","05","06","07", ...
                "08","09","10","11","12","13","14" ]
            ApathyScaleScore (ind) = ApathyScaleScore (ind) + str2num(cData.(strcat("Apat", cQuestion))) ;
        end
        
    catch
        ApathyScaleScore (ind) =  nan;
        ApathyScaleError = [ApathyScaleError;  cSub];
    end
end
end

