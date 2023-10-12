function behavior_analysis(p)

for i_coh = 1:numel(p.data.coherences)

    targets = []; reports = []; rts = []; bfca = []; angdev = []; mid_coherence = [];

    for i_sub = 1:numel(p.subjects)
    
        sub_id = p.subjects(i_sub);
    
        % Load logfile
        sub_str = ['sub-' num2str(sub_id, '%02i')];
        load(fullfile(p.dirs.data, 'logs', sub_str, [sub_str '_task-condec_log.mat']), 'log');
    
        % Get indices for current coherence level
        coh_ind = find(log.coherences == log.coh_list(i_coh));

        t = log.targets(coh_ind)';
        r = log.reports(coh_ind)';

        targets(:,i_sub) = t;
        reports(:,i_sub) = r;
        rts(:,i_sub) = log.rts(coh_ind)';

        % Caluclate angular deviation
        ad = r - t;
        ad(ad < -180) = ad(ad < -180) + 360; ad(ad > 180) = ad(ad > 180) - 360;
        ang_dev(:,i_sub) = ad;

        % Calculate BFCA
        t(find(isnan(r))) = NaN;
        bfca(i_sub,1) = bal_norm_circ_resp_dev(deg2rad(r), deg2rad(t),'trapz');

        if strcmp(p.data.coherences{i_coh}, 'mid')
            mid_coherence(i_sub,1) = log.coh_list(i_coh);
        end
    end

    out_dir = fullfile(p.dirs.data, 'results', 'behavior');
    if ~exist(out_dir, 'dir'), mkdir(out_dir), end
    out_name = ['behavior_' p.data.coherences{i_coh} '.mat'];
    save(fullfile(out_dir, out_name), 'targets', 'reports', 'rts', 'ang_dev', 'bfca')

    if strcmp(p.data.coherences{i_coh}, 'mid')
        save(fullfile(out_dir, ['mid_coherence.mat']), 'mid_coherence')
    end

end