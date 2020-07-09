% volume correction done RIGHT.

% PER V:

%*%*%*%* reproduceer procedure bij slice-correction

% pak genoeg data.
% filter, met 150 Hz (zoals ook later wordt gedaan tijdens
% slice-correction).

% rondom V, pak 2*N s
% definieer sp en sn, als previous en next slice-artifact.
% maak residuals matrix van de s zonder sp en sn.
% cluster deze.
% bereken correlaties tussen sp en sn.

% vergelijk sp en sn met hoogst-gecorreleerde cluster.
% vervang het laatste stukje van sp
% vervang het eerste stukje van sn

% stop het intermittend-stukje in een array, en zet dat op ~0 (of doe er
% wat anders mee).



function d=do_volume_correction(d,sl,o,m)


    
    sv                  =m.sv;
    ss                  =m.ss;
    interpfactor        =o.interpfactor;
    MRtimes             =o.MRtimes;
    fs                  =o.fs;
    nch                 =o.nch;
    nslices             =o.nslices;
    nvol                =o.nvol;
    
    rtime_first         =o.vol.rtime_first;
    rtime_last          =o.vol.rtime_last;
    soffset             =o.soffset;
    
    sdur                =o.sdur;
    dtime               =o.dtime;
    
    N                   =o.N;
    N2                  =o.N2;
    
    % keyboard;
    
    % find the slice that coincides with volume N. Due to the way these are
    % calculated, they always coincide. see emg_add_slicetriggers.m
    % nog.. even niet 150 Hz filteren.
    
    for ch=1:nch
        
        disp(['starting work on channel: ' num2str(ch)]);

        % sn == slicenumber that goes with volume i.
        for i=1:numel(sv);
            sn(i)=find([ss]==sv(i));
        end

        % window=48;
        
        
        % first interpolate...
        [samples adjust]=marker_helper(1:numel(ss),sl,interpfactor);
        % keyboard;

        % pack;
        
        clear v;
        clear iv;
        v=d.original(samples,ch);
        iv=interp(v,interpfactor);
        
        
        
        % apply the 'phase shift' to every template.
        disp('applying phase-shift to all templates');
        extra=20;
        % extra samples = extended slice duration = multiply sdur with a
        % factor.
        dur=o.sdur*(extra*2+numel(sl(1).b:sl(1).e))/numel(sl(1).b:sl(1).e);

        for j=1:numel(ss)

            
             %(20 more samples!)
            % keyboard;
            tb=sl(j).b-adjust-extra;
            te=sl(j).e-adjust+extra;
            curdata=iv(tb:te);

            dt=sl(j).b_rounderr/fs/interpfactor;
            % phase-shift according to the round-off error.
            % take a little bit MORE data...
            % keyboard;
            curdata2=helper_phaseshifter2(curdata,dur,dt);
            if ~isreal(curdata2)
                keyboard;
            end
            

            iv((tb+extra):(te-extra))=curdata2((extra+1):(end-extra));

        end
        
        
        
        %%% first part...
        % what's the best template for each first and each last slice?
        % store it then
        extra=20;
        lastslice_arr=single(zeros(numel(sl(1).b:sl(1).e)+2*extra,numel(sn)));
        firstslice_arr=single(zeros(numel(sl(1).b:sl(1).e)+2*extra,numel(sn)));
        for i=2:numel(sn)
            
            % if i==10;keyboard;end
            % select N other slices.

            % these indices need to be adjusted.
            curr=sn(i);     
            prev=curr-1;

            % and these supply the examples.
            % re-do this one.
            
            curslice=iv((sl(curr).b:sl(curr).e)-adjust);
            prevslice=iv((sl(prev).b:sl(prev).e)-adjust);
            

            % clustermatrixje maken.
            clustermat_unscaled_curr=zeros(numel(sl(curr).b:sl(curr).e),numel(sl(curr).others));
            for k=1:numel(sl(curr).others)
                tmp_b=sl(sl(curr).others(k)).b-adjust;
                tmp_e=sl(sl(curr).others(k)).e-adjust;
                clustermat_unscaled_curr(:,k)=iv(tmp_b:tmp_e);
            end

            
            % clustermatrixje maken.
            clustermat_unscaled_prev=zeros(numel(sl(prev).b:sl(prev).e),numel(sl(prev).others));
            for k=1:numel(sl(prev).others)
                tmp_b=sl(sl(prev).others(k)).b-adjust;
                tmp_e=sl(sl(prev).others(k)).e-adjust;
                clustermat_unscaled_prev(:,k)=iv(tmp_b:tmp_e);
            end

            
            % dit is belangrijk. Bij 'current' slice, let op het einde want
            % het begin is niet goed. Bij 'previous' slice, let op het
            % begin want het einde is niet goed.
            MRi=round(MRtimes*interpfactor*fs);
            currkeep=[MRi(2):MRi(3) MRi(4):numel(sl(1).b:sl(1).e)];
            prevkeep=[1:MRi(1) MRi(2):MRi(3)];
            
            
            
