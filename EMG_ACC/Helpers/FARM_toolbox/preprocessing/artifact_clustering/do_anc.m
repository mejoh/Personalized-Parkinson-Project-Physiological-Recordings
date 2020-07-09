function d=do_anc(d,o,m,sl)




    %% the final stuff. do ANC, using our desamples data found in EEG.data_template and EEG.data_cleaned.
    %
    % refer to paper from Niazy and fmrib toolbox on how to implement this.
    %
    % after all these manipulations, i'm pretty sure that what you have left,
    % are the most stochastic components of the EMG.
    %
    %
    fs              =o.fs;
    trans           =o.filter.trans;

    lpf             =o.filter.anclpf;
    minfac          =o.filter.lpffac;

    nyq             =0.5*fs;
    
    ss              =m.ss;
    
    nch             =o.nch;
    sduration       =o.sduration;
    
    
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



    N=double(sduration+2);
    d1=ss(1);
    d2=ss(end)+sduration;
    mANC=d2-d1+1;


    %%
    for i=1:nch

        % do ANC for every channel separately!
        Noise=d.noise(:,i);
        cleanEEG=d.clean(:,i);

        
        % keep the filter weights optimized even around v-artifacts.
        % see to it that the V-artifact is here also removed.
        % remove little volume-segments
        % and later add them again.
        % the signal has already been low-pass filtered prior to
        % decimation. and also high-pass filtered just before this step.
        
        % use formula to calculate v-segments.
        % store points and data in a struct.
        

        
        total=0;
        delete_points=[];
        for j=1:o.nvol-1
            
            vseg(j).b       = floor(sl(j*o.nslices).e/o.interpfactor);
            vseg(j).e       = ceil(sl(j*o.nslices+1).b/o.interpfactor);
            
            delete_points   = [delete_points  vseg(j).b:vseg(j).e];
            
            vseg(j).data    = d.clean(vseg(j).b:vseg(j).e,i);
            
            vseg(j).cut     = vseg(j).b-1-total;
            
            total           = total + numel(vseg(j).b:vseg(j).e);
            
        end
        

        
        % re-do it.
        N=double(sduration+2);
        d1=ss(1);
        d2=ss(end)+sduration-numel(delete_points);
        mANC=d2-d1+1;

        
        Noise(delete_points)=[];
        cleanEEG(delete_points)=[];

        % do a filter, low-pass, at 250 Hz.
        % cleanEEG=filtfilt(lpfwts,1,cleanEEG);
        % Noise=filtfilt(lpfwts,1,Noise);

        % do a filter, high-pass, at f_slice/2.
        refs=Noise(d1:d2);
        refs=filtfilt(lpfwts,1,refs);
        
        tmpd=filtfilt(ANCfwts,1,cleanEEG);
        tmpd=filtfilt(lpfwts,1,tmpd);
        
        dat=double(tmpd(d1:d2));
        Alpha=sum(dat.*refs)/sum(refs.*refs);
        refs=double(Alpha*refs);
        mu=double(0.05/(N*var(refs)));

        % keyboard;
        
        [out,y]=fastranc(refs,dat,N,mu);

        
        % re-build the signal by re-introducing the omitted v-segments;
        anc_cleaned=cleanEEG;
        if isinf(max(y))
            wst=sprintf('ANC Failed for channel number %d. Skipping ANC.',i);
            warning(wst);
            
        else
            % keyboard;
            anc_cleaned(d1:d2)=cleanEEG(d1:d2)-y;
            % d.anc(d1:d2,i)=d.clean(d1:d2,i)-y;
        end
        
        % and here .... add all of the the stored data again at the correct
        % loci.
        

        vec=anc_cleaned;
        for j=(o.nvol-1):-1:1
                
            cut=vseg(j).cut;
            
            try
            vec=[vec(1:cut);vseg(j).data;vec(cut+1:end)];
            catch
               keyboard;
            end
        end
        
        % keyboard;
        d.anc(:,i)=vec;
        
        
        
        
        disp(sprintf('done with channel... %d!',i));

    end
