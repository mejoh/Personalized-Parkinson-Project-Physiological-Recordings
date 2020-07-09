% todo, 30-1-2009.
%
% (3) find a way to align slices even better --> frequency-alignment within
% clusters?
% --> tried it; setting imaginary part to 0 really distorts the artifact
% template a great deal, BUT... we don't want to change it so robustly, we
% only wish to change the phase a really litttle little bit.
% we can make a helper-function that accepts a) MRtimes, b) srate, c) a 
% segment, d) another segment.
% it then returns a) a phase, b) a frequency and c) the 'adjusted' segment.
% 
% % (2) determine reasonable settings for sampling rate 1024 Hz.
% ideas: a) bigger window, more accurate beginshift, lower level of
% low-pass filtering, more lenient clustering, due to more remaining
% artifact in residuals, be more strict in a) pca thresholding and b) ANC
% noise cancellation.
%
% (1) group settings in a struct:
%   settings include:
% * general: window, interpfactor, beginshift, sections, MRtimes, low-pass
% filter value BEFORE starting, BEFORE decimation, AFTER decimation.
% * clustering: min_clustersize, speedup, min_eligible clustering, values of
% mojena stopping rule (SD, offset).
% * pca: variance explained per basis set, cumsum, slope of asvar
% * ANC: 'ANC' filter, low-pass filter, mu.
%
%
% - look at the helper functions (there's 1 helper filtering function
% that's out-of-place.
%
% - change the filter methods, so that they match with Niazy's
% 
% - look at pca offset/svd calculation, compare with tutorial on pca.
%
% 
% testrun on 1106 and 1106, compare EMG power-spectra.


% artifact correction, using an artifact template made up of clustered
% templates.
%
% we follow Niazy's example for EEG, but with modifications for EMG.
% for in the EMG you CANNOT assume the slice-artifacts are the same... but
% perhaps, they can be clustered.
% the most important modifications:
% - a 20-Hz high-pass filter, ie: 2X the slice-frequency, to counter any
%   kind of movement artifacts degrading the slice-template, instead of 1
%   Hz. 
% - for slice correction, the average artifact made up of the best-fitting
%   cluster of artifact templates
% - using optimal basis sets for removal of remainding artifacts but with
%   higher # of sets.
% - for volume correction, using 0-filling at the times of the start of the
%   new scan --> prospective removal with OBS and adaptive filtering.
% - in frequency domain, 0-filling at all of the slice-frequencies
%   (optional)
% - Low-pass 250 Hz filter, before decimation.
% - using fir-based filtering.
%
%
% and we turn off warnings of the clusterings.
% warning off all.
% impose another restriction on clustermat... use only the very
% first few samples; before the gradient pulses!
% the first 0.014 secs is representative for what comes next!
% throw out some of the gradient-artifact stuff.
% focus even more closely on what you'd like to cluster!!
% the slice-select gradient
% sequence_timing_information = [0.0122    0.0171    0.0244    0.0500];
% tmp_a=1:300;
% the ky + begin kx
% tmp_b=500:750;
% the ending of the slice-readout
% tmp_c=1550:size(clustermat_unscaled,1);

% function EEG=emg_slicecorrection(EEG)

    tic


    % handy for later on. makes it run quicker.
    disp('turning off irritating warning message about nonmonotonic trees');
    warning off stats:linkage:NonMonotonicTree

    % the very first thing we do, is high-pass filter the data at 20
    % Hz.
    disp('filtering data with 20 Hz high-pass filter... in case you havent done it yet');
    Wn=20/(EEG.srate/2);
    n=round(EEG.srate*(4/20));
    if mod(n,2)>0
        n=n-1;
    end
    b = fir1(n,Wn,'high');
    for i=1:EEG.nbchan
        EEG.data(i,:)=filtfilt(b,1,EEG.data(i,:));
    end
    
    
    
    beginshift=0.07;
    interpfactor=20;
    window=60;
    % to save memory, do the interpolations in sections.
    sections=7;
    MRtimes=[0.0122    0.0171    0.0244    0.0500];
    % 5 % power remains, after removal of PCA's fitted components on the residuals.
    X=5;
    % just to have a handle for when it's asked:
    fh=0;
    %ah=axes('parent',fh);
    % a boundary... for the clustering algorithm
    min_clustersize=15;
    if EEG.srate==1024
        min_clustersize=8;
    end
    
    % a second boundary... for the choosing of an applicable cluster.
    % when should you distrust your clustering algorithm and keep going
    % until there are 9 clusters??
    % min_cluster_components=11;

    
    % how much you will speedup your slice-timing alignment:
    if EEG.srate==2048
        speedup=8;
    elseif EEG.srate==1024
        speedup=8;
    end
    

    EEG.data_cleaned=single(zeros(size(EEG.data)));
    EEG.data_artifact=single(zeros(size(EEG.data)));
    
    
    % find ss...
    ms=find(strcmp({EEG.event(:).type},'sliceTrigger'));
    if numel(ms)==0
        ms=find(strcmp({EEG.event(:).type},'s'));
    end
    ss=[EEG.event(ms).latency];
    % for memory purposes: seclength!
    seclength=floor(numel(ss)/sections);
    
    % calculate # samples for slices.
    sduration=ceil(median(ss(2:end)-ss(1:end-1)));
    % calculate beginning for offset.
    soffset=round(-1*beginshift*sduration);
    
   

%%    
    % now calculate the 'adjusts'; the amount of data points the others
    % have to shift to be in 'perfect' alignment with the current slice
    % template.
    % calculated again for each individual slice.
    % you can't take no chances with changing slice-templates!
    % a) use high-pass filter
    % b) use a 'section' of the artifact instead of it all
    % c) use a very fast corr. function
    % d) use a speedup factor for calculating the correlation.
    
    
    % initialize the sl struct.
    sl=struct(...
        'b',int32(0),...
        'e',int32(0),...
        'others',int32(zeros(1,window)),...
        'adjusts',int16(zeros(1,window)),...
        'scalingdata',single(zeros(EEG.nbchan,window)),...
        'Tmat',single(zeros(window-1,3,EEG.nbchan)),...
        'clusterdata',int16(zeros(EEG.nbchan,window)),...
        'chosenTemplate',int16(zeros(1,EEG.nbchan)),...
        'template_scalings',single(zeros(1,EEG.nbchan)),...
        'template_adjusts',single(zeros(1,EEG.nbchan)),...
        'cluster_correlation',single(zeros(1,EEG.nbchan))...
        );
   
    
    
    
    % initial choice for the other slices.
    % and initial adjustments for the other slice artifacts.
    disp('for each slice, selecting (other) candidate-"elects" for the tempate.');
    for i=1:numel(ss)
        
        % a neat solution for index i= near 1 and numel(ss)!
        sl(i).others=pick_function(i,numel(ss),window);
        
        % beginning and ending samples
        sl(i).b=(ss(i)+soffset)*interpfactor;
        sl(i).e=(ss(i)+soffset+sduration-1)*interpfactor;

    end
    
    
    
