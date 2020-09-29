function intersel = pf_pmg_seltremorUI(plots,titles,channels,powspcts,powers,freqs,hand,allchan,peakopt,mancheck)
%
% pf_pmg_seltremor let's you interactively select datapoints of all the
% subplots (plots) plotted in your current figure using the brush tool. 
% It will return the selected channel with corresponding frequency, power, 
% standard deviation of power and coefficient of variation of power. This
% is all stored in a MxN structure corresponding to the row/column index of
% the corresponding subplot.

% ©Michiel Dirkx, 2014
% $ParkFunC

%--------------------------------------------------------------------------

%% Initiate parameters
%--------------------------------------------------------------------------

fprintf('\nInteractive data selection activated')

figure(gcf);
intersel    =   [];
[row,col]   =   size(plots);
cnt         =   1;
multiflag   =   0; % Flag for multiple condition, standard 0

%--------------------------------------------------------------------------

%% Select datapoints
%--------------------------------------------------------------------------

% brush on; brush off
if strcmp(peakopt,'mansingle')
    fprintf('\nClick on the datapoints that you want to include in the figure.\nEnter "return" when you are done.\n')
    brush on    % always turn on brush, either to manually select now or perhaps after automatic peakfinder (mancheck='yes')
    brush green
    keyboard
    brush off
elseif strcmp(peakopt,'peakfinder') && strcmp(mancheck,'yes') % if you want to manually select, then you first need to plot all the peaks.
    
    % --- Perform peakselection in plot --- %
    
    fprintf('%s\n','Performing automatic peakselection')
    
    for a = 1:prod([row col])
        
        % --- Select Current subplot --- %
        
        CurChans  =   channels{a};
        nChans   =   length(CurChans);
        
        CurFreqs  =   freqs{a};
        CurPow    =   powspcts{a};        
        
        % --- autoselect peaks --- %
        
        subplot(plots(a))
        hold on
        idx     =   cell(nChans,1);
        val     =   cell(nChans,1);
        % OLD: already brush data
%         bh      =   findobj(plots(a),'-property','Brushdata');
%         bh      =   flipud(bh); % Because is loaded in inverse order
        for b = 1:nChans
            thrsh                 =   2*std(CurPow(b,:));             % Threshold for peak selection;
            %             pf_horline(thrsh);
            [idx{b},val{b}]   =   peakfinder(CurPow(b,:),thrsh);    %         Peakfinder (noise robust)
            %             [idx{b},val{b}]   =   peakfinder(CurPow(b,:));    %         Peakfinder (noise robust)
            %             [val{b},idx{b}]     =   findpeaks(CurPow(b,:),'Threshold',thrsh); % Findpeaks (matlab)
            if ~isempty(idx{b})
                plot(CurFreqs(idx{b}),val{b}+0.5,'*','MarkerSize',10);
%                 brushvec         =   zeros(1,length(CurPow(b,:)));
%                 brushvec(idx{b}) =   2;
%                 set(bh(b),'BrushData',brushvec)
            end
        end
    end
    fprintf('\nClick on the datapoints that you want to include in the figure.\nEnter "return" when you are done.\n')
    brush on
    brush green
    keyboard
    brush off
end

%--------------------------------------------------------------------------

%% Retrieve corresponding data values
%--------------------------------------------------------------------------

fprintf('\nSelected:\n')

for a = 1:prod([row col])
    
    % --- Select Current subplot --- %
    
    CurTit    =   titles{a};
    CurChans  =   channels{a};
    CurFreqs  =   freqs{a};
    CurPow    =   powspcts{a};
    CurPowers =   powers{a};
    
    nChans   =   length(CurChans);
    
    fprintf('%s\n',['Subplot ' num2str(a) ': "' CurTit '"']);
    
    % --- Detect Session --- %
    
%     sesscode    =   pf_pmg_sesscode(CurTit);   % Helper function to retrieve the sesscode with input str (usually CurTit)
    sesscode    =   pf_pmg_seltremorUI_sesscode(CurTit);
