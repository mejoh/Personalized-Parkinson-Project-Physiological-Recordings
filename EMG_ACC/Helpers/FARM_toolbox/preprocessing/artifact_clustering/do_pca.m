% function d=do_pca(d,sl,o);
%
%
% and now, perform PCA on the residuals to gain even more information
% on the artifacts.
% maybe store per slice, the template used for substraction -- as well
%
% this is the final section. It estimates PCA components, removes the
% best fit (Data-Template(cluster)-pcamat*beta = clean_data), removes
% volume repetitive artifacts,
% filters&downsamples the EMG data, and prepares output for... ANC! The
% final (rather necessary) step in this whole procedure.


function [d sl m]=do_pca(d,sl,o,m)


nch                         =o.nch;
interpfactor                =o.interpfactor;

usr_max_components          =o.pca.usr_max_components;
usr_max_components2         =o.pca.usr_max_components2;

% second_iter_components    =o.pca.second_iter_components;

declpf                      =o.filter.declpf;
lpffac                      =o.filter.lpffac;

fs                          =o.fs;
nyq                         =fs/2;
sections                    =o.sections;
seclength                   =o.seclength;

% pcahpf                    =o.filter.pcahpf;
nslices                     =o.nslices;
nvol                        =o.nvol;



disp('calculating the PC of the residuals, and storing...');

