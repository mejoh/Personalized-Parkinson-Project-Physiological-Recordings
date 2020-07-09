% sample files.txt file:
%
% survey	1001	survey			DBIEX_1_1.REC	xx				xx
% REC		1001	gonogo1			DBIEX_3_1.REC	EEG_108.TRC		gonogo_new20.log
% REC		1001	motor_tappen	DBIEX_5_1.REC	EEG_109.TRC     motor
% REC		1001	gonogo2			DBIEX_6_1.REC	EEG_110.TRC		gonogo_new21.log
% REC		1001	motor_nadoen	DBIEX_8_1.REC	EEG_112.TRC     motor
% REC		1001	gonogo3			DBIEX_9_1.REC	EEG_113.TRC		gonogo_new22.log	
% REC		1001	motor_nadoen2	DBIEX_10_1.REC	EEG_114.TRC     motor
% REC		1001	reward1			DBIEX_11_1.REC	EEG_115.TRC		1001_reward_1.txt
% REC		1001	reward2			DBIEX_12_1.REC	EEG_116.TRC		1001_reward_2.txt
% b0		1001	b0				DBIEX_1_1.REC	xx				xx
% t1  	1001	t1                  xx				xx				xx
%
%
% deze functie heeft dus een files.txt nodig in de ruw directory.
% hij leest de 6e kolom. Als er geen 'xx' staat, dan gaat ie wat doen.
%
% function batch_log_to_mat(study,pp)
% 
function batch_log_to_mat(study,pp)

ruwDir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/Lopend_onderzoek/fMRI/' study '/ruw/' pp '/log/'];


if isdir(ruwDir)
    cd(ruwDir);
end
pwd;

% keyboard;
fid=fopen([ruwDir '../files.txt']);

while ~feof(fid)
    line=fgetl(fid);

    if ~numel(regexp(line,'^#'))&&numel(line)>0 % allow for comments in filex.txt file.

        parts=regexp(line,'[^\s]*','match');
        % dus als er idd een '.TRC' staat...
        if ~strcmp(parts{6},'xx')

            filename=parts{6};
            task=parts{3};
            % disp(sprintf(['\n\n' filename ' ' pp ' ' task]));

            destDir=[regexprep(pwd, '(^.*)(Onderzoek.*)', '$1') 'Onderzoek/Lopend_onderzoek/fMRI/' study '/pp/' pp '/' task '/regressor/'];
            if ~isdir(destDir);mkdir(destDir);end
            load([destDir '../parameters']);
            tr=parameters(1);
            nvol=parameters(3);

            files={};




            if numel(regexp(filename,'tremor1'))>0


                disp(sprintf('building motor block models.\n---\n'));
                % net zoals alle andere conversion dingen, stop deze
                % functie de .mat files gelijk op de juiste plek.
                files{1}=build_block_models(filename,tr);

            end

            disp(filename)
            if numel(regexp(filename,'tremor2'))>0


                disp(sprintf('building tremor block models.\n---\n'));
                % net zoals alle andere conversion dingen, stop deze
                % functie de .mat files gelijk op de juiste plek.
                files{1}=build_block_models(filename,tr);

            end

            disp(filename)
            if numel(regexp(filename,'tapping'))>0


                disp(sprintf('building tremor block models.\n---\n'));
                % net zoals alle andere conversion dingen, stop deze
                % functie de .mat files gelijk op de juiste plek.
                files{1}=build_block_models(filename,tr);

            end
            
            disp(filename)
            if numel(regexp(filename,'wijzen'))>0


                disp(sprintf('building tremor block models.\n---\n'));
                % net zoals alle andere conversion dingen, stop deze
                % functie de .mat files gelijk op de juiste plek.
                files{1}=build_block_models(filename,tr);

            end            
            %if numel(regexp(filename,'tapping'))>0


                %disp(sprintf('building tremor block models.\n---\n'));
                % net zoals alle andere conversion dingen, stop deze
                % functie de .mat files gelijk op de juiste plek.
                %warning('conversion:gonogo','gonogo conversion not yet implemented.');
                %disp('Building Block Model...');
                %files{1}=build_block_models(filename,tr);

            %end



            %if numel(regexp(filename,'reward'))>0

                %disp(sprintf('deciphering reward task event data.\n---\n'));
                %files{1}=reward_crawler([ruwDir filename]);

            %end




            if numel(regexp(filename,'tol'))>0


            end      




            % application of scanning-time contraint, and.. move it to the
            % right directory.
            for i=1:numel(files)

                clear names onsets durations
                load(files{i});
                disp(['now adjusting ' files{i} ' to obey scanner Time...']);
                [onsets durations]=apply_scanTime_contraint(onsets,durations,nvol*tr);
                save(files{i},'names','onsets','durations');

                movefile(files{i},[destDir '.']);

            end
        
        
        end


    end
end


fclose(fid);
