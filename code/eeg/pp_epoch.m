function pp_epoch(i_sub,p)

sub_str = ['sub-' num2str(i_sub, '%02i')];

disp(['Create epochs - ' sub_str]);

for i_ses = 1:p.data.n_sessions

    for i_epoch = 1:numel(p.pp.epochs)

        % Load preprocessed data
        filename = get_filename_pp(i_sub, i_ses, 'trials.set');
        trials_file = dir(fullfile(p.dirs.data, 'eeg', sub_str, filename));
        EEG = pop_loadset('filename', trials_file.name, 'filepath', trials_file.folder);

        % Get epoch info
        epoch_name = p.pp.epochs{i_epoch};
        epoch_timewindow = p.pp.epoch_timewindows{i_epoch};
        epoch_trigger = p.pp.epoch_trigger{i_epoch};

        % Add padding to timewindow
        epoch_timewindow = epoch_timewindow + p.pp.epoch_padding*[-1 1];

        % Create epochs
        EEG = pop_epoch(EEG, {epoch_trigger}, epoch_timewindow, 'epochinfo', 'yes');
    
        % Save file
        savefile = get_filename_pp(i_sub, i_ses, [epoch_name '.set']);
        EEG = pop_editset(EEG, 'setname', savefile);
        pop_saveset(EEG, 'filename', savefile, 'filepath', trials_file.folder);

    end
end