%     if isnan(sesscode)
%         disp('Selected NaN as sesscode, please debug me :)')
%         keyboard
%     end
    
    % --- Retrieve brushdata or autoselect peaks --- %
    subplot(plots(a))
    hold on
    if strcmp(peakopt,'mansingle') || strcmp(mancheck,'yes')
        bh      =   findobj(plots(a),'-property','BrushData');
        bval    =   get(bh,'BrushData');
        if iscell(bval)
            sel     =   cellfun(@(x) length(x)==size(CurPow,2),bval);   % Select only the power data (not plotted peaks)
            bval    =   bval(sel);
            bval    =   flipud(bval); % Because everything is loaded in inverse order
        else
            bval    =   {bval};
        end           
    elseif strcmp(peakopt,'peakfinder')
        idx     =   cell(nChans,1);
        val     =   cell(nChans,1);
        for b = 1:nChans
            thrsh                 =   2*std(CurPow(b,:));             % Threshold for peak selection; 
%             pf_horline(thrsh);
            [idx{b},val{b}]   =   peakfinder(CurPow(b,:),thrsh);    %         Peakfinder (noise robust)
%             [idx{b},val{b}]   =   peakfinder(CurPow(b,:));    %         Peakfinder (noise robust)
%             [val{b},idx{b}]     =   findpeaks(CurPow(b,:),'Threshold',thrsh); % Findpeaks (matlab)
            if ~isempty(idx{b})
                plot(CurFreqs(idx{b}),val{b},'*','MarkerSize',10);
            end
        end
    end

    % --- Find the selected data --- %
    
    for b = 1:nChans
       
       if ~isempty(strfind(CurTit,'vs'))    % If multiple conditions per plot
           chansel    =  strfind(CurChans{b},' ');
           CurChan    =  CurChans{b}(1:chansel-1);
           
           CurCond    =  CurChans{b}(chansel+1:end);
           condstring =  CurCond;
       else                                 % If only one condition per plot
           CurChan    =  CurChans{b};    
           condstring =  CurTit;
       end
       
%        ChanCode      =  pf_pmg_seltremorUI_chancode(CurChan); % OLD
       ChanCode     =   pf_pmg_chancode(CurChan);
       
       if isempty(ChanCode) && ~isempty(strfind(CurChans{b},' ')) && isempty(strfind(CurChans{b},'&'))   % If some of the conditions were not loaded into the subplot there will be no 'vs' in the name
           chansel    =  strfind(CurChans{b},' ');
           CurChan    =  CurChans{b}(1:chansel-1);
           
           CurCond    =  CurChans{b}(chansel+1:end);
           condstring =  CurCond;
           ChanCode      =  find(strcmp(allchan,CurChan));
       end
       
       % --- Detect Condition --- %
       
       [condcode,cond] =   pf_pmg_condcode(condstring);
       
       % --- Get idx of selected data --- %
       
       if strcmp(peakopt,'mansingle') || strcmp(mancheck,'yes')
           CurBrush  = bval{b};
           iBrush    = find(CurBrush~=0);
       else
           iBrush    = idx{b};      % Still called iBrush for compatibility
       end
       
       cntt      = 1;
       cntm      = 1;
       
       % --- If something was selected --- %
       
       fprintf('%s\n',[' - Condition "' cond '" (condcode=' num2str(condcode) ')'])
       
       if ~isempty(iBrush)
           
           for c = 1:length(iBrush)
               
               fprintf('%s\n',[' -- Channel "' CurChan '" with frequency "' num2str(CurFreqs(iBrush(c))) '" Hz '])
               
               % --- Retrieve typecode --- %
               
               mrk          = 0;
               [fld,type,cntt,cntm]   =   pf_pmg_seltremorUI_typecode(cond,condcode,CurChan,ChanCode,hand,mrk,CurFreqs(iBrush(c)),c,cntt,cntm);
                   
               fprintf('%s\n',[' --- Specified type ' num2str(type) ' (' fld ')'])
               
               % --- Calculate AUC if need be --- %
               
               if strcmp(peakopt,'auc')
                   switch peakopt.aucdef
                       case 'div2'
                           plusmin =  CurPow(b,iBrush(c))/2;    % Half of the peak power
                           
                           
                           
                       otherwise
                           warning('pmg:peaksel',['Did not recognize AUC-definition "' conf.fa.fig.peaksel.aucdef '"'])
                   end
               end
               
               % --- Store everything --- %

               %==========================================================%
               %[1           2        3      4      5       6        7      8         9       10     11 ]
               %[Session Condition Channel Type Frequency Power PowerSTD PowerCOV PowerMIN PowerMAX nDAT]
               if  isempty(CurPowers)
                   intersel(cnt,:)     =   [sesscode condcode ChanCode type CurFreqs(iBrush(c)) CurPow(b,iBrush(c)) nan nan nan nan nan];
                   fprintf('%s\n',' ---- Power over time was not found')
               else
                   disp('debug me');keyboard
                   % Implement PowerMIN, PowerMAX, nDat
                   intersel(cnt,:)     =   [sesscode condcode ChanCode type CurFreqs(iBrush(c)) CurPow(b,iBrush(c)) nanstd(CurPowers(b,iBrush(c),:)) (nanstd(CurPowers(b,iBrush(c),:))/CurPow(b,iBrush(c)))];
               end
               cnt = cnt+1;
               subplot(plots(a)); hold on;
               text(CurFreqs(iBrush(c)),CurPow(b,iBrush(c)), strcat('\leftarrow',num2str(CurFreqs(iBrush(c))),' Hz'),'FontSize',10)
               %==========================================================%
           end 
       end 
    end
