function [ R ] = series_downsample( S, upsample_factor  )
%SERIES_DOWNSAMPLE decrease sampling rate by integer factor
%   Requires Signal Processing Toolbox

    if upsample_factor>1
        % and downsample after convolving
        %C = resample(C,1,upsample_factor);
        R = downsample(S,upsample_factor); % from signal processing toolbox
    else
        R = S;
    end
end

