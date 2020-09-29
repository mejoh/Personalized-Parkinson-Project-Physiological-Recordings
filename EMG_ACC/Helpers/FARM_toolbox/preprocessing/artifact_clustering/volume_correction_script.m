%%  do volume-artifact correction first. THEN, we do the rest.


% first step... is to look in our old data, and retrieve the parts that
% were originally V-artifact, using the paramters Vdur and Voffset.


    disp('running volume correction. Template formation+OBS on the (short) volume artifacts');
    % track-keeping struct.
    vo=struct('b',[],'e',[]);
    
    % EEG.data=EEG.data_cleaned;
    
    
    mV=find(strcmp({EEG.event(:).type},'65535'));
    if numel(mV)==0
        mV=find(strcmp({EEG.event(:).type},'V'));
    end
    
    % samples for s and V
    sV=[EEG.event(mV).latency];
    
    
%     % scanner parameters. about 20 ms is the artifact (taken a little bit
%     % on the 'wide' side.
    vduration_detail=round(0.020*EEG.srate);
    voffset_detail=round(-1*1.05*vduration_detail);
%     disp('processing volume markers.');
%     % we take 2 extra samples before b and 2 extra samples after e, to
%     % allow us to re-think the b and e markers of our volumes.


    % do it EXTRA safely, and take a time interval of the beginning of
    % previous slice artifact, to the beginning of the next slice artifact
    % (!).
    
    tmp_off=zeros(1,numel(sV)-2);
    tmp_dur=zeros(1,numel(sV)-2);
    for i=2:numel(sV)-1
        tmp_b(i)=ss(find(ss==sV(i))-1);
        tmp_e(i)=ss(find(ss==sV(i))+1);
        tmp_off(i)=tmp_b(i)-sV(i);
        tmp_dur(i)=tmp_e(i)-tmp_b(i);
    end

    % voffset=median(tmp_off);
    % vduration=median(tmp_dur);

    extra_factor=2;
    %     for j=1:numel(sV)
    % 
    %         vo(j).b=(sV(j)+voffset-extra_factor)*interpfactor;
    %         vo(j).e=(sV(j)+voffset+vduration-1+extra_factor)*interpfactor;
    % 
    %     end


    
    % quick fix, to prevent v-correction taking 2 slice-artifacts around a
    % volume, and make it so that it just takes the volume-artifact (ie,
    % about 0.020 [s], before a V-marker, with just a single extra sample.
    voffset=voffset_detail-1;
    vduration=vduration_detail+3;
    

    for j=1:numel(sV)

        vo(j).b=(sV(j)+voffset-extra_factor)*interpfactor;
        vo(j).e=(sV(j)+voffset+vduration-1+extra_factor)*interpfactor;
        vo(j).bd=(sV(j)+voffset_detail)*interpfactor;
        vo(j).ed=(sV(j)+voffset_detail+vduration_detail-1)*interpfactor;

    end
    
    
    % restore parts of our Volume data!
    for i=1:EEG.nbchan
        
        for j=1:numel(sV)
            EEG.data_cleaned(i,vo(j).bd/interpfactor:vo(j).ed/interpfactor)=EEG.data(i,vo(j).bd/interpfactor:vo(j).ed/interpfactor);
            
        end
    end
    
        
    for i=1:EEG.nbchan

        % build a matrix of volume-artifact data.
        Vmat=zeros(numel(vo(1).b:vo(1).e)+interpfactor-1,numel(vo));
        Vmat_original=zeros(size(Vmat,1)/interpfactor,numel(vo));

        for j=1:numel(sV)

            Vmat_original(:,j)=EEG.data_cleaned(i,vo(j).b/interpfactor:vo(j).e/interpfactor);
            Vmat(:,j)=interp(EEG.data_cleaned(i,vo(j).b/interpfactor:vo(j).e/interpfactor),interpfactor);

        end

        % 'volume-alignment'... use Hilbert transform... determine 'mean' volume artifact...
        % and then put each separate volume artifact on top of this 'mean' one.
        % VmatH=abs(hilbert(Vmat)); 

        % but firstly, let's just try using the mean Vmat.
        meanV=mean(Vmat,2);
        for j=1:numel(vo);

            samples=(vo(1).bd:vo(1).ed)-vo(1).b;
            vo(j).adjustment=find_adjustment(meanV(samples),Vmat(samples,j),round(2*interpfactor),speedup);
            
        end



        % now the second stage of V-removal is first to make a NEW matrix,
        % using the new b and e markers (ie: adjusted), and shorter
        % (2*interpfactor in each end).

        Vmat_aligned=zeros(size(Vmat,1)-2*extra_factor*interpfactor,numel(vo));
        for j=1:numel(vo);

            tmp_b=1+extra_factor*interpfactor+vo(j).adjustment;
            tmp_e=size(Vmat,1)-extra_factor*interpfactor+vo(j).adjustment;
            Vmat_aligned(:,j)=Vmat(tmp_b:tmp_e,j);
        end

        % cluster em?
        Y=pdist(Vmat_aligned','euclidean');
        Z=linkage(Y,'centroid');

        % cluster em.
        N=mojena_stopping_rule(Z,1.5,1.5,150,0,4,0,fh);
        T=cluster(Z,'maxclust',N(1));

        % these are the eligible templates:
        Vtemplates=zeros(size(Vmat_aligned,1),max(T));

        count=zeros(1,max(T));
        for j=1:max(T)
            vec=find(T==j);
            count(j)=numel(vec);
            Vtemplates(:,j)=mean(Vmat_aligned(:,vec),2);
        end
        
        % select the Vtemplates... they should have > 10 template
        % waveforms!
        
%         marked=[];
%         for j=1:numel(count)
%             if count(j)<11
%                 marked=[marked j];
%             end
%         end
%         count(marked)=[];
        % other, GREEN, solution to this problem... change 'count' the
        % last.
        % keyboard;
        Vtemplates(:,count<11)=[];
        count(count<11)=[];





        % now do PCA on volume artifacts! firstly, contruct a residuals matrix,
        % and at the same time construct also, a template matrix.
        Vresidue=zeros(size(Vmat_aligned));
        Vartifact=zeros(size(Vmat_aligned));

        for j=1:numel(vo);



            % first find with which template the correlation is biggest.
            data=Vmat_aligned(:,j);
            corrs=zeros(1,numel(count));
            for k=1:size(Vtemplates,2)
                corrs(k)=prcorr2(data,Vtemplates(:,k));
            end

            vo(j).chosenTemplate=find(corrs==max(corrs),1);
            template=Vtemplates(:,vo(j).chosenTemplate);


            % and after that, find maybe an additional shift...

            extra_adjust=find_adjustment(data,template,2*interpfactor,8);
            vo(j).extra_adjust=extra_adjust;

            % this shifts the template to the left or right, and uses
            % some interpolation to make up the data from  the other end.
            
            if extra_adjust>0
                tmp=template(1+extra_adjust:end);

                % determine RC at the end of template.
                rc=template(end)/2-template(end-2)/2;

                tmp((numel(tmp)+1):(numel(tmp)+extra_adjust))=template(end)+rc*(1:extra_adjust);

                template=tmp;
                template=reshape(template,numel(template),1);
            end

            if extra_adjust<0

                tmp((1-extra_adjust):numel(template))=template(1:(end+extra_adjust));

                % determine RC at the beginning of template.
                rc=template(1)/2-template(3)/2;
                tmp(1:(-extra_adjust))=template(1)+rc*((-extra_adjust):-1:1);

                template=tmp;
                template=reshape(template,numel(template),1);

            end

            % then... determine the correct 'scaling'!!!
            scaling=data'*template/(template'*template);
            Vresidue(:,j)=data-scaling*template;
            Vartifact(:,j)=scaling*template;
        end





        % now do PCA analysis on the residues (!).
        % first de-trend column-wise and row-wise.
        Vresidue_detrended=detrend(Vresidue,'constant');
        off_Vresidue=mean(Vresidue,2);
        Vresidue_detrended=(detrend(Vresidue_detrended','constant')');

        [apc,ascore,asvar]=pca_calc(Vresidue_detrended);

        % thresholding.
        cum_explained_variance=cumsum(asvar/sum(asvar)*100);
        % be twice as hard WRT PCA, when it comes to volume artifacts. they
        % have less averages-in-time. subsequent templates could vary (a
        % lot) more because they occur far less frequent-in-time than the
        % slice artifacts.
        max_components=find(cum_explained_variance<(100-X),1,'last');


        pcamat=ascore(:,1:max_components);

        % re-scale to the 1st component.
        tmp_minmax=max(pcamat(:,1))-min(pcamat(:,1));
        for tmp=2:max_components
            pcamat(:,tmp)=pcamat(:,tmp)*tmp_minmax/...
                (max(pcamat(:,tmp))-min(pcamat(:,tmp)));
        end

        % and now... contruct the 'cleaned' data.
        Vcleaned=zeros(size(Vmat_aligned));

        for j=1:numel(vo)

            fitted_pca=pcamat*(pcamat\Vresidue(:,j));
            Vcleaned(:,j)=Vresidue(:,j)-fitted_pca;
            Vartifact(:,j)=Vartifact(:,j)+fitted_pca;

        end


        % now, we put em back right where they belong... in EEG.data_artifact
        % and EEG.data_cleaned.
        % these matrices will later be updated.
        % but first, we low-pass filter our data with 250 Hz low-passing.



        % now, put it all back at exactly the right spot in the original
        % matrix. then, decimate it again. and finally, use the extra_factor to
        % put it the matrix back at the right spots in EEG.data.

        Vmat_artifact=zeros(size(Vmat));
        Vmat_cleaned=zeros(size(Vmat));

        for j=1:numel(vo)

            tmp_b=1+extra_factor*interpfactor+vo(j).adjustment+vo(j).extra_adjust;
            tmp_e=size(Vmat,1)-extra_factor*interpfactor+vo(j).adjustment+vo(j).extra_adjust;

            Vmat_artifact(tmp_b:tmp_e,j)=Vartifact(:,j);
            Vmat_cleaned(tmp_b:tmp_e,j)=Vcleaned(:,j);

        end
        
        
        % filter n decimate:
        Wn=250/(EEG.srate*interpfactor/2);
        n=round(EEG.srate*interpfactor*(1/250));
        b = fir1(n,Wn,'low');
        
        Vmat_cleaned_f=zeros(size(Vmat_cleaned));
        Vmat_artifact_f=zeros(size(Vmat_artifact));
        
        
        % Vmat_cleaned=detrend(Vmat_cleaned,'constant');
        for j=1:numel(vo)

            Vmat_cleaned_f(:,j)=filtfilt(b,1,Vmat_cleaned(:,j));
            Vmat_artifact_f(:,j)=filtfilt(b,1,Vmat_artifact(:,j));

        end

        
        Vmat_artifact_fd=zeros(size(Vmat,1)/interpfactor,numel(vo));
        Vmat_cleaned_fd=zeros(size(Vmat,1)/interpfactor,numel(vo));
        
        for j=1:numel(vo)
            
            Vmat_artifact_fd(:,j)=decimate(Vmat_artifact_f(:,j),interpfactor);
            Vmat_cleaned_fd(:,j)=decimate(Vmat_cleaned_f(:,j),interpfactor);
            
        end
            
        Vmat_cleaned_fd([1:(extra_factor+1) size(Vmat,1)/interpfactor-((extra_factor+1):-1:1)+1],:)=[];
        Vmat_artifact_fd([1:(extra_factor+1) size(Vmat,1)/interpfactor-((extra_factor+1):-1:1)+1],:)=[];
        Vmat_cleaned_fd=detrend(Vmat_cleaned_fd,'constant');
        
        % Vmat_cleaned_decimated=detrend(Vmat_cleaned_decimated,'constant';
        
        % and now put it 'back', in the EEG traces.

        for j=1:numel(vo)

            tmp1_b=vo(j).b/interpfactor+extra_factor+1;
            tmp1_e=vo(j).e/interpfactor-extra_factor-1;

            EEG.data_cleaned(i,tmp1_b:tmp1_e)=Vmat_cleaned_fd(:,j);
            EEG.data_artifact(i,tmp1_b:tmp1_e)=Vmat_artifact_fd(:,j);

            % and just... also do immedeately the correction for our data.
            % EEG.data(i,tmp1_b:tmp1_e)=Vmat_cleaned_fd(:,j);


        end



    end
    

    % cleanup. there must be more but these are the biggest ones.
    clear Vmat Vmat_aligned Vmat_artifact Vmat_artifact_f Vmat_artifact_fd;
    clear Vmat_cleaned Vmat_cleaned_f Vmat_cleaned_fd Vmat_original;
    clear Vresidue Vartifact Vcleaned Vresidue_detrended Vtemplates meanV;
    clear tmp1_b tmp1_e tmp_b tmp_e tmp_minmax;
    
    % the rest...
    clear pcamat ascore asvar apca fitted_pca cum_explained_variance max_components;
    
    