%%   
    
    
    disp('slice-timing the canditate-"elects" to the slice-artifacts');
    for sc=1:sections
        % first determine what sl we should go through.
        sli=((sc-1)*seclength+1):(sc*seclength);
        if sc==sections
            sli=((sc-1)*seclength+1):numel(sl);
        end

        [samples adjust]=marker_helper(sli,sl,interpfactor);

        % high-pass filter this v with > 200 Hz filter.
        v=EEG.data(1,samples);
        v=custom_filter_250(v,EEG.srate);
        iv=interp(v,interpfactor);


        for i=sli

            curdata=iv((sl(i).b-adjust):(sl(i).e-adjust))';

            % find for all of the other elements, the optimal time-shift.
            % the time this takes, scales with interpfactor*window.
            mat=zeros(size(curdata,1),numel(sl(i).others));
            for j=1:numel(sl(i).others)

                % what is the beginning and ending of the other slices??
                tmp_b=sl(sl(i).others(j)).b-adjust;
                tmp_e=sl(sl(i).others(j)).e-adjust;
                mat(:,j)=iv(tmp_b:tmp_e)';
            end
            
            
            MRi=round(MRtimes*interpfactor*EEG.srate);
            keep=[1:MRi(1) MRi(2):MRi(3) MRi(4):size(mat,1)];
            away=1:size(mat,1);
            away(keep)=0;
            away(away==0)=[];

            % use this chopped matrix for the correlation function.
            mat_chopped=mat(keep,:);
            curdata_chopped=curdata(keep);
            
            
            % find the adjustments.
            adjustments=zeros(1,numel(sl(i).others));
            mat_adjusted=zeros(size(curdata,1),numel(sl(i).others));
            for j=1:size(mat,2)
                % compare the following with curdata.
                otherdata=mat_chopped(:,j);

                adjustments(j)=find_adjustment(curdata_chopped,otherdata,round(2*interpfactor),speedup);

                % contruct 'adjusted mat.
                tmp_b=sl(sl(i).others(j)).b-adjust+adjustments(j);
                tmp_e=sl(sl(i).others(j)).e-adjust+adjustments(j);
                mat_adjusted(:,j)=iv(tmp_b:tmp_e);

            end
            
            sl(i).adjusts=adjustments;
            

            % diagnostics for displaying the progress.
            check=mod(i,round(numel(sl)/100));
            if ~check
                str=['section ' num2str(sc) '/' num2str(sections) ', ' num2str(i/round(numel(sl)/100)) ' percent done.\n'];
                fprintf(str);
            end


        end
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
%%
    % when the 'adjusts' are known, we can continue with clustering our
    % data.
    % do this for every channel.
    % cluster data; if not enough clusters, proceed to next 'level'.
    disp('clustering the "elects" into most-resembling sub-groups, for each channel, and also determine scaling factors alpha...!');

    
    for i=1:EEG.nbchan

        
        
        for sc=1:sections
            
            disp(['interpolating data channel ' num2str(i) ' section ' num2str(sc)]);

            % first determine what sl we should go through.
            sli=((sc-1)*seclength+1):(sc*seclength);
            if sc==sections
                sli=((sc-1)*seclength+1):numel(sl);
            end


            
            % do the helper again.
            [samples adjust]=marker_helper(sli,sl,interpfactor);
            v=EEG.data(i,samples);
            v=custom_filter_150_250(v,EEG.srate);
            % iv=interp(v,interpfactor);

            iv=interp(v,interpfactor);


            % v=interp(EEG.data(i,:),interpfactor);
            for j=sli


                
                % - rescale
                % - cluster!
                % row or column vectors !?!?! we support row vectors.
                curdata=iv((sl(j).b-adjust):(sl(j).e-adjust))';

                % clustermat_unscaled=zeros(numel(sl(j).b:sl(j).e),numel(sl(j).others));
                clustermat_unscaled=zeros(numel(sl(j).b:sl(j).e),numel(sl(j).others));

                for k=1:numel(sl(j).others)


                    tmp_b=sl(sl(j).others(k)).b + sl(j).adjusts(k)-adjust;
                    tmp_e=sl(sl(j).others(k)).e + sl(j).adjusts(k)-adjust;

                    % one of the other artifact templates.
                    otherdata=iv(tmp_b:tmp_e)';
                    
                    % determing scaling parameters(!), for each channel.
                    scale_factor=curdata'*otherdata/(otherdata'*otherdata);

                    % storing scaling info
                    sl(j).scalingdata(i,k)=scale_factor;
                    
                    % and scaling the (filtered -- with less emg
                    % 'artifact') artifact template.
                    clustermat_unscaled(:,k)=otherdata;
                    % clustermat_scaled(:,k)=scale_factor*otherdata;
 
                end
                


                % impose another restriction on clustermat... use only the
                % very
                % first few samples; before the gradient pulses!
                % the first 0.014 secs is representative for what comes next!
                % throw out some of the gradient-artifact stuff.
                % focus even more closely on what you'd like to cluster!!
                % the slice-select gradient
                % define the exact timing above.
                MRi=round(MRtimes*interpfactor*EEG.srate);
                keep=[1:MRi(1) MRi(2):MRi(3) MRi(4):size(clustermat_unscaled,1)];
                away=1:size(clustermat_unscaled,1);
                away(keep)=0;
                away(away==0)=[];


                % away=round([0.0228 0.0488]*EEG.srate*interpfactor);

                % round(0.014*EEG.srate*interpfactor);
                clustermat_chopped=clustermat_unscaled(keep,:);


                
                % how many clusters?
                % mojena_stopping_rule(Z,k1_offset,k2_std,window,extra_lag,
                % lag_offset,verbosity);
                
                % and now... our secret weapon, applied!
                Y=pdist(clustermat_chopped','euclidean');
                Z=linkage(Y,'centroid');
                sl(j).Tmat(:,:,i)=Z;

                N=mojena_stopping_rule(Z,1,5,35,0,4,0,fh);
                

                ncount=1;
                iterate=1;
                
                % there should be 1 cluster of at the very least, this
                % size!
                min_elements=min_clustersize;
                
                while iterate

                    T=cluster(Z,'maxclust',N(ncount));

                    % size of the cluster.
                    sizes=zeros(1,max(T));
                    for Ti=1:max(T)
                        sizes(Ti)=sum(T==Ti);
                    end
                
                    if max(sizes)>=min_elements
                        iterate=0;
                        % ncount=ncount;
                    
                    elseif max(sizes)<min_elements&&numel(N)>ncount
                        % keyboard;
                        % disp(['slice ' num2str(j) ': detected too low clustersize (' num2str(max(sizes)) ') ... going to bigger clusters.']);
                        iterate=1;
                        ncount=ncount+1;

                    elseif max(sizes)<min_elements&&numel(N)==ncount
                        disp(['slice ' num2str(j) ': still not enough templates put in clusters, but stopping anyway.\nClustering at maxclust=7.']);
                        iterate=0;
                        
                        % fall back onto something else.
                        T=cluster(Z,'maxclust',7);
                        sizes=zeros(1,max(T));
                        for Ti=1:max(T)
                            sizes(Ti)=sum(T==Ti);
                        end
                        
                        % ncount=ncount;
                    end
                end

                    
                sl(j).clusterdata(i,:)=T;

                
                % which correlations are biggest??
                corrdata=[];
                eligible_clusters=find(sizes>=min_clustersize);
                for tc=1:numel(eligible_clusters)
                    
                    vec=find(T==eligible_clusters(tc));
                    

                    % corrdata number of elements (to be > 10!).
                    corrdata(tc,1)=numel(vec);
                    
                    % a look-up matrix; the cluster
                    % number in T to use.
                    corrdata(tc,2)=eligible_clusters(tc);
                    
                    % the correlation.
                    % scaledmat=ones(size(clustermat_unscaled,1),1)*sl(9000).scalingdata(i,:).*clustermat_unscaled;
                    % corrdata(tc,3)=prcorr2(curdata,sum(scaledmat(:,vec),2));
                    corrdata(tc,3)=prcorr2(curdata,mean(clustermat_unscaled(:,vec),2));

                    
                    
                end
                
                
                try
                [corr tmp]=max(corrdata(:,3));
                catch
                    keyboard
                    lasterr
                end
                % store, for later diagnotical use, the correlation between
                % clustermean and 

                sl(j).chosenTemplate(i)=corrdata(tmp,2);
        


                check=mod(j,round(numel(sl)/100));
                if ~check
                    str=['channel ' num2str(i) ', section ' num2str(sc) ', ' num2str(j/round(numel(sl)/100)) ' percent done \n'];
                    fprintf(str);
                end

            end

        end
    end
    
    
    
%% and now an in-between step, to align the slices precisely.

for i=1:EEG.nbchan
    
        
    for sc=1:sections
        
        disp(['refining template adjustments and scalings, channel ' num2str(i) ' section ' num2str(sc)]);

        % first determine what sl we should go through.
        sli=((sc-1)*seclength+1):(sc*seclength);
        if sc==sections
            sli=((sc-1)*seclength+1):numel(sl);
        end



        % do the helper again.
        [samples adjust]=marker_helper(sli,sl,interpfactor);
        v=EEG.data(i,samples);
        iv=interp(v,interpfactor);

        for j=sli

            % make the 'current data'.
            curdata=iv((sl(j).b-adjust):(sl(j).e-adjust))';

            % construct the template.
            % which of the others to take??
            parts=find(sl(j).clusterdata(i,:)==sl(j).chosenTemplate(i));
            adjusts=sl(j).adjusts(parts);
            scalings=sl(j).scalingdata(i,parts);
            
            
            % construct the template.
            mat=zeros(numel(curdata),numel(parts));
            for tc=1:numel(parts)
                tmp_b=sl(sl(j).others(parts(tc))).b+adjusts(tc)-adjust;
                tmp_e=sl(sl(j).others(parts(tc))).e+adjusts(tc)-adjust;
                otherdata=iv(tmp_b:tmp_e)'*scalings(tc);

                mat(:,tc)=otherdata;

            end
            template=mean(mat,2);
            
            
            % now calculate template temporal adjustment and extra scaling
            % factor.
            extra_adjust=find_adjustment(curdata,template,2*interpfactor,8);

            % do some tricks to faithfully calculate the extra needed
            % scaling for the template.
            tmp=zeros(size(template));
            if extra_adjust>0
                tmp=template(1+extra_adjust:end);

                % determine RC at the end of template.
                rc=template(end)/2-template(end-2)/2;

                tmp((numel(tmp)+1):(numel(tmp)+extra_adjust))=template(end)+rc*(1:extra_adjust);

                template=tmp;
            end
        
            if extra_adjust<0

                tmp((1-extra_adjust):numel(template))=template(1:(end+extra_adjust));

                % determine RC at the beginning of template.
                rc=template(1)/2-template(3)/2;
                tmp(1:(-extra_adjust))=template(1)+rc*((-extra_adjust):-1:1);

                template=tmp;

            end
            
            sl(j).template_scalings(i)=(curdata'*template)/(template'*template);
            sl(j).template_adjusts(i)=extra_adjust;
            
            % for later diagnostical use, store the 'cluster correlation'.
            % how well does you matched cluster actually fit the current
            % slice template ???
            sl(j).cluster_correlation(i)=prcorr2(curdata,sl(j).template_scalings(i)*template);
            
            
            check=mod(j,round(numel(sl)/100));
            if ~check
                str=['channel ' num2str(i) ', section ' num2str(sc) ', ' num2str(j/round(numel(sl)/100)) ' percent done \n'];
                fprintf(str);
            end
 
        end
    
    end
end
            
            
% using a neat helper function, I can now make a template for each slice, that consists of an average of a somewhat picky choice of surrounding slices using cluster analysis. The templates have been further refined with an extra temporal shift, and also a scaling-per-template.         


%% save this crazy work.

    % using the sl and EEG structs, you can generate any type of template.
    % very useful for doing a ppt presentation on this subject matter and
    % making nice plots... and also monitor what's *really* going on.
    save sl sl
    
    
    
    
    

%%
    
    % and now, perform PCA on the residuals to gain even more information
    % on the artifacts.
    % maybe store per slice, the template used for substraction -- as well
    %
    % this is the final section. It estimates PCA components, removes the
    % best fit (Data-Template(cluster)-pcamat*beta = clean_data), removes
    % volume repetitive artifacts, 
    % filters&downsamples the EMG data, and prepares output for... ANC! The
    % final (rather necessary) step in this whole procedure.
    

    disp('calculating the PC of the residuals, and storing...');
    for i=1:EEG.nbchan


        
        for sc=1:sections
            
            disp(['interpolating data channel ' num2str(i) ' section ' num2str(sc)]);

            % first determine what sl we should go through.
            sli=((sc-1)*seclength+1):(sc*seclength);
            if sc==sections
                sli=((sc-1)*seclength+1):numel(sl);
            end


            
            % do the helper again.
            [samples adjust]=marker_helper(sli,sl,interpfactor);
            v=EEG.data(i,samples);
            iv=interp(v,interpfactor);
            
            try
                residuals=zeros(numel(sl(1).b:sl(1).e),numel(sli));
            catch
                disp('out of memory... fixing with pack.');
                pack;
                residuals=zeros(numel(sl(1).b:sl(1).e),numel(sli));
            end
                
                
            
            disp(['channel ' num2str(i) ', section ' num2str(sc) ', constructing residual matrix for PCA']);
            
            for j=1:numel(sli)
               
                curdata=iv((sl(sli(j)).b-adjust):(sl(sli(j)).e-adjust))';

                template=helper_slice(iv,adjust,sli(j),i,sl,[]);
                
                residuals(:,j)=curdata-template;
                
                
%                 % diagnostics for displaying the progress.
%                 check=mod(i,round(numel(sl)/100));
%                 if ~check
%                     str=['section ' num2str(sc) '/' num2str(sections) ', ' num2str(i/round(numel(sl)/100)) ' percent done.\n'];
%                     fprintf(str);
%                 end
                
                
                
            end
            
            
            % DO PCA 
            % first detrend column-wise (automatically, in matlab...)
            resmeans=mean(residuals);
            residuals=detrend(residuals,'constant');
            off_residuals=mean(residuals,2);
            
            residuals=detrend(residuals','constant')';
            
            
            disp('now calculating the PCs');
            [apc,ascore,asvar]=pca_calc(residuals);
            
            clear residuals;
            clear apc;    
            % clear some memory!

            % build up the matrix of the components.

            % first determing the right slice; take the mean of all
            % slice-artifacts that are in the cluster defined by
            % clusterdata, shifted by adjusts and scaled by
            % scalingdata.
            % then substract it... and after that, add to PCA matrix.
            
            % what number of components need to be added, so that the
            % explained variance is < X (usr specifies) percent??
            % cum_explained_variance=cumsum(asvar/sum(asvar)*100);
            % max_components=find(cum_explained_variance<(100-X),1,'last')+1;
            TH_SLOPE=1.5;
            TH_CUMVAR=85;
            TH_VAREXP=4;
            
            oev=100*asvar/sum(asvar);
            d_oev=find(abs(diff(oev))<TH_SLOPE);
            dd_oev=diff(d_oev);
            for I=1:length(dd_oev)-3
                if [dd_oev(I) dd_oev(I+1) dd_oev(I+2)]==[1 1 1]
                    break
                end
            end
            SLOPETH_PC=d_oev(I)-1;
            TMPTH=find(cumsum(oev)>TH_CUMVAR);
            CUMVARTH_PC=TMPTH(1);
            TMPTH=find(oev<TH_VAREXP);
            VAREXPTH_PC=TMPTH(1)-1;
            max_components=floor(mean([SLOPETH_PC CUMVARTH_PC VAREXPTH_PC]));
            fprintf('\n%d residual PCs will be removed from channel %d\n',max_components,i); 

            
            % to gain a 'green' light.. replace last pca component...
            % with... the offset of the residuals!!
            pcamat=ascore(:,1:max_components);
            clear ascore;
            % and then... add the means, again, to gain the
            % full set of... ' compressed residuals '.
            % a test?
            % pcamat(:,end)=off_residuals; % +repmat(off_residuals,1,size(pcamat,2));
            
            
            % re-scale to the 1st component... is this... REALLY necessary
            % !??!? nope.
            tmp_minmax=max(pcamat(:,1))-min(pcamat(:,1));
            for tmp=2:max_components
                pcamat(:,tmp)=pcamat(:,tmp)*tmp_minmax/...
                    (max(pcamat(:,tmp))-min(pcamat(:,tmp)));
                
                
            end

            
            % maybe store the components in a nice file?
%             for i=1:numel(max_components)
%                 save(['pcamat_section_' num2str(sc) '.mat']);
%                 
%             end
% nah.
            
            
            % now make the final two matrices, which are used in the
            % decimation process. cleaned_data, and adjusted_artifact.
            
            % make new vectors in interpfactor*20 space, and place it all
            % on exactly the right spot.
            % first vector's going to be artifact (template+fitted_pca).
            % second vector: cleaned_data (curdata-template-fitted_pca).
            
            % cleaned_data=zeros(numel(sl(1).b:sl(1).e),numel(sli));
            % adjusted_template=zeros(numel(sl(1).b:sl(1).e),numel(sli));
            
            % after iv, also create artifact and cleaned -interpolated-
            % data.
            iv_artifact=zeros(size(iv));
            iv_cleaned=zeros(size(iv));
            
            for j=1:numel(sli);

                
                tb=sl(sli(j)).b-adjust;
                te=sl(sli(j)).e-adjust;
                curdata=iv(tb:te)';
                template=helper_slice(iv,adjust,sli(j),i,sl,[]);
                residual=curdata-template;
                % see a tutorial on principal component analysis, from Linday I
                % Smith. (google-search it).
                fitted_pca=pcamat*(pcamat\residual);
                
                % this is deemed to be the artifact: one term from the
                % clustered template waveforms, and another from the fitted
                % principal components of the residuals after template
                % substraction.
                iv_artifact(tb:te)=template+fitted_pca;
                
                cleaned=curdata-template-fitted_pca;
                % and this, is thought to be somewhat 'cleaned' signal; the
                % raw data with removed, our best guess of what might be
                % artifact-related.
                iv_cleaned(tb:te)=curdata-template-fitted_pca;
                
                
%                 % diagnostics for displaying the progress.
%                 check=mod(i,round(numel(sl)/100));
%                 if ~check
%                     str=['section ' num2str(sc) '/' num2str(sections) ', ' num2str(i/round(numel(sl)/100)) ' percent done.\n'];
%                     fprintf(str);
%                 end
%                 
%                 % de-bug...
%                 set(ah,'nextplot','replace');
%                 plot(ah,curdata,'k');
%                 set(ah,'nextplot','add');
%                 plot(ah,curdata-template,'g');
%                 plot(ah,curdata-template-fitted_pca,'r');
                
            end



            % now that we have iv_artifact and iv_cleaned, let's first
            % low-pass filter em, and then after that decimate em.
            disp('filtering data < 250 Hz.... ');
            Wn=250/(EEG.srate*interpfactor/2);
            n=round(EEG.srate*interpfactor*(4/250));
            % trade-off between speed of filtering, and quality of
            % filtering :-(
            b = fir1(n,Wn,'low');
            
            % reshuffle our memory!
            try
                iv_cleaned=filtfilt(b,1,iv_cleaned);


            catch
                pack;
                disp('out-of-memory workaround using the pack function.');
                iv_cleaned=filtfilt(b,1,iv_cleaned);

            end
            
            % reshuffle our memory!
            try
                iv_artifact=filtfilt(b,1,iv_artifact);

            catch
                pack;
                disp('out-of-memory workaround using the pack function.');
                iv_artifact=filtfilt(b,1,iv_artifact);

            end
            

                            

            
            
            v_cleaned=decimate(iv_cleaned,interpfactor);
            v_artifact=decimate(iv_artifact,interpfactor);
            
%             % 20 (!) Hz high-pass.
%             Wn=20/(EEG.srate/2);
%             n=round(EEG.srate*(4/20));
%             if mod(n,2)>0
%                 n=n-1;
%             end
%             b = fir1(n,Wn,'high');
%             v_cleaned=filtfilt(b,1,v_cleaned);
%             v_artifact=filtfilt(b,1,v_artifact);
            
            
            % and... finally, store the 'cleaned' data and the stuff that
            % we substracted. 
            
            % which samples do we need to replace again??
            % samples in data....
            samples_trace=(sl(min(sli)).b/interpfactor):sl(max(sli)).e/interpfactor;

            % and! samples in our decimated data.
            % divide by interpfactor, the summation of 1) adjust, 2)
            % 5*interpfactor, 3) difference between b of min of others and
            % b of the min.
            % this is NOT trivial!!! you should draw it out on a ruler.
            % the assumption that markers' = markers*interpfactor when you
            % interpolate, that is not...
            % not really that good. but... doesn't matter that much.
            % the real data begins when 
            tmp_BEGIN=(5*interpfactor+sl(min(sli)).b-sl(min(sl(min(sli)).others)).b)/interpfactor+1;
            if sc==1
                tmp_BEGIN=5+1;
            end
            tmp_END=tmp_BEGIN+numel(samples_trace)-1;
            samples_vector=tmp_BEGIN:tmp_END;
            
            disp(['done, with samples: ' num2str(min(samples_trace)) ' through ' num2str(max(samples_trace))]);
            
            EEG.data_cleaned(i,samples_trace)=v_cleaned(samples_vector);
            EEG.data_artifact(i,samples_trace)=v_artifact(samples_vector);
            
                
        end
        
    end
    
    
