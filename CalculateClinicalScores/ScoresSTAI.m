%%  STAI (angst) en naar de apathy scale
function [STAIScore, STAIError] = ScoresSTAI (filedir, Subs)

STAIError = [];

STAIScore.Classification.Low = [];
STAIScore.Classification.Moderate = [];
STAIScore.Classification.High = [];

% ---- calculates sum BDI score for each individual
for ind = 1:length(Subs)
    cSub = Subs{ind} ;
    cDir = fullfile(filedir, cSub);
    cFile1 = fullfile(filedir, cSub, "Castor.HomeQuestionnaires1.06_Zelfbeoordeling_STAI.Dispositie_Trait");
    cFile2 = fullfile(filedir, cSub, "Castor.HomeQuestionnaires1.06_Zelfbeoordeling_STAI.Toestand_State") ;
    if ~exist (cFile1, 'file') || ~exist (cFile2, 'file')
        STAIError = [STAIError; cSub];
    else
        cText1 = fileread (cFile1);
        cData1 = jsondecode (cText1);
        cText2 = fileread (cFile2);
        cData2 = jsondecode (cText2);
        try
        cData1 = struct2table(cData1.crf);
        cData2 = struct2table(cData2.crf);
            % Calc part 1
            Score = 0;
            for cQuestion = [ "01","03","06","07","10","14","15", "16","19"]
                if cData1.(strcat("StaiTrait", cQuestion)) == '4'
                    Score = Score +1;
                elseif cData1.(strcat("StaiTrait", cQuestion)) == '3'
                    Score = Score +2;
                elseif cData1.(strcat("StaiTrait", cQuestion)) == '2'
                    Score = Score +3;
                elseif cData1.(strcat("StaiTrait", cQuestion)) == '1'
                    
                    Score = Score + 4;
                end
            end
            
            
            for cQuestion = ["02","04","05","08","09","11","12","17","18","20"]
                Score = Score + str2num (cData1.(strcat("StaiTrait", cQuestion)));
            end
            STAIScore.Dispositie_Trait(ind) = Score;
            
            % Calc part 2
            Score = 0 ;
            
            for cQuestion = [ "01","02","05","08","11","15","16", "19","20"]
                if cData2.(strcat("StaiState", cQuestion)) == '4'
                    Score = Score +1;
                elseif cData2.(strcat("StaiState", cQuestion)) == '3'
                    Score = Score +2;
                elseif cData2.(strcat("StaiState", cQuestion)) == '2'
                    Score = Score +3;
                elseif cData2.(strcat("StaiState", cQuestion)) == '1'
                    
                    Score = Score + 4;
                end
            end
            
            
            for cQuestion = ["03","04","06","07","09","10", "12","13","14","17","18"]
                Score = Score + str2num (cData2.(strcat("StaiState", cQuestion)));
            end
            STAIScore.Toestand_State(ind) = Score;
            STAIScore.Total(ind) = STAIScore.Dispositie_Trait(ind) + STAIScore.Toestand_State(ind);
        catch
            STAIScore.Dispositie_Trait(ind) =  nan;
            STAIScore.Toestand_State(ind) = nan;
            STAIScore.Total(ind) = nan;
        end
    end
    
end



end