end

%--------------------------------------------------------------------------

%% Decoding functions
%--------------------------------------------------------------------------

function sesscode    =   pf_pmg_seltremorUI_sesscode(str)
% returns the sesscode (as defined in decoding_PMG.xls) based on input str

if ~isempty(strfind(str,'OFF'))
    sesscode = 1;
elseif ~isempty(strfind(str,'ON'))
    sesscode = 2;
else
    sesscode = nan;
end

%--------------------------------------------------------------------------

function [cond,condcode]  =   pf_pmg_seltremorUI_condcode(condstring)
% returns cond (a string indicating the general condition) and its unique
% condcode (as decoded in decoding_PMG.xls)

if ~isempty(strfind(condstring,'Rest1'))
    cond = 'rest';
    condcode = 1;
elseif ~isempty(strfind(condstring,'Rest2'))
    cond = 'rest';
    condcode = 10;
elseif ~isempty(strfind(condstring,'Rest3'))
    cond = 'rest';
    condcode = 17;
elseif ~isempty(strfind(condstring,'Rest'))
    cond = 'rest';
    condcode = 24;
elseif ~isempty(strfind(condstring,'Coco'))
    cond = 'coco';
    condcode = 26;
elseif ~isempty(strfind(condstring,'RestCOG1'))
    cond = 'coco';
    condcode = 2;
elseif ~isempty(strfind(condstring,'RestCOG2'))
    cond = 'coco';
    condcode = 11;
elseif ~isempty(strfind(condstring,'RestCOG3'))
    cond = 'coco';
    condcode = 18;
elseif ~isempty(strfind(condstring,'RestmoM1'))
    cond = 'most';
    condcode = 3;
elseif ~isempty(strfind(condstring,'RestmoM2'))
    cond = 'most';
    condcode = 12;
elseif ~isempty(strfind(condstring,'RestmoM3'))
    cond = 'most';
    condcode = 19;
elseif ~isempty(strfind(condstring,'EntrM'))
    cond = 'most';
    condcode = 8;
elseif ~isempty(strfind(condstring,'RestmoL1'))
    cond = 'least';
    condcode = 4;
elseif ~isempty(strfind(condstring,'RestmoL2'))
    cond = 'least';
    condcode = 13;
