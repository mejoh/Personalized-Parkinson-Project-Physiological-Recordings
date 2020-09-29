function [ onsets, durations ] = mat_convert_to_onsets_durations(m,tr)
%mat_convert_to_onsets_durations converts a 0-1 timeseries pattern into onset and duration values.
%   Inverse function of mat_convert_onsets_durations
%   M should contain timeseries as columns with zero's for 'inactive' volumes
%   TR specifies the volume interval
%   Returns onset and duration values in a cell array.

    ncols=size(m,2);
    onsets = cell(1,ncols);
    durations = cell(1,ncols);
    for col=1:ncols
        prevlevel=0;
        len = 0;
        for row=1:size(m,1)
            if prevlevel~=m(row,col)
                if prevlevel==0
                    onsets{col} = [onsets{col} tr*row];
                else
                    durations{col} = [durations{col} (tr*len)];
                    len = 0;
                end
                prevlevel = m(row,col);
            end
            if m(row,col)
                len = len+1;
            end
        end
    end
end