%             keyboard;
            matched_curr=helper_match(curslice,clustermat_unscaled_curr,currkeep,N,N2);
            matched_prev=helper_match(prevslice,clustermat_unscaled_prev,prevkeep,N,N2);
            
            
            % now that matchings are in order... make a (somewhat)
            % bigger matrix... for FFT transformation.
                % clustermatrixje maken.
            clustermat_unscaled_curr=zeros(numel(sl(curr).b:sl(curr).e)+2*extra,numel(sl(curr).others));
            for k=1:numel(sl(curr).others)
                tmp_b=sl(sl(curr).others(k)).b-adjust-extra;
                tmp_e=sl(sl(curr).others(k)).e-adjust+extra;
                clustermat_unscaled_curr(:,k)=iv(tmp_b:tmp_e);
            end
            templ_curr=mean(clustermat_unscaled_curr(:,matched_curr),2);
            

            
            % clustermatrixje maken.
            clustermat_unscaled_prev=zeros(numel(sl(prev).b:sl(prev).e)+2*extra,numel(sl(prev).others));
            for k=1:numel(sl(prev).others)
                tmp_b=sl(sl(prev).others(k)).b-adjust-extra;
                tmp_e=sl(sl(prev).others(k)).e-adjust+extra;
                clustermat_unscaled_prev(:,k)=iv(tmp_b:tmp_e);
            end
            templ_prev=mean(clustermat_unscaled_prev(:,matched_prev),2);
            
            
            

            % contruct a template matrix with some extra elements; but only
            % use the matched others this time. then phase-shift it.
            % clustermatrixje maken.

            
            % apply the 'phase shift' to every template.
            % disp('applying phase-shift to all templates');
            
            dur=o.sdur*(extra*2+numel(sl(1).b:sl(1).e))/numel(sl(1).b:sl(1).e);

            dt=-1*sl(curr).b_rounderr/fs/interpfactor;
            templ_curr_shifted=helper_phaseshifter2(templ_curr,dur,dt);
            % templ_curr_shifted=templ_curr_shifted(extra+1:end-extra);
            
            
            dt=-1*sl(prev).b_rounderr/fs/interpfactor;
            templ_prev_shifted=helper_phaseshifter2(templ_prev,dur,dt);
            % templ_prev_shifted=templ_prev_shifted(extra+1:end-extra);
           
            
            lastslice_arr(:,sn(i))=templ_prev_shifted;
            firstslice_arr(:,sn(i))=templ_curr_shifted;
            
            
        end
        
        
        
        %%% reset phase-differences, to replace parts near-a-volume.
        disp('restoring phase values');
        clear iv;
        try
            iv=interp(v,interpfactor);
        catch
            disp('packing memory');
            pack;
            iv=interp(v,interpfactor);
        end

            
        % what parts of the first and of the last slice should we focus on,
        % to determing extra time lags?? 
        % --> the first part of the new slice in a new volume, as well as
        % the last part of the last slice in the previous volume, is
        % corrupted. So use some interesting areas to determine extra
        % time-lag. Or slice-correction will fail near the beginning of a
        % new slice-artifact. 
        % once this is in place, the burst detection can finally begin.
  
        %%%% second part... replacing key portions of firstslice and
        %%%% lastsli
        disp('replacing selected pieces of volume-artifact data to match slice template waveforms');
        for i=2:numel(sn)

            
            % these indices need to be adjusted.
            curr=sn(i);     
            prev=curr-1;

            % keyboard;

            
            lastslice=iv((sl(prev).b-adjust):(sl(prev).e-adjust));

            % get this from our matrix.
            templatel=lastslice_arr((extra+1):(end-extra),sn(i));
            % templatel=templatel-mean(templatel)+mean(lastslice);
            
            firstslice=iv((sl(curr).b-adjust):(sl(curr).e-adjust));
            
            % also, get from our matrix.
            templatef=firstslice_arr((extra+1):(end-extra),sn(i));
            

            
            
            rli=(numel(lastslice)-round(rtime_last*fs*interpfactor)+1):numel(lastslice);
            lastslice(rli)=templatel(rli);
            last_adjust=numel(templatel)-numel(rli);

            
            rfi=1:round(rtime_first*fs*interpfactor);
            firstslice(rfi)=templatef(rfi);
            first_adjust=numel(templatef)-numel(rfi);
            


            % update in-between:
            b=sl(prev).b-adjust+last_adjust;
            e=sl(curr).e-adjust-first_adjust;
            
            
            % now create our sibstitute data.
            % indices_between... is to connect the two points.
            % ib=(numel(b:e)-numel(rfi)-numel(rli));
            % difft=templatef(1)-templatel(end);
            % ibd=difft/ib*(1:ib)+templatel(end);
            
            % keyboard;
            
            % continuee ~ 10 samples in same direction.
            directionl1 = templatel(end)-templatel(end-1);
            directionl2 = templatel(2)-templatel(1);
            directionl=mean([directionl1 directionl2]);
            % afterl = templatel(end)+(1:10)*direction;
            % 'rightly' paste a piece of the first part at the end of the
            % last part...
            % afterl=templatel(1:10)'-(templatel(1)-templatel(end))+directionl;
            afterl=lastslice_arr((end-extra+1):(end-extra+10),sn(i));
            
            directionf1 = templatef(2)-templatef(1);
            directionf2 = templatef(end)-templatef(end-1);
            directionf=mean([directionf1 directionf2]);
            
            % beforef = templatef(1)+(-10:1:-1)*direction;
            % beforef=templatef((end-10+1):end)'-(templatef(end)-templatef(1)+directionf);

            beforef=firstslice_arr((extra-9):extra,sn(i));
            
            ib=(numel(b:e)-numel(rfi)-numel(rli)-10-10);

            difft=beforef(1)-afterl(end);
            ibd=difft/ib*(1:ib)+afterl(end);
            
            
            ibd=[templatel(rli)' afterl' ibd beforef' templatef(rfi)'];
            
%             if ch==7&&i==100
%                 keyboard
%             end
                
            % and now... replace new-and-improved data over old(er) volume
            % data.
            
            
            try
                % keyboard;
                iv(b:e)=ibd;
                % d.vol_original(b:e,ch)=iv(b:e);
            catch
%                 keyboard;
                if i==2
                    warning('FARM:volcorrect',['Failed to fully substitute b:e (' num2str(length(b:e)) ' samples) with ibd (' num2str(length(ibd)) ' samples)']);
                end
                iv(b:e)    =   ibd(1:length(b:e));
            end
            
        end
        

%         WARNING: this has already been fixed (!!) -- see the above.
%         code.
%         disp('restoring template phases.');
%         extra=20;
%         dur=o.sdur*(extra*2+numel(sl(1).b:sl(1).e))/numel(sl(1).b:sl(1).e);
% 
%         for j=1:numel(ss)
% 
%              %(20 more samples!)
%             tb=sl(j).b-adjust-extra;
%             te=sl(j).e-adjust+extra;
%             curdata=iv(tb:te);
% 
%             dt=sl(j).b_rounderr/fs/interpfactor;
%             % phase-shift according to the round-off error.
%             % take a little bit MORE data...
%             curdata2=helper_phaseshifter2(curdata,dur,-1*dt);
% 
%             iv((tb+extra):(te-extra))=curdata2((extra+1):(end-extra));
% 
%         end
%         
%         % keyboard;
        
        
        
        clear vd;
        try
            vd=decimate(iv,interpfactor);
        catch
            pack;
            disp('packing memory');
            vd=decimate(iv,interpfactor);
        end
        
        % now take some parts of vd, and replace the original data with the
        % replaced parts.
        
        
        
%         disp('replacing selected parts of the process in decimated space');
%         
%         prev_samples=round(rtime_last*fs)+round(dtime*fs);
%         next_samples=round(rtime_first*fs);
%         for i=1:numel(sn)
%             
%             tbo=m.sv(i)-prev_samples+soffset;
%             teo=m.sv(i)+next_samples+soffset;
%             
%             tbi=tbo-samples(1);
%             tei=teo-samples(1);
%             
%             d.original(tbo:teo,ch)=vd(tbi:tei);
%             
%         end
        
        d.original(samples,ch)=vd;
        
    end

    
    

%             clustermat_unscaled_curr=zeros(numel(sl(curr).b:sl(curr).e)+2*extra,numel(matched_curr));
%             for k=1:numel(sl(curr).others)
%                 tmp_b=sl(sl(curr).others(k)).b-adjust-extra;
%                 tmp_e=sl(sl(curr).others(k)).e-adjust+extra;
%                 clustermat_unscaled_curr(:,k)=iv(tmp_b:tmp_e);
%             end
%             templ_curr=mean(clustermat_unscaled_curr,2);
% 
%             
%             % clustermatrixje maken.
%             clustermat_unscaled_prev=zeros(numel(sl(prev).b:sl(prev).e)+2*extra,numel(matched_prev));
%             for k=1:numel(sl(prev).others)
%                 tmp_b=sl(sl(prev).others(k)).b-adjust-extra;
%                 tmp_e=sl(sl(prev).others(k)).e-adjust+extra;
%                 clustermat_unscaled_prev(:,k)=iv(tmp_b:tmp_e);
%             end
%             templ_prev=mean(clustermat_unscaled_prev,2);
%             

    
    
    
    
    
    
    