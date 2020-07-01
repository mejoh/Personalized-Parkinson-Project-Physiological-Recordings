function [auc] = js_extract_auc(data, cfg, conf)
% This function extracts the FWHM area under the curve (AUC) for the highest peak in a power spectrum.   
% 
%  Required variables are: 
%  - data: accelerometry data required for FFT
%  - cfg: particularly the fields: cfg.cfg_freq.foi, conf.auc
%  - conf: particularly the fields: conf.dir.auc, conf.sub.name,
%  conf.sub.ses, conf.sub.run
% 
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

%% Creating segmented data

cfg_fft = cfg.fft_auc{1};
segmenteddata = ft_redefinetrial(cfg_fft, data); %redefine data into segments    

%% FFT frequency analysis using Fieldtrip

cfg_fft = cfg.fft_auc{2};
FFT = ft_freqanalysis(cfg_fft,segmenteddata);


%% RANGE SELECTION
lower_index = find(round(cfg_fft.foi*10)/10 == conf.auc.filter(1));
upper_index = find(round(cfg_fft.foi*10)/10 == conf.auc.filter(2));
range = lower_index:upper_index;
freq_filter = conf.auc.filter;

%% SETTINGS
i = 0; %counter
channel_count = length(conf.auc.chan{1}); %count amount of channels
peaks = cell(channel_count,1); %specify size peaks
locs = cell(channel_count,1); %specify size locs

%% PEAK SELECTION
for x = conf.auc.chan{1};
    i = i+1;
    [peaks{i}, locs{i}] = findpeaks(FFT.powspctrm(x,range)); %find local maxima of one channel
    max_val(i) = max(peaks{i});  %select maximum per channel
end

max_val_all = max(max_val); %select overall maximum
[peak_channel, c] = find(FFT.powspctrm == max_val_all); %find channel and index (frequency) of peak 
peak_freq =  cfg_fft.foi(c); %frequency of peak
peak_channel_name = data.label(peak_channel); % name of that channel
peak_value = FFT.powspctrm(peak_channel, c); % value of the peak

%% Upsampling of channel with highest peak

us_factor = conf.auc.us_factor; %specify upsample factor here
us_powerspectrum = interp(FFT.powspctrm(peak_channel, :),us_factor); %actual upsampling
us_foi = interp(cfg_fft.foi,us_factor); %upsampling of foi

%creating upsampled range
us_lower_index = find(round(us_foi*100)/100 == conf.auc.filter(1)); 
us_upper_index = find(round(us_foi*100)/100 == conf.auc.filter(2));
us_range = us_lower_index:us_upper_index;

%finding new peak values
us_peak_value = max(findpeaks(us_powerspectrum(us_range))); 
us_peak_ind = find(us_powerspectrum == us_peak_value);
us_peak_freq = us_foi(us_peak_ind);
us_half_max = us_peak_value/2;

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
peak_freq_title = ['Peak frequency: ' num2str(peak_freq) 'Hz.'];
peak_value_title = ['Peak value: ' num2str(peak_value, 4)] ;
title({'AAC power spectrum.', peak_freq_title, peak_value_title});

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
peak_chan_title = ['Peak channel: ' char(peak_channel_name)] ;
us_peak_freq_title = ['Upsampled peak freq: ' num2str(us_peak_freq) 'Hz'];
us_peak_title = ['Upsampled peak:' num2str(us_peak_value, 4)];
title ({auc_title, peak_chan_title, us_peak_freq_title, us_peak_title})
suptitle(['Subject: ' char(subject_id)]);

%% Save
file_name_img = fullfile(conf.dir.auc,[subject_id '_' session '_' run '_plotAUC_' char(peak_channel_name) '.jpg']);
if ~exist(conf.dir.auc);mkdir(conf.dir.auc);end
set(gcf,'PaperPositionMode','auto')
saveas(fig, file_name_img);

file_name_data = fullfile(conf.dir.auc,[subject_id '_' session '_' run '_auc.mat']);
save(file_name_data, ...
        'subject_id', 'session', 'run', ...
        'auc', 'auc_window', 'freq_filter', ...
        'peak_channel', 'peak_channel_name', 'peak_freq', 'peak_value', 'peaks', 'locs', ...
         'us_peak_value', 'us_peak_ind', 'us_peak_freq', 'us_range' ...
        );

fprintf (['\n AUC analysis has been conducted successfully. Results have been saved. AUC-value is: ' num2str(auc, 4) ' in channel ' char(peak_channel_name) '. \n']);

