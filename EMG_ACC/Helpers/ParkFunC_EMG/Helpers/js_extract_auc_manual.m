function [auc] = js_extract_auc_manual(data, cfg, conf)
% This function extracts the FWHM area under the curve (AUC) for the highest peak in a power spectrum.   
% 
%  Required variables are: 
%  - data: accelerometry data required for FFT
%  - cfg: particularly the fields: cfg.cfg_freq.foi, 
%  - conf: particularly the fields: conf.dir.auc, conf.sub.name,
%  conf.sub.ses, conf.sub.run, conf.auc (all variables)
% 
%  UPDATE DESCRIPTION!!
% The function follows these steps: 
% 1. divides the data in 5-second segments (using fieldtrip).
% 2. do a fast Fourier transform to get the power spectrum for each segment, which are then averaged, using a filter (2-8 Hz) (using fieldtrip, 'mtmfft' and 'hanning' taper).
% 3. Find channel with peak frequency by selecting highest local maximum ('findpeaks'; between specified filter, ideally 3.4-6.6 Hz).
% 4. Upsample peak channel with a factor 20. Find peak again.
% 5. Find local minima next to peak and FWHM values in upsampled spectrum.
% 6. Calculate AUC based on the FWHM (trapz-function).
% 7. The results are plotted and saved. 
% 
%  Written as an addition to Park_FunC (by M. Dirkx) by Jitse Amelink 
%  based on earlier scripts from Freek Nieuwhof
%  20200120
%% Variable check
entered_channel = conf.auc.manual_chan;
entered_range = conf.auc.manual_range;

if isempty(entered_range) == 1
    error('Manual range is not specified, modify conf.auc.manual_range in raw2regr.')
elseif length(entered_range) > 2
    error('Manual range has more than two values, modify conf.auc.manual_range in raw2regr.')
elseif all(entered_range < cfg.fft_auc{2}.foi(1) | entered_range > cfg.fft_auc{2}.foi(end));
    error('Manual range is outside powerspectrum, modify conf.auc.manual_range in raw2regr.')
elseif isempty(entered_channel) == 1
    error('Manual channel is not specified, modify conf.auc.manual_chan in raw2regr.')
elseif length(entered_channel) > 1
    error('Manual channel has more than one value, modify conf.auc.manual_chan in raw2regr.')
elseif all(conf.auc.chan{1}(1) > entered_channel | conf.auc.chan{1}(end) < entered_channel)
    error('Manual channel is not in range of channels. Modify conf.auc.manual_chan or check channel definitions (conf.auc.chan).')
end

%% Creating segmented data

cfg_fft = cfg.fft_auc{1};
segmenteddata = ft_redefinetrial(cfg_fft, data); %redefine data into segments    

%% FFT frequency analysis using Fieldtrip

cfg_fft = cfg.fft_auc{2};
FFT = ft_freqanalysis(cfg_fft,segmenteddata);

%% Groundwork: setting channel and upsampling channel
entered_channel_name = data.label(entered_channel);
fprintf(['Channel for manual peak selection is: ', char(entered_channel_name), '. This channel will be upsampled.' ])

us_factor = conf.auc.us_factor; %specify upsample factor here
us_powerspectrum = interp(FFT.powspctrm(entered_channel, :),us_factor); %actual upsampling
us_foi = interp(cfg_fft.foi,us_factor); %upsampling of foi