for i=1:nch
    
    
    for sc=1:sections
        
        disp(['interpolating data channel ' num2str(i) ' section ' num2str(sc)]);
        
        % first determine what sl we should go through.
        sli=((sc-1)*seclength+1):(sc*seclength);
        if sc==sections
            sli=((sc-1)*seclength+1):numel(sl);
        end
        
        
        
        % do one more slice --> to prevent filter stepfunction
        % artifacts.
        
        if sc==1
            replace=[1 max(sli)];
            sli=[sli max(sli)+1];
        end
        if sc==sections
            replace=[min(sli) max(sli)];
            sli=[min(sli)-1 sli];
        end
        if sc>1&&sc<sections
            replace=[min(sli) max(sli)];
            sli=[min(sli)-1 sli max(sli)+1];
        end
        
        
        % do the helper again.
        [samples adjust]=marker_helper(sli,sl,interpfactor);
        v=d.original(samples,i);
        iv=interp(v,interpfactor);
        iv_artifact=zeros(size(iv));
        
        
        
        % phase-shift ALL slice-artifacts.
        disp('time-shifting...');
        extra=20;
        dur=(numel(sl(1).b:sl(1).e)+2*extra)/fs/interpfactor;
        
        minj=min([sl(sli(1)).others;sl(sli(2)).others;sli(1)]);
        maxj=max([sl(sli(end)).others;sl(sli(end-1)).others;sli(end)]);
        
        
        for j=minj:maxj
            
            %(20 more samples!)
            tb=sl(j).b-adjust-extra;
            te=sl(j).e-adjust+extra;
            curdata=iv(tb:te);
            
            dt=sl(j).b_rounderr/fs/interpfactor;
            % phase-shift according to the round-off error.
            % take a little bit MORE data...
            curdata2=helper_phaseshifter2(curdata,dur,dt);
            
            % keyboard;
            
            iv((tb+extra):(te-extra))=curdata2((extra+1):(end-extra));
            
        end
        
        
        
        % disp(['channel ' num2str(i) ', section ' num2str(sc) ', constructing residual matrix for PCA']);
        
        % for the phase-turning.
        % points=ceil([0.00000000001 o.MRtimes(1)]*fs*interpfactor);
        
        % keyboard;
        %% subtract the data... 
        % WITH modelling deformations in the shape of
        % slice-artifact using PCA analysis.
        % 
        % 
        % I scale the data!!! -- remove?? especially near V-markers??
        disp('subtracting scaled artifacts...');
        for j=1:numel(sli)
            
            tmp_b=sl(sli(j)).b-adjust;
            tmp_e=sl(sli(j)).e-adjust;
            
            [template mat]=helper_slice(iv,adjust,sli(j),i,sl,[]);
            curdata=iv(tmp_b:tmp_e);
            
            % scaling and NO (!) baseline correction:
            % template=template-mean(template)+mean(curdata);

            scaling=curdata'*template/(template'*template);
            template=template*scaling;
            
            
            corrs_prev(j)=prcorr2(template,curdata);
            
            
            % keyboard;
            
            if o.pca.pca_rough>0

                % use ANOTHER algorithm!
                % disp(sli(j));
                
                % the template = offset of the matrix
                offset_mat=mean(mat,2);
                
                % scaled.
                scaling=offset_mat'*template/(offset_mat'*template);
                
                % do the scaling.
                template=offset_mat*scaling;
                
                % this leaves us with a remainder.
                remainder=curdata-template;
                
                % and a matrix of remainders.
                remainder_mat=mat-template*ones(1,size(mat,2));
                
                % analyze the remainder for any other very common
                % waveforms.
                [EVEC, ELOAD, EVAL] = pca_calc(remainder_mat);
                
                % it gives us a matrix of residuals waveforms which could
                % still be present. maybe one of them is also needed for
                % template formation.
                
                % if it is big enough, then we add it.
                explained=EVAL/sum(EVAL)*100;
                
                components_mat=max(find(explained>o.pca.pca_rough));
                % keyboard;
                
                if numel(components_mat)>0
                    
                    pcamat_mat=ELOAD(:,1:components_mat);

                    % keyboard;
                    

                    % try to model the remainder (after subtracting the offset)
                    % with a set of PC's.
                    fitted_pca_mat = pcamat_mat*(pcamat_mat\remainder);

                    template=template+fitted_pca_mat;

                    corrs_after(j)=prcorr2(template,curdata);
                    
                
                end
            
            end
            
            
            iv_artifact(tmp_b:tmp_e)=template;
            
        end
        % keyboard;
        
        
        
        
        % V-correction, part II:
        % find the points in-between, and replace them with something
        % more appropriate!
        % keyboard;
        % volume triggers in this little piece of EMG data.
        disp('applying Volume-correction, part II');
        vec=1:nslices*nvol;
        voltrigs=intersect(find(rem(vec,nslices)==0),sli);
        if max(voltrigs)==max(vec)
            voltrigs(end)=[];
        end
        
        % re-interpolate the data again in prep. segments.
        iv_res=iv-iv_artifact;
        for j=1:numel(voltrigs)
            
            tb2=sl(voltrigs(j)).e-adjust-round(numel(sl(1).b:sl(1).e)/20);
            tb=sl(voltrigs(j)).e-adjust;
            te=sl(voltrigs(j)+1).b-adjust;
            te2=sl(voltrigs(j)+1).b-adjust+round(numel(sl(1).b:sl(1).e)/20);
            bval=mean(iv_res(tb2:tb));
            eval=mean(iv_res(te:te2));
            pnum=te-tb-1;
            slope=(eval-bval)/pnum;
            ibd=(bval+slope*(1:pnum))';
            iv_res(tb+1:te-1)=ibd;
            
            bval=iv_artifact(tb);
            eval=iv_artifact(te);
            pnum=te-tb-1;
            slope=(eval-bval)/pnum;
            ibd_artifact=(bval+slope*(1:pnum))';
            
            iv_artifact(tb+1:te-1)=ibd_artifact;
            

        end
        
        % fix intermitting stuff.
        
        try
            

        % iv_res([sl(sli(find([sl(sli(1:end-1)).e]-[sl(sli(2:end)).b]<-1))).e]-adjust+1)=0;
        
        
        points=[sl(sli(find([sl(sli(1:end-1)).e]-[sl(sli(2:end)).b]<-1))).e]-adjust+1;
        
        % keyboard;
        for ai=1:numel(points)
            iv_res(points(ai))      = iv_res(points(ai)-1)/2      + iv_res(points(ai)+1)/2;
            iv_artifact(points(ai)) = iv_artifact(points(ai)-1)/2 + iv_artifact(points(ai)+1)/2;
        end
        
        
        
        catch
            keyboard;
        end
        
        
        % keyboard;
        
        
        
        
        %% PCA Run 1
        % magic for estimating PCA on a reduced matrix of residual
        % artifacts.
        % sli is normally an array of indices. For the construction of
        % our residuals matrix, make an array of indices where slices
        % near volumes are exempt!
        % make a 'union' between v (everything but 'bad' template
        % indices) and sli.
        % keyboard;
        if usr_max_components>0
            
            disp('PCA Run I');
            disp(sprintf(' filtering residual data with pca hpf at %d Hz, with %d components',o.pca.hpf,usr_max_components));
            iv_resf=helper_filter(iv_res,o.pca.hpf,o.fs*o.interpfactor,'high');
            
            % the entire collection of artifacts; fit residual components
            % to these (!!!)
            artifacts=zeros(numel(sl(1).b:sl(1).e),numel(sli));
            for j=1:numel(sli)
                
                tmp_b=sl(sli(j)).b-adjust;
                tmp_e=sl(sli(j)).e-adjust;
                
                artifacts(:,j)=iv_resf(tmp_b:tmp_e);
                artifacts2(:,j)=iv(tmp_b:tmp_e);
                
            end
            
            
            
            % keyboard;
            % remove the offset.
            off_artifacts=mean(artifacts,2);
            disp('  matrixifying the artifacts and subtracting the offset from the set of filtered, residual artifacts');
            artifacts=detrend(artifacts','constant')';
            
            
            
            
            % do not keep volume-trigs.
            vec=1:nslices*nvol;
            voltrigs=find(rem(vec,nslices)==0);
            voltrigs=[0 voltrigs];
            voltrigs=[voltrigs voltrigs+1];
            voltrigs=sort(voltrigs);
            voltrigs([1 end])=[];
            vec(voltrigs)=[];
            
            
            
            % sometimes, skip 1, other times: skip 2 (!).
            tmpind=0;
            tmpvec=[];
            while tmpind<nvol*nslices
                
                tmpind=tmpind+2-floor(rand+0.1);
                tmpvec=[tmpvec tmpind];
                
                
            end
            
            
            
            
            newsli=intersect(intersect(sli,vec),tmpvec);
            % newsli=intersect(sli,vec);
            
            % also remove slice-artifacts that are just too odd.
            
            
            %DIT TIJDELIJK UIT VOOR UMCG EMG, GEEN SHAPES OMITTEN! tot line
            %364
            if o.pca.omit_weird_shapes
                corrsm=reshape([sl.templateCorrelation],8,numel(sl))';
                
                % the angles = acos(a.*b/|a| |b|) ~ 1 - x^2/2;
                corrs=corrsm(newsli,i);
                
                omit_shapes=find(corrs<o.pca.corrs_thr);
                
                % keyboard;
                if numel(omit_shapes)>0
                    
                    % keyboard;
                    disp(sprintf('  omitted %d shapes out of %d from section %d',numel(omit_shapes),numel(corrsm),sc));
                    
                    newsli(omit_shapes)=[];
                    
                end
                
                
                
            end
            
            
            
            disp('   constructing a reduced set of filtered, off-set-subtracted residual data');
            % try
                
                residuals=artifacts(:,newsli-sli(1)+1);
                residuals=residuals(:,2:end-1);
            % catch
               %  keyboard;
            % end
            
            % keyboard
            residuals=artifacts;% AANGEZET!!!!
            
            
            
            
            
            
            
            
            
            disp('    now calculating the PCs');
            [apc,ascore,asvar]=pca_calc(residuals);
            
            max_components=usr_max_components;
            
            % this is the matrix that we're going to analyze our
            % variances with.
            pcamat=ascore(:,1:max_components);
            
            % re-scale to the 1st component... i dunno why.
            tmp_minmax=max(pcamat(:,1))-min(pcamat(:,1));
            for tmp=2:size(pcamat,2)
                pcamat(:,tmp)=pcamat(:,tmp)*tmp_minmax/...
                    (max(pcamat(:,tmp))-min(pcamat(:,tmp)));
            end
            
            
            
            % keyboard;
            
            % this is going to be our 'cleaned' data.
            iv_cleaned=zeros(size(iv));
            
            disp('     matching pcamat to full set of offset-subtracted and filtered residual data');
            disp('      and subtracting the best fit, and the offset, from the un-filtered residual data');
            for j=1:numel(sli);
                
                
                tb=sl(sli(j)).b-adjust;
                te=sl(sli(j)).e-adjust;
                
                % fit pcamat to each 'point', ie. artifact rel. to mean
                % artifact shape.
                
                try
                    fitted_pca=pcamat*(pcamat\artifacts(:,j));
                    
                catch
                    keyboard;
                end
                
                % this will then become the entire artifact.
                iv_artifact(tb:te)=iv_artifact(tb:te)+fitted_pca+off_artifacts;
                
                % what's left after subtracting OBS fit, will be our
                % data.
                iv_cleaned(tb:te)=iv_res(tb:te)-fitted_pca-off_artifacts;
                
            end
            
            
            % keyboard;
            % iv_cleaned_firstpass=iv_cleaned;
            
            
        else
            iv_cleaned = iv_res;
        end

      % keyboard;
        
        
     %% PCA RUN 2
     
      if usr_max_components2>0
            
            disp('PCA Run II');
            disp(sprintf(' filtering residual data with pca hpf at %d Hz, with %d components',o.pca.hpf2,usr_max_components2));

            % apply pca to a lower bandwidth.
            iv_resf=helper_filter(iv_cleaned,o.pca.hpf2,o.fs*o.interpfactor,'high');
            % iv_resf=helper_filter(iv_resf,o.pca.hpf2,o.fs*o.interpfactor,'high');
            
            
            % the entire collection of artifacts; fit residual components
            % to these (!!!)
            % shift=sl(1).e-sl(1).b
            artifacts=zeros(numel(sl(1).b:sl(1).e),numel(sli));
            for j=1:numel(sli)
                
                tmp_b=sl(sli(j)).b-adjust;
                tmp_e=sl(sli(j)).e-adjust;
                
                artifacts(:,j)=iv_resf(tmp_b:tmp_e);
                % artifacts2(:,j)=iv(tmp_b:tmp_e);
                
            end
            
            
            
            % keyboard;
            % remove the offset.
            off_artifacts=mean(artifacts,2);
            disp('  matrixifying the artifacts and subtracting the offset from the set of filtered, residual artifacts');
            artifacts=detrend(artifacts','constant')';
            
            
            
            
            % do not keep volume-trigs.
            vec=1:nslices*nvol;
            voltrigs=find(rem(vec,nslices)==0);
            voltrigs=[0 voltrigs];
            voltrigs=[voltrigs voltrigs+1];
            voltrigs=sort(voltrigs);
            voltrigs([1 end])=[];
            vec(voltrigs)=[];
            
            
            
            % sometimes, skip 1, other times: skip 2 (!).
            tmpind=-1;
            tmpvec=[];
            while tmpind<nvol*nslices
                
                tmpind=tmpind+2-floor(rand+0.1);
                tmpvec=[tmpvec tmpind];
                
                
            end
            
            
            
            newsli=intersect(intersect(sli,vec),tmpvec);
            % newsli=intersect(sli,vec);
            
            % also remove slice-artifacts that are just too odd.
            if o.pca.omit_weird_shapes
                corrsm=reshape([sl.templateCorrelation],8,numel(sl))';
                
                % the angles = acos(a.*b/|a| |b|) ~ 1 - x^2/2;
                corrs=corrsm(newsli,i);
                
                omit_shapes=find(corrs<o.pca.corrs_thr);
                
                % keyboard;
                if numel(omit_shapes)>0
                    
                    % keyboard;
                    disp(sprintf('  omitted %d shapes from section %d',numel(omit_shapes),sc));
                    
                    newsli(omit_shapes)=[];
                    
                end
                
                
                
            end
            
            
            
            disp('   constructing a reduced set of filtered, off-set-subtracted residual data');
            try
                residuals=artifacts(:,newsli-sli(1)+1);
                residuals=artifacts(:,2:end-1);
            catch
                keyboard;
            end
            %residuals=artifacts;
            
            
            
            
            
            
            
            
            
            disp('    now calculating the PCs');
            [apc,ascore,asvar]=pca_calc(residuals);
            
            if usr_max_components~=0
                max_components=usr_max_components;
            end
            
            max_components=usr_max_components2;
            
            
            
            % fprintf('\n%d residual PCs will be removed from channel %d\n',max_components,i);
            
            % this is the matrix that we're going to analyze our
            % variances with.
            pcamat=ascore(:,1:max_components);
            
            % re-scale to the 1st component... i dunno why.
            tmp_minmax=max(pcamat(:,1))-min(pcamat(:,1));
            for tmp=2:size(pcamat,2)
                pcamat(:,tmp)=pcamat(:,tmp)*tmp_minmax/...
                    (max(pcamat(:,tmp))-min(pcamat(:,tmp)));
            end
            
            
            
            
            % keyboard;
            
            % this is going to be our 'cleaned' data.
            % iv_cleaned=zeros(size(iv));
            
            disp('     matching pcamat to full set of offset-subtracted and filtered residual data');
            disp('      and subtracting the best fit, and the offset, from the un-filtered residual data');
            for j=1:numel(sli);
                
                
                tb=sl(sli(j)).b-adjust;
                te=sl(sli(j)).e-adjust;
                
                % fit pcamat to each 'point', ie. artifact rel. to mean
                % artifact shape.
                
                try
                    fitted_pca=pcamat*(pcamat\artifacts(:,j));
                    
                catch
                    keyboard;
                end
                
                % this will then become the entire artifact.
                iv_artifact(tb:te)=iv_artifact(tb:te)+fitted_pca+off_artifacts;
                
                % what's left after subtracting OBS fit, will be our
                % data.
                iv_cleaned(tb:te)=iv_cleaned(tb:te)-fitted_pca-off_artifacts;
                
            end
            
            % keyboard; 
            
            
            
            

            

        end
     
     
        
        %%
        
     
        
        
        
        
        
        % a low-pass filter is created thus:
        
        % keyboard;
        trans=0.15;
        nyq=0.5*fs;
        
        filtorder=round(interpfactor*lpffac*fix(fs/declpf));
        
        if rem(filtorder,2)~=0
            filtorder=filtorder+1;
        end
        
        f=[0 declpf/nyq/interpfactor declpf*(1+trans)/nyq/interpfactor 1];
        a=[1 1 0 0];
        lpfwts=firls(filtorder,f,a);
        
        
        iv_cleaned=filtfilt(lpfwts,1,iv_cleaned);
        
        
        iv_artifact=filtfilt(lpfwts,1,iv_artifact);
        
        % comb-filter
        
        if o.filter.comb==1
            
            
            toolboxes=ver;
            
            %                 if sum(strcmp({toolboxes.Name},'Filter Design Toolbox'))
            %
            %                     % keyboard;
            disp('applying a comb filter to reduce all harmonics of sdur');
            disp('warning: this takes an extremely long time!');
            % dparams = fdesign.comb('notch','L,BW,GBW,Nsh',round(fs*interpfactor*o.sdur),5,-4,3,fs*interpfactor);
            dparams = fdesign.comb('notch','L,BW,GBW,Nsh',round(o.fs*o.interpfactor*o.sdur),3,-2,2,o.fs*o.interpfactor);
            Hd=design(dparams);
            b_filt=Hd.Numerator;
            a_filt=Hd.denominator;
            iv_cleaned2=filter(b_filt,a_filt,iv_cleaned);
            
            %                 else
%             disp('applying a comb filter to reduce all harmonics of sdur');
%             lag=floor(o.sdur*fs*interpfactor);
%             iv_cleaned2=0.5*(iv_cleaned(1:(end-lag))-iv_cleaned((1+lag):end));
%             % take care of delays.
%             beginpad    = zeros(floor((numel(iv_cleaned)-numel(iv_cleaned2))/2),1);
%             endpad      = zeros(ceil((numel(iv_cleaned)-numel(iv_cleaned2))/2),1);
%             iv_cleaned2 = [iv_cleaned2;beginpad;endpad];
%             
%             % reverse pass of filter.
%             lag=ceil(o.sdur*fs*interpfactor);
%             iv_cleaned2_r = iv_cleaned2(end:-1:1);
%             iv_cleaned2_r = 0.5*(iv_cleaned2_r(1:(end-lag))-iv_cleaned2_r((1+lag):end));
%             beginpad    = zeros(floor((numel(iv_cleaned)-numel(iv_cleaned2_r))/2),1);
%             endpad      = zeros(ceil((numel(iv_cleaned)-numel(iv_cleaned2_r))/2),1);
%             iv_cleaned2_r = [iv_cleaned2_r;beginpad;endpad];
%             iv_cleaned2_rr = iv_cleaned2_r(end:-1:1);
%             
%             iv_cleaned2 = iv_cleaned2_rr;
            
            
            % keyboard;
            % reverse order.
            
            % end
            
            
            %                 lag=ceil(o.sdur*fs*interpfactor);
            %                 iv_cleaned2=0.5*(iv_cleaned2(1:(end-lag))-iv_cleaned2(1:(end-lag)));
            %                 % take care of delays.
            %                 beginpad    = zeros(floor((numel(iv_cleaned)-numel(iv_cleaned2))/2),1);
            %                 endpad      = zeros(ceil((numel(iv_cleaned)-numel(iv_cleaned2))/2),1);
            %                 iv_cleaned2 = [beginpad;iv_cleaned2;endpad];
            
            
            
        else
            iv_cleaned2=iv_cleaned;
        end
        
        
        v_cleaned=decimate(iv_cleaned2,interpfactor);
        
        
        v_artifact=decimate(iv_artifact,interpfactor);
        
        
        % and... finally, store the 'cleaned' data and the stuff that
        % we substracted.
        
        % which samples do we need to replace again??
        % samples in data....
        % samples_trace=(sl(min(sli)).b/interpfactor):sl(max(sli)).e/interpfactor;
        
        % and! samples in our decimated data.
        % divide by interpfactor, the summation of 1) adjust, 2)
        % 5*interpfactor, 3) difference between b of min of others and
        % b of the min.
        % this is NOT trivial!!! you should draw it out on a ruler.
        % the assumption that markers' = markers*interpfactor when you
        % interpolate, that is not...
        % not really that good. but... doesn't matter that much.
        % the real data begins when
        % tmp_BEGIN=(5*interpfactor+sl(min(sli)).b-sl(min(sl(min(sli)).others)).b)/interpfactor+1;
        % if sc==1
        %     tmp_BEGIN=5+1;
        % end
        % tmp_END=tmp_BEGIN+numel(samples_trace)-1;
        % samples_vector=tmp_BEGIN:tmp_END;
        
        
        b_of_v=ceil((sl(replace(1)).b-adjust)/interpfactor);
        e_of_v=ceil((sl(replace(end)).e-adjust)/interpfactor);
        
        b_of_data=min(samples)+b_of_v-1;
        e_of_data=min(samples)+e_of_v-1;
        
        % keyboard;
        
        
        disp(['done, with samples: ' num2str(b_of_data) ' through ' num2str(e_of_data)]);
        disp(sprintf('\n\n\n'));
        
        try
            d.clean(b_of_data:e_of_data,i)=v_cleaned(b_of_v:e_of_v);
            % d.clean(b_of_data) = 10000;
            % d.clean(e_of_data) = -10000;
        catch
            keyboard;
        end
        
        d.noise(b_of_data:e_of_data,i)=v_artifact(b_of_v:e_of_v);
        
        m.beginsegmarker(sc)=b_of_data;
        m.endsegmarker(sc)=e_of_data;
        
    end
    
end