%% again, save our hard work.


% filter all with 20 Hz low-pass filter.
    % the very first thing we do, is high-pass filter the data at 20
    % Hz.
    disp('filtering data with 20 Hz high-pass filter... again!!');
    Wn=20/(EEG.srate/2);
    n=round(EEG.srate*(4/20));
    if mod(n,2)>0
        n=n-1;
    end
    b = fir1(n,Wn,'high');
    for i=1:EEG.nbchan
        EEG.data(i,:)=filtfilt(b,1,EEG.data(i,:));
        EEG.data_cleaned(i,:)=filtfilt(b,1,EEG.data_cleaned(i,:));
        EEG.data_artifact(i,:)=filtfilt(b,1,EEG.data_artifact(i,:));
    end
    

disp('saving EEG struct, without (yet) the volume correction...');
save EEG_corrected_tem_obs.mat EEG
            
    
    
    

%%    
    
    toc


   % total_minutes=(begin_seconds-end_seconds)/60;
   % disp(['correction almost done. This lasted about ' num2str(total_minutes) ' minutes.']);
    
    
%% the final stuff. do ANC, using our desamples data found in EEG.data_template and EEG.data_cleaned.
%
% refer to paper from Niazy and fmrib toolbox on how to implement this.
%
% after all these manipulations, i'm pretty sure that what you have left,
% are the most stochastic components of the EMG.
%
%
fs=EEG.srate;
trans=0.15;
nyq=0.5*fs;
lpf=250;
minfac=3;