%% PEAK SElECTION WITH RANGE IN UPSAMPLED SPECTRUM
fprintf(['\n Peak is selected within range: ' num2str(entered_range) ])
if length(entered_range) == 2 %Selects peak within range

    %creating range and upsampled range
    lower_index = find(round(cfg_fft.foi*10)/10 == conf.auc.filter(1));
    upper_index = find(round(cfg_fft.foi*10)/10 == conf.auc.filter(2));
    range = lower_index:upper_index;
    
    us_lower_index = find(round(us_foi*100)/100 == entered_range(1)); 
    us_upper_index = find(round(us_foi*100)/100 == entered_range(2));
    us_range = us_lower_index:us_upper_index;
    
    %finding peaks within range
    peak_value = findpeaks(FFT.powspctrm(entered_channel, range));
    us_peak_value = findpeaks(us_powerspectrum(us_range)); 

    if any(length(us_peak_value) > 1 | length(peak_value) > 1) %in case more than one peak is present in range
        peak_value = max(peak_value); %select overall maximum
        us_peak_value = max(us_peak_value); 
        warning('More than one peak was found in the manual range. The highest peak was selected.')
    end
    
    %find peak indices
    [peak_channel, peak_ind] = find(FFT.powspctrm == peak_value); %find channel and index (frequency) of peak 
    peak_freq =  cfg_fft.foi(peak_ind); %frequency of peak
    entered_channel_name = data.label(peak_channel); % name of that channel
    peak_value = FFT.powspctrm(peak_channel, peak_ind); % value of the peak
    
    us_peak_ind = find(us_powerspectrum == us_peak_value);
    us_peak_freq = us_foi(us_peak_ind);
    us_half_max = us_peak_value/2;

end

%% PEAK SELECTION WITH ONE VALUE
if length(entered_range) == 1 %Selects peak closest to given value
    entered_index = find(round(cfg_fft.foi*10)/10 == entered_range(1));
    [peaks, peak_indices] = findpeaks(FFT.powspctrm(entered_channel,:)); %find local maxima    
    dist2closest_peak = min(abs(peak_indices - entered_index)); %minimize distance to local maximum from desired frequency
   
    us_entered_index = find(round(us_foi*100)/100 == entered_range(1)); %find upsampled index of desired frequency
    [us_peaks, us_peak_indices] = findpeaks(us_powerspectrum(:)); %find local maxima
    us_dist2closest_peak = min(abs(us_peak_indices - us_entered_index)); %minimize distance to local maximum from desired frequency
    
    %if-loop to get index of nearest peak
    if any(dist2closest_peak + entered_index == peak_indices)
        peak_ind = dist2closest_peak + entered_index;
    elseif any(us_entered_index - us_dist2closest_peak == us_peak_indices)
        peak_ind = entered_index - dist2closest_peak;
    else
        error('Peak index was not found. Try a range or a different channel.')
    end
    
    %Upsampled.
    if any(us_dist2closest_peak+us_entered_index == us_peak_indices)
        us_peak_ind = us_dist2closest_peak+us_entered_index;
    elseif any(us_entered_index-us_dist2closest_peak == us_peak_indices)
        us_peak_ind = us_entered_index-us_dist2closest_peak;
    else
        error('Upsampled peak index was not found. Try a range or a different channel.')
    end
    
    peak_value = FFT.powspctrm(entered_channel, peak_ind); % value of the peak
    peak_freq =  cfg_fft.foi(peak_ind); %frequency of peak
    
    us_peak_value = us_powerspectrum(us_peak_ind); 
    us_peak_freq = us_foi(us_peak_ind);
    us_half_max = us_peak_value/2;
end

%% Find local minima closest to max peak
inverted_powerspectrum = us_peak_value - us_powerspectrum; %invert power spectrum
[peaks, ind_local_min] = findpeaks(inverted_powerspectrum); %use inverted power spectrum to find peaks (= local minima)
dist2peak = ind_local_min - us_peak_ind; %calculate distance of local minima to peak 
ind_left_local_min = max(dist2peak(dist2peak<0)) + us_peak_ind; %select left local minimum (is below zero, therefore max close to peak)
ind_right_local_min = min(dist2peak(dist2peak>0)) + us_peak_ind; %select right local minimum (above zero, therefore min)

%% Find FWHM indices
diff_half_max = abs(us_powerspectrum - us_half_max); %calculate the difference between powerspectrum and half-maximum.

