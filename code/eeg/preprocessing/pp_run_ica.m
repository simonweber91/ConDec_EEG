function pp_run_ica(i_sub, p)

sub_str = ['sub-' num2str(i_sub, '%02i')];

disp(['ICA - ' sub_str]);

for i_ses = 1:p.data.n_sessions

    % Load preprocessed data
    filename = get_filename_pp(i_sub, i_ses, 'pre-ica.set');
    pp_file = dir(fullfile(p.dirs.data, 'eeg', sub_str, filename));
    EEG = pop_loadset('filename', pp_file.name, 'filepath', pp_file.folder);

    % Apply pre-ICA highpass filter
    ICA = pop_basicfilter(EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  p.pp.ica_highpass, 'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' );

    % Run ICA
    ICA = pop_runica(ICA, 'extended', 1, 'interrupt', 'off');

    % Copy ICA weights to unfiltered data structure
    EEG.icawinv = ICA.icawinv;
    EEG.icasphere = ICA.icasphere;
    EEG.icaweights = ICA.icaweights;
    EEG.icachansind = ICA.icachansind;

    % Save file
    savefile = get_filename_pp(i_sub, i_ses, 'ica.set');
    EEG = pop_editset(EEG, 'setname', savefile);
    pop_saveset(EEG, 'filename', savefile, 'filepath', pp_file.folder);

end