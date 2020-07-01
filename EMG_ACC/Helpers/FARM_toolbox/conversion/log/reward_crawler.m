% filename = '990x_reward_[123].txt
% scanTime = the total scanning time. This is the amount of functional data
% at your disposal (and it's not a good idea to break off a scan while the
% task is still running... this is why i built this one feature in.

%% lezen regels
function out=reward_crawler(filename)

    
    fid = fopen(filename);
    
    % lees de eerste regel; daar staat de filename van de edat file
    % edatfilename = fgetl(fid);

    % lees de tweede regel; daar staan de namen van de variabelen die we
    % gaan evallen...
    column_line = fgetl(fid);
    columnnames = textscan(column_line,'%s');
    columnnames = columnnames{1};
    
    % 'initialiseer' de variabelen waarvan de namen in de kolommen te
    % vinden zijn.
    for i=1:length(columnnames)
        
        % keyboard;
        
        % huishoudingsdingen in de columnnames:
        % haal de [] dingen weg; vervang '[' door '_' en ']' door '' anders
        % denkt matlab dat ik rare dingen (elementen van rijen) probeer aan
        % te roepen.
        columnnames{i} = strrep(columnnames{i},'[','_');
        columnnames{i} = strrep(columnnames{i},']','');
        
        % ik heb ook gemerkt dat ie structs niet-zo-fijn vindt... maak dus
        % alles naar underscores... ook de '.' in de filenames.
        columnnames{i} = strrep(columnnames{i},'.','_');

        
        
        % maak de 'lege' rijen; definieer de variabelen; anders geeft 
        % matlab de foutmelding 'maar die variabele die ken ik helemaal 
        % niet!!!'
        % we gaan 'cell' arrays maken...
        eval([columnnames{i} '= {};']);
    end
    

%% nu 2x fgetl(fid) doen, en dan in de 3e de onsettime 'distillen'

fgetl(fid);fgetl(fid);
line=fgetl(fid);

line_elements = textscan(line,'%s','delimiter','\t','emptyvalue',0);
line_elements = line_elements{1};

% grappige weergave.
% disp([columnnames(1:numel(line_elements)) num2cell((1:numel(line_elements))') line_elements]);

% where, o where... is the onset time??
ind=find(strcmp('Fix_OnsetTime',columnnames)==1);

log_OnsetTime=str2double(line_elements{ind})/1000;


    
%% nu alles inlezen...
    % lees de derde regel; daar staat hoelang de instructie duurt... hebben
    % we niet nodig verder
%   instructionperiod_line = fgetl(fid);
    
    
    % lees de rest van de regels...
    while ~feof(fid)
        line = fgetl(fid);
        
        % tabs geven de 'volgende' waardes aan; lege velden zijn gelijk aan
        % 0!
        line_elements = textscan(line,'%s','delimiter','\t','emptyvalue',0);
        line_elements = line_elements{1};
        
        % if line_elements == # columns, dan aan de slag gaan...
        % anders stoppen.
        
        if numel(line_elements)==numel(columnnames)


            % voor elke kolom: plak de data er achter/onder
            for i=1:length(columnnames)

                % genereer een txt string om te evaluaten met eval:
                % gebruik ook sprintf om de ' in de string te genereren...

                str = [''];
                str = [str columnnames{i}];
                str = [str ' = ['];
                str = [str columnnames{i}];
                str = [str ' {' sprintf('\''')];
                str = [str line_elements{i}];
                str = [str sprintf('\''') '}];'];

                eval(str);

            end
            
        end
        
            
    end
    
    fclose(fid);
    
    
%% bouwen van design matrix nu.

onsets={};
durations={};
names={'Anticipation_G3','Anticipation_G2','Anticipation_G1','Neutral','Anticipation_L1','Anticipation_L2','Anticipation_L3','Respond','Outcome_Positive','Outcome_Neutral','Outcome_Negative'};
    for i=1:numel(names)
        
        onsets{i} = [];
        durations{i} = [];
    end
    
%% dingetjes invullen

for i=1:numel(Trial)


    if numel(Cue_OnsetTime{i})>0&&numel(Tgt_OnsetTime{i})>0

        cueType=RunList{i};

        % what kind of feedback?
        feedbackType=Chng{i};


        % primer cues
        log_cueTime=str2num(Cue_OnsetTime{i})/1000 -log_OnsetTime;
        log_cueDuration=0.250+str2num(Delay{i})/1000;

        % buttor presses
        log_respondTime=str2num(Tgt_OnsetTime{i})/1000-log_OnsetTime;
        log_respondDuration=str2num(Tgt_RT{i})/1000;

        % errors
        % no error logging... this time (!)
        error=0;
%             if(log_respondDuration==0)
%                 error=1;
%             end

        % feedbacks
        log_feedbackTime=str2num(Fbk_OnsetTime{i})/1000-log_OnsetTime;
        log_feedbackDuration=1.650;

        % disp([error log_cueTime log_cueDuration log_respondTime log_respondDuration log_feedbackTime log_feedbackDuration]);


            switch error;

                % haal de fouten eruit
                case 1
                    onsets{12}(end+1)= log_respondTime;
                    durations{12}(end+1) = log_respondDuration;

                % en sorteer de goeden
                case 0

                    % voeg regel toe om t einde van een scansessie te
                    % maken...

                    disp([cueType ' ' num2str([log_cueTime log_cueDuration])]);

                    switch cueType

                        % Anticipation_G1
                        case '1'
                            onsets{3}(end+1)    = log_cueTime;
                            durations{3}(end+1) = log_cueDuration;

                        % Anticipation_G2
                        case '2'
                            onsets{2}(end+1)    = log_cueTime;
                            durations{2}(end+1) = log_cueDuration;

                        % Anticipation_G3
                        case '3'
                            onsets{1}(end+1)    = log_cueTime;
                            durations{1}(end+1) = log_cueDuration;

                        % Anticipation_L1
                        case '4'
                            onsets{5}(end+1) 	= log_cueTime;
                            durations{5}(end+1) = log_cueDuration;

                        % Anticipation_L2
                        case '5'
                            onsets{6}(end+1)    = log_cueTime;
                            durations{6}(end+1) = log_cueDuration;

                        % Anticipation_L3
                        case '6'
                            onsets{7}(end+1)    = log_cueTime;
                            durations{7}(end+1) = log_cueDuration;

                        % Neutral
                        case '7'
                            onsets{4}(end+1)    = log_cueTime;
                            durations{4}(end+1) = log_cueDuration;


                    end



                    switch feedbackType

                        % positive feedback
                        case '+'

                            onsets{9}(end+1)        = log_feedbackTime;
                            durations{9}(end+1)     = log_feedbackDuration;

                        % neutral feedback
                        case 'O'

                            onsets{10}(end+1)       = log_feedbackTime;
                            durations{10}(end+1)    = log_feedbackDuration;


                        % negative feedback
                        case '-'

                            onsets{11}(end+1)       = log_feedbackTime;
                            durations{11}(end+1)    = log_feedbackDuration;



                    end

                    onsets{8}(end+1)            = log_respondTime;
                    durations{8}(end+1)         = log_respondDuration;

            end



        end

end


%% for now... set all durations to 1.
for i=1:numel(onsets)
    for j=1:numel(onsets{i})
        durations{i}(j)=1;
    end
end




%% save
save event names onsets durations
out='event.mat';
% voor snelle hulp --        
% dingetjes                         RunList     Chng
%     [ 1]    'Anticipation_G3'     3
%     [ 2]    'Anticipation_G2'     2
%     [ 3]    'Anticipation_G1'     1
%     [ 4]    'Neutral'             7
%     [ 5]    'Anticipation_L1'     4
%     [ 6]    'Anticipation_L2'     5
%     [ 7]    'Anticipation_L3'     6
%     [ 8]    'Respond'                     
%     [ 9]    'Outcome_Positive'                +
%     [10]    'Outcome_Neutral'                 0
%     [11]    'Outcome_Negative'                -
%     [12]    'error'    




    
    

