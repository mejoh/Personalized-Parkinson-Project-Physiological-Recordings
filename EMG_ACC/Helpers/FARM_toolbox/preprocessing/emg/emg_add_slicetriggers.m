% plaats events in EEG structure 4 each slice.
% optimize slicesampleduration for 'dead time' just before new volume
% trigger. (approxximately, i don't really look at the end volume trigger.
% just at the beginning volume trigger.
%
% probeer een tweede manier van slice triggers plaatsen.
%
% er is een stukje 'dode' tijd.
% varieer deze dode tijd en reken een soort optimale dode tijd uit.
%
% 
% 'dead time' = van 0 naar 20 samples! (vergelijk: 1 slice ~ 50 samples
%
%
% hoelang is 1 volume? doe maar simpel vol(2)-vol(1), in de tijd.
function EEGOUT=emg_add_slicetriggers(EEG,channel,conf)
% load(regexprep([pwd '/../parameters'],'\\','/'));
% parameters
% keyboard
    parameters = conf.file.scanpar;
mkdir slicetrigger_check

%tmp2=find(strcmp({EEG.event(:).type},'S 39')==1 | strcmp({EEG.event(:).type},'S 41')==1);
%tmp2=find(strcmp({EEG.event(:).type},'S 37')==1 | strcmp({EEG.event(:).type},'S 39')==1 | strcmp({EEG.event(:).type},'S 41')==1);
tmp2=find(strcmp({EEG.event(:).type},conf.file.etype)==1);

if numel(tmp2)==0;
    tmp2=find(strcmp({EEG.event(:).type},'V')==1);
end

for i=1:numel(tmp2)
    EEG.event(tmp2(i)).type='V';
end

%for i=1:numel(tmp2)
%    EEG.event(tmp2(i)).type='V';
%end

d=EEG.event(tmp2(2)).latency-EEG.event(tmp2(1)).latency;

% ruwe schatting hoe lang een slice duurt aan samples, en dat delen door 2.
% dat levert genoeg 'dode' tijd op voor het artefact per volume. Dat is
% altijd kleiner dan de tijd nodig voor 1 slice. (afkloppen...)

ed=round(d/parameters(2)/2);%AANZETTEN VOOR NIEUWE SCANNER EMGs
% ed=130;%AANZETTEN BIJ OUDE SCANNER EMGs

% onze optimalisatie-matrix...
thematrix=zeros(ed+1,numel(tmp2));

% lijst voor "remaining" variantie, per volume
for i=1:numel(tmp2)
    
    b=EEG.event(tmp2(i)).latency;

    e=b+d;
    
    % we gaan 'sweepen', van 0 naar 20 samples.
    try
        st_list=(e-b-[0:ed])/parameters(2);
    catch
        fid=fopen('error.txt','w+');
        disp(lasterr);
        fprintf(fid,['error: numel(stlist) = ' num2str(numel(st_list))]);
        fclose(fid);
        break;
    end

    % bereken de std over alle segmenten: 'std-list'
    std_list=[];

    % bij de beste std, plaats die markers (!)

    for st=st_list

        % keyboard;
        % onze tijdelijke slice-data-matrix.
        m=[];

        % temporary slice markers...
        % slice-markers zetten
        sm=zeros(parameters(2),1);
        for j=1:parameters(2)

            sm(j)=b+round((j-1)*st);

            % EEG.data(channel,iet...) we gaan kijken naar het 1e kanaal voor
            % onze optimalisatie. net zoals de fmrib toolbox
            try
                m(j,:)=EEG.data(channel,sm(j):sm(j)+round(st));
            catch
                error('you are probably out of data and need to delete manually the final volume trigger before attempting this again!');
            end

        end


        std_list(end+1)=sum(std(m));



    end
    
    matrix=[st std_list];
    
%     if ~exist(['matrix_' num2str(i) '.txt'],'file');
%         fid=fopen(['matrix_' num2str(i) '.txt'],'w+');
%     else
%         fid=fopen(['matrix_' num2str(i) '.txt'],'w+');
%     end
%     
%     fprintf(fid,num2str(matrix));
 %    fclose(fid);
    

    % keyboard;
    % correcte index;
    st_ind=find(std_list==min(std_list));
    

    st=st_list(st_ind);
    % keyboard;
    disp(['correct slice timing is now: ' num2str(st) ', volume = ' num2str(i)]);
    
    % sla de waarden op om later te plotten
    % xdata=st_list;
    % ydata=std_list;
    
    
    thematrix(:,i)=std_list';
    % ok -- prima -- plaats nu maar die triggers (!!!).
    
    
    % voeg extra triggers in, per volume, maar niet de laatste; daar zit
    % zo'n vervelende Volume dead time.
    m2=[];
    for k=1:parameters(2)
        
        % afronden - naar sample! Why?
        EEG.event(end+1).latency=round(b + round(st*(k-1)));
%         EEG.event(end+1).latency= ( b + round(st*(k-1)) ); % MDx workaround for downsample
        EEG.event(end).type='s';
        %!! Volume triggers do NOT have a duration!
        % EEG.event(end).duration=0;     
        
        % opnieuw m, onze slice-artefact-matrix, gaan maken...
        % keyboard;
        m2(:,k)=EEG.data(channel,EEG.event(end).latency+(1:round(st)))';

    end
    % keyboard;
    
    % fh=figure;
    % set(fh,'visible','off');
    % keyboard;
    % plot(m2);
    % title(['for volume trigger: ' num2str(i) ',st = ' num2str(st)]);
    % saveas(fh,['slicetrigger_check/artefacts_' num2str(i)],'jpg');

    % save(['slicetrigger_check/artefacts_' num2str(i,'%.4d') '.mat'],'m2');
    % close(fh);
    


    
end

% foutmeldingen voorkomen...
for i=1:numel(EEG.event)
    EEG.event(i).duration=0;
end

EEGOUT=EEG;






%
% maak coole plaatjes om de triggering echt te volgen
% keyboard;
if strcmp(conf.slt.plot,'yes')

fh=figure;
set(fh,'visible','off');
surf(thematrix)
saveas(fh,'slicetrigger_check_slicetrigger_check','jpg');
% close(fh);
disp('made it to 191')
tmp=find(strcmp({EEG.event(:).type},'s')==1);
for i=1:20:numel(tmp2)
    fh=figure;
    set(fh,'visible','off');
    b=EEG.event(tmp2(i)).latency-300;
    e=b+600;
    plot(b:e,EEG.data(channel,b:e))
    hold on
    ylim=get(gca,'ylim');
    
    % get all of the slice triggers, nearest to our volume trigger.
    tmp5=find(abs(EEG.event(tmp2(i)).latency-[EEG.event(tmp).latency])<300);
    
    for j=tmp5
        line(EEG.event(tmp(j)).latency*[1 1],ylim,'color','m')
    end
    
    line(EEG.event(tmp2(i)).latency*[1 1],ylim,'color','k')
    


    saveas(fh,['slicetrigger_check_volume_trigger' num2str(i)],'jpg');

    close(fh);
    
    
end

end
