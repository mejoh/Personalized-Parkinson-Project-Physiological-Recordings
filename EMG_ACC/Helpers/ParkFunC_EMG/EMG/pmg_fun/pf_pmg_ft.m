function pf_pmg_ft(conf)
% pf_pmg_ft(conf) is the FieldTrip analysis part of the pf_pmg_batch
% function. Specify the following options in conf.ft.meth:
%   - 'freqana': Frequency analyses of your PMG data.
%   - 'plot':      Plot the freqana data. Within the plot function you can
%                  also perform a peak selection.
%   - 'reanalyze': reanalyze freqana data using a previous peak selection
%                  file. Useful when you did peak selection on a freqana
%                  dataset but then decide you should've done a different
%                  freqana on the dataset. This way you can just load the
%                  specification of this peak selection to perform it on
%                  the new freqana. Freqana is leading, make sure all the
%                  subjects/sessions/conditions in freqana are present in
%                  peaksel.
%   - 'reanalyze2': same as reanalyze, but now the peaksel file is leading.
%   - 'fragmentana': function to analyze fragments of conditions.
%
% Part pf_pmg_batch.m

% �Michiel Dirkx, 2015
% $ParkFunC, version 20150609

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
        CurHand =   conf.sub.hand{a};
        for b = 1:nSess
            CurSess =   conf.sub.sess{b};
            CurFile =   pf_findfile(conf.dir.ftsource,conf.ft.file,'conf',conf,'CurSub',a,'CurSess',b);
            %==========================FILES==================================%
            Files{cnt,1}.sub        =   CurSub;
            Files{cnt,1}.sess       =   CurSess;
            Files{cnt,1}.hand       =   CurHand;
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
        freqana = pf_pmg_ft_freqana2(conf,Files);
        
        %=================================================================%
        case 'plot'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Plotting frequency analyzed data'])
        pf_pmg_ft_plot(conf,freqana);
        
        %=================================================================%
        case 'reanalyze'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Reanalyzing data based on previous peakselection and frequency analysis (freqana leading)'])
        pf_pmg_ft_reanalyze(conf,freqana);
        
        %=================================================================%
        case 'reanalyze2'
        %=================================================================%
        
        fprintf('\n%s\n',[num2str(a+1) ') Reanalyzing data based on previous peakselection and frequency analysis (peaksel leading)'])
        pf_pmg_ft_reanalyze2(conf,freqana);
        
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
            



