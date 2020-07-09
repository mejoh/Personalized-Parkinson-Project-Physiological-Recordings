% function outmat=mat_convert_onsets_durations(onsets,durations,tr,nvol,srate[,zero_padding_sec])
%
% srate = sample rate, in samples / volume (!!!), NOT / second
% 
% 2010-10-18: Paul added optional zero_padding_sec argument because zero padding is not always useful

function outmat=mat_convert_onsets_durations(onsets,durations,tr,nvol,srate,zero_padding_sec)

    m=zeros(round(nvol*srate),numel(onsets));

    % ga de onsets en durations 'samplen'
    for i=1:numel(onsets)

        for j=1:numel(onsets{i})

            b=round(onsets{i}(j)*srate/tr+1);
            e=round(durations{i}(j)*srate/tr)+b;

            m(b:e,i)=1;

        end
    end

    % circumvent nasty error messages... (pad with zeros)
    if nargin<6
        zero_padding_sec = 10; % 10 seconds by default
    end
    if zero_padding_sec>0
        m(end:end+srate*zero_padding_sec,:)=0;
    end

    outmat=m;