filtorder=round(minfac*fix(fs/lpf));

if rem(filtorder,2)~=0
    filtorder=filtorder+1;
end

f=[0 lpf/nyq lpf*(1+trans)/nyq 1];
a=[1 1 0 0];
lpfwts=firls(filtorder,f,a);





Tr=1;
while Tr<=length(ss)
    Trtime=ss(Tr+1)-ss(1);
    if Trtime>=fs
        break
    end
    Tr=Tr+1;
end
    % keyboard;
ANCf=0.75*Tr;

filtorder=round(1.2*fs/(ANCf*(1-trans)));
if rem(filtorder,2)~=0
    filtorder=filtorder+1;
end

f=[0 ANCf*(1-trans)/nyq ANCf/nyq 1];
a=[0 0 1 1];
ANCfwts=firls(filtorder,f,a);



N=sduration+2;
d1=ss(1);
d2=ss(end)+sduration;
mANC=d2-d1+1;

try
    EEG.data_cleaned_ANC=zeros(size(EEG.data_cleaned));
catch
    pack;
end
%%
for i=1:EEG.nbchan
    
    % do ANC for every channel separately!
    Noise=EEG.data_artifact(i,:)';
    cleanEEG=EEG.data_cleaned(i,:)';
    
    % do a filter, low-pass, at 250 Hz.
    cleanEEG=filtfilt(lpfwts,1,cleanEEG);
    Noise=filtfilt(lpfwts,1,Noise);
    
    % do a filter, high-pass, at f_slice/2.
    refs=Noise(d1:d2);
    tmpd=filtfilt(ANCfwts,1,cleanEEG);
    d=double(tmpd(d1:d2));
    Alpha=sum(d.*refs)/sum(refs.*refs);
    refs=double(Alpha*refs);
    mu=double(0.05/(N*var(refs)));
    
    [out,y]=fastranc(refs,d,N,mu);
    
    if isinf(max(y))
        wst=sprintf('ANC Failed for channel number %d. Skipping ANC.',i);
        warning(wst);
        disp('hmmokay. did nothing.');
    else
        EEG.data_cleaned_ANC(i,d1:d2)=EEG.data_cleaned(i,d1:d2)-y';
    end
    disp(sprintf('done with channel... %d!',i));
    
