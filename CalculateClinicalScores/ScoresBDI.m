function [BDIScore, BDIError] = ScoresBDI (filedir, Subs)
BDIError = [];

BDIScore.Classification.minimal = [];
BDIScore.Classification.light = [];
BDIScore.Classification.moderate = [];
BDIScore.Classification.severe = [];

% ---- calculates sum BDI score for each individual
for ind = 1:length(Subs)
    cSub = Subs{ind} ;
    cFile = fullfile(filedir, cSub, "Castor.HomeQuestionnaires1.13_Stemming_BDI2.Stemming");
    if ~exist (cFile, 'file')
        BDIError = [BDIError; cSub];
        if sum(contains(cDir.name, "Visit1")) > 0
            BDIScore.PerSub.Visit1 (ind,1) = nan;
            
        else sum(contains(cDir.name, "Visit2")) > 0
            BDIScore.PerSub.Visit2 (ind,1) = nan;
        end
    else
        cText = fileread (cFile);
        cData = jsondecode (cText);
        try
            cData = struct2table(cData.crf);
            cDir = struct2table(dir (fullfile(filedir, cSub)));
            BDITotal = sum([str2double(cData.Bdi2It01), str2double(cData.Bdi2It01), ...
                str2double(cData.Bdi2It01), str2double(cData.Bdi2It02), str2double(cData.Bdi2It03), ...
                str2double(cData.Bdi2It04), str2double(cData.Bdi2It05), str2double(cData.Bdi2It06), ...
                str2double(cData.Bdi2It07), str2double(cData.Bdi2It08), str2double(cData.Bdi2It09), ...
                str2double(cData.Bdi2It10), str2double(cData.Bdi2It11), str2double(cData.Bdi2It12), ...
                str2double(cData.Bdi2It13), str2double(cData.Bdi2It14), str2double(cData.Bdi2It15), ...
                str2double(cData.Bdi2It16), str2double(cData.Bdi2It17), str2double(cData.Bdi2It18), ...
                str2double(cData.Bdi2It19), str2double(cData.Bdi2It20), str2double(cData.Bdi2It21)]);
            
            if sum(contains(cDir.name, "Visit1")) > 0
                BDIScore.PerSub.Visit1 (ind,1) = BDITotal;
                
            else sum(contains(cDir.name, "Visit2")) > 0
                BDIScore.PerSub.Visit2 (ind,1) = BDITotal;
            end
            
            if BDITotal <14
                BDIScore.Classification.minimal = [BDIScore.Classification.minimal; cSub];
            elseif BDITotal>13 && BDITotal<20
                BDIScore.Classification.light = [BDIScore.Classification.light; cSub];
            elseif BDITotal>19 && BDITotal<29
                BDIScore.Classification.moderate = [BDIScore.Classification.moderate; cSub];
            elseif BDITotal>28
                BDIScore.Classification.severe = [BDIScore.Classification.severe; cSub];
            end
            
        catch
            BDIError = [BDIError; cSub];
            if sum(contains(cDir.name, "Visit1")) > 0
                BDIScore.PerSub.Visit1 (ind,1) = nan;
                
            else sum(contains(cDir.name, "Visit2")) > 0
                BDIScore.PerSub.Visit2 (ind,1) = nan;
            end
        end
    end
end


end