elseif ~isempty(strfind(condstring,'RestmoL3'))
    cond = 'least';
    condcode = 20;
elseif ~isempty(strfind(condstring,'EntrL'))
    cond = 'least';
    condcode = 9;
elseif ~isempty(strfind(condstring,'POSH'))
    cond = 'posh';
    condcode = 25;
elseif ~isempty(strfind(condstring,'POSH1'))
    cond = 'posh';
    condcode = 6;
elseif ~isempty(strfind(condstring,'POSH2'))
    cond = 'posh';
    condcode = 15;
else
    cond     = 'NOTFOUND';
    condcode = nan;
    fprintf('%s\n',['Could not detect condition "' condstring '"'])
end

%--------------------------------------------------------------------------

function [fld,type,cntt,cntm]   =   pf_pmg_seltremorUI_typecode(cond,condcode,CurChan,ChanCode,hand,mrk,peakfreq,loopidx,cntt,cntm)
% Returns the unique typecode which can be based on the following criteria:
% 1) condition 2) channel 3) handedness. The type represents if the
% selected peak is a tremor (or harmonic of this), movement (or harmonic),
% mirrormovement. The typecodes are specified in decoding_PMG.xls. It will
% take counters as input and return the updated versions of this as wel.


if ChanCode==17
    fld   = 'HF';
    type  = 12;
elseif strcmp(cond,'rest') || strcmp(cond,'coco')
    if loopidx == 1
        fld  = 'tremor';
        type = 2;
    else
        fld  = ['harmontr' num2str(cntt)];
        type = 4;
        cntt  = cntt+1;
    end
elseif ( condcode==8 && (strcmp(hand,'R') && ( ChanCode<8 || ChanCode ==15))) || ( condcode==8 && (strcmp(hand,'L') && ( (ChanCode>7 && ChanCode<15) || ChanCode ==16))) % If EntrM & MA
    if loopidx == 1
        fld = 'move';
        type = 1;
    else
        fld = 'tremor';
        type = 2;
    end
elseif (condcode==8 && (strcmp(hand,'L') && ( ChanCode<8 || ChanCode ==15))) || ( condcode==8 && (strcmp(hand,'R') && ( (ChanCode>7 && ChanCode<15) || ChanCode ==16))) % If EntrM & LA
    if loopidx == 1
        fld  = 'mirrormove';
        type = 7;
    else
        fld = 'tremor';
        type = 2;
    end
elseif (condcode==9 && (strcmp(hand,'R') && ( ChanCode<8 || ChanCode ==15))) || ( condcode==9 && (strcmp(hand,'L') && ( (ChanCode>7 && ChanCode<15) || ChanCode ==16))) % If EntrL & MA
    if loopidx == 1
        fld  = 'mirrormove';
        type = 7;
    else
        fld = 'tremor';
        type = 2;
    end
elseif (condcode==9 && (strcmp(hand,'L') && ( ChanCode<8 || ChanCode ==15))) || ( condcode==9 && (strcmp(hand,'R') && ( (ChanCode>7 && ChanCode<15) || ChanCode ==16))) % If EntrL & LA
    if loopidx == 1
        fld = 'move';
        type = 1;
    else
        fld = 'tremor';
        type = 2;
    end
elseif    ( (condcode==3 || condcode==12 || condcode==19) && (strcmp(hand,CurChan(1))) )... %RestMoM, MA channel
        || ( (condcode==4 || condcode==13 || condcode==20) && (~strcmp(hand,CurChan(1))) )   %RestMoL, LA channel
    if loopidx==1
        fld  = 'move';
        type = 1;
    else
        while mrk==0
            in   =   input(' -- Please specify this marker (1=movement; 2=tremor; 3=movement harmonic; 4=tremor harmonic; 7=mirrormove):  ');
            if in==1
                fld = 'move';
                mrk = 1;
            elseif in==2
                fld = 'tremor';
                mrk = 1;
            elseif in==3
                fld = ['harmonmv' num2str(cntm)];
                mrk = 1;
                cntm = cntm+1;
            elseif in==4
                fld = ['harmonmtr' num2str(cntt)];
                mrk = 1;
                cntt = cntt+1;
            elseif in==7
                fld = 'mirrormove';
                mrk = 1;
            else
                disp(['Could not recognize specification "' num2str(in) '". Please try again'])
            end
        end
        type = in;
    end
