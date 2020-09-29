function stats = pf_corrline(A,B,varargin)
% pf_corrline(A,B,varargin) makes a scatter plot of the matrices A and B and adds a
% correlational line in a least-squares sense.
% Input:
%   - A: vector A for correlation
%   - B: vector B for correlation
%   - varargin:
%       - 'meth': 'ls' (least squares, default), 'rf' (robust fit)
% Output:
%   - stats:
%       - pears: r- and p-value of pearson correlation of A with B
%       - spear: rho- and p-value of spearman correlation of A with B
%       - kend: rho- and p-value of kendall correlation of A with B
%       - coef: coefficients of the regression line (y=coef(1)*x+coef(2))
%       - coefse: standard error of coeffecient estimates (only for robustfit)
%       - coefset: ratio of coeffecient estimates to coefse (only for robustfit)
%       - coefsetp: p-value of coefset


% � Michiel Dirkx, 2015
% $ParkFunC, version 20150224

%--------------------------------------------------------------------------

%% Defaults
%--------------------------------------------------------------------------

meth    =   'ls';
col     =   'b';


%--------------------------------------------------------------------------

%% Deal with varargin
%--------------------------------------------------------------------------


for a = 1:length(varargin)
if mod(a,2)    
switch varargin{a}
case 'meth'
    meth    =   varargin{a+1};      % message about multiple files
case 'color'
    col    =   varargin{a+1};      % message about multiple files
end
end
end

%--------------------------------------------------------------------------

%% Execute correlational tests
%--------------------------------------------------------------------------

[stats.pears(1),stats.pears(2)]   =   corr(A,B);
[stats.spear(1),stats.spear(2)]   =   corr(A,B,'type','spearman');
[stats.kend(1),stats.kend(2)]     =   corr(A,B,'type','kendall');

% pears             =   corr(A,B);
% spear             =   corr(A,B,'type','spearman');


%--------------------------------------------------------------------------

%% Perform 
%--------------------------------------------------------------------------

figure;
scatter(A,B,[],col,'filled','s');

switch meth
    
    %=====================================================================%
    case 'ls'
    %=====================================================================%
        
    coef    =   polyfit(A,B,1);
    refline(coef(1),coef(2));
        
    stats.coef  = coef;
    
    %=====================================================================%
    case 'rf'
    %=====================================================================%
        
    [coef,s]    =   robustfit(A,B);
    refline(coef(2),coef(1));
    
    stats.coef     = flipud(coef);
    stats.coefse   = flipud(s.se);
    stats.coefset  = flipud(s.t);
    stats.coefsetp = flipud(s.p);
    
    %=====================================================================%
        
end

        
        
        


