% deze functie gaat alle emg 'trctomatlabben'
% input pp='1000', of iets anders
% hij gaat dan de files.txt lezen in de 'ruw' folder en de magie zelf doen.
% 
% function batch_emg_to_mat(study,pp)


function batch_emg_to_mat(study,pp)


% keyboard;

ruwDir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/Lopend_onderzoek/fMRI/' study '/ruw/' pp '/'];%ruwDir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/fMRI/' study '/ruw/' pp '/'];
cd(ruwDir);
pwd
fid=fopen([ruwDir 'files.txt']);

while ~feof(fid)
    line=fgetl(fid);
    regexp(line,'[^\s]*','match');
   
    

    
    if strcmp(regexp(line,'^REC','match'),'REC')
        
        parts=regexp(line,'[^\s]*','match');
        % dus als er idd een '.TRC' staat...
        if regexp(parts{5},'\.TRC')>0

            filename=parts{5};
            task=parts{3};
            disp([filename ' ' pp ' ' task]);
            
            % deze maakt dus een emg.mat file.
            trctomatlab([ruwDir 'trc/' filename]);
            
            % dir is de destination.
            destDir=[ruwDir '../../pp/' pp '/' task '/emg/'];
            if ~isdir(destDir);mkdir(destDir);end
            disp(destDir)
            
            % en nu ff de # volumes checken.
            disp('checking the # of volumes...');
            load([destDir '../parameters']);

            load emg.mat
            
            try
            
                % nog ff de tr dubbel-checken...
                tr=mean(([EEG.event(2:end).latency]-[EEG.event(1:end-1).latency])/EEG.srate);
                disp(['according to your EMG trace, the tr is ... ' num2str(tr)]);
                disp(['according to your PAR file, the tr is .... ' num2str(parameters(1))]);



%                 % check of het # slicetriggers > # volumes
%                 while(numel(EEG.event)>parameters(3))
%                     disp('too many scans... compensating...');
%                     disp(['removing EEG event ' num2str(numel(EEG.event)) '...']);
%                     EEG.event(end)=[];
%                 end


                % ideally, this will never happen...
                % the EMG trace is too short! (this is the translation of the
                % next line...
                if(size(EEG.data,2)-EEG.event(1).latency)/EEG.srate-parameters(1)*parameters(3)<0

                    % remedy: kill last event
                    EEG.event(end).latency=[];

                    % set parameters 3 to the # of volumes in the EMG ... and
                    % save.
                    parameters(3)=numel(EEG.event);                
                    save([destDir '../parameters'],'parameters','-ascii');
                    disp('ohno! -- emg computer shutdown before stop of scan...');
                    disp('compensating...');

                end
                
            catch
                disp('check failed ... written report in EEG.alert.');
                EEG.alert='check failed: are there any volume triggers?';
            end
            
            
            disp(parameters);
            
            %-------------------------------------------
            % 2009-11-07: paul filled some header fields 
            EEG.comments    = EEG.setname;
            EEG.setname     = [pp ', ' task, ', raw emg'];
            EEG.filename    = 'emg.mat';
            EEG.filepath    = destDir;
            EEG.subject     = pp;
            EEG.condition   = task;
            %-------------------------------------------
            
            save emg.mat EEG
            
            
            % en dan nu de emg.mat 'moven'...
            movefile('emg.mat',[destDir '.']);
            
            
        end
   end
        
        

    if strcmp(regexp(line,'^emg_nofield','match'),'emg_nofield')


        % keyboard;
        parts=regexp(line,'[^\s]*','match');
        filename=parts{5};
        task=parts{3};

        destDir=[ruwDir '../../pp/' pp '/' task '/emg/'];
        if ~isdir(destDir);mkdir(destDir);end
        trctomatlab([ruwDir 'trc/' filename]);
        movefile('emg.mat',[destDir 'emg_nofield.mat']);

    end



    if strcmp(regexp(line,'^emg_prescan','match'),'emg_prescan')

        parts=regexp(line,'[^\s]*','match');
        filename=parts{5};
        task=parts{3};

        destDir=[ruwDir '../../pp/' pp '/' task '/emg/'];
        if ~isdir(destDir);mkdir(destDir);end
        trctomatlab([ruwDir 'trc/' filename]);
        movefile('emg.mat',[destDir 'emg_prescan.mat']);

    end


% emg_nofield	1009	motor_tappen	xx		EEG_366.TRC		xx
% emg_nofield	1009	motor_nadoen	xx		EEG_367.TRC		xx
% emg_prescan	1009	motor_tappen	xx		EEG_369.TRC		xx
% emg_prescan	1009	motor_nadoen	xx		EEG_372.TRC		xx

end


muscles=read_channels_file([ruwDir 'channels.txt']);
save([ruwDir '../../pp/' pp '/muscles.mat'],'muscles');


    

fclose(fid);
