function eeg_statistics(p)

for i_event = 1:numel(p.psvr.event)
    for i_band = 1:numel(p.psvr.bands)
        for i_label = 1:numel(p.psvr.labels)
            for i_coh = 1:numel(p.data.coherences)

                bfca = load_bfca(p, i_event, i_band, i_label, i_coh);
                bfca = bfca - 50;
                bfca = permute(moving_average(permute(bfca, [2 1 3]), 3), [2 1 3]);
                
                tmass_stats = cluster_t_mass(bfca, 'right');

                out_name = ['psvr_' p.psvr.event{i_event} '_' p.psvr.bands{i_band} '_' p.psvr.labels{i_label} '_' p.data.coherences{i_coh} '_' num2str(p.psvr.n_perm) 'perm_stats.mat'];
                out_dir = fullfile(p.dirs.data, 'results', 'psvr');
                if ~exist(out_dir,'dir'), mkdir(out_dir); end
                save(fullfile(out_dir, out_name), 'tmass_stats')
            end
        end
    end
end