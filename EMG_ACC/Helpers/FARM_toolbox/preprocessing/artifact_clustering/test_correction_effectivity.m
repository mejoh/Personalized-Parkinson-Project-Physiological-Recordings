% checken kwaliteit van emg mbv verschillende correctie methoden.
% opzetje voor genereren grafieken.


% EEG_fastr
% I did the correction till the clustering step.
% And also, I did the fmrib correction and stored the data into
% EEG_fastr.mat.
% this is all that is needed... if all is well.




sections=7;
interpfactor=10;
seclength = o.seclength;
fs=o.fs;



% interpoleer d_old en d_new.
for i=1:8


    for sc=1:sections


        disp(['interpolating data channel ' num2str(i) ' section ' num2str(sc)]);

        % first determine what sl we should go through.
        sli=((sc-1)*seclength+1):(sc*seclength);
        if sc==sections
            sli=((sc-1)*seclength+1):numel(sl);
        end



        % do the helper again.
        [samples adjust]=marker_helper(sli,sl,interpfactor);

        id_original=interp(d.original(samples,i),interpfactor);
        id_fastr=interp(EEG_fastr.data(i,samples),interpfactor)';


        % this is for fastr.
        for j=sli

            % this is for fastr.

            % - rescale
            % - cluster!
            % row or column vectors !?!?! we support row vectors.
            slice_original=id_original((sl(j).b-adjust):(sl(j).e-adjust));
            slice_fastr=id_fastr((sl(j).b-adjust):(sl(j).e-adjust));
            slice_artifact=slice_original-slice_fastr;
            % keyboard;
            


            % diagnostical information.
            sl(j).FASTR.templateCorrelation(i)=prcorr2(slice_original,slice_artifact);
            sl(j).FASTR.templateAmplitude(i)=max(abs(slice_artifact));
            % keyboard;
            if j>min(sli)
                % keyboard;
                sl(j).FASTR.templateAngleWrtPrev(i)=slice_artifact'*olddata/sqrt(slice_artifact'*slice_artifact)/sqrt(olddata'*olddata);
            else
                sl(j).FASTR.templateAngleWrtPrev(i)=1;
            end
            olddata=slice_artifact;

            check=mod(j,round(numel(sl)/100));
            if ~check
                str=['channel ' num2str(i) ', section ' num2str(sc) ', ' num2str(j/round(numel(sl)/100)) ' percent done \n'];
                fprintf(str);
            end

        end


        % this is for new method -- choose only better slice-artifacts.
        for j=sli

            % this is for fastr.

            % - rescale
            % - cluster!
            % row or column vectors !?!?! we support row vectors.
            
            % keyboard;
            slice_original=id_original((sl(j).b-adjust):(sl(j).e-adjust));

            % make slice_artifact...
            clustermat_unscaled=zeros(numel(sl(j).b:sl(j).e),numel(sl(j).others));
            for k=1:numel(sl(j).others)
                tmp_b=sl(sl(j).others(k)).b-adjust;
                tmp_e=sl(sl(j).others(k)).e-adjust;
                % try
                clustermat_unscaled(:,k)=id_original(tmp_b:tmp_e);
                % catch;keyboard;lasterr;end
            end
            chosenj=find(sl(j).clusterdata(i,:)==sl(j).chosenTemplate(i));
            slice_artifact=mean(clustermat_unscaled(:,chosenj),2);
            scaling=slice_original'*slice_artifact/(slice_artifact'*slice_artifact);
            slice_artifact=scaling*slice_artifact;
            % keyboard;

try

            % diagnostical information.
            sl(j).CORR.templateCorrelation(i)=prcorr2(slice_original,slice_artifact);
            sl(j).CORR.templateAmplitude(i)=max(abs(slice_artifact));
            % keyboard;
            if j>min(sli)
                % keyboard;
                sl(j).CORR.templateAngleWrtPrev(i)=slice_artifact'*olddata/sqrt(slice_artifact'*slice_artifact)/sqrt(olddata'*olddata);
            else
                sl(j).CORR.templateAngleWrtPrev(i)=1;
            end
            olddata=slice_artifact;
            
catch
    keyboard;
end

            check=mod(j,round(numel(sl)/100));
            if ~check
                str=['channel ' num2str(i) ', section ' num2str(sc) ', ' num2str(j/round(numel(sl)/100)) ' percent done \n'];
                fprintf(str);
            end

        end


        disp('now applying phase-shift...');
        % apply the 'phase shift' to every template.
        % phase-shift ALL slice-artifacts.
        extra=20;
        dur=o.sdur*(extra*2+numel(sl(1).b:sl(1).e))/numel(sl(1).b:sl(1).e);
        minj=min([sl(sli(1)).others;sl(sli(2)).others;sli(1)]);
        maxj=max([sl(sli(end)).others;sl(sli(end-1)).others;sli(end)]);
        for j=minj:maxj



            %(20 more samples!)
            tb=sl(j).b-adjust-extra;
            te=sl(j).e-adjust+extra;
            curdata=id_original(tb:te);

            dt=sl(j).b_rounderr/fs/10;
            % phase-shift according to the round-off error.
            % take a little bit MORE data...
            curdata2=helper_phaseshifter2(curdata,dur,dt);

            % keyboard;

            id_original((tb+extra):(te-extra))=curdata2((extra+1):(end-extra));

        end



        % this is for new method -- choose only better slice-artifacts.
        % and now, also add phase-shifting.
        for j=sli


            % row or column vectors !?!?! we support row vectors.
            slice_original=id_original((sl(j).b-adjust):(sl(j).e-adjust));

            % make slice_artifact...
            clustermat_unscaled=zeros(numel(sl(j).b:sl(j).e),numel(sl(j).others));
            for k=1:numel(sl(j).others)
                tmp_b=sl(sl(j).others(k)).b-adjust;
                tmp_e=sl(sl(j).others(k)).e-adjust;
                % try
                clustermat_unscaled(:,k)=id_original(tmp_b:tmp_e);
                % catch;keyboard;lasterr;end
            end
            chosenj=find(sl(j).clusterdata(i,:)==sl(j).chosenTemplate(i));
            slice_artifact=mean(clustermat_unscaled(:,chosenj),2);
            % implement scaling.
            scaling=slice_original'*slice_artifact/(slice_artifact'*slice_artifact);
            slice_artifact=scaling*slice_artifact;



            % diagnostical information.
            sl(j).CORRPH.templateCorrelation(i)=prcorr2(slice_original,slice_artifact);
            sl(j).CORRPH.templateAmplitude(i)=max(abs(slice_artifact));
            if j>min(sli)
                % keyboard;
                sl(j).CORRPH.templateAngleWrtPrev(i)=slice_artifact'*olddata/sqrt(slice_artifact'*slice_artifact)/sqrt(olddata'*olddata);
            else
                sl(j).CORRPH.templateAngleWrtPrev(i)=1;
            end
            olddata=slice_artifact;

            check=mod(j,round(numel(sl)/100));
            if ~check
                str=['channel ' num2str(i) ', section ' num2str(sc) ', ' num2str(j/round(numel(sl)/100)) ' percent done \n'];
                fprintf(str);
            end

        end



















    end
end





% d_old - d_new = artifact
