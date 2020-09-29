function sl=do_refinements(d,sl,o,m)



    fs                  =o.fs;
    % phase_adjust        =o.phase_adjust;
    ss                  =m.ss;
    sections            =o.sections;
    interpfactor        =o.interpfactor;
    MRtimes             =o.MRtimes;
    nch                 =o.nch;
    
    % how many slice-markers in one go?
    seclength           =floor(numel(ss)/sections);





    % after clustering is completed, re-adjust the slicetiming and scaling
    % for an even better fit.
    % and now an in-between step, to align the slices precisely.
    for i=1:nch


        for sc=1:sections

            disp(['refining template adjustments and scalings, channel ' num2str(i) ' section ' num2str(sc)]);

            % first determine what sl we should go through.
            sli=((sc-1)*seclength+1):(sc*seclength);
            if sc==sections
                sli=((sc-1)*seclength+1):numel(sl);
            end



            % do the helper again.
            [samples adjust]=marker_helper(sli,sl,interpfactor);
            v=d.original(samples,i);
            iv=interp(v,interpfactor);

            for j=sli

                % make the 'current data'.
                curdata=iv((sl(j).b-adjust):(sl(j).e-adjust));

                % construct the template.
                % which of the others to take??
                parts=find(sl(j).clusterdata(i,:)==sl(j).chosenTemplate(i));
                adjusts=sl(j).adjusts(parts);
                % scalings=sl(j).scalingdata(i,parts);
                % keyboard;


                % construct the template.
                mat=zeros(numel(curdata),numel(parts));
                for tc=1:numel(parts)
                    tmp_b=sl(sl(j).others(parts(tc))).b+adjusts(tc)-adjust;
                    tmp_e=sl(sl(j).others(parts(tc))).e+adjusts(tc)-adjust;
                    otherdata=iv(tmp_b:tmp_e)'; % *scalings(tc);

                    mat(:,tc)=otherdata;

                end
                
                
                
                template=mean(mat,2);
                
                
                
                % keyboard;
                
                
%                 % now is the time for calculating eventual phase-locking to
%                 % the 'curdata', of the templates.
%                 %*%*
%                 
%                 % code for applying the phase-shift... and storing it!
                MRi=round(MRtimes*interpfactor*fs);
% 
%                 % find which point p (or points) to do phase-matching with.
%                 v=curdata(:,i);
%                 if rem(numel(v),2)
%                     v=v(1:end-1);
%                     endmat=mat(end,:);
%                     mat(end,:)=[];
%                 end
% 
%                 u=v((MRi(4)-numel(v)/2+1):MRi(4));
%                 aU=abs(fft(u));
%                 
%                 point=find(aU==max(aU),1);
%                 % re-calculate towards the point in the twice-as-large
%                 % frequency spectrum:
%                 point=1+2*(point-1);
%                 
%                 if point ~=19
%                     warning(['point of frequency matching is not equal to 19, but is... ' num2str(point) '.']);
%                 end
                
                % and now 'phase-adjust' the 
                % project stopped -- let's try being more stringent with th
                % e pca's for now.
                
                
                
                
                %*%*
                
                %*%*
                
                
                
                
                

                
                
%                 % workaround for 1024 Hz...
%                 MRi=round(MRtimes*interpfactor*fs);
%                 keep=[1:MRi(3) (MRi(4)-100):size(mat,1)];
%                 curdata_detail=curdata(keep);
%                 
% %                 template_detail=template(keep);
% 
% 
%                 % keyboard;
%                 % now calculate template temporal adjustment and extra scaling
%                 % factor.
%                 extra_adjust=find_adjustment(curdata_detail,template_detail,2*interpfactor,8);
% 
%                 % do some tricks to faithfully calculate the extra needed
%                 % scaling for the template.
%                 tmp=zeros(size(template));
%                 if extra_adjust>0
%                     tmp=template(1+extra_adjust:end);
% 
%                     % determine RC at the end of template.
%                     rc=template(end)/2-template(end-2)/2;
% 
%                     tmp((numel(tmp)+1):(numel(tmp)+extra_adjust))=template(end)+rc*(1:extra_adjust);
% 
%                     template=tmp;
%                 end
%                 
% 
%                 if extra_adjust<0
% 
%                     tmp((1-extra_adjust):numel(template))=template(1:(end+extra_adjust));
% 
%                     % determine RC at the beginning of template.
%                     rc=template(1)/2-template(3)/2;
%                     tmp(1:(-extra_adjust))=template(1)+rc*((-extra_adjust):-1:1);
% 
%                     template=tmp;
% 
%                 end
% 
%                 if abs(extra_adjust)>2
%                     extra_adjust=sign(extra_adjust)*2;
%                     disp(['warning: extra adjust exceeds 2.. resetting to' num2str(extra_adjust)]);
%                     disp(['channel=' num2str(i) ' slice=' num2str(j)]);
%                 end

% no longer the 'extra adjust'... we trust our initial slice-alignment
% step.
                % sl(j).template_adjusts(i)=extra_adjust;
                
                
                keep=[1:MRi(3) (MRi(4)-100):size(mat,1)];

                curdata_detail=curdata(keep);
                template_detail=template(keep);
                
                
                
                sl(j).template_scalings(i)=(curdata_detail'*template_detail)/(template_detail'*template_detail);

                

                
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
    
    
    


