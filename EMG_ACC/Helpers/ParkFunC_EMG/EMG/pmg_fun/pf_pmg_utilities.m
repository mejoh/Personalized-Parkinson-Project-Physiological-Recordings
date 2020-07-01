function pf_pmg_utilities(conf)
% pf_pmg_utilities(conf) is a function which hosts several useful tools for
% pf_pmg_batch. Choose for one of the following methods:
%   - 'convertpeaksel': convert peaksel data into other matrix formats
%   - 'plotedf': simple plot of EDF file
%   - 'classificationplot_postpd': plot where subject will be classified,
%                   delta frequency (Y-axis) versus drop in power (X-axis)
%
% Part of pf_pmg_batch

% © Michiel Dirkx, 2015
% $ParkFunC, version 20151114

%--------------------------------------------------------------------------

%% Initialize

fprintf('%s\n\n','% ------------ Utilities ------------ %')

nMeth   =   length(conf.util.meth);


%% Meth
%--------------------------------------------------------------------------

for a = 1:nMeth
   CurMeth  =   conf.util.meth{a};
   switch CurMeth 
       
       %==================================================================%
       case 'convertpeaksel'
       %==================================================================%
        
       fprintf('%s\n',[num2str(a) ') Converting peaksel data into other formats'])
       pf_pmg_utilities_convpeaksel(conf);
       
       %==================================================================%
       case 'convertpeaksel2'
       %==================================================================%
        
       fprintf('%s\n',[num2str(a) ') Converting peaksel data into other formats'])
       pf_pmg_utilities_convpeaksel2(conf);
       
       %==================================================================%
       case 'plotedf'
       %==================================================================%
        
       fprintf('%s\n',[num2str(a) ') Simply plot EDF+ files '])
       pf_pmg_utilities_plotedf(conf);
       
       %==================================================================%
       case 'classificationplot_postpd'
       %==================================================================%
        
       fprintf('%s\n',[num2str(a) ') Classifying subjects inplot '])
       pf_pmg_utilities_classplotpostpd(conf);
       
       %==================================================================%
       otherwise
       %==================================================================%
        
       warning('pmg:util',['Could not determine utilities method "' CurMeth '"'])
       
       %==================================================================%
   end 
end








