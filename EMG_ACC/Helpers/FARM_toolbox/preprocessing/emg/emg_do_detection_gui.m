% a helper function which places markers and determines the threshold, with
% my_mode_vector.
%
% it returns the beginnings of a struct which stores event data, and it
% also returns if you ask for it the threshold that has been calculated
% with my_mode_vector.
%
% function [bursts thr]=emg_place_markers_gui(data,vec,params)

function bursts=emg_do_detection_gui(data,mode,vec,params)


    % let's also define our 'event' cell-structure.
    bursts={struct('b',[],'e',[],'amp',[],'dur',[],'area',[],'verdict',[0],'cond',[],'thresh',[],'ch',[],'mode',[],'burstnumber',[],'bt',[],'et',[])};
    bursts{1}(1)=[];
    for i=2:8
        bursts{i}=bursts{1};
    end
    % verdict = 'todo','use','omit'.
    % cond = condition where this burst was in.
    % thresh = the threshold that was used for this one burst.

    pfields=fieldnames(params);
    for i=1:numel(pfields)
        eval([pfields{i} '=params.' pfields{i} ';']);
        disp(['var = ' pfields{i}]);
    end

    
    burstnumber=0;
    
    for ch=params.doMuscles
        disp(sprintf('busy with channel %d',ch));
    


        s=data(ch,:);
        m=mode(ch,:);
        % Segmentations... works with vec (see notes).
        for i=1:numel(vec)
            
            threshhigh=params.thresh(i,1);
            threshlow=params.thresh(i,2);

            disp(sprintf('doing markers for muscle %d, cond %d',ch,i));

            % markers{i}=struct('b',[],'e',[]);

            md=[];
            sd=[];
            
            for j=1:size(vec{i},1)

                v=vec{i}(j,:);
                p=find(v);

                % segmented signal; 'signal detail'.
                sd=[sd s(p)];
                try
                md=[md m(p)];
                catch
                    keyboard;
                end
                
            end
            
            % keyboard;
            

            % rectify
            sdr=abs(sd);
            sdh=abs(hilbert(sd));


            sdrf=helper_filter(sdr,25,srate,'low');
            sdhf=helper_filter(sdh,25,srate,'low');

            % keyboard;
            % close(fh);fh=figure;ah=axes('parent',fh);
            % plot(ah,sdhf);hold on;plot(ah,threshhigh*md,'r');plot(ah,threshlow*md,'g');

            % keyboard;
            markers=emg_marker_routine(sdhf,threshhigh*md,threshlow*md);
            
            for k=1:numel(markers.b)
                
                bursts{ch}(end+1).b=markers.b(k);
                bursts{ch}(end).e=markers.e(k);
                bursts{ch}(end).cond=i;
                bursts{ch}(end).ch=ch;
                bursts{ch}(end).verdict=0;
                bursts{ch}(end).thresh=[threshhigh threshlow];
                
                burstnumber=burstnumber+1;
                bursts{ch}(end).burstnumber=burstnumber;
                
            end
            
            % title(sprintf('channel %d, condition %d',ch,i));
            % legend(ah,{[num2str(numel(bursts{ch})) ' detected']});
            
        end
        
    end
    
    % close(fh);
            

%                 % get the mode, and a nice figure handle with visibility 0.
%                 % 7 is just an empirical value and gives you nice figures. It
%                 % doesn't *really* matter that much as long as it's not < 5 or
%                 % > 10 or so; the mode yields the same results regardless.
%                 % keyboard;
%                 % [mode fh]=my_mode(sd,12*median(sdr),1,1);
%                 % above doesn't work.
%                 % try the below.
% 
%                 % calculate the mode vector.
%                 % keyboard;
% 
%                 % during rest; increase the threshold.
% 
% 
%     %             if ~exist('modecheck','dir')
%     %                 mkdir('modecheck')
%     %             end
%     %             saveas(fh,['modecheck/hist_' muscle '_cond_' num2str(i) '_sec_' num2str(j)],'jpg');
%     %             close(fh);
% 
%                 % keyboard;
% 
% 
%                 % with this mode, determine the markers.
%                 % step 1 = get the markers.
%                 % keyboard;
%                 % keyboard;
%                 disp('placing markers.');
% 
%                 % during rest; add an extra factor of 1 * mode.
% 
%                 m=emg_marker_routine(sdrf,5*mv,2*mv);
%                 % keyboard;
% 
%                 % step 2 = get latencies and areas_above_mode.
% 
%                 disp('rejecting unlikely events.');
%                 lat=emg_calculate_latency(m);
% 
%                 % apply area threshold...
%                 sur=emg_calculate_area(sdh,m,mv);
% 
%                 amp=emg_calculate_amplitude(sdhf,m);
% 
% 
%                 % keyboard;
%                 % look at the mean of the area, and discard accordingly...
%                 % meana=emg_calculate_mean_area(abs(sdh),m);
% 
% 
%                 % make a nice figure depicting the signal and the two
%                 % thresholds; save as .fig and as .jpg.
%                 fh=figure;
%                 set(fh,'visible','off');
%                 plot(sdh);
%                 hold on;
%                 plot(thramp_low*mv,'k');
%                 plot(thramp_high*mv,'k');
% 
%                 for k=1:numel(m.b)
%                     line(m.b(k)*[1 1],get(gca,'ylim'),'color','g');
%                     line(m.e(k)*[1 1],get(gca,'ylim'),'color','r');
%                 end
%                 if ~exist('modecheck','dir');
%                     mkdir('modecheck');
%                 end
%                 title=['modecheck/tr' muscle '_c_' num2str(i) '_s_' num2str(j)];
%                 saveas(fh,title,'fig');
%                 saveas(fh,title,'jpg');
%                 close(fh);
% 
% 
% 
% 
%                 markers{i}(1).b=m.b;
%                 markers{i}(1).e=m.e;
% 
% 
% 
%                 matrix=[];
%                 for i=1:numel(m.b)
%                     matrix(i,:)=[m.b(i) m.e(i) lat(i) sur(i) amp(i)];
%                 end
% 
%                 data{i}=matrix;
% 
%                 disp(['muscle ' muscle ', condition ' num2str(i) ', section ' num2str(j) ': found ' num2str(numel(m.b)) ' events.'])
% 
% 
% 
%             end
% 
%     %         debug; i= condition...
%     %         if i==1
%     %             keyboard;
%     %         end
% 
%         end
%     end
    

        
        
        
        
        
        
        