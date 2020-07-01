%% import stuff

function out=gonogo_crawler(filename)


fid=fopen(filename);

lines={};

while ~feof(fid)
    lines{end+1}=fgetl(fid);
end

fclose(fid);
% keyboard;

%% beginning of scans

% m is... The Matrix (!!!)
m=[];

% m(:,1) = 1, 2, 3 (=picture, response, of pulse.
% m(:,2) = 1, 2, 3 (=picX, picY)
% m(:,4) = [0-9]*, een nummer dat de tijd weergeeft.



for i=1:numel(lines)

    % keyboard;
    pieces=regexp(lines{i},'[^\t]*','match');

    if numel(pieces)>0
        if numel(pieces{1})>3
        pieces(1)=[];
        
        end
    end
       
    
    
    % geen lege lijnen.
    % m alleen in deze gevallen uitbreiden...
    if numel(pieces)>3
        
        switch pieces{2}
            
            case 'Picture'
                
                m(end+1,1)=1;
                
            case 'Response'
                
                m(end+1,1)=2;
                
            case 'Pulse'
                
                m(end+1,1)=3;
                
            
        end

        
        % alleen als er picture, response, of pulse staat... anders niet
        % dus geen 'quit', en/of lege lijnen...
        switch pieces{3}

            case 'X'

                m(end,2)=1;

            case 'Y'

                m(end,2)=2;
                
        end
        
        
        % check of het uit louter getakken bestaat...
        % voorkom error melding.
        if numel(pieces)>3
            if numel(regexp(pieces{4},'[^0-9]'))==0

                m(end,3)=str2double(pieces{4});

            end
        end
            

        
        
    end
    
end


%% nu handige dingen doen met m...

% een 'id' toevoegen...
m=[(1:size(m,1))' m];
m=[m m(end+1,:)]; 

% alle pulsen.
i_alle_pulsen=m(find(m(:,2)==3),1);
i_eerste_puls=i_alle_pulsen(1);
i_laatste_puls=i_alle_pulsen(end);

% als aller-eerste stap: alleen tijdens de 'scan', de logfile extracten.
% m 'pre-tailoren'... alles voor 1e en na laatste ttl wegmikken.
if i_eerste_puls > 2
    m(1:i_eerste_puls-1,:)=[];
end

if i_laatste_puls < size(m,1)
    m(i_laatste_puls+1:end,:)=[];
end

%% resetten indices van m --> dit is noodzakelijk!!
m(:,1)=[];
m=[(1:size(m,1))' m];


%% alle plaatjes.
i_alle_plaatjes=m(find(m(:,2)==1),1);




%% nu de indices van de stop en go trials vinden uit m.
%


% st = stimuli
st = m(i_alle_plaatjes,[1 3]);

% stop = een placeholder array van stop i's, voor de st.
% deze moet dus op 'm' werken gaan.
i_stop = [];
i_go = st(1,1); % de eerste trial is altijd n 'go'...

% pt = previous trial

for i=2:size(st,1)
   
    % definitie van stoptrial: current trial is t zelfde.
    if st(i-1,2)==st(i,2)

        i_stop(end+1)=st(i,1);
    end
    
    if st(i-1,2)~=st(i,2)

        i_go(end+1)=st(i,1);
    end
    
end

ind.go=i_go';
ind.stop=i_stop';




%% en dan nu de responsies gaan doen.

% we hebben m.
% en we hebben i_stop en i_go.
% keyboard;

% nu kijken of er iets voor of achter is gebeurd qua responsies.

rtime.go=zeros(size(i_go));
rtime.stop=zeros(size(i_stop));

%% de go en de stop trials, tijden extraheren.

for field={'go','stop'};
    
    f=field{1};
    
    
    onset.(f)=zeros(size(ind.(f)));
    rtime.(f)=zeros(size(ind.(f)));
    
    
    for i=1:numel(ind.(f))

        % wat is de onset?
        onset.(f)(i)=(m(ind.(f)(i),4)-m(1,4))/10000;

        
        % hoeveel indices is het volgende picture weg??
        j=1;
        while m(ind.(f)(i)+j,2)~=m(ind.(f)(i),2)&&ind.(f)(i)+j<size(m,1)
            j=j+1;
        end
        % en vind dan in het tussen-stukje de responsies.
        % met for-loopje.
        % en vul dan de 'rt', if any, in.
        
        response_times=[];
        for k=ind.(f)(i)+(0:j)
            if m(k,2)==2
                response_times(end+1)=(m(k,4)-m(ind.(f)(i),4))/10000;
            end
        end
        
        if numel(response_times)==1
            rtime.(f)(i)=response_times(1);
        end
        

        if numel(response_times)>1
            rtime.(f)(i)=response_times(1);
            disp(['De pp heeft ' num2str(numel(response_times)) ' x op response gedrukt!! -- bij ' f '-trial nr. ' num2str(i+1)]);
        end
            

    end
    
%       dit is slechts een check....    
%     check.(f)=zeros(size(m,1),2);
%     for i=1:numel(ind.(f))
%         check.(f)(ind.(f)(i),1)=1;
%         check.(f)(ind.(f)(i),2)=rtime.(f)(i);
%     end

end



 

%% en dan nu de design matrix gaan maken.
names={'GoRespond','GoInhibit','StopRespond','StopInhibit'};
onsets=cell(1,4);
durations=cell(1,4);

% ga stop en go trials af... en vul names, onsets en durations...
% in dit geval... onets.

for i=1:numel(ind.go)
    
    if rtime.go(i)>0
        onsets{1}(end+1)=onset.go(i);
        
    end
    
    if rtime.go(i)==0
        onsets{2}(end+1)=onset.go(i);
        
    end
    

    
end

for i=1:numel(ind.stop)
    
    if rtime.stop(i)>0
        onsets{3}(end+1)=onset.stop(i);
        
    end
    
    
    if rtime.stop(i)==0
        onsets{4}(end+1)=onset.stop(i);
        
    end
    
end

%% set durations to 1
for i=1:numel(onsets)
    for j=1:numel(onsets{i})
        durations{i}(j)=1;
    end
end



%% verbosity is nice!

disp(['GoRespond events: ' num2str(numel(onsets{1}))]);
disp(['GoInhibit events: ' num2str(numel(onsets{2}))]);
disp(['StopRespond events: ' num2str(numel(onsets{3}))]);
disp(['StopInhibit events: ' num2str(numel(onsets{4}))]);


%% onsets GoRespond = Implicit Baseline. Daarom gaan we m niet modellen.
% Dacht t niet!!!

save event.mat names onsets durations
out='event.mat';


% names(1)=[];
% onsets(1)=[];
% durations(1)=[];
% 
% save event.mat names onsets durations
% out2='event.mat';







    
    