function [R,names,r_origres] = pf_emg_hrfregr(conf,regr,tr,dummy,nscan,dummyscans)
% [R,names] = pf_emg_hrfregr(conf,regr,tr,dummy,nscan,dummyscans) is a
% function to (1) convert a EMG timecourse with nSamples to nScans and (2)
% convolve this 'scan-regressor' with a hemodynamic BOLD function. If
% present, it will get rid of prescans (those are scans which you don't use
% in your FLA) which are usually included to get the correct tremor BOLD
% response at scan 1 and extratime (that is time included to account for
% the hanning taper, i.e. if your TR is 0.859 and you have a hanning taper
% of 2s your last scan will not be accounted for (1s of nans)). These items
% are defined during pf_emg_raw2regr_prepemg. The input includes
%       - conf: basic configuration structure
%       - regr: an old fashioned way of the regressor structure
%       - tr: the tr of every scan (defined during pf_emg_raw2regr_prepemg)
%       - dummy: the prestart of the first USED scan (so this is not the
%         amount of dummyscans you use, it is dummy+1-prestart)
%       - nscan: amount of scans detected in your folder (excluding
%                dummyscans)
%       - dummyscans: amount of dummyscans.
%
% The output is a SPM friendly regressor and a quality check (regressor with original temporal resolution):
%       - R: 4 regressors
%       - names: names of regressors
%       - r_origres: linear unconvolved regressor with original temporal
%       resolution

% � Michiel Dirkx, 2014
% contact: michieldirkx@gmail.com
% $ParkFunC
%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

uScan   =   unique(regr(:,2));
nScan   =   length(uScan);

timedat =   regr(2,3)-regr(1,3);     % Time of one datapoint
% if ~isempty(find(uScan==999, 1))
%     r       =   nan(nScan+dummyscans,1); %Plus one if extratime was included
%     dr      =   nan(nScan+dummyscans,1);
% else
%     r       =   nan(nscan+dummyscans,1); % Or not if no extratime
%     dr      =   nan(nscan+dummyscans,1);
% end

dr = nan(nScan,1);
r = nan(nScan,1);

nTrans  =   length(conf.mkregr.trans);

%--------------------------------------------------------------------------

%% Convert nDatapoints to nScans
%--------------------------------------------------------------------------

for a = 1:nScan
    
    CurScan =   uScan(a);
    sel     =   regr(:,2)==CurScan;
    
    scansam =   regr(sel,1);
    
    if CurScan~=999 && length(scansam) ~= round(tr(CurScan)/timedat)
        fprintf('%s\n',['- WARNING: Scan ' num2str(CurScan) ' has different amount of samples than the tr (' num2str(length(scansam)) ' VS ' num2str(tr(CurScan)/timedat) ' samples)']);
    end
    
    r(a)    =   scansam(conf.mkregr.sample);
    
end

if ~isempty(find(isnan(r), 1))
    warning('hrfregr:nan','Too few data for the amount of scans you entered (probably because you stopped the EMG before the scanner or the hanning taper is too big). Exterpolating last data...')
    good    =   r(~isnan(r));
    r(isnan(r)) = good(end);
end

%--------------------------------------------------------------------------

%% Calculate HRF
%--------------------------------------------------------------------------

spm('Defaults','fmri');

hrfOrig = spm_hrf(tr(1));                     % get HRF for TR

%--------------------------------------------------------------------------

%% Convolve HRF*EMG
%--------------------------------------------------------------------------

cr    = conv(r, hrfOrig);               % convolve data with HRF
cr    = cr(1:end-length(hrfOrig)+1);    % get rid of last datapoints (equal to length of HRF)
cr    = detrend(cr,'constant');         % detrend to remove linear trend

%--------------------------------------------------------------------------

%% Calculate transformations
%--------------------------------------------------------------------------

for a = 1:nTrans
    CurTrans    =   conf.mkregr.trans{a}; 
    switch CurTrans
        case 'deriv1'
            dr    = gradient(r);
            cdr   = conv(dr, hrfOrig);               % convolve data with HRF
            cdr   = cdr(1:end-length(hrfOrig)+1);    % get rid of last datapoints (equal to length of HRF)
            cdr   = detrend(cdr,'constant');      % detrend to remove linear trend
    end
end

% --- Remove dummy --- %

r     = r(dummy+1:end);                 % get rid of prestart
cr    = cr(dummy+1:end);                % get rid of prestart

dr    = dr(dummy+1:end);
cdr   = cdr(dummy+1:end);

% --- Remove Extratime for hanning taper --- %

if CurScan==999
    r     = r(1:end-1);                 % get rid of extratime if present (in which case the last r(a) should be based on code 999)
    cr    = cr(1:end-1);               
    
    dr    = dr(1:end-1);
    cdr   = cdr(1:end-1);
end

% --- check if current regressor matches the amount of scans detected --- %

if length(r) ~= nscan
    warning('hrfregr:scanmismatch',['The created regressor (n= ' num2str(length(r)) ') does not match the predefined amount of scans (n = ' num2str(nscan) '). Entering debug mode...'])
    keyboard
end

% --- Do the same for the original resolution --- %

sel        = regr(:,2)<regr(1,2)+dummy | regr(:,2)==999;
r_origres  = regr(~sel,:);

%--------------------------------------------------------------------------

%% Merge
%--------------------------------------------------------------------------

R       =   [r cr dr cdr];
names   =   {'lin_unconvolved';'lin_convolved';'deriv1_unconvolved';'deriv1_convolved';};

%==========================================================================