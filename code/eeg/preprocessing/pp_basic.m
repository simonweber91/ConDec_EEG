function pp_basic(i_sub, p)

sub_str = ['sub-' num2str(i_sub, '%02i')];

disp(['Preprocessing - ' sub_str]);

for i_ses = 1:p.data.n_sessions

    % Load file from header
    filename = get_filename_pp(i_sub, i_ses, 'eeg.vhdr');
    vhdr_file = dir(fullfile(p.dirs.data, 'eeg', sub_str, filename));
    EEG = pop_loadbv(vhdr_file.folder, vhdr_file.name);

    % Add channel locations
    EEG = pop_chanedit(EEG, 'lookup', p.pp.chanlocs);

    % Bandpass and notch filter
    EEG = pop_basicfilter(EEG, 1:EEG.nbchan, 'Boundary', 'boundary', 'Cutoff', p.pp.bandpass_filter, 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2, 'RemoveDC', 'on');
    EEG  = pop_basicfilter(EEG,  1:EEG.nbchan, 'Boundary', 'boundary', 'Cutoff',  p.pp.notch_filter, 'Design', 'notch', 'Filter', 'PMnotch', 'Order', 180);

    % Downsample
    EEG = pop_resample(EEG, p.pp.resample_freq);

    % Trim EEG
    EEG = trimEEG(EEG);

    % Channel Rejection
    bad_channels = p.info.bad_channels(i_sub);
    chan_interp = channel_index_from_name(EEG, bad_channels);
    EEG = pop_interp(EEG, chan_interp, 'spherical');

    % Whole-head refernecing
    EEG.data(end + 1, :) = zeros(1, EEG.pnts);
    EEG = pop_reref(EEG, []);
    EEG = pop_select(EEG, 'nochannel', EEG.nbchan); 

    % Save file
    savefile = get_filename_pp(i_sub, i_ses, 'pre-ica.set');
    EEG = pop_editset(EEG, 'setname', savefile);
    pop_saveset(EEG, 'filename', savefile, 'filepath', vhdr_file.folder);

end