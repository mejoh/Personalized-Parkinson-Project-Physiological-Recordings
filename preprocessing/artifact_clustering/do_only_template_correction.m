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


function [d sl]=do_only_template_correction(d,sl,o)


    nch                         =o.nch;
    interpfactor                =o.interpfactor;

    usr_max_components          =o.pca.usr_max_components;
    second_iter_components      =o.pca.second_iter_components;
    
    declpf                      =o.filter.declpf;
    lpffac                      =o.filter.lpffac;
    
    fs                          =o.fs;
    nyq                         =fs/2;
    sections                    =o.sections;
    seclength                   =o.seclength;
    
    % pcahpf                      =o.filter.pcahpf;
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
            extra=20;
            dur=o.sdur*(extra*2+numel(sl(1).b:sl(1).e))/numel(sl(1).b:sl(1).e);
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
            
            
                
            
            disp(['channel ' num2str(i) ', section ' num2str(sc) ', constructing residual matrix for PCA']);
            
            % for the phase-turning.
            % points=ceil([0.00000000001 o.MRtimes(1)]*fs*interpfactor);
            
            % keyboard;

            % I scale the data!!! -- remove?? especially near V-markers??
            for j=1:numel(sli)
               
                tmp_b=sl(sli(j)).b-adjust;
                tmp_e=sl(sli(j)).e-adjust;

                template=helper_slice(iv,adjust,sli(j),i,sl,[]);
                curdata=iv(tmp_b:tmp_e);

                % scaling and baseline correction:
                template=template-mean(template)+mean(curdata);
                scaling=curdata'*template/(template'*template);
                template=template*scaling;
                
                iv_artifact(tmp_b:tmp_e)=template;
                
            end
            

            
            % the magic formula...
            % keyboard;
            % iv_res=helper_filter(iv-iv_artifact,o.filter.pcahpf,o.fs*o.interpfactor,'high');
            iv_cleaned=iv-iv_artifact;
            
            % V-correction, part II:
            % find the points in-between, and replace them with something
            % more appropriate!
            % keyboard;
            % volume triggers in this little piece of EMG data.
            vec=1:nslices*nvol;
            voltrigs=intersect(find(rem(vec,nslices)==0),sli);
            if max(voltrigs)==max(vec)
                voltrigs(end)=[];
            end
            for j=1:numel(voltrigs)
               
                tb=sl(voltrigs(j)).e-adjust;
                te=sl(voltrigs(j)+1).b-adjust;
                bval=iv_cleaned(tb);
                eval=iv_cleaned(te);
                pnum=te-tb-1;
                slope=(eval-bval)/pnum;
                ibd=(bval+slope*(1:pnum))';
                iv_cleaned(tb+1:te-1)=ibd;
                
            end

            % find those points... 
            
            
            
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
            
            
            d.clean(b_of_data:e_of_data,i)=v_cleaned(b_of_v:e_of_v);
            d.noise(b_of_data:e_of_data,i)=v_artifact(b_of_v:e_of_v);
                
        end
        
    end
    
    