function pp_extact_trial(i_sub,p)

% List of triggers
% stimulus: 'R100'
% response: 'R200'
% button_press: 'R210'
% catch_response: 'R220'
% no_response: 'R230'
% end_of_trial: 'R 70';

sub_str = ['sub-' num2str(i_sub, '%02i')];

disp(['Extract trials - ' sub_str]);

for i_ses = 1:p.data.n_sessions

    % Load preprocessed data
    filename = get_filename_pp(i_sub, i_ses, 'post-ica.set');
    post_ica_file = dir(fullfile(p.dirs.data, 'eeg', sub_str, filename));
    EEG = pop_loadset('filename', post_ica_file.name, 'filepath', post_ica_file.folder);
    
    % Remove boundry events to avoid discontinuity errors
    boundary_events = [];
    for i = 1:numel(EEG.event)
        if strcmp(EEG.event(i).type, 'boundary')
            boundary_events = [boundary_events, i];
        end
    end   
    EEG = pop_editeventvals(EEG, 'delete', boundary_events);
    
    % Extend data with 10 seconds (using the mean of the previous 100
    % samples) to avoid discontinuity errors in last trial
    for i = 1:EEG.srate*10
        EEG.data(:,end+1) = mean(EEG.data(:,end-100:end),2);
        EEG.times(end+1) = EEG.times(end)+(1000/EEG.srate);
    end
    EEG.pnts = numel(EEG.times);
    EEG.xmax = EEG.times(end)/1000;

    % Extract trials
    EEG = pop_epoch(EEG, {'R100'}, p.pp.trial_timewindow, 'epochinfo', 'yes');
    
    % Remove unwanted events ...
    % ... before the stimulus
    pre_trial_events = [];
    for i = 1:numel(EEG.epoch)
        latency = [EEG.epoch(i).eventlatency{:}];
        pre_trial = EEG.epoch(i).event(find(latency<0));
        pre_trial_events = [pre_trial_events, pre_trial];
    end   
    EEG = pop_editeventvals(EEG, 'delete', pre_trial_events);

    % ... after end of trial
    post_trial_events = [];
    for i = 1:numel(EEG.epoch)
        trial_end = find(strcmp(EEG.epoch(i).eventtype, 'R 70'), 1, 'first');
        if trial_end < numel(EEG.epoch(i).event)
            post_trial = EEG.epoch(i).event(trial_end+1):EEG.epoch(i).event(end);
        else
            post_trial = [];
        end
        post_trial_events = [post_trial_events, post_trial];
    end
    EEG = pop_editeventvals(EEG,'delete',post_trial_events);
    
    % Basline correction
    EEG = pop_rmbase(EEG, p.pp.trial_baseline);

    % Save file
    savefile = get_filename_pp(i_sub, i_ses, 'trials.set');
    EEG = pop_editset(EEG, 'setname', savefile);
    pop_saveset(EEG, 'filename', savefile, 'filepath', post_ica_file.folder);
    
end