elseif    ( (condcode==3 || condcode==12 || condcode==19) && (~strcmp(hand,CurChan(1))) )... %RestMoM, LA channel
        || ( (condcode==4 || condcode==13 || condcode==20) && (strcmp(hand,CurChan(1))) )     %RestMoL, MA channel
    while mrk==0
        in   =   input(' -- Please specify this marker (1=movement; 2=tremor; 3=movement harmonic; 4=tremor harmonic; 7=mirrormove):  ');
        if in==1
            fld = 'move';
            mrk = 1;
        elseif in==2
            fld = 'tremor';
            mrk = 1;
        elseif in==3
            fld = ['harmonmv' num2str(cntm)];
            mrk = 1;
            cntm = cntm+1;
        elseif in==4
            fld = ['harmonmtr' num2str(cntt)];
            mrk = 1;
            cntt = cntt+1;
        elseif in==7
            fld = 'mirrormove';
            mrk = 1;
        else
            disp(['Could not recognize specification "' num2str(in) '". Please try again'])
        end
    end
    type = in;
elseif condcode == 6 || condcode == 15
    if loopidx == 1
        fld  = 'tremor';
        type = 2;
    else
        fld  = ['harmontr' num2str(cntt)];
        type = 4;
        cntt  = cntt+1;
    end
elseif strcmp(cond,'posh') || strcmp(cond,'post') || strcmp(cond,'weight')        
    if peakfreq<3.5
        fld  = 'lowfreqnoise';
        type = 10;
    elseif peakfreq<6
        fld  = 'tremor';
        type = 2;
    else
        fld  = 'posttremor';
        type = 11;
    end
else
    disp('No type specified')
    type    =   nan;
    fld     =   'NOTFOUND';
end

% -------------------------------------------------------------------------

function chancode = pf_pmg_seltremorUI_chancode(chanstring)
% Function to retrieve the code corresponding to the current channel. All
% these codes are arbitrarily chosen and registered in an excel file filed
% under Evernote DRDR-PMG-POSTPD sess-cond-chan-type decoding

if strcmp(chanstring,'R-Deltoideus')
    chancode = 1;
elseif strcmp(chanstring,'R-Biceps')
    chancode = 2;
elseif strcmp(chanstring,'R-Triceps')
    chancode = 3;
elseif strcmp(chanstring,'R-EDC')
    chancode = 4;
elseif strcmp(chanstring,'R-FCR')
    chancode = 5;
elseif strcmp(chanstring,'R-ABP')
    chancode = 6;
elseif strcmp(chanstring,'R-EDC')
    chancode = 7;
elseif strcmp(chanstring,'R-FID1')
    chancode = 8;
elseif strcmp(chanstring,'L-Deltoideus')
    chancode = 9;
elseif strcmp(chanstring,'L-Biceps')
    chancode = 10;
elseif strcmp(chanstring,'L-Triceps')
    chancode = 11;
elseif strcmp(chanstring,'L-EDC')
    chancode = 12;
elseif strcmp(chanstring,'L-FCR')
    chancode = 13;
elseif strcmp(chanstring,'L-ABP')
    chancode = 14;
elseif strcmp(chanstring,'R-ACC')
    chancode = 15;
elseif strcmp(chanstring,'L-ACC')
    chancode = 16;
elseif strcmp(chanstring,'ECG')
    chancode = 17;
elseif strcmp(chanstring,'L-EDC&L-FCR')
    chancode = 18;
elseif strcmp(chanstring,'R-EDC&R-FCR')
    chancode = 19;
else
    chancode = nan;
end


%==========================================================================