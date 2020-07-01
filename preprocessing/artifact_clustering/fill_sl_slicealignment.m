% this'll take care of clustering and slice-timing and will tell you the
% best possible artifact.

function sl=fill_sl_slicealignment(d,sl,o,m)


    ss                  =m.ss;
    sections            =o.sections;
    beginshift          =o.beginshift;
    window              =o.window;
    interpfactor        =o.interpfactor;
    MRtimes             =o.MRtimes;
    fs                  =o.fs;
    speedup             =o.cl.corrspeedup;
    
    sduration           =ceil(median(ss(2:end)-ss(1:end-1)));
    soffset             =round(-1*beginshift*sduration);
    
    % how many slice-markers in one go?
    seclength           =floor(numel(ss)/sections);
    


    % initial choice for the other slices.
    % and initial adjustments for the other slice artifacts.
    disp('for each slice, selecting (other) candidate-"elects" for the tempate.');
    for i=1:numel(ss)
        
        % a neat solution for index i= near 1 and numel(ss)!
        % keyboard;
        sl(i).others=pick_function(i,numel(ss),window);
        
        % beginning and ending samples
        sl(i).b=(ss(i)+soffset)*interpfactor;
        sl(i).e=(ss(i)+soffset+sduration-1)*interpfactor;

    end
    
    
    

    
    
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
            
            % keyboard;
            
            sl(i).adjusts=adjustments;
            

            % diagnostics for displaying the progress.
            check=mod(i,round(numel(sl)/100));
            if ~check
                str=['section ' num2str(sc) '/' num2str(sections) ', ' num2str(i/round(numel(sl)/100)) ' percent done.\n'];
                fprintf(str);
            end


        end
        
    end
    

    
    
    
    