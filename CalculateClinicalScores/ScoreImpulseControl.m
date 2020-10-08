function QUIPout = ScoresImpulseControl (cQuipFiles)
%Loop through the four files and analyse them 

for cFileCounter = 1:4
    %Load data
    cFileName = strcat("file", string(cFileCounter));
    cFile = cQuipFiles.(cFileName); 
    cText = fileread(cFile); 
    cData = jsondecode (cText); 
    cDataTable = struct2table(cData.crf);
    
    %Calculate score 
    for cVar = ["QuipWho", "QuipCsiPos", "QuipCag"]; 
        if contains(cVar, string(cDataTable.Properties.VariableNames))
            cDataTable = removevars(cDataTable, cVar); 
        end
    end
    cScore = sum(str2double(table2cell(cDataTable)));
   
    %Save 
    QUIPout.(strcat("Part", string(cFileCounter))).File = cFile; 
    QUIPout.(strcat("Part", string(cFileCounter))).rawData = cData; 
    QUIPout.(strcat("Part", string(cFileCounter))).SubScore = cScore; 
end 

%Combine all subscores
QUIPout.TotalScore = sum([QUIPout.Part1.SubScore, QUIPout.Part2.SubScore, QUIPout.Part3.SubScore, QUIPout.Part4.SubScore]); 
end

