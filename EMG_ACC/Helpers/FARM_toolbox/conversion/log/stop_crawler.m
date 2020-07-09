%% import stuff
% cjamge!

% belangrijk! er zijn 2 dingen in de stoptaak logfile
% 1) cut/paste t tweede gedeelte in een txt file
% 2) op regel 2, plak de onsettijd van t begin van t scannen
% 3) en save ut niet als unicode tekst, uiteraard (!!!)

function stop_crawler(filename)

fid=fopen(filename);

lines={};

while ~feof(fid)
    lines{end+1}=fgetl(fid);
end

fclose(fid)
% keyboard;

%% beginning of scans

tbegin=str2double(lines{2});





%% go thru trials -- incl. warmups, there are about 105.000 st.names.

num=(numel(lines)-2)/3;
for i=1:num
    
    % the 'fix' log line
    lfix=lines{2 + (i-1)*3 + 1};
    % the 'target' log line
    lt=lines{2 + (i-1)*3 + 2};
    % the stop or go log line!
    lsg=lines{2 + (i-1)*3 + 3};
    
    
    % uit elkaar trekken.
    lfixp=regexp(lfix,'[^\t]*','match');
    ltp=regexp(lt,'[^\t]*','match');
    lsgp=regexp(lsg,'[^\t]*','match');
    
    
    % beginning time??
    begintime=str2double(lfixp{4})-tbegin;
    
    
    % response?
    % =0 with no response (later, succesful stop t.name, or sleeping during
    % go t.names
    % =1 
    
    if numel(ltp)==9
        
        response=0;
        reaction_time=-1;
        % wanneer zie je die pijl nou?? dat is mijn onset-time.
        t(i).onset_pijl=(str2double(ltp{4})-tbegin)/10000;
        
    elseif numel(ltp)==12;
        
        
        response=str2double(ltp{4});
        reaction_time=str2double(ltp{5});
        % wanneer zie je die pijl nou?? dat is mijn onset-time.
        t(i).onset_pijl=(str2double(ltp{7})-tbegin)/10000;
        
    end
    
    % stop, or go; left, or right?
    % stop =1 with stop t.names; 0 with go t.names (since it's not a stop)
    % hand=1 means lefthand, =2 means righthand.
    
    % disp([num2str(i) ' ' lsgp{2}(end)]);
    
    switch str2double(lsgp{2}(end))
        
        case 1
            
            stop=0;
            hand=1;
            
        case 2
            
            stop=0;
            hand=2;
            
            
        case 8
            stop=1;
            hand=1;
            
        case 6
            stop=1;
            hand=2;
    end
    

    % deze ga ik niet gebruiken; dit is nmk de onset-tijd van de trial...
    % die onset zie je niet in het echt; je ziet alleen een fixatiekruis en
    % een pijl naar L of naar R.
    t(i).onset=begintime/10000;
    
    % tijdsverscil tussen begin van de trial, en het einde van het zien van
    % die pijl.
    t(i).duration=str2double(lsgp{4})+str2double(lsgp{6})-str2double(lfixp{4});
    
    % tijdsverschil tussen zien van de pijl en verdwijnen van de pijl. dit
    % wordt mijn 'duration'.
    t(i).duration_pijl=(str2double(lsgp{4})+str2double(lsgp{6})-tbegin)/10000-t(i).onset_pijl;

    t(i).i=i;
    disp(t(i).onset_pijl);
        disp(t(i).duration_pijl);
    % disp(lsgp{4});
    % disp(lsgp{6});
    
    % sleep -- niet gedrukt op 'go'
    % incorrect stop -- verkeerd gedrukt op 'stop'
    
    % is er niet gedrukt op een go t.name?
    if (stop==0 && response==0)
        t(i).name='Sleep';     
    end
    
    % is er gedrukt op een stop trial + verkeerd gedrukt ?
    if (stop==1 && response>0)
        
        t(i).RT=reaction_time;

        if(hand==1)
            t(i).name='StopRespondL';
            if(response==2)
                t(i).name='WrongPress';
            end
        elseif(hand==2)
            t(i).name='StopRespondR';
            if(response==1)
                t(i).name='WrongPress';
            end
        end

    end
    
    % is er gedrukt op een go t.name + verkeerd gedrukt ?
    if (stop==0&&response>0)
        
        t(i).RT=reaction_time;

        if(hand==1)
            t(i).name='GoL';
            if(response==2)
                t(i).name='WrongPress';
            end
        elseif(hand==2)
            t(i).name='GoR';
            if(response==1)
                t(i).name='WrongPress';
            end

        end

    end
    
    % is er niet gedrukt op een stop t(i).name?
    if (stop==1&&response==0)

        if(hand==1)
            t(i).name='StopL';
        elseif(hand==2)
            t(i).name='StopR';
        end
    end
        
    
    
end



%% design matrix

names={'GoL','GoR','StopL','StopR','StopRespondL','StopRespondR'};
addonnames={'Sleep','WrongPresses'};
onsets={[],[],[],[],[],[]};
durations={[],[],[],[],[],[]};


% keyboard;


for i=1:num
    
    switch t(i).name
        
        case 'GoL'
            onsets{1}(end+1)=t(i).onset_pijl;
            durations{1}(end+1)=t(i).duration_pijl;
            
        case 'GoR'
            onsets{2}(end+1)=t(i).onset_pijl;
            durations{2}(end+1)=t(i).duration_pijl;
            
        case 'StopL'
            onsets{3}(end+1)=t(i).onset_pijl;    
            durations{3}(end+1)=t(i).duration_pijl;
            
        case 'StopR'
            onsets{4}(end+1)=t(i).onset_pijl;   
            durations{4}(end+1)=t(i).duration_pijl;
            
        case 'StopRespondL'
            onsets{5}(end+1)=t(i).onset_pijl;  
            durations{5}(end+1)=t(i).duration_pijl;
            
        case 'StopRespondR'
            onsets{6}(end+1)=t(i).onset_pijl; 
            durations{6}(end+1)=t(i).duration_pijl;
%             
%         case 'Sleep'
%             onsets{7}(end+1)=t(i).onset_pijl; 
%             durations{7}(end+1)=t(i).duration_pijl;
%             
%         case 'WrongPress'
%             onsets{8}(end+1)=t(i).onset_pijl; 
%             durations{8}(end+1)=t(i).duration_pijl;
            
    end
end

save model.mat names onsets durations

