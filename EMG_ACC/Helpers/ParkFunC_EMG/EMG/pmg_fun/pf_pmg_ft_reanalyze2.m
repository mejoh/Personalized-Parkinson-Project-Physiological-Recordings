function pf_pmg_ft_reanalyze2(conf,freqana)
% pf_pmg_ft_reanalyze(conf,Files) reanalyses data. That is, it uses a peak
% selection input (specified by the user) to reload that data and perform
% this peakselection on a frequency analysis dataset specfied in freqana.
% For this, it is necessary you have a 'freqana' dataset and a 'peaksel'
% dataset. Unlike pf_pmg_ft_reanalyze, in this script the peaksel file is
% leading, that is it will try to find the freqana data corresponsing
% to every peak in the peaksel file.
%
% Practical example: let's say you manually did a peak selection on a
% freqana dataset which was bandpass filtered at 2-40 Hz. Later on you
% decide that you should have taken a band-pass filter of 1-40 Hz. In this
% case, do the freqana again (specify in conf.ft.meth) for the required
% subjects, enter the input 'peaksel' file which indicates the manual peak
% selection you previously did and run this script again. You can choose to
% plot the figures or not.
%
% Part of pf_pmg_batch.m

% © Michiel Dirkx, 2015
% $ParkFunC, version 20160215

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

inp   =   load(conf.ft.reanalyze.input);
fn    =   fieldnames(inp);
inp   =   inp.(fn{1});

data_freq = freqana;
cnt       =   1;

nPeaks  =   length(inp);

%--------------------------------------------------------------------------

%% Loop
%--------------------------------------------------------------------------

