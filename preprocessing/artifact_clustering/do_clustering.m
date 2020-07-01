function sl=do_clustering(d,sl,o,m)

    
    fs                  =o.fs;
    ss                  =m.ss;
    sections            =o.sections;
    interpfactor        =o.interpfactor;
    window              =o.window;
    MRtimes             =o.MRtimes;
    % mv                  =o.cl.mojenavalues;

    % minclustsize        =o.cl.minclustsize;
    % biggestclustsize    =o.cl.biggestclustsize;
    nch                 =o.nch;
    % fail_maxclust       =o.cl.fail_maxclust;
    N                   =o.N;
    N2                  =o.N2;
    
    % how many slice-markers in one go?
    seclength           =floor(numel(ss)/sections);
    
    % maxclusters         =o.cl.maxcluster;
    

    
    
    % when the 'adjusts' are known, we can continue with clustering our
    % data.
    % do this for every channel.
    % cluster data; if not enough clusters, proceed to next 'level'.
    disp('clustering the "elects" into most-resembling sub-groups, for each channel, and also determine scaling factors alpha...!');

    
    for i=1:nch

        
        for sc=1:sections
            

            disp(['interpolating data channel ' num2str(i) ' section ' num2str(sc)]);

            % first determine what sl we should go through.
            sli=((sc-1)*seclength+1):(sc*seclength);
            if sc==sections
                sli=((sc-1)*seclength+1):numel(sl);
            end


            
            % do the helper again.
            [samples adjust]=marker_helper(sli,sl,interpfactor);
            v=d.original(samples,i);
            
            % maybe another filter here?
            % v=custom_filter_150_250(v,EEG.srate);
            % iv=interp(v,interpfactor);

            iv=interp(v,interpfactor);


            
            % apply the 'phase shift' to every template.
            % phase-shift ALL slice-artifacts.
            extra=20;
            dur=(numel(sl(1).b:sl(1).e)+2*extra)/fs/interpfactor;
            minj=min([sl(sli(1)).others;sl(sli(2)).others;sli(1)]);
            maxj=max([sl(sli(end)).others;sl(sli(end-1)).others;sli(end)]);            
            for j=minj:maxj
            
                
                %%if j==200;keyboard;end


                 %(20 more samples!)
                tb=sl(j).b-adjust-extra;
                te=sl(j).e-adjust+extra;
                curdata=iv(tb:te);
                
                dt=sl(j).b_rounderr/fs/interpfactor;
                % phase-shift according to the round-off error.
                % take a little bit MORE data...
                curdata2=helper_phaseshifter2(curdata,dur,dt);
                
                % keyboard;

                iv((tb+extra):(te-extra))=curdata2((extra+1):(numel(curdata2)-extra));
                
            end
            
            
            
           % keyboard;
           

            
           

            
            for j=sli


                % if j==200;keyboard;end
                % - rescale
                % - cluster!
                % row or column vectors !?!?! we support row vectors.
                curdata=iv((sl(j).b-adjust):(sl(j).e-adjust));

                % 'elects': data of other artifacts in the neighbourhood.
                clustermat_unscaled=zeros(numel(sl(j).b:sl(j).e),numel(sl(j).others));
                for k=1:numel(sl(j).others)
                    tmp_b=sl(sl(j).others(k)).b-adjust;
                    tmp_e=sl(sl(j).others(k)).e-adjust;
                    % try
                    clustermat_unscaled(:,k)=iv(tmp_b:tmp_e);
                    % catch;keyboard;lasterr;end
                end
                
                % if j==100;keyboard;end
                
                
                
                
            
                % focus on details at the beginning to pick appropriate
                % template.
                MRi=round(MRtimes*interpfactor*fs);
                keep=[1:MRi(1) MRi(2):MRi(3) MRi(4):size(clustermat_unscaled,1)];
            
                % determine N artifacts with maximum correlation to
                % curdata. Then keep the N2 most 'consistent' ones, ie.
                % throw away those templates that are too far away.
                choseni=helper_match(curdata,clustermat_unscaled,keep,N,N2);
                
                % define groups.
                tmpvec=2*ones(1,window);
                tmpvec(choseni)=1;
                
                sl(j).clusterdata(i,:)=tmpvec;
                sl(j).chosenTemplate(i)=1;
                

                % diagnostical information.
                sl(j).templateCorrelation(i)=prcorr2(mean(clustermat_unscaled(:,choseni),2),curdata);
                sl(j).templateAmplitude(i)=max(abs(curdata));
                if j>min(sli)
                    % keyboard;
                    sl(j).templateAngleWrtPrev(i)=curdata'*olddata/sqrt(curdata'*curdata)/sqrt(olddata'*olddata);
                end
                olddata=curdata;
                
                % keyboard;
                

                check=mod(j,round(numel(sl)/100));
                if ~check
                    str=['channel ' num2str(i) ', section ' num2str(sc) ', ' num2str(j/round(numel(sl)/100)) ' percent done \n'];
                    fprintf(str);
                end

            end
        end
    end
    
    

    
%                 % impose another restriction on clustermat... use only the
%                 % very
%                 % first few samples; before the gradient pulses!
%                 % the first 0.014 secs is representative for what comes next!
%                 % throw out some of the gradient-artifact stuff.
%                 % focus even more closely on what you'd like to cluster!!
%                 % the slice-select gradient
%                 % define the exact timing above.
%                 MRi=round(MRtimes*interpfactor*fs);
%                 keep=[1:MRi(1) MRi(2):MRi(3) MRi(4):size(clustermat_unscaled,1)];
%                 % away=1:size(clustermat_unscaled,1);
%                 % away(keep)=0;
%                 % away(away==0)=[];
% 
% 
%                 % away=round([0.0228 0.0488]*EEG.srate*interpfactor);
% 
%                 % round(0.014*EEG.srate*interpfactor);
%                 clustermat_chopped=clustermat_unscaled(keep,:);
%                 curdata_chopped=curdata(keep);
% 
% 
%                 % figure;plot(clustermat_chopped);
%                 % keyboard;
%                 
%                 % how many clusters?
%                 % mojena_stopping_rule(Z,k1_offset,k2_std,window,extra_lag,
%                 % lag_offset,verbosity);
%                 
%                 % and now... our secret weapon, applied!
%                 Y=pdist(clustermat_chopped','correlation');
%                 Z=linkage(Y,'single');
%                 sl(j).Tmat(:,:,i)=Z;
% 
%                 % if i==3&&j==876;keyboard;end
%                 
%                 if o.fs==2048
%                     
%                                         
%                     N=mojena_stopping_rule(Z,mv(1),mv(2),mv(3),0,mv(4),0,0);
%                     
% 
%                     ncount=1;
%                     iterate=1;
% 
%                     % there should be 1 cluster of at the very least, this
%                     % size!
%                     min_elements=biggestclustsize;
%                 
% 
% 
%                     while iterate
% 
% 
%                         T=cluster(Z,'maxclust',N(ncount));
% 
%                         % size of the cluster.
%                         sizes=zeros(1,max(T));
%                         for Ti=1:max(T)
%                             sizes(Ti)=sum(T==Ti);
%                         end
% 
% 
%                         ssizes=sort(sizes,'descend');
% 
% 
%                         if ssizes(1)>=min_elements
%                             iterate=0;
%                             % ncount=ncount;
% 
%                         elseif ssizes(1)<min_elements&&numel(N)>ncount
%                             % keyboard;
%                             disp(['slice ' num2str(j) ': detected too low clustersize (' num2str(ssizes(1)) ') ... going to bigger clusters.']);
%                             iterate=1;
%                             ncount=ncount+1;
%                             % keyboard;
% 
%                         elseif ssizes(1)<min_elements&&numel(N)==ncount
%                             disp(sprintf(['slice ' num2str(j) ': still not enough templates put in clusters, but stopping anyway.\nClustering at maxclust=' num2str(fail_maxclust) '.']));
%                             iterate=0;
% 
%                             % fall back onto something else.
%                             T=cluster(Z,'maxclust',fail_maxclust);
%                             sizes=zeros(1,max(T));
%                             for Ti=1:max(T)
%                                 sizes(Ti)=sum(T==Ti);
%                             end
% 
%                         end
%                     end
%                 end
%                 
%                 
%                 % for aliasing data, some other (!) thresholding scheme!.
%                 if o.fs==1024
%                     
%                     % the mojena stopping rule doesn't work, for aliased
%                     % data. So... we just 'set' the number of clusters to a
%                     % fixed amount (!!)
%                     % this is where we begin...
%                     iterate=1;
%                     ncount=1;
% 
%                     % there should be 1 cluster of at the very least, this
%                     % size!
%                     % min_elements=biggestclustsize;
%                     
%                     % keyboard;
%                     
%                     while iterate
% 
% 
%                         T=cluster(Z,'maxclust',maxclusters+1-ncount);
% 
%                         % size of the cluster.
%                         sizes=zeros(1,max(T));
%                         for Ti=1:max(T)
%                             sizes(Ti)=sum(T==Ti);
%                         end
%                         
% 
% 
%                         ssizes=sort(sizes,'descend');
%                         
%                         % we can't have too many sizes falling between 2
%                         % and maxsizes (only about 4).
%                         
%                         % keyboard;
%                         
%                         % do some manipulation on cluster sizes.
%                         % how many clusters are there that are small?
%                         % keep on going iterating until there are only
%                         % about 3 or 4 of them.
%                         tmpnum=numel(intersect(find(ssizes>1),find(ssizes<8)));
% 
%                         
% 
%                         try
%                             if tmpnum<=4
%                                 iterate=0;
%                                 % ncount=ncount;
% 
%                             else
%                                 % disp(['slice ' num2str(j) ': detected too many clusters (' num2str(numel(ssizes)) ') ... going to bigger clusters.']);
%                                 iterate=1;
%                                 ncount=ncount+1;
% 
%                             end
%                         catch
%                             keyboard;
%                         end
% 
%                         
%                         
%                    end 
%                     
%                    % keyboard;
%                    
% 
%                     
%                     
%                 end
% 
%                 
%                 % keyboard;
%                     
%                 sl(j).clusterdata(i,:)=T;
% 
%                 
%                 
%                 % which correlations are biggest??
%                 corrdata=[];
%                 eligible_clusters=find(sizes>=fail_maxclust);
%                 for tc=1:numel(eligible_clusters)
%                     
%                     vec=find(T==eligible_clusters(tc));
%                     
% 
%                     % corrdata number of elements (to be > 10!).
%                     corrdata(tc,1)=numel(vec);
%                     
%                     % a look-up matrix; the cluster
%                     % number in T to use.
%                     corrdata(tc,2)=eligible_clusters(tc);
%                     
%                     % the correlation.
%                     % scaledmat=ones(size(clustermat_unscaled,1),1)*sl(9000).scalingdata(i,:).*clustermat_unscaled;
%                     % corrdata(tc,3)=prcorr2(curdata,sum(scaledmat(:,vec),2));
%                     corrdata(tc,3)=prcorr2(curdata(keep),mean(clustermat_chopped(:,vec),2));
% 
%                     
%                     
%                 end
%                 
%                 
%                 try
%                 [corr tmp]=max(corrdata(:,3));
%                 catch
%                     keyboard
%                     lasterr
%                 end
%                 % store, for later diagnotical use, the correlation between
%                 % clustermean and 
% 
%                 % keyboard;
%                 sl(j).chosenTemplate(i)=corrdata(tmp,2);
%                 % keyboard;
%         
% 
%                 vec=find(T==sl(j).chosenTemplate(i));
%                 
%                 template=mean(clustermat_unscaled(:,vec),2);
%                 template_chopped=template(keep);
%                 
%                 
%                 
%                 % keyboard;
%                 
%                 % determine slice_template_adjusts??
%                 
%                 % store the scaling for template
%                 sl(j).template_scalings(i)=(curdata_chopped'*template_chopped)/(template_chopped'*template_chopped);    % scaling...
%                 % and also store the correlation.
%                 sl(j).cluster_correlation(i)=prcorr2(curdata_chopped,sl(j).template_scalings(i)*template_chopped);                  % if scaled, then what is the correlation...
%                 % keyboard;
%                 
%                 
% %                 if j==46;
% %                 keyboard;
% %                 end
%                 
%                 
    