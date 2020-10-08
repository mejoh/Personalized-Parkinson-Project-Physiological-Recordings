function STAIout = ScoreSTAI(cFile1, cFile2)
%% Part 1
%Data formatting
cText1 = fileread (cFile1);
cData1 = jsondecode (cText1);
cData1 = struct2table(cData1.crf);

% Calc SubScore part 1
subScore1 = 0;
for cQuestion = [ "01","03","06","07","10","14","15", "16","19"]
    if cData1.(strcat("StaiTrait", cQuestion)) == '4'
        subScore1 = subScore1 +1;
    elseif cData1.(strcat("StaiTrait", cQuestion)) == '3'
        subScore1 = subScore1 +2;
    elseif cData1.(strcat("StaiTrait", cQuestion)) == '2'
        subScore1 = subScore1 +3;
    elseif cData1.(strcat("StaiTrait", cQuestion)) == '1'
        subScore1 = subScore1 + 4;
    end
end
for cQuestion = ["02","04","05","08","09","11","12","17","18","20"]
    subScore1 = subScore1 + str2num (cData1.(strcat("StaiTrait", cQuestion)));
end

%Save 
STAIout.Part1.SubScore = subScore1;
STAIout.Part1.File = cFile1;
STAIout.Part1.rawData = cText1;

%% Part 2
%Data formatting
cText2 = fileread (cFile2);
cData2 = jsondecode (cText2);
cData2 = struct2table(cData2.crf);

% Calc SubScore part 2
subScore2 = 0 ;
for cQuestion = [ "01","02","05","08","11","15","16", "19","20"]
    if cData2.(strcat("StaiState", cQuestion)) == '4'
        subScore2 = subScore2 +1;
    elseif cData2.(strcat("StaiState", cQuestion)) == '3'
        subScore2 = subScore2 +2;
    elseif cData2.(strcat("StaiState", cQuestion)) == '2'
        subScore2 = subScore2 +3;
    elseif cData2.(strcat("StaiState", cQuestion)) == '1'
        
        subScore2 = subScore2 + 4;
    end
end
for cQuestion = ["03","04","06","07","09","10", "12","13","14","17","18"]
    subScore2 = subScore2 + str2num (cData2.(strcat("StaiState", cQuestion)));
end

%Save output
STAIout.Part2.SubScore = subScore2;
STAIout.Part2.File = cFile2;
STAIout.Part2.rawData = cText2;

%TotalScore
STAIout.TotalScore = subScore2 + subScore1;
end
