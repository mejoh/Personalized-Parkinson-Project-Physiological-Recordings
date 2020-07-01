function [Xe,varargout]    =   pf_boxplot(D,Xb,varargin)
%
% [Xe,varargout] = pf_boxplot(D,Xb,varargin) plots the average + 
% 25th-75th percentile of the data in vector D with first datapoint plotted on Xb.
% Addiotionally, all data elements are plotted as well (this unlike the 
% traditional MatLab boxplot function). Furthermore it returns the center X
% coordinate of your boxplot (useful for xtick) and X coordinate of your
% last datapoint
%
% You can specify additional varargin options:
%       - 'avg':    choose 'median' or 'mean' (default = median)
%       - 'stat':   statistics. 'ttest' for a one-sampe ttest.
%
% You can also choose to have varargout options:
%       -  Xc:    Center of x coordinates
%       -  H:     H=0 indicates null hypothesis cannot be rejected.
%       -  p:     p-value
%

% © Created by Michiel Dirkx, 2014
% $ParkFunC

%--------------------------------------------------------------------------

%% Bug Reports

if size(D,1) > 1 && size(D,2) > 1
    warning('bxplot:mtx','Your data is a matrix. This function can only handle vectors, please redefine.')
end


%% Deal with Varargin options
%--------------------------------------------------------------------------

if nargin < 2; Xb = 1; end

for a = 1:length(varargin)
if mod(a,2) == 1
switch varargin{a}
case 'avg'
    avg   =   varargin{a+1};
case 'stat'
    stat  =   varargin{a+1};
end
end
end

%--------------------------------------------------------------------------

%% Calculate Boxplot parameters
%--------------------------------------------------------------------------

if ~exist('avg','var')
    avg     =   median(D);
elseif strcmp(avg,'mean') 
    avg     =   nanmean(D);
end

prct        =   prctile(D,[25 75]);
    
%--------------------------------------------------------------------------    

%% Initiate Loop Parameters
%--------------------------------------------------------------------------

nD      =  length(D);
x       =  Xb;
xall    =  nan(1,nD);

%--------------------------------------------------------------------------

%% Plot
%--------------------------------------------------------------------------

% --- All Data points --- %

for a = 1:nD
    
    plot(x,D(a),'x','color','b')
    hold on
    
    xall(1,a)  =  x;
    x          =  x + 0.1;
         
end

% --- Additional X values --- %

Xc             =   median(xall);
varargout{1}   =   Xc;
Xe             =   max(xall);

% --- Draw Boxplot --- %

plot([Xb Xe],[avg avg],'r-','linewidth',2)
pat =   patch([Xb Xe Xe Xb],[prct(1) prct(1) prct(2) prct(2)],'b');
set(pat,'EdgeColor','b','FaceColor','none')

%--------------------------------------------------------------------------

%% Perform Statistics
%--------------------------------------------------------------------------

if exist('stat','var')
    switch stat
        case 'ttest'
            if ~isnan(D)
            try
            [H,P]           =   ttest(D);
            catch
                disp('Could not perform Ttest')
                H           =   nan;
                P           =   nan;
            end
            else
            warning('bxplt:ttest','Some of the values in your data vector are NaNs, which you cannot use for a ttest.')
            H = nan;
            P = nan;
            end
            varargout{2}    =   H;
            varargout{3}    =   P;
    end
end
            
            
            
    


