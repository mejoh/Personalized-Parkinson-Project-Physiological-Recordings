function pf_horline(y,varargin)
%
% Plots a horizontal line in current figure for y coordinate = y
% 'col',color | 'style',style

%% Set defaults

col     =   'k';
style   =   '-';

%% Deal with varargin 

for a = 1:length(varargin)
if mod(a,2) == 1
switch varargin{a}
case 'color'
    col    =   varargin{a+1};      % message about multiple files
case 'style'
    style    =   varargin{a+1};      % message about no files
end
end
end

%% Plot Line

hold on
plot(get(gca,'xlim'),[y y],'color',col,'LineStyle',style);
hold off


