function cov = pf_coefvar(x)
%
% Compute the coefficient of variation for time series x as measured by
% std/mean.

% 

%% Warnings

if sum(isnan(x)) > 0
    warning('COV:nan','Your vector contains at least one nan.')
end

%% CoV

cov = nanstd(x(:))/nanmean(x(:))*100;