function pf_verline(x,varargin)
%
% PF_verline(x,varargin) plots a vertical line on coordinate x in your
% current figure. You can use the following varargin's to make up your
% line:
%   -   'Color',[r g b]: specify your color (default 'k')
%   -   'LineWidth',x  : Specify your line width (default 0.5)
%   -   'LineStyle','' : Specify your line style (default '-')
%
% Michiel Dirkx, 2014
% $ParkFunC

%% Warming Up

if nargin < 1
    error('VerLine:x','No x-value was specified')
end

col     = 'k';
style   = '-';
width   = 0.5;

if exist('varargin','var')
for a = 1:length(varargin)
    if mod(a,2)
    switch varargin{a}
        case 'color'
            col = varargin{a+1};
        case 'linestyle'
            style = varargin{a+1};
        case 'linewidth'
            width = varargin{a+1};
    end
    end
end
end

%% Plot Vertical Line on x

for b = 1:length(x)
    line([x(b) x(b)],get(gca,'YLim'),'Color',col,'LineStyle',style,'LineWidth',width)
end




