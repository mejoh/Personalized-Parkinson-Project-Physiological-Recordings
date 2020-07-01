function EEG=emg_filter_artifact_frequencies(EEG,thresh,frange,chan_thresh)


    % this function is comprised of 2 stages.
    % first, every segment of power is spitted through, to compare those
    % points that exceed some threshold with other points that exceed a
    % threshold in other channels.

    load ../parameters
    nvol=parameters(3);
    
    if exist('../../muscles.mat','file')
        load ../../muscles.mat
    else
        for i=1:EEG.nbchan
            muscles{i}=num2str(i);
        end
    end
    % thresh=3.72; % equivalent to p < 0.0001, or 1 10000th chance.
    % thresh=3.0901; %^equivalent to p < 0.001, or 1 in 1000th chance.
    % thresh=2.32633; %^equivalent to p < 0.01, or 1 in 100th chance.
%     thresh = 1.64485; % equivalent to p < 0.05.
%     frange=4; % in Hz, the size of the segments where EMG power is studied.
%     chan_thresh=2;
    
    % 3.72 ~ p < 1/10^4;
    
    
    wdir=pwd;
    dirname=[num2str(thresh) '_' num2str(frange) '_' num2str(chan_thresh)];
    dirname=regexprep(dirname,'\.','');
    sdir=[wdir '/filter_report_' dirname '/'];
    report={};
    
    if ~isdir(sdir)
        mkdir(sdir);
    end
    
    % keyboard;
    
    % this function selectively filters out every filter-frequency.
    
    % determine 'middle' points of the segments.
    intervals=EEG.pnts*(0:frange/EEG.srate:0.5); % ga tot de helft in het f-spectrum, in stapjes
    % die vergelijkbaar zijn met frange Hz.
    intervals(end)=[];
    
    freqdur=round(frange*EEG.pnts/EEG.srate)+2;
    
    intervals=round(intervals+freqdur/2);

    
    % keyboard;
    
    
    
    
    points=[];
    
    d=EEG.data';
    D=fft(d);


    ah=[];
   
    for j=1:numel(intervals)
        
        
        fh=figure;
        set(fh,'visible','off');
        
        

        mark=intervals(j);
        i_tmp=round(mark-freqdur/2):round(mark+freqdur/2);
        i_tmp=i_tmp(find(i_tmp>0));
        i_tmp=i_tmp(find(i_tmp<EEG.pnts/2));
        
        report{end+1}=['Evaluating frequency points between ' num2str(i_tmp(1)) ' and ' num2str(i_tmp(end))];
        disp(report{end});

        % a word on 'record'; this is to find those frequencies that are
        % abnormally high in MORE than just one channel. 
        % These should be frequencies that
        % have to do with the artifact. I assume that frequencies that are
        % abnormally high in just 1 channel doesn't so-much have to do with
        % the artifact.
        record=zeros(EEG.nbchan,numel(i_tmp));
        
        % keyboard;
        for i=1:EEG.nbchan
        
            v=abs(D(:,i));
            
            % keyboard;
            
            % take a little piece of data.
            v_tmp=abs(D(i_tmp,i));
            
            med_v_tmp=median(v_tmp);
            std_v_tmp=std(v_tmp);
            
            cutoff=med_v_tmp + thresh*std_v_tmp;
            
            points_tmp=find(v_tmp>cutoff);
            record(i,points_tmp)=1;
            
            % keyboard;
            % points{i}=[points{i};(points_tmp+i_tmp(1)-1)];
            
            
            % save results.
            ah(i)=subplot(4,2,i);
            plot(v_tmp);hold on;
            xlim([1 freqdur]);
            line(get(gca,'xlim'),med_v_tmp*[1 1],'color','k');
            line(get(gca,'xlim'),cutoff*[1 1],'color','r');
            % title(['frequency content between ' num2str(j-1) ' and ' num2str(j) 'Hz.']);
            

            
            % keyboard;
            
                       
        end
        
        % points to be deleted.
        points_tmp=find(sum(record)>=chan_thresh);
        
        % keyboard;
        for i_ah=1:EEG.nbchan
            plot(ah(i_ah),points_tmp,(get(ah(i_ah),'ylim')*[0 1/2]')*ones(numel(points_tmp)),'kx');
            % keyboard;
            ylabel(ah(i_ah),muscles{i_ah});
            set(ah(i_ah),'xticklabel',{num2str(frange*(j-1)),num2str(freqdur),num2str(frange*j)});
            set(ah(i_ah),'xtick',[1 freqdur/2 freqdur]);
            
            % title(ah(i_ah),[muscles(i_ah) ', frange= ' num2str(frange*(j-1)) '-' num2str(frange*j) 'Hz.']);
        end
        
        points=[points (points_tmp+i_tmp(1)-1)];

        
        % keyboard;
        saveas(fh,[sdir num2str(j,'%.3d') '_f_' num2str(frange*(j-1)) '_' num2str(frange*j) '_Hz.jpg'],'jpg');
        % keyboard;
        close(fh);
        
    end
    
    
    % don't keep the 0 Hz frequency...
    if points(1)==1
        points(1)=[];
    end


    % removes overlap in points with unique.
    report{end+1}=['These are found twice due to overlapping windows: ' num2str(points(~diff(points))) ' ... thrown away.'];
    % keyboard;
    points=unique(points);
    points(find(points>EEG.pnts/2))=[]; % to remove points, that exceed the middle of the spectrum.
    disp(report{end});

    
    

    % This section writes a log to tell the user some useful information;
    % this is saved in a text file 'report.txt' in the appropriate folder,
    % together with the jpegs of the spectra.
    artefact_freq_contents=2*numel(points)/EEG.pnts*100;
    report{end+1}=['\n\nI am replacing ' num2str(numel(points)) ' points in the spectrum, which is ' num2str(artefact_freq_contents,'%2.1f') ' percent of your EMG frequency points, with zero.'];
    disp(report{end});
    

    tmp=round([30 250]/(EEG.srate/EEG.pnts));
    i_30_250=tmp(1):tmp(2);
    report{end+1}=['There are ' num2str(numel(i_30_250)) ' points between 30 and 250 Hz.'];
    disp(report{end});
    

    % more reporting!
    for i=1:EEG.nbchan
        
        pow_total=sum(abs(D(:,i)));
        pow_thrown_away=sum(abs(D(points,i)));
        ratio2=num2str(100*pow_thrown_away/pow_total,'%2.1f');
        
        pow_in_30_250=sum(abs(D(i_30_250,i)));
        points_in_30_250_thrown_away=intersect(find(points>round(30/(EEG.srate/EEG.pnts))),find(points<250/(EEG.srate/EEG.pnts)));
        pow_in_30_250_thrown_away=sum(abs(D(points_in_30_250_thrown_away,i)));
        ratio1=num2str(100*pow_in_30_250_thrown_away/pow_in_30_250,'%2.1f');

        report{end+1}=['In channel ' num2str(i) ', this accounts for ' ratio1 ' percent of the power within 30-250 Hz. \n\t And also ' ratio2 ' percent of the total power in the EMG.'];
        disp(sprintf(report{end}));
        
    end
    
    
    % save to file, some reporting...
    fid=fopen([sdir 'frequency_report.txt'],'w+');
    for i=1:numel(report);
        fprintf(fid,[report{i} '\n']);
    end
    fclose(fid);

    
    

    
    % in what way would you 'penalize' out-of-the-ordinary points?
    % here, i've chosen to just set them all to 0.
    % however, a different method may be used, such as shrinkage of the
    % amplitude togehter with setting of a randomized phase.
    % effectively adding some meaningless white noise in these frequencies.
    % but for now, setting to 0 is a bit easier.
    
    Dn=D;
    Dn(points,:)=0;
    Dn(end-points+2,:)=0;
    dn=ifft(Dn);
    EEG.data=dn';
    

    % save for prospective inspection of what's been done.
    save([sdir 'spectra.mat'],'D','Dn');
    
    
    % rather don't save these spectra; it gives too big a figure!
%     % and, also after!.
%     fh3=figure;
%     set(fh3,'visible','off');
%     plot(abs(Dn(:,1)));
%     save([sdir 'power_after.jpg']);
%     close(fh3);

%     % plot power before manipulation...
%     fh2=figure;
%     set(fh2,'visible','off');
%     plot(abs(D(:,1)));
%     save([sdir 'power_before.jpg']);
%     close(fh2);
    
    
        % keyboard;
        
        % this part works... but now we need a cleverer way to find the
        % points.
%         for j=1:numel(points)
%             
%             p1=points(j);
%             p2=numel(D)-p1+2;
%             
%             % find nearest 20 neighbourhood points... and see what's the ampl. there.
%             
%             ind=(p1-20):(p1+20);
%             
%             % prevent out-of-bounds error.
%             ind=ind(find(ind>0));
%             ind=ind(find(ind<numel(v)));
%             
%             ampl = median(v(ind));
%             
%             % normally distributed amplidude!
%             % and uniformly distributed phase!
%             newpoint=ampl*(1+randn/4)/2*exp(1i*2*pi*rand);
%             % make up a random wave...
%             
%             % keyboard;
%             
%             D(p1)=newpoint;
%             D(p2)=conj(newpoint);
% 
%             
%             
%             
%         end
        
        
        
        