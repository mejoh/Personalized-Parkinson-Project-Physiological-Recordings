function pf_pmg_ft_kelsey(conf)
% pf_pmg_ft(conf) is the FieldTrip analysis part of the pf_pmg_batch
% function. Specify the following options in conf.ft.meth:
%   - 'freqana':   Frequency analyses of your PMG data.
%   - 'plot':      Plot the freqana data. Within the plot function you can
%                  also perform a peak selection.
%   - 'fragmentana': function to analyze fragments of conditions.
%
% Part pf_pmg_batch_kelsey.m

% �Michiel Dirkx, 2015
% $ParkFunC, version 20150609
% Made suitable for the reemergent project of Kelsey, 20180915
%--------------------------------------------------------------------------

%% Initialize
%--------------------------------------------------------------------------

nSub    =   length(conf.sub.name);
nSess   =   length(conf.sub.sess);

Files   =   cell(nSub*nSess,1);
cnt     =   1;

nMeth   =   length(conf.ft.meth);

%--------------------------------------------------------------------------

%% Retrieve all fullfiles
%--------------------------------------------------------------------------

fprintf('%s\n\n','1) Retrieving all file info')

if strcmp(conf.ft.load,'yes')
    fprintf('%s\n',['- Loading pre-analyzed data (' conf.ft.savefile ')...'])
    freqana = load(fullfile(conf.dir.datsave,'freqana',conf.ft.savefile));
    fn      = fieldnames(freqana);
    freqana = freqana.(fn{1});
else
    for a = 1:nSub
        CurSub  =   conf.sub.name{a};
        for b = 1:nSess
            CurSess =   conf.sub.sess{b};
            CurFile =   pf_findfile(conf.dir.ftsource,conf.ft.file,'conf',conf,'CurSub',a,'CurSess',b);
            %==========================FILES==================================%
            Files{cnt,1}.sub        =   CurSub;
            Files{cnt,1}.sess       =   CurSess;
            Files{cnt,1}.file       =   fullfile(conf.dir.ftsource,CurFile);
            %=================================================================%
            cnt =   cnt+1;
            fprintf('%s\n',['- added ' CurFile]);
        end
    end

end

%--------------------------------------------------------------------------

%% Perform all specified FT options
%--------------------------------------------------------------------------

for a = 1:nMeth
    CurMeth =   conf.ft.meth{a};
    switch  CurMeth
        
        %=================================================================%
        case 'freqana'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Frequency analysis using FieldTrip'])
        freqana = pf_pmg_ft_freqana2_kelsey(conf,Files);
        
        %=================================================================%
        case 'plot'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Plotting frequency analyzed data'])
        pf_pmg_ft_plot_kelsey(conf,freqana);
        
        %=================================================================%
        case 'fragmentana'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Analyzing fragments of your specifed conditions: ' cell2str(conf.ft.fragana.cond)])
        pf_pmg_ft_fragmentana(conf,freqana);
        
        %=================================================================%
        case 'timetopeak'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Analyzing time to peak'])
        pf_pmg_ft_timetopeak(conf,freqana);
        
        %=================================================================%
        otherwise
        %=================================================================%
        
        warning('pmg:fieldtirp',['Could not determine fieldtrip method "' CurMeth '"'])
        
        %=================================================================%
    end
end
            



