function eeg_reconstruction(p)

for i_sub = p.subjects

%     parallel_pool(p.par.n_workers, 'restart', 'rng_shuffle');

    % Load logfile
    sub_str = ['sub-' num2str(i_sub, '%02i')];
    load(fullfile(p.dirs.data, 'logs', sub_str, [sub_str '_task-condec_log.mat']), 'log');

    for i_event = 2%1:numel(p.psvr.event)

        % Load data
        event_name = p.psvr.event{i_event};
        load(fullfile(p.dirs.data, 'eeg', sub_str, [sub_str '_task-condec_' event_name '_bands.mat']), 'band_data');

        for i_band = 1:numel(p.psvr.bands)
            for i_label = 1%:numel(p.psvr.labels)
                for i_coh = 1:numel(p.data.coherences)

                    % Prepare data for reconstruction
                    [data, labels_psvr, labels_rad, missing] = pSVR_prepare_data(band_data, log, p, i_sub, i_event, i_band, i_label, i_coh);
                    n_tp = size(data,3);

                    % Check progress of analysis, skip if result file
                    % already exists
                    [analysis_complete, predictions, results, first_perm] = pSVR_check_progress(i_sub, p, i_event, i_band, i_label, i_coh, n_tp);
                    if analysis_complete == 1
                        warning('Result file already exists, continue', sub_id);
                        continue;
                    end

                    for i_perm = first_perm:p.psvr.n_perm+1

                        % Create permutations
                        if i_perm ~= 1
                            % Permute labels
                            perm_ind = randperm(numel(labels_psvr));
                        else
                            perm_ind = 1:numel(labels_psvr);
                        end
                        labels_psvr_perm = labels_psvr(perm_ind);
                        labels_rad_perm = labels_rad(perm_ind);

                        sin_pred = cell(1, n_tp); cos_pred = cell(1, n_tp); ang_pred = cell(1, n_tp); bfca = zeros(1, n_tp);

%                         for i_tp = 1:n_tp
                        parfor i_tp = 1:n_tp
                
                            fprintf('Analysing: subject %d/%d - permutation %d/%d - Timepoint %d/%d ... \n', i_sub, numel(p.subjects), i_perm, p.psvr.n_perm, i_tp, n_tp)
                            
                            % Run pSVR
                            [sin_pred{i_tp}, cos_pred{i_tp}, ang_pred{i_tp}] = pSVR_predict(data(:,:,i_tp), labels_psvr, missing, p);
                
                            bfca(i_tp) = bal_norm_circ_resp_dev(ang_pred{i_tp}, labels_rad_perm, 'trapz') .* 100;
                
                        end
                        % Assign predictions
                        if p.psvr.save_predictions
                            predictions.sin_pred(i_perm, :) = sin_pred;
                            predictions.cos_pred(i_perm, :) = cos_pred;
                            predictions.ang_pred(i_perm, :) = ang_pred;
                        end
                        % Calculate balanced feature-continuous accuracy
                        results.bfca(i_perm, :) = bfca;

                        % Save temporary file every 100 iterations
                        if mod(i_perm, 100) == 0
                            pSVR_save_temp(results, predictions, i_sub, p, i_event, i_band, i_label, i_coh, i_perm);
                        end

                    end

                    % Save results
                    pSVR_save(results, predictions, i_sub, p, i_event, i_band, i_label, i_coh);

                end
            end
        end
    end
end