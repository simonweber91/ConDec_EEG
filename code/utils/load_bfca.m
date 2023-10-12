function bfca = load_bfca(p, i_event, i_band, i_label, i_coh)

for i_sub = 1:numel(p.subjects)

    sub_id = p.subjects(i_sub);

    sub_str = ['sub-' num2str(sub_id, '%02i')];
    filename = get_filename_psvr(sub_id, p, i_event, i_band, i_label, i_coh);
    result_file = dir(fullfile(p.dirs.data, 'psvr', sub_str, [filename '_2*.mat']));
    load(fullfile(result_file.folder, result_file.name), 'results');

    bfca(i_sub,:,:) = permute(results.bfca,[3 2 1]);

end