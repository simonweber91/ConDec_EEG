function pp_extract_frequency_bands(i_sub, p)

sub_str = ['sub-' num2str(i_sub, '%02i')];

load(fullfile(p.dirs.data, 'logs', sub_str, [sub_str '_task-condec_log.mat']));
% parallel_pool(p.par.n_workers);

for i_epoch = 1:numel(p.pp.epochs)

    % Get epoch info
    epoch_name = p.pp.epochs{i_epoch};
    switch epoch_name
        case 'stimulus', labels = log.targets;
        case 'response', labels = log.reports;
    end

    % Load data from both sessions and concatenate
    data = [];
    for i_ses = 1:p.data.n_sessions
    
        % Load epoch data
        filename = get_filename_pp(i_sub, i_ses, [epoch_name '.set']);
        epoch_file = dir(fullfile(p.dirs.data, 'eeg', sub_str, filename));
        EEG = pop_loadset('filename', epoch_file.name, 'filepath', epoch_file.folder);
        
        if i_ses == 1
            % Determine the number of missed trials during the practice
            % round (first 25 trials), which has to be considered when
            % removing the practice round.
            missing_practice_trials = 360-size(EEG.data,3)-sum(isnan(labels(1:360)));
            data = EEG.data(:, :, 25-missing_practice_trials:size(EEG.data, 3));
        elseif i_ses == 2
            data = cat(3, data, EEG.data);
        end
    end
    
    % Get some info
    freqs = p.tf.freqs;
    out_times = floor(EEG.pnts/2);
    n_trials = numel(labels);
    n_channels = EEG.nbchan;

    is_erp = any(strcmp(p.tf.bands, 'erp'));

    % Calculate ERPs
    if is_erp
        erp_freqs = p.tf.band_freqs{find(strcmp(p.tf.bands, 'erp'))};

        erps = eegfilt(data, EEG.srate, erp_freqs(1), erp_freqs(2));
        erps = reshape(erps, size(data));
        band_data.erp = nan(n_channels, EEG.pnts, n_trials);
        band_data.erp(:,:,~isnan(labels)) = erps;
        band_data.erp_times = EEG.times;
    end

    % Calculate remaining requency-bands from time-frequency decomposition
    if any(~strcmp(p.tf.bands, 'erp'))

        band_ind = find(~strcmp(p.tf.bands, 'erp'));
        n_bands = numel(band_ind);

        % Preallocate temporary output variables
        tfs = nan(numel(freqs), out_times, n_channels, n_trials);
        bands = nan(n_channels, out_times, n_trials, numel(band_ind));
    
        % Compute time-frequency decomposition for each trial and channel
        % individually
%         parfor i_tr = 1:n_trials
        for i_tr = 1:n_trials
    
            % Skip missing trials
            if isnan(labels(i_tr)), continue, end
            disp(['Trial: ', num2str(i_tr)])
            % Get correct data trial, accounting for missing trials
            data_ind = i_tr-sum(isnan(labels(1:i_tr)));
    
            for i_ch = 1:n_channels
                ersp = newtimef(data(i_ch,:,data_ind), EEG.pnts, [EEG.times(1) EEG.times(end)], EEG.srate, [3 0.8], 'freqs', freqs, 'ntimesout', out_times, 'nfreqs', numel(freqs));
                close;
                tfs(:,:,i_ch,i_tr) = ersp;
                % Extract frequencies
                for i_band = 1:n_bands
                    band_freqs = p.tf.band_freqs{band_ind(i_band)};
                    freq_range = find(freqs==band_freqs(1)):find(freqs==band_freqs(2));
                    bands(i_ch,:,i_tr,i_band) = mean(ersp(freq_range, :));
                end
            end
        end

        % Assign to output struct
        for i_band = 1:n_bands
            band_data.(p.tf.bands{band_ind(i_band)}) = bands(:,:,:,i_band);
        end
    
        % Get timepoints of time-frequency decomposition
        [~,~,~,times] = newtimef(data(1,:,1), EEG.pnts, [EEG.times(1) EEG.times(end)], EEG.srate, [3 0.8], 'freqs', freqs, 'ntimesout', out_times, 'nfreqs', numel(freqs)); close;
        band_data.band_times = times;
    end

    % Save frequency band data
    save(fullfile(epoch_file.folder, [sub_str '_task-condec_' epoch_name '_bands.mat']), 'band_data', '-v7.3')


    % Save time-frequency decompositions
    tf_data.data = tfs;
    tf_data.times = times;
    
    % Calcualate condition-wise averages (for potential plotting)
    tf_averages.all = mean(mean(tf_data.data,3),4);
    cohs = log.coherences;
    for i_coh = 1:numel(p.data.coherences)
        tf_averages.tfs.(p.data.coherences{i_coh}) = mean(mean(tfs(:,:,:,find(cohs == log.coh_list(i_coh))),3),4);
    end
    tf_averages.times = times;
    
    % Save averaged tfs, and optionally the full set of tf decompositions
    if p.tf.save_full_tf
        save(fullfile(epoch_file.folder, [sub_str '_task-condec_' epoch_name '_tf-data.mat']), 'tf_data', 'tf_averages', '-v7.3')
    else
        save(fullfile(epoch_file.folder, [sub_str '_task-condec_' epoch_name '_tf-data.mat']), 'tf_averages', '-v7.3')
    end

end
