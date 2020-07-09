% custom-made artefact removal
% the departure point is the EEG-lab data structure in matlab

%% voorbereidend werk
load parameters
slices=parameters(2);
nvol=parameters(3);

% geef verder op: de 3 intervallen, waar correctie dient te geschieden.
% in (normale) samples.

load emg.mat
EEG=emg_filter_highpass(EEG,30); % verbetert je slicetriggers berekening als je dit vantevoren doet.
EEG=emg_make_bipolar(EEG); 

% EEG=emg_add_slicetriggers(EEG,1); % kan nog beter geimplementeerd worden.

%% these settings may change if the sampling is different (!)
% may be in a future program called 'options'!
%
% load emg_2.mat (FILTERED, BIPOLARED AND TRIGGERED EEG)
%



option.interpfactor=40;
option.datashift=3;
option.intervalboundaries=[27 104]; % MOETEN er nu 2 zijn.
option.sliceeventname='sliceTrigger';


%% vanaf hier wordt t een functie.

% ik verwacht EEG, van emg_2.mat, en ook de 'option'!

% ik verwacht dat deze twee bestanden aanwezig zijn:
load parameters;
load sliceTriggers; % uitgerekende slicetriggers.

slices=parameters(2);
nvol=parameters(3);


interpfactor=option.interpfactor;
datashift=option.datashift; % how much you wish to displace the markers.
intervalboundaries=option.intervalboundaries;
sliceeventname=option.sliceeventname;
srate=EEG.srate;


%% maak matrixje voor triggers

%
% nog meer voorbereidend werk;
%
% EEG=emg_names_add('Loops','9919');
tmp=find(strcmp({EEG.event.type},sliceeventname));

% slice-triggers.
st=[EEG.event(tmp).latency];

% what's the slice-trigger length? -- used in later calculations
sl=median(st(2:end)-st(1:end-1));

% and then reshape... nslices rows, nvols columns...
st=reshape(st,slices,numel(st)/slices);

save sliceTriggers.mat st sl


%% en verder:
% doe de artefact correctie procedure voor elk volume afzonderlijk!!!
% pak data van 10-begin eerste slice, t/m eind laatste slice!

%
% ! vereist goede 'huishouding' !
%% do this for each volume...



newdata=EEG.data;