end
    
    

    
%% extra stuff.
    % now, low-pass filter with 250 Hz and downsample.
    
    
   
    
    
    
    % and finally, apply the ANC cancellation procedure.
    
    
    
    % done!
    
    
%     % which of the others to take??
%                 parts=find(sl(j).clusterdata(i,:)==sl(j).chosenTemplate(i));
%                 adjusts=sl(j).adjusts(parts);
%                 scalings=sl(j).scalingdata(i,parts);
%                 
                % construct the template.
%                 mat=zeros(numel(curdata),numel(parts));
%                 for tc=1:numel(parts)
%                     tmp_b=sl(sl(j).others(parts(tc))).b+adjusts(tc)-adjust;
%                     tmp_e=sl(sl(j).others(parts(tc))).e+adjusts(tc)-adjust;
%                     otherdata=iv(tmp_b:tmp_e)'*scalings(tc);
% 
%                     mat(:,tc)=otherdata;
%                     
%                 end
%                 template=mean(mat,2);
    
    
 
    
            
    
    

% %%
% 
%             oev=100*asvar/sum(asvar);
%             if sec==1
%                 if ischar(npc)
%                     d_oev=find(abs(diff(oev))<TH_SLOPE);
%                     dd_oev=diff(d_oev);
%                     for I=1:length(dd_oev)-3
%                         if [dd_oev(I) dd_oev(I+1) dd_oev(I+2)]==[1 1 1]
%                             break
%                         end
%                     end
%                     SLOPETH_PC=d_oev(I)-1;
%                     TMPTH=find(cumsum(oev)>TH_CUMVAR);
%                     CUMVARTH_PC=TMPTH(1);
%                     TMPTH=find(oev<TH_VAREXP);
%                     VAREXPTH_PC=TMPTH(1)-1;
%                     pcs=floor(mean([SLOPETH_PC CUMVARTH_PC VAREXPTH_PC]));
%                     fprintf('\n%d residual PCs will be removed from channel %d\n',pcs,c);                    
%                 else
%                     pcs=npc;
%                 end
%             end
%             
%             
%             f strig==0
%                 papc=double([ascore(:,1:pcs) ones(pre_peak+max_postpeak+1,1)]);
%             else
%                 papc=double([ascore(:,1:pcs)]);
%             end
%          
% 
%             minmax1=max(papc(:,1))-min(papc(:,1));
%             for apc=2:pcs
%                 papc(:,apc)=papc(:,apc)*minmax1/...
%                     (max(papc(:,apc))-min(papc(:,apc)));
%             end
%             
%             
%             
%             minmax1=max(papc(:,1))-min(papc(:,1));
%             for apc=2:pcs
%                 papc(:,apc)=papc(:,apc)*minmax1/...
%                     (max(papc(:,apc))-min(papc(:,apc)));
%             end
% 
%             for s=starts:lasts
%                 if s==1
%                     if ~STARTFLAG
%                        fitted_res(secmarker(s)-pre_peak:secmarker(s)+max_postpeak)=...
%                            papc*(papc\...
%                            double(Ipca(secmarker(s)-pre_peak:...
%                            secmarker(s)+max_postpeak))');
%                     end
%             
            