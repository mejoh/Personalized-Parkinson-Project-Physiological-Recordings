function pf_pmg_ft_plot(conf,freqana)
% pf_pmg_ft_plot(conf,freqana) will plot the frequency analyzed data in
% freqana. You can either load this freqana dataset from a previously saved
% frequency analysis, or call 'freqana' first in conf.ft.meth befor you
% call 'plot'. Specify the following plotting options in conf.fa.fig.meth
%       -   'powspct': will plot a power spectrum of the data and (if
%                      indicated) you can perform a peak selection on this.
%       -   'tfr': will plot a time-frequency representation of this. Note
%                  that this script was made a while ago and a lot has changed, so it
%                  might need some debugging.
%
% Part of pf_pmg_batch.m

% �Michiel Dirkx, 2015
% $ParkFunC, 20150609

%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

% --- Retrieve subjects based on loaded/created data --- %

if strcmp(conf.ft.load,'yes')
    uSub    =   conf.sub.name;
else
    ss      = cellfun(@(x) x.sub,freqana,'uniformoutput',0);
    uSub    = unique(ss);
end

nMeth        =   length(conf.fa.fig.meth);

%--------------------------------------------------------------------------

%% Plotting method 
%--------------------------------------------------------------------------

for a = 1:nMeth
    CurMeth =   conf.fa.fig.meth{a};   
    switch CurMeth
        
        %=================================================================%
        case 'powspct'
        %=================================================================%
        
        if freqana{1}.cfg.callinfo.calltime(2)<6 && freqana{1}.cfg.callinfo.calltime(1)<2016        % Backwards compatibility
            pf_pmg_plot_powspct(conf,freqana,uSub)
        else
            pf_pmg_plot_powspct2(conf,freqana,uSub)
        end
            
        %=================================================================%
        case 'tfr'
        %=================================================================%
            
        pf_pmg_plot_tfr(conf,freqana,uSub)
        
        %=================================================================%
        case 'coh'
        %=================================================================%
            
        pf_pmg_plot_coh(conf,freqana,uSub)
        
        %=================================================================%
        otherwise
        %=================================================================%
            
        warning('plot:meth',['Could not determine plotting method "' CurMeth '"'])
            
    end
end














