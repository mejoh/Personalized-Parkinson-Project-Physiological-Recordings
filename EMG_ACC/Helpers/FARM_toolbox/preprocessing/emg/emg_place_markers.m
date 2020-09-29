% this is the key function that places markers.
% determine if vec has > 1 rows
% then, do wavelet analysis rigrsure soft threshold non-white noise
% then do abs
% then scale with the SD.
% then determine threshold.
% this will place the markers and return the bursts structure!, that we so
% carefully defined.

function markers=emg_place_markers(data,params)


    pfields=fieldnames(params);
    for i=1:numel(pfields)
        eval([pfields{i} '=params.' pfields{i} ';']);
        disp(['var = ' pfields{i}]);
    end

    % out = helper_filter(in,40,srate,'low')
    

    

    % Segmentations... works with vec (see notes).
    for i=1:numel(vec)
        

        markers{i}=struct('b',[],'e',[]);

        for j=1:size(vec{i},1)
            
            
            disp(['doing markers for cond  ' num2str(i)]);
            
            v=vec{i}(j,:);
            p=find(v);
            
            % segmented signal; 'signal detail'.
            % keyboard;
            try
            sd=s(p);
            catch
                lasterr
                keyboard;
            end
            
            
            
            % rectify
            sdr=abs(sd);
            sdh=abs(hilbert(sd));
            
            % low-pass filter -- attenuates frequencies which are too high.
            sdrf=filtfilt(fb,fa,sdr); 
            
            sdhf=filtfilt(fb,fa,sdh);
            
            % get the mode, and a nice figure handle with visibility 0.
            % 7 is just an empirical value and gives you nice figures. It
            % doesn't *really* matter that much as long as it's not < 5 or
            % > 10 or so; the mode yields the same results regardless.
            % keyboard;
            % [mode fh]=my_mode(sd,12*median(sdr),1,1);
            % above doesn't work.
            % try the below.
            
            % calculate the mode vector.
            % keyboard;
            disp('calculating mode...');
            mv=my_mode_vector(sd,10,2048,10*2024);
            % during rest; increase the threshold.

            
%             if ~exist('modecheck','dir')
%                 mkdir('modecheck')
%             end
%             saveas(fh,['modecheck/hist_' muscle '_cond_' num2str(i) '_sec_' num2str(j)],'jpg');
%             close(fh);

            % keyboard;
            

            % with this mode, determine the markers.
            % step 1 = get the markers.
            % keyboard;
            % keyboard;
            disp('placing markers.');

            % during rest; add an extra factor of 1 * mode.
            
            m=emg_marker_routine(sdrf,5*mv,2*mv);
            % keyboard;
            
            % step 2 = get latencies and areas_above_mode.
            
            disp('rejecting unlikely events.');
            lat=emg_calculate_latency(m);
            
            % apply area threshold...
            sur=emg_calculate_area(sdh,m,mv);
            
            amp=emg_calculate_amplitude(sdhf,m);

            
            % keyboard;
            % look at the mean of the area, and discard accordingly...
            % meana=emg_calculate_mean_area(abs(sdh),m);

            
            % make a nice figure depicting the signal and the two
            % thresholds; save as .fig and as .jpg.
            fh=figure;
            set(fh,'visible','off');
            plot(sdh);
            hold on;
            plot(thramp_low*mv,'k');
            plot(thramp_high*mv,'k');
            
            for k=1:numel(m.b)
                line(m.b(k)*[1 1],get(gca,'ylim'),'color','g');
                line(m.e(k)*[1 1],get(gca,'ylim'),'color','r');
            end
            if ~exist('modecheck','dir');
                mkdir('modecheck');
            end
            title=['modecheck/tr' muscle '_c_' num2str(i) '_s_' num2str(j)];
            saveas(fh,title,'fig');
            saveas(fh,title,'jpg');
            close(fh);
            
            
            
            
            markers{i}(1).b=m.b;
            markers{i}(1).e=m.e;
            

            
            matrix=[];
            for i=1:numel(m.b)
                matrix(i,:)=[m.b(i) m.e(i) lat(i) sur(i) amp(i)];
            end
            
            data{i}=matrix;
            
            disp(['muscle ' muscle ', condition ' num2str(i) ', section ' num2str(j) ': found ' num2str(numel(m.b)) ' events.'])
            

            
        end

%         debug; i= condition...
%         if i==1
%             keyboard;
%         end
        
    end
    

        
        
        
        
        
        
        