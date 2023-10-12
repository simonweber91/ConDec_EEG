function [data, labels_psvr, labels_rad, missing] = pSVR_prepare_data(band_data, log, p, i_sub, i_event, i_band, i_label, i_coh)

% Get indices for current coherence level
coh_ind = find(log.coherences == log.coh_list(i_coh));

% Get labels
labels = log.(p.psvr.labels{i_label});
labels = labels(coh_ind);
[labels_psvr, labels_rad, missing_labels] = pSVR_prepare_labels(labels);

% Get data
data = band_data.(p.psvr.bands{i_band});
data = data(:,:,coh_ind);

% Get timepoints
if strcmp(p.psvr.bands{i_band}, 'erp')
    times = band_data.erp_times;
else
    times = band_data.band_times;
end

% Remove padding from timepoints and data
timewindow = p.pp.epoch_timewindows{i_event}*1000;
time_start = find(times-timewindow(1) == min(abs(times-timewindow(1))), 1, 'first');
time_stop = find(times-timewindow(2) == min(abs(times-timewindow(2))), 1, 'first');

times = times(time_start:time_stop);
data = data(:,time_start:time_stop,:);

% Downscale to 50 Hz
downscale = 50;
time_length = range(timewindow)/1000;
step = round(numel(times)/(time_length*downscale),1);
downscale_ind = floor([1:step:numel(times)]);

times = times(downscale_ind);
data = data(:,downscale_ind,:);

% Based on the electrode layout information in Charlie's scripts
% reorder electrodes according to layout of cap 2
if p.info.cap(i_sub) == 2
    tmp_data = data;
    data([31,61,63,64],:,:) = tmp_data([32,62,64,31],:,:);
end
% exclude EOGv/l, AFz
data([31,32,62],:,:,:) = [];

% Adjust the format of the data for TDT
data = permute(data, [3, 1, 2]);

% Remove missing trials
missing_data = isnan(squeeze(data(:,1,1)));
missing = missing_data+missing_labels > 0;
data(missing,:,:) = [];
labels_psvr(missing) = [];
labels_rad(missing) = [];

% Rescale data of each timepoint to increase estimation speed
for tp = 1:size(data,3)
    data(:,:,tp) = rescale(data(:,:,tp));
end
