function r = getray(x,y,z)
% r = getray(x,y,z) returns the ray of a sphere with coordinates x, y, z
%
% Created by Michiel Dirkx, 2014
% Contact michiel_dirkx@outlook.com

%% Warming Up

if nargin < 1
    x = 0;
end

if nargin < 2
    y = 0;
end

if nargin < 3
    z = 0;
end

%% Calculate ray

r = sqrt(x^2 + y^2 + z^2);