% deze functe extraheert de design matrix uit de file 'filename'
% gebruik:
%
% [consets condur] = extractdesignmatrix(filename)
%
% construeer eerst de filename met volledige directory volgens
% filename = [basecwd '\' filename] of iets dergelijks...

function out = tol_crawler(filename)

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
    
    % lees de derde regel; daar staat hoelang de instructie duurt... hebben
    % we niet nodig verder
    instructionperiod_line = fgetl(fid);
    
    
    % lees de rest van de regels...
    while ~feof(fid)
        line = fgetl(fid);
        
        % tabs geven de 'volgende' waardes aan; lege velden zijn gelijk aan
        % 0!
        line_elements = textscan(line,'%s','delimiter','\t','emptyvalue',0);
        line_elements = line_elements{1};
        
      
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
  
    % sluit de file = netjes...
    fclose(fid);
    
    % zoek nu in het excel sheetje op hoe de varabelen heten; ze zijn vanaf
    % nu gewoon aan te roepen in dit script.
    % LET WEL:
    % 1) . = _
    % 2) [ = _
    % 3) ] =
    % zoals hierboven omgezet. 
    % voorbeeld: Tol_RT
    
    % voor ons van belang zijn de volgende rijen:
    %		
    % Tol_OnsetTime	- NuEcht_OffsetTime
    % Tol_RT
    % Tol_ACC	
    % Category
    % let wel het zijn allen {'strings','in deze cell'}, dus met str2num
    % converteren naar getallen.
    
    disp(['lengte van de logfile: ' num2str(length(Tol_RT)) ' regels']);
    
    
    % sorteren: neem Tol_RT maar als lengte-indicator... ze zijn toch allen
    % hetzelfde.
    %disp('Er zijn ' num2str(length(Tol_RT)) 'rijen... in de file');
    
    % consets initialiseren
    % condur initialiseren
    % dan wordt daarop verder gebouwd...
    
    % 1=kleur
    % 2=1move
    % ...
    % 6=5moves
    % 7=fouten!
    for i=1:7
        
        consets{i} = [];
        condur{i} = [];
    end
    
    for i=i:length(Tol_RT)

    % maak er getallen van...
    % Tol_OnsetTime	- NuEcht_OffsetTime
    % Tol_RT
    onset = str2num(Tol_OnsetTime{i})-str2num(NuEcht_OffsetTime{i});
    onset = onset / 1000;
    dur = str2num(Tol_RT{i});
    dur = dur / 1000;
        
        switch str2num(Tol_ACC{i});
        
            % haal de fouten eruit
            case 0
                consets{7} = [consets{7} onset];
                condur{7} = [condur{7} dur];
            
            % en sorteer de goeden
            case 1
                
                switch str2num(Category{i});
                    
                    % kleuren tellen
                    case 0
                        consets{1} = [consets{1} onset];
                        condur{1} = [condur{1} dur];

                    % makkelijk = 1 move    
                    case 1
                        consets{2} = [consets{2} onset];
                        condur{2} = [condur{2} dur];
                        
                    % makkelijk = 2 moves
                    case 2
                        consets{3} = [consets{3} onset];
                        condur{3} = [condur{3} dur];
                        
                    % gemiddeld = 3 moves    
                    case 3
                        consets{4} = [consets{4} onset];
                        condur{4} = [condur{4} dur];
                        
                    % moelijker = 4 moves    
                    case 4
                        consets{5} = [consets{5} onset];
                        condur{5} = [condur{5} dur];
                        
                    % einstein-b-gone = 5 moves!!!    
                    case 5
                        consets{6} = [consets{6} onset];
                        condur{6} = [condur{6} dur];
                end
                
            
        end
        
    end
        
        
    names={'kleuren','1','2','3','4','5','fout'};
    onsets=consets;
    durations=condur;
    
    save event.mat names onsets durations
    out='event.mat';

    
    % De cononsets = Tol.OnsetTime - NuEcht.OffsetTime
    % De condurs = Tol.RT
    
    % haal eerst alles met Tol.Acc = 0 eruit (stop later in de laatste
    % conditie)
    % daarna sorteren op Tol.Category
    

    
    
    
    % sort the data
    
    
    
    
    % generate designmatrix (the output)
    
    
    
