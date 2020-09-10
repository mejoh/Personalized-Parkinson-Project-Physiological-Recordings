function [MocaScore, MocaError] = ScoresMoca (Subs, filedir)
MocaError = [];

%% Subject level
for ii = 1:length(Subs)
    cSub = Subs{ii};
  
    cFile = fullfile(filedir, cSub, "Castor.Visit1.Neuropsychologische_taken.MOCA");
    if exist (cFile, "file")
        cText = fileread (cFile);
        cData = jsondecode (cText);
        try
            cData = struct2table(cData.crf);
            SubScore(ii,1) = sum([str2double(cData.NpsMocVisExe), str2double(cData.NpsMocOrient), ...
                str2double(cData.NpsMocNaming), str2double(cData.NpsMocLangu1), str2double(cData.NpsMocLangu2), ...
                str2double(cData.NpsMocAtten2), str2double(cData.NpsMocAtten1), str2double(cData.NpsMocAtten3), ...
                str2double(cData.NpsMocDelRec), str2double(cData.NpsMocAbstra)])
            
            
            % NpsMocVisExe = total score of the visuo- executive domain.
            % NpsMocNaming = total score of the naming domain.
            % NpsMocOrient = total score of the orientation domain.
            % psMocAtten2 + NpsMocAtten1 + NpsMocAtten3 = total score of the
            % attention domain
            % NpsNpsMocLangu1 + NpsMocLangu2 = total score of the language
            % domain
            % NpsMocAbstra = total score of the abstrant domain.
            % NpsMocDelRec total score of the recall/memory domain
            
            if str2double(cData.NpsEducYears) <13
                SubScore(ii,1)= SubScore(ii,1) + 1;
            end
            if str2double(cData.NpsMocPhoFlu) >10
                SubScore(ii,1) = SubScore(ii,1) + 1;
            end
            
        catch
            MocaError = [MocaError; cSub];
            SubScore(ii,1) = nan;
            
        end
        
    else
        MocaError = [MocaError; cSub];
        SubScore(ii,1) = nan;
    end
MocaScore.SubScore = SubScore    ; 


% ------ End subject level

%% Start group level analysis

MocaScore.group.mean = nanmean(SubScore);
MocaScore.group.std = nanstd(SubScore);
MocaScore.group.min= min(SubScore);
MocaScore.group.max= max(SubScore);
MocaScore.group.missing= sum(isnan(SubScore));
MocaScore.group.nsubs = sum(~isnan(SubScore));

    
    
end


