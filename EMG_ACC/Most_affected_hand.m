function AffectedSide = Most_affected_hand (subject)
% Find most affected side using task files

if contains (subject, "POM") 
    sbjct.taskdir = dir(char((strcat('/project/3022026.01/DataTask/*', subject, '*'))));
elseif contains (subject, "PIT")
    sbjct.taskdir = dir(char((strcat('/project/3024006.01/task_data/reward/*', subject, '*'))));
end

if any(contains({sbjct.taskdir.name},"Right"))
    AffectedSide = 'Right';
elseif any(contains({sbjct.taskdir.name},"Left"))
    AffectedSide = 'Left';
end

end
