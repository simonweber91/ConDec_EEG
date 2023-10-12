function pp_reject_ica_components(i_sub, p)

sub_str = ['sub-' num2str(i_sub, '%02i')];

disp(['Reject ICA components - ' sub_str]);

% The EEG variable must be global in this function and the outermost
% invokung function (e.g. analysis_pipeline.m) to allow for a successful
% rejection of ICA components.
global EEG

for i_ses = 1:p.data.n_sessions

    % Load preprocessed data
    filename = get_filename_pp(i_sub, i_ses, 'ica.set');
    ica_file = dir(fullfile(p.dirs.data, 'eeg', sub_str, filename));
    EEG = pop_loadset('filename', ica_file.name, 'filepath', ica_file.folder);

    % Display first 35 components
    EEG = iclabel(EEG);
    pop_selectcomps(EEG, [1:10]); %[1:35]

    % Wait for manual selection
    uiwait(msgbox('Click OK after selecting components for removal.'));

    % Remove selected components
    reject = find(EEG.reject.gcompreject);
    disp(reject)
    pause(2)
    EEG = pop_subcomp(EEG, reject);

    % Save file
    savefile = get_filename_pp(i_sub, i_ses, 'post-ica.set');
    EEG = pop_editset(EEG, 'setname', savefile);
    pop_saveset(EEG, 'filename', savefile, 'filepath', ica_file.folder);
   
end
    