[halfmax_left] = sort((diff_half_max([ind_left_local_min: us_peak_ind]))); %sorts left half-maximum differences (range between left local minimum and peak).
if isempty(halfmax_left) == 1; % for cases where no local minimum left of peak - set lower boundary to 1.
    halfmax_left = sort((diff_half_max([1 : us_peak_ind])));
end

ind_left = find(halfmax_left(1) == diff_half_max); %finds index of left half-maximum
[halfmax_right] = sort((diff_half_max([us_peak_ind: ind_right_local_min]))); 
if isempty(halfmax_right) == 1; % for cases where no local minimum right of peak - set upper boundary to end-1.
    halfmax_right = sort((diff_half_max([us_peak_ind: end-1])));
end
ind_right = find(halfmax_right(1) == diff_half_max);

auc_window = us_foi([ind_left ind_right]); %gives the frequency window of the FWHM in frequencies
auc_window_ind = [ind_left ind_right]; %gives the frequency window of the FWHM in indices

%% Calculate AUC
auc = trapz(us_powerspectrum(auc_window_ind(1):auc_window_ind(2)));

%% Plot power spectrum
subject_id = char(conf.sub.name);
session = char(conf.sub.sess);
run = char(conf.sub.run);

fig = figure('units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1]);
subplot(1,3,1);
plot(FFT.freq,FFT.powspctrm(cfg.chandef{1},:))
line([peak_freq peak_freq],[0 max(max(FFT.powspctrm(cfg.chandef{1},:)))],'Color','k','LineStyle','--');
xlabel(' Frequency (Hz)' )
ylabel('Power')
legend(FFT.label(cfg.chandef{1}));
title('EMG power spectrum');
  
subplot(1,3,2);
plot(FFT.freq,FFT.powspctrm(conf.auc.chan{1},:))
line([peak_freq peak_freq],[0 max(max(FFT.powspctrm(conf.auc.chan{1},:)))],'Color','k','LineStyle','--');
xlabel(' Frequency (Hz)' )
ylabel('Power')
legend(FFT.label(conf.auc.chan{1}));
title({'AAC power spectrum.'});

area_x = us_foi(auc_window_ind(1):auc_window_ind(2));
area_y = us_powerspectrum(auc_window_ind(1):auc_window_ind(2));

subplot(1,3,3)
plot(us_foi,us_powerspectrum)
line([auc_window(1) auc_window(1)],get(gca,'Ylim'),'Linestyle',':','Color','r');
line([auc_window(2) auc_window(2)],get(gca,'Ylim'),'Linestyle',':','Color','r');
hold on;
area(area_x, area_y);
hold off;
xlabel(' Frequency (Hz)' )
ylabel('Power')
auc_title = ['Area under the curve: ' num2str(auc, 4)];
peak_chan_title = ['Peak channel: ' char(entered_channel_name)] ;
us_peak_freq_title = ['Upsampled peak freq: ' num2str(us_peak_freq) 'Hz'];
us_peak_title = ['Upsampled peak:' num2str(round(us_peak_value))];
title ({auc_title, peak_chan_title, us_peak_freq_title, us_peak_title})
suptitle(['Subject: ' char(subject_id)]);

%% Save
file_name_img = fullfile(conf.dir.auc,[subject_id '_' session '_' run '_plotAUC_manual_' char(entered_channel_name) '.jpg']);
set(gcf,'PaperPositionMode','auto')
saveas(fig, file_name_img);

file_name_data = fullfile(conf.dir.auc,[subject_id '_' session '_' run '_auc_manual.mat']);
save(file_name_data, ...
        'subject_id', 'session', 'run', ...
        'auc', 'auc_window', ...
        'entered_range', 'entered_channel', 'entered_channel_name', ...
        'peak_value', 'peak_ind', 'peak_freq', ...
        'us_peak_value', 'us_peak_ind', 'us_peak_freq' ...
        );

fprintf (['\n Manual AUC analysis has been conducted successfully. Results have been saved. AUC-value is: ' num2str(auc, 4) ' in channel ' char(entered_channel_name) '. \n']);
