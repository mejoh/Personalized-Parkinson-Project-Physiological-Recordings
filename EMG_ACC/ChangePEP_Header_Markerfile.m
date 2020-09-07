% This script provides an easy fix/debugging for the differences between the PEP EEG header and marker files. This script must be run after ChangeMarkersAllSubs.
% ChangeChannels changes the way in which the channels are saved in the header file. 
% ChangeDoubleResponse: after running ChangeMarkersAllSubs, response was listed twice in each row. This part allows to remove one "Response". This way, it is possible to use the files for FARM correction. 


%%ToDo

ChangeChannels          = false;
ChangeDoubleResponse    = true;


%% start 

if ChangeChannels
    
    cDir = '/project/3022026.01/analyses/tessa/Test/correction_markerfiles/reward/' ;
    AllFiles = dir ('/project/3022026.01/analyses/tessa/Test/correction_markerfiles/reward/sub-*eeg.vhdr');
    FilesTable = struct2table(AllFiles);
    for ind = 1:size(AllFiles,1)
        cFile = fullfile(cDir, FilesTable.name {ind});
        
        if ~exist (strrep (cFile, "reward_eeg", "reward_eeg_old"), 'file')
            copyfile (cFile, strrep (cFile, "reward_eeg", "reward_eeg_old"));
        end
        
        cData = fopen(cFile);
        for cLine = 1:24
            OldLine = string(fgetl(cData));
            newLine = strrep(OldLine, "Ch1=extensor_right_arm,,1", "Ch1=1,,10,ÂµV");
            newLine = strrep(newLine, "Ch1=flexor_right_arm,,1", "Ch2=2,,10,ÂµV");
            newLine = strrep(newLine, "Ch1=extensor_left_arm,,1", "Ch3=3,,10,ÂµV");
            newLine = strrep(newLine, "Ch1=flexor_left_arm,,1", "Ch4=4,,10,ÂµV");
            newLine = strrep(newLine, "Ch1=pulse_sensor,,1", "Ch5=9,,152.6,ÂµV");
            newLine = strrep(newLine, "Ch1=respiration_sensor,,1", "Ch6=10,,152.6,ÂµV");
            newLine = strrep(newLine, "Ch1=accelerometer_x,,1", "Ch7=11,,152.6,ÂµV");
            newLine = strrep(newLine, "Ch1=accelerometer_y,,1", "Ch8=12,,152.6,ÂµV");
            newLine = strrep(newLine, "Ch1=accelerometer_z,,1", "Ch9=13,,152.6,ÂµV");
            header(cLine)= newLine;
        end
        header = header';
        fclose(cData);
        cHeaderFile = fopen(cFile, 'w+');        % open and destory content
        
        for cLine = 1:24
            fprintf(cHeaderFile, strcat(header(cLine), "\r\n"));
        end
        
        fclose(cHeaderFile); %close
    end
end


if ChangeDoubleResponse
    cDir = '/project/3022026.01/analyses/tessa/Test/correction_markerfiles/reward/';
    AllFiles = dir ('/project/3022026.01/analyses/tessa/Test/correction_markerfiles/reward/sub-*eeg.vmrk');
    FilesTable = struct2table(AllFiles);
    for ind = 1:size(AllFiles,1)
        cFile = fullfile(cDir, FilesTable.name {ind});
        
        if ~exist (strrep (cFile, "reward_eeg", "reward_eeg_old"), 'file')
            copyfile (cFile, strrep (cFile, "reward_eeg", "reward_eeg_old"));
        end
        
        cData = fopen(cFile);
        
        for cLine = 1:300
            OldLine = string(fgetl(cData));
            newLine = strrep(OldLine, "Response,Response,R ", "Response,R ");
            newLine = strrep(newLine, "R 1", "R  1"); 
            newLine = strrep(newLine, "-1", "") ; 
            header(cLine)= newLine;
        end
        header = header';
        fclose(cData);
        cHeaderFile = fopen(cFile, 'w+');        % open and destory content
        
        for cLine = 1:300
            fprintf(cHeaderFile, strcat(header(cLine), "\r\n"));
        end
        
        fclose(cHeaderFile); %close
    end

end 

