function GENout = ScoreMotorOffGeneral(cFile)
%Format Data
cText = fileread (cFile);
cData = jsondecode (cText);
cData = struct2table(cData.crf);

%Get Date of first diagnosis
if ~any(strcmp('DiagParkDay',cData.Properties.VariableNames)) || contains(cFile, "sub-POMU1AF190923B4BD2D0") || contains(cFile, "sub-POMUB049991CAC0835C7") || contains(cFile, "sub-POMUB8AACCD35D0C861C") || contains(cFile, "sub-POMUD2FD255D3A4156D4")
    DateDiagnosis = strcat(cData.DiagParkMonth, "-", cData.DiagParkYear);
    GENout.DiagParkDate = datetime(DateDiagnosis,'InputFormat','MM-yyyy');
    warning(strcat("No DiagParkDay variable in file: ", cFile));
else
    DateDiagnosis = strcat(cData.DiagParkDay, "-", cData.DiagParkMonth, "-", cData.DiagParkYear);
    GENout.DiagParkDate = datetime(DateDiagnosis,'InputFormat','dd-MM-yyyy');
end


%Most affected side
switch cData.MostAffSide
    case '1'
        GENout.MostAffSide= "One-sided right";
    case '2'
        GENout.MostAffSide= "One-sided left";
    case '3'
        GENout.MostAffSide= "Bilateral: right more than left";
    case '4'
        GENout.MostAffSide= "Bilateral: left more than right";
    case '5'
        GENout.MostAffSide= "Bilateral: left as much as right";
    case '6'
        GENout.MostAffSide= "No(ne)";
end

%Preferred hand
switch cData.PrefHand
    case '1'
        GENout.PrefHand= "Right-handed";
    case '2'
        GENout.PrefHand= "Left-handed";
    case '3'
        GENout.PrefHand= "No preferred hand";
end

%Preferred Leg
switch cData.PreferLeg
    case '1'
        GENout.PreferLeg= "Right-leg";
    case '2'
        GENout.PreferLeg= "Left-leg";
    case '3'
        GENout.PreferLeg= "No preferred leg";
end

%Year of first symptom
GENout.FirstSympYear = datetime(cData.FirstSympYear, 'InputFormat', 'yyyy', 'Format', 'yyyy');

%Source of diagnosis
%Most affected side
switch cData.MostAffSide
    case '1'
        GENout.MostAffSide= "One-sided right";
    case '2'
        GENout.MostAffSide= "One-sided left";
    case '3'
        GENout.MostAffSide= "Bilateral: right more than left";
    case '4'
        GENout.MostAffSide= "Bilateral: left more than right";
    case '5'
        GENout.MostAffSide= "Bilateral: left as much as right";
    case '6'
        GENout.MostAffSide= "No(ne)";
end

%Diagnosis
if ~strcmp(cData.DiagParkSource, '3') %If people are self-diagnosed, they will not have a diagnosis certainty
    switch cData.DiagParkCertain
        case '1'
            GENout.Diagnosis= "Parkinson?s Disease";
        case '2'
            GENout.Diagnosis= "Doubt about parkinson's";
        case '3'
            GENout.Diagnosis= "Parkinsonism";
        case '4'
            GENout.Diagnosis= "Doubt about parkinsonism";
        case '5'
            GENout.Diagnosis= "Neither parkinson's nor parkinsonism";
    end
else
    warning(strcat("We don't take have DiagParkCertain for file: ", cFile, " (Probably because of self diagnosis)"));
end

%Additional check for 1
if ~strcmp(cData.DiagParkSource, '3') %For safety reasons, people who don't have a diagnosis certainty at all, are not taken into account as PD
    if strcmp(cData.DiagParkCertain, '1')
        GENout.isPD = true;
    else
        GENout.isPD = false;
    end
else
    GENout.isPD = false;
end

%Source of diagnosis
switch cData.DiagParkSource
    case '1'
        GENout.Source_of_diagnosis= "Neurologist";
    case '2'
        GENout.Source_of_diagnosis= "General practitioner";
    case '3'
        GENout.Source_of_diagnosis= "Participant";
end

%Side the watch is worn
switch cData.WatchSide
    case '1'
        GENout.WatchSide= "Right";
    case '2'
        GENout.WatchSide= "Left";
end

%Walking AID
if cData.WalkingAid.x0; GENout.UseOfWalkingAid.NoWalkingAid = true;         else; GENout.GENout.UseOfWalkingAid.NoWalkingAid = false; end %nothing
if cData.WalkingAid.x1; GENout.UseOfWalkingAid.WalkingStick = true;         else; GENout.GENout.UseOfWalkingAid.WalkingStick = false; end %stick
if cData.WalkingAid.x2; GENout.UseOfWalkingAid.Crutches = true;             else; GENout.GENout.UseOfWalkingAid.Crutches = false; end %crutches
if cData.WalkingAid.x3; GENout.UseOfWalkingAid.WalkingFrame = true;         else; GENout.GENout.UseOfWalkingAid.WalkingFrame = false; end %frame
if cData.WalkingAid.x4; GENout.UseOfWalkingAid.WalkerOrZimmerFrame = true;  else; GENout.GENout.UseOfWalkingAid.WalkerOrZimmerFrame = false; end %zimmer or frame
if cData.WalkingAid.x5; GENout.UseOfWalkingAid.WheelChair = true;           else; GENout.GENout.UseOfWalkingAid.WheelChair = false; end %wheelchair
if cData.WalkingAid.x6; GENout.UseOfWalkingAid.CanNotWalk = true;           else; GENout.GENout.UseOfWalkingAid.CanNotWalk = false; end %can't walk at all

%Return raw
GENout.File = cFile;
GENout.rawData = cText;
end