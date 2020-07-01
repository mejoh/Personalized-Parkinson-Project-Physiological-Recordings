% this'll take care of clustering and slice-timing and will tell you the
% best possible artifact.
% we'll try to do the phase-adjustment later on.
% calls the function find_adjustment repetitively. this is a customized
% function that speeds up the speedup from Niazy's C routine even higher by
% a factor given by o.cl.corrspeedup.

function sl=do_slicetiming(d,sl,o,m)


    ss                  =m.ss;
    sections            =o.sections;
    interpfactor        =o.interpfactor;
    MRtimes             =o.MRtimes;
    fs                  =o.fs;
    speedup             =o.corrspeedup;
    
    % how many slice-markers in one go?
    seclength           =floor(numel(ss)/sections);
    


    
    
    disp('slice-timing the canditate-"elects" to the slice-artifacts');
    for sc=1:sections
        % first determine what sl we should go through.
        sli=((sc-1)*seclength+1):(sc*seclength);
        if sc==sections
            sli=((sc-1)*seclength+1):numel(sl);
        end

        [samples adjust]=marker_helper(sli,sl,interpfactor);

        
        v=d.original(samples,1);
        
        %         % maybe high-pass filter?
        %         % try some hpf's.
        %         % extract some parameters
        %         hpf=o.vol.pcahpf;
        %         fac=o.filter.hpffac;
        %         nyq=o.fs/2;
        %         trans=o.filter.trans;
        %         fs=o.fs;
        % 
        % 
        %         % build the filter using fir-least squares
        %         filtorder=round(fac*fs/(hpf*(1-trans)));
        %         if rem(filtorder,2)
        %             filtorder=filtorder+1;
        %         end
        % 
        %         a=[0 0 1 1];
        %         f=[0 hpf*(1-trans)/nyq hpf/nyq 1];
        % 
        %         hpfweights=firls(filtorder,f,a);
        %         
        %         v=filtfilt(hpfweights);
        
        
        iv=interp(v,interpfactor);


        for i=sli

            curdata=iv((sl(i).b-adjust):(sl(i).e-adjust));

            % find for all of the other elements, the optimal time-shift.
            % the time this takes, scales with interpfactor*window.
            mat=zeros(size(curdata,1),numel(sl(i).others));
            for j=1:numel(sl(i).others)

                % what is the beginning and ending of the other slices??
                tmp_b=sl(sl(i).others(j)).b-adjust;
                tmp_e=sl(sl(i).others(j)).e-adjust;
                mat(:,j)=iv(tmp_b:tmp_e);
            end
            
            
            MRi=round(MRtimes*interpfactor*fs);
            keep=[1:MRi(1) MRi(2):MRi(3) MRi(4):size(mat,1)];
            % away=1:size(mat,1);
            % away(keep)=0;
            % away(away==0)=[];

            % use this chopped matrix for the correlation function.
            mat_chopped=mat(keep,:);
            curdata_chopped=curdata(keep);
            
            % keyboard;
            % find the adjustments.
            adjustments=zeros(1,numel(sl(i).others));
            mat_adjusted=zeros(size(curdata,1),numel(sl(i).others));
            for j=1:size(mat,2)
                % compare the following with curdata.
                otherdata=mat_chopped(:,j);

                adjustments(j)=find_adjustment(curdata_chopped,otherdata,round(2*interpfactor),speedup);

                % keyboard;
                % contruct 'adjusted mat.
                tmp_b=sl(sl(i).others(j)).b-adjust+adjustments(j);
                tmp_e=sl(sl(i).others(j)).e-adjust+adjustments(j);
                mat_adjusted(:,j)=iv(tmp_b:tmp_e);

            end
            
            % keyboard;
            
            sl(i).adjusts=adjustments;
            % keyboard;
            
            

            % diagnostics for displaying the progress.
            check=mod(i,round(numel(sl)/100));
            if ~check
                str=['section ' num2str(sc) '/' num2str(sections) ', ' num2str(i/round(numel(sl)/100)) ' percent done.\n'];
                fprintf(str);
            end


        end
        
    end
    

    
    
    
    
    
    
    
    
    
    