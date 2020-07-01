% initial choice for the other slices.
% and initial adjustments for the other slice artifacts.
function sl=init_slicetimes(sl,o,m)


    % slices              =o.nslices;
    % sv                  =m.sv;
    ss                  =m.ss;
    window              =o.window;
    beginshift          =o.beginshift;
    interpfactor        =o.interpfactor;
    sduration           =ceil(median(ss(2:end)-ss(1:end-1))+0.5);
    soffset             =round(-1*beginshift*sduration);

            
    % keyboard;
    
    % re-do the slice-alignment, on channel no. 1

        
        
        
        
%         tmp2=find(strcmp({EEG.event(:).type},'65535')==1);
% 
% for i=1:numel(tmp2)
%     EEG.event(tmp2(i)).type='V';
% end
% 
% d=EEG.event(tmp2(2)).latency-EEG.event(tmp2(1)).latency;
% 
% % ruwe schatting hoe lang een slice duurt aan samples, en dat delen door 2.
% % dat levert genoeg 'dode' tijd op voor het artefact per volume. Dat is
% % altijd kleiner dan de tijd nodig voor 1 slice. (afkloppen...)
% ed=round(d/parameters(2)/2);
% 
% % onze optimalisatie-matrix...
% thematrix=zeros(ed+1,numel(tmp2));
% 
% % lijst voor �remaining� variantie, per volume
% 
% deadtimes=zeros(1,numel(tmp2));
% for i=1:numel(tmp2)
%     
%     b=EEG.event(tmp2(i)).latency;
% 
%     e=b+d;
%     
%     % we gaan 'sweepen', van 0 naar 20 samples.
%     try
%         st_list=(e-b-[0:ed])/parameters(2);
%     catch
%         fid=fopen('error.txt','w+');
%         disp(lasterr);
%         fprintf(fid,['error: numel(stlist) = ' num2str(numel(st_list))]);
%         fclose(fid);
%         break;
%     end
% 
%     % bereken de std over alle segmenten: 'std-list'
%     std_list=[];
% 
%     % bij de beste std, plaats die markers (!)
% 
%     for st=st_list
% 
%         % keyboard;
%         % onze tijdelijke slice-data-matrix.
%         m=[];
% 
%         % temporary slice markers...
%         % slice-markers zetten
%         sm=zeros(parameters(2),1);
%         for j=1:parameters(2)
% 
%             sm(j)=b+round((j-1)*st);
% 
%             % EEG.data(channel,iet...) we gaan kijken naar het 1e kanaal voor
%             % onze optimalisatie. net zoals de fmrib toolbox
%             m(j,:)=EEG.data(channel,sm(j):sm(j)+round(st));
% 
%         end
% 
% 
%         std_list(end+1)=sum(std(m));
% 
% 
% 
%     end
% 
%     % correcte index;
%     st_ind=find(std_list==min(std_list));
% 
%     
%     st=st_list(st_ind);
%     disp(['correct slice timing is now: ' num2str(st) ', volume = ' num2str(i)]);
%     
%     
%     deadtimes(i)=e-(b+parameters(2)*st);
%     
%     % sla de waarden op om later te plotten
%     % xdata=st_list;
%     % ydata=std_list;
%     
%     
%     thematrix(:,i)=std_list';
%     % ok -- prima -- plaats nu maar die triggers (!!!).
%     
%     % keyboard;
%     
%     % voeg extra triggers in, per volume, maar niet de laatste; daar zit
%     % zo'n vervelende Volume dead time.
%     m2=[];
%     for k=1:parameters(2)
%         
%         % afronden - naar sample!
%         EEG.event(end+1).latency=round(b + round(st*(k-1)));
%         EEG.event(end).type='s';
%         %!! Volume triggers do NOT have a duration!
%         % EEG.event(end).duration=0;     
%         
%         % opnieuw m, onze slice-artefact-matrix, gaan maken...
%         % keyboard;
%         m2(:,k)=EEG.data(channel,EEG.event(end).latency+(1:round(st)))';
% 
%     end
        
        
        
        
        
    
    
    

    disp('for each slice, selecting (other) candidate-"elects" for the tempate.');
    for i=1:numel(ss)
        
        % a neat solution for index i= near 1 and numel(ss)!
        % keyboard;
        sl(i).others=pick_function(i,numel(ss),window);
        
        % beginning and ending samples
        sl(i).b=(ss(i)+soffset)*interpfactor-(interpfactor-1);
        sl(i).e=(ss(i)+soffset+sduration-1)*interpfactor-(interpfactor-1);

    end
    
    