for a = 1:nPeaks
    
    % --- Current peak --- %
    
    CurPeaks    =   inp(a,:);
    
    % --- Retrieve freqana data corresponding to sub/session --- %
    
    subcode     =   inp(a,1);
    CurSub      =   ['p' num2str(subcode,'%02i')];
    
    sesscode    =   inp(a,2);
    CurSess     =   pf_pmg_sessname(sesscode);
    
    sel         =   cellfun(@(x) strcmp(x.sub,CurSub) && strcmp(x.sess,CurSess),freqana);
    CurDat      =   freqana(sel);
    
    if isempty(CurDat)
        disp(['- Did not find frequency analyzed data for "' CurSub '-' CurSess '"'])
        continue
    end
    
    % --- Retrieve freqana data corresponding to condition --- %
    
    condcode    =   inp(a,3);
    CurCond     =   pf_pmg_condname(condcode);
    
    if strcmp(CurCond,'RestAVG')
        sel     =   cellfun(@(x) strcmp(x.cond,'Rest1') || strcmp(x.cond,'Rest2') || strcmp(x.cond,'Rest3'),CurDat);
        CurDat  =   CurDat(sel);
    elseif strcmp(CurCond,'POSHAVG')
        sel     =   cellfun(@(x) strcmp(x.cond,'POSH1') || strcmp(x.cond,'POSH2'),CurDat);
        CurDat  =   CurDat(sel);
    elseif strcmp(CurCond,'COCOAVG')
        sel     =   cellfun(@(x) strcmp(x.cond,'RestCOG1') || strcmp(x.cond,'RestCOG2') || strcmp(x.cond,'RestCOG3'),CurDat);
        CurDat  =   CurDat(sel);
    elseif strcmp(CurCond,'POSTAVG')
        sel     =   cellfun(@(x) strcmp(x.cond,'POST1') || strcmp(x.cond,'POST2'),CurDat);
        CurDat  =   CurDat(sel);
    else
        sel     =   cellfun(@(x) strcmp(x.cond,CurCond),CurDat);
        CurDat  =   CurDat(sel);
    end
    
    if length(CurDat)>1 % If multicondition need to be averaged
       nDat     =   length(CurDat);
       size3    =   max(cellfun(@(x) size(x.powspctrm,3),CurDat)); % Take the longest time course for averaging
       pow      =   nan(size(CurDat{1}.powspctrm,1),size(CurDat{1}.powspctrm,2),size3,nDat);
       for b=1:nDat
           curdat   =   CurDat{b}.powspctrm;
           pow(:,:,1:size(curdat,3),b) = curdat;
       end
       pow      =   nanmean(pow,4);
       sel      =   cellfun(@(x) length(x.time)==size3,CurDat);
       CurDat   =   CurDat{sel}; 
       CurDat.powspctrm =   pow;
       CurDat.cond      =   CurCond;
    elseif isempty(CurDat)
        disp(['-- Did not find frequency analyzed data for "' CurSub '-' CurSess ' ' CurCond '"'])
        continue
    end
    
    if iscell(CurDat)
        CurDat  =   CurDat{1};
    end
    
    % --- Retrieve iChan from CurDat --- %
    
    chancode    =   inp(a,4);
    CurChan     =   pf_pmg_chancode2name(chancode);
    
    if strcmp(CurChan,'L-EDC&L-FCR')
        sel         =   ismember(conf.ft.chans(:,2),{'L-EDC';'L-FCR'});
        CurChan     =   conf.ft.chans(sel,1);
        iChan       =   ismember(CurDat.label,CurChan);
    elseif strcmp(CurChan,'R-EDC&R-FCR')
        sel         =   ismember(conf.ft.chans(:,2),{'R-EDC';'R-FCR'});
        CurChan     =   conf.ft.chans(sel,1);
        iChan       =   ismember(CurDat.label,CurChan);
    else
        sel         =   ismember(conf.ft.chans(:,2),CurChan);
        CurChan     =   conf.ft.chans(sel,1);
        iChan       =   strcmp(CurDat.label,CurChan);
    end
    
    if isempty(iChan)
        disp(['- Did not find frequency analyzed data for "' CurSub '-' CurSess ' ' CurCond ' ' CurChan '"'])
        continue
    end
    
    % --- Retrieve iFreq from CurDat --- %
    
    CurFreq =   CurPeaks(6);
    iFreq   =   pf_closestto(CurDat.freq,CurFreq);
    
    % --- And now, calculate all parameters --- %
    
    iTime(1)      =   pf_closestto(CurDat.time,CurDat.time(1)+conf.ft.reanalyze.time(1));
    if conf.ft.reanalyze.time(2)==999
        iTime(2)  =   length(CurDat.time);
    else
        iTime(2)  =   pf_closestto(CurDat.time,CurDat.time(1)+conf.ft.reanalyze.time(2));
    end
    
    Power       =   squeeze(CurDat.powspctrm(iChan,iFreq,iTime(1):iTime(2)));
    if size(Power,1)>1 && size(Power,2)>1   % Channel averaging
        Power   =   nanmean(Power,1);
    end
    
    PowerAVG =   nanmean(Power);    
    PowerSTD =   nanstd(Power);
    PowerCOV =   PowerSTD/PowerAVG;
    PowerMin =   min(Power);
    PowerMax =   max(Power);
    nPower   =   length(Power);
    
    % ====================AND BUILD THE NEW PEAKSEL=======================%
    %[1        2        3       4      5       6       7      8         9       10     11       12  ]
    %[Sub   Session Condition Channel Type Frequency Power PowerSTD PowerCOV PowerMIN PowerMAX nDAT ]
    
    intersel(cnt,:) =   [subcode sesscode condcode chancode CurPeaks(5) CurFreq PowerAVG PowerSTD PowerCOV PowerMin PowerMax nPower];
    cnt            =   cnt+1;
    %=====================================================================%
    
end

%--------------------------------------------------------------------------

%% Save Peaksel
%--------------------------------------------------------------------------

if ~exist(conf.dir.datsave,'dir'); mkdir(conf.dir.datsave); end

savename = fullfile(conf.dir.datsave,conf.ft.reanalyze.savename);
save(savename,'intersel');
fprintf('\n%s\n',['Saved reanalyzed data to ' savename])

%--------------------------------------------------------------------------



