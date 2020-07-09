function [ R ] = series_upsample( S, upsample_factor )
%SERIES_UPSAMPLE increase sampling rate by integer factor
%   Requires Signal Processing Toolbox

    if upsample_factor>1
        % Note: the following functions introduce some oscillation on abrubt changes
        %R = resample(S, upsample_factor,1);
        R = interp(S, upsample_factor); % from signal processing toolbox
    else
        R = S;
    end
end