for vol=1:nvol


    %#%# interpoleren... begin & einde data bepalen
    bdata=st(1,vol)-10; % voor zekerheid: wat extra's
    edata=st(slices,vol)+sl; % dan stukje dode tijd en dan nieuw vol

    % pak een stukje data.
    d=EEG.data(:,bdata:edata)';

    di=[];
    for i=1:size(d,2)
        di(:,i)=single(interp(d(:,i),interpfactor));
    end

    save(['slicetrigger_check\i_data_vol_' num2str(vol,'%.3d')],'di');

    %#%# nu hebben we de data. laten we de markers ook vertalen.
    %
    % naar de 'nieuwe' ruimte !

    sti=st(:,vol)-st(1,vol)+1+10-datashift; % 10 samples erbij gepakt + 3 samples verschuiven naar links.
    sti=sti*interpfactor;    
    sli=sl*interpfactor;


    %#%# data matrixificeren
    % nu... maak een data structure, voor 1 volume.

    mi=single(zeros(sli,slices)); % data / slice trigger.

    mi=[];
    for ch=1:size(di,2) % channels, dus.
        for i=1:slices % 43, dus.

            b=sti(i);
            e=b+sli-1;
            mi(:,i,ch)=di(b:e,ch)';
        end
    end


    %#%# bepaal verschuivingen
    % this is to calculate the 'marker-shift', to be applied later on.

    disp(['slice alignment in process, vol = ' num2str(vol)]);

    displacement=[0];
    for i=2:slices

        % keyboard;
        tmp=[];
        for shift=(-1.5*interpfactor:1.5*interpfactor)

            % apply shift, and calculate difference.
            diff=sum((mi(:,1)-circshift(mi(:,i),shift)).^2);

            tmp(end+1,:)=[shift diff];

        end

        % figure;plot(tmp);
        % sneakbak truuk, om optimum (laagste waarde) boven te krijgen.
        tmp=sortrows(tmp,2);

        displacement(end+1)=tmp(1,1);


    end
    displacement=displacement';
    disp(displacement');




    %#%# data opnieuw eruit pikken, met verbeterde markers.
    % nu... maak een data structure, voor 1 volume.

    mi2=single(zeros(sli,slices)); % data / slice trigger.

    mi2=[];
    for ch=1:size(di,2) % channels, dus.
        for i=1:slices % 43, dus.

            b=sti(i)-displacement(i);
            e=b+sli-1;
            mi2(:,i,ch)=di(b:e,ch)';
        end
    end


    %#%# now that that's underway... go, and make a template artefact waveform!
    %
    % fits a distorted template, and correct the data.

    X=[0.001 1.000 0.001 0.001 0.001 0.001 0.001];
    n=(intervalboundaries-datashift)*interpfactor; % intervallen
    % gebruiken we nu ff niet.
    % [b a]=butter(2,400*2/srate/interpfactor,'low'); % < 400 Hz = gone!
    mic=zeros(size(mi)); % matrix interpolated corrected.
    totchannels=size(mi,3);
    for ch=1:totchannels;

        % de template... to be fitted.
        template = mean(mi2(:,:,ch),2);

        for i=1:slices

            % keyboard;
            % give nice message for users to watch!
            percentcomplete=100*((vol-1)*totchannels*slices+(ch-1)*slices+i-1)/nvol/totchannels/slices;
            disp(['fitting artefact, vol = ' num2str(vol) ', ch = ' num2str(ch) ', slice = ' num2str(i) ', progress = ' num2str(percentcomplete)]);

            artefact = mi2(:,i,ch);

            % step 1) fit!
            xend=fminsearch(@(x)my_template_fitfun(x,n,artefact,template,X),X./X,optimset('MaxFunEvals',10000,'MaxIter',10000));
            xend=xend.*X;

            disp(xend);
            % do weird fitting, with slice-artefact, and template


            % step 2) make the template according to fit procedure.
            [newtpl,offsetvec,rcvec]=my_template_scalingfun2(template,n,xend);

            % step 3) substract!
            corrected_data=artefact-rcvec.*template;

            % step 4) filter! (doen we nu ff niet)
            % newdata=filter(b,a,newdata);

            m_templates=rcvec.*template;
            mic(:,i,ch)=corrected_data;



        end

        mat_templates(:,ch)=offsetvec+rcvec.*template;
        mat_fitparameters(:,ch)=xend'; % moet k nog uitbreiden!

    end

    save(['slicetrigger_check\mat_templates_vol_' num2str(vol,'%.3d')],'mat_templates');
    save(['slicetrigger_check\mat_fitparameters_vol_' num2str(vol,'%.3d') '.txt'],'mat_fitparameters','-ascii');

    %#%# now, re-make d, and put it back into EEG.data
    %
    % go from mic dic...

    dic=di;
    for ch=1:size(di,2) % channels, dus.
        for i=1:slices % 43, dus.

            b=sti(i)-displacement(i);
            e=b+sli-1;
            dic(b:e,ch)=mic(:,i,ch);
        end
    end

    save(['slicetrigger_check\ci_data_vol' num2str(vol,'%.3d')],'dic');
    % en weer terug naar d

    % pak een stukje data.


    dc=d; % data 'corrected';
    for i=1:size(d,2)


        dc(:,i)=decimate(dic(:,i),interpfactor);

        % hier kan je verschillende dingen proberen. Je ziet een effect het
        % asynchroon lopen van de data acquisitie en de MRI scanner.
        % het loopt net vervelend :-/
        % eem fir-filter lijkt te werken?
        % dc(:,i)=decimate(dic(:,i),interpfactor,160,'fir')
    end


    save(['slicetrigger_check\c_data_vol_' num2str(vol,'%.3d')],'dc');
    newdata(:,bdata:edata)=dc';

        


end




