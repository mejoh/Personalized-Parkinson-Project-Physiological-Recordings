function d=correct_volumes(d,o,m)



% first step... is to look in our old data, and retrieve the parts that
% were originally V-artifact, using the paramters Vdur and Voffset.


    disp('running volume correction. Template formation+OBS on the (short) volume artifacts');
    % track-keeping struct.
    vo=struct('b',[],'e',[]);
    
	% get some variables.
    sV              =m.sv;
    interpfactor    =o.interpfactor;
    duration        =o.vol.duration;
    beginshift      =o.vol.beginshift;
    extra_factor    =o.vol.extra_factor;
    nch             =o.nch;
    fs              =o.fs;
    data            =d.original;
    speedup         =o.corrspeedup;
    tplcount        =o.vol.tplcount;
    
    
    % re-calcute to samples: duration and beginshift(=offset)...
    vduration=round(duration*fs);
    voffset=round(-1*beginshift*vduration);

    % markers, interpolated space.
    for j=1:numel(sV)
        vo(j).b=(sV(j)+voffset-extra_factor)*interpfactor;
        vo(j).e=(sV(j)+voffset+vduration-1+extra_factor)*interpfactor;
    end
    
    
    % build matrix for template extraction n stuff.
    for i=1:nch

        % build a matrix of volume-artifact data.
        Vmat=zeros(numel(vo(1).b:vo(1).e)+interpfactor-1,numel(vo));
        Vmat_original=zeros(size(Vmat,1)/interpfactor,numel(vo));


        for j=1:numel(sV)
            Vmat_original(:,j)=data(vo(j).b/interpfactor:vo(j).e/interpfactor,i);
            Vmat(:,j)=interp(data(vo(j).b/interpfactor:vo(j).e/interpfactor,i),interpfactor);
        end
        


        % get adjustments.
        meanV=mean(Vmat,2);
        for j=1:numel(vo);

            vo(j).adjustment=find_adjustment(meanV,Vmat(:,j),round(2*interpfactor),speedup);
            
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

        % keyboard;
        
        
        
        % cluster em?
        Y=pdist(Vmat_aligned','euclidean');
        Z=linkage(Y,'centroid');

        % cluster em.
        N=mojena_stopping_rule(Z,1.5,1.5,150,0,4,0,0);
        T=cluster(Z,'maxclust',N(1));

        % these are the eligible templates:
        Vtemplates=zeros(size(Vmat_aligned,1),max(T));

        count=zeros(1,max(T));
        for j=1:max(T)
            vec=find(T==j);
            count(j)=numel(vec);
            Vtemplates(:,j)=mean(Vmat_aligned(:,vec),2);
        end
        

        Vtemplates(:,count<tplcount)=[];
        count(count<tplcount)=[];



        % now do PCA on volume artifacts! firstly, contruct a residuals matrix,
        % and at the same time construct also, a template matrix.


        % artifact substraction.
        Vresidue=zeros(size(Vmat_aligned));
        Vartifact=zeros(size(Vmat_aligned));

        for j=1:numel(vo);



            % first find with which template the correlation is biggest.
            tmpdata=Vmat_aligned(:,j);
            corrs=zeros(1,numel(count));
            for k=1:size(Vtemplates,2)
                corrs(k)=prcorr2(tmpdata,Vtemplates(:,k));
            end

            vo(j).chosenTemplate=find(corrs==max(corrs),1);
            template=Vtemplates(:,vo(j).chosenTemplate);


            % and after that, find maybe an additional shift...

            extra_adjust=find_adjustment(tmpdata,template,2*interpfactor,8);
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
            scaling=tmpdata'*template/(template'*template);
            Vresidue(:,j)=tmpdata-scaling*template;
            Vartifact(:,j)=scaling*template;
        end



        
        
                
        % try some hpf's.
        % extract some parameters
        hpf=o.vol.pcahpf;
        fac=o.filter.hpffac;
        nyq=o.fs/2;
        trans=o.filter.trans;
        fs=o.fs;


        % build the filter using fir-least squares
        filtorder=round(fac*fs/(hpf*(1-trans)));
        if rem(filtorder,2)
            filtorder=filtorder+1;
        end

        a=[0 0 1 1];
        f=[0 hpf*(1-trans)/nyq hpf/nyq 1];

        b=firls(filtorder,f,a);
        
        
        

        % tryout... no hpf, on the residues of the volume correction...
        % this'll cause the pca to correct for far greater amount of
        % variability.
        % now do PCA analysis on the residues (!).
        % first de-trend column-wise and row-wise.
        Vresidue_detrended=detrend(Vresidue,'constant');
        Vresidue_detrendedf=zeros(size(Vresidue_detrended));
        for j=1:size(Vresidue_detrended,2)
            Vresidue_detrendedf(:,j)=filtfilt(b,1,Vresidue_detrended(:,j));
        end
        
        
        [apc,ascore,asvar]=pca_calc(Vresidue_detrendedf);

        % thresholding.
        cum_explained_variance=cumsum(asvar/sum(asvar)*100);
        % be twice as hard WRT PCA, when it comes to volume artifacts. they
        % have less averages-in-time. subsequent templates could vary (a
        % lot) more because they occur far less frequent-in-time than the
        % slice artifacts.
        max_components=find(cum_explained_variance<(100-0.25),1,'last');

        

        
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


        
        
        
        % now, put it all back at exactly the right spot in the original
        % matrix. then, decimate it again. and finally, use the extra_factor to
        % put it the matrix back at the right spots in EEG.data.

        
        
        
        % filter < 250 Hz.
        % try some hpf's.
        % extract some parameters
        lpf=o.filter.declpf;
        fac=o.filter.lpffac;
        nyq=o.fs/2;
        trans=o.filter.trans;
        fs=o.fs;


        % build the filter using fir-least squares
        filtorder=round((fac/2)*fs*interpfactor/(lpf));
        if rem(filtorder,2)
            filtorder=filtorder+1;
        end

        a=[1 1 0 0];
        f=[0 lpf/nyq/interpfactor lpf*(1+trans)/nyq/interpfactor 1];

        lpfweights=firls(filtorder,f,a);
        

        
        
        Vcleaned_f=zeros(size(Vcleaned));
        Vartifact_f=zeros(size(Vartifact));
        for j=1:numel(vo)

            Vcleaned_f(:,j)=filtfilt(lpfweights,1,Vcleaned(:,j));
            Vartifact_f(:,j)=filtfilt(lpfweights,1,Vartifact(:,j));

        end
        
        


        
        Vartifact_fd=zeros(size(Vartifact,1)/interpfactor,numel(vo));
        Vcleaned_fd=zeros(size(Vcleaned,1)/interpfactor,numel(vo));
        
        

        for j=1:numel(vo)
            
            Vartifact_fd(:,j)=decimate(Vartifact_f(:,j),interpfactor);
            Vcleaned_fd(:,j)=decimate(Vcleaned_f(:,j),interpfactor);
            
        end
            
        
        
        % and now put it 'back', in the EEG traces.
        

        

        for j=1:numel(vo)

            tmp1_b=vo(j).b/interpfactor+extra_factor;
            tmp1_e=vo(j).e/interpfactor-extra_factor;

            % replace 'original' data.
            d.original(tmp1_b:tmp1_e,i)=Vcleaned_fd(:,j);

            d.vol_artifacts(tmp1_b:tmp1_e,i)=Vartifact_fd(:,j);
            d.vol_cleaned(tmp1_b:tmp1_e,i)=Vcleaned_fd(:,j);

            % and just... also do immedeately the correction for our data.
            % EEG.data(i,tmp1_b:tmp1_e)=Vmat_cleaned_fd(:,j);


        end

    % keyboard;

    end
    

%     % cleanup. there must be more but these are the biggest ones.
%     clear Vmat Vmat_aligned Vmat_artifact Vmat_artifact_f Vmat_artifact_fd;
%     clear Vmat_cleaned Vmat_cleaned_f Vmat_cleaned_fd Vmat_original;
%     clear Vresidue Vartifact Vcleaned Vresidue_detrended Vtemplates meanV;
%     clear tmp1_b tmp1_e tmp_b tmp_e tmp_minmax;
%     
%     % the rest...
%     clear pcamat ascore asvar apca fitted_pca cum_explained_variance max_components;
    
    