function EEG = trimEEG(EEG)

    % This function was provided by Charlie
    
    run_start = 'R 50'; 
    run_end = 'R 90';
    
    starts = find(strcmp(run_start, {EEG.event.type}));
    
    if strcmpi('Original file: s414_Sess1.eeg', EEG.comments)
        starts = starts(1:end - 1);
    end
    
    ends = find(strcmp(run_end, {EEG.event.type}));
    disp(length(starts));
    disp(length(ends));
    assert(length(starts) == length(ends), 'Trigger counts inconsistent');
    
    runs = length(starts);
    
    if runs == 0
        return
    end
    
    reject = zeros(runs + 1, 2); % defining points before, between and after runs, so n. spaces = runs + 1;
    reject(1, 1) = 1;
    reject(end, 2) = length(EEG.times); % first point, last point of data
    
    onesec = EEG.srate; % number of index points in EEG.times to move one second 
    
    for r = 1:runs
        idx_start = floor((EEG.event(starts(r)).latency)); % start of run
        idx_end = floor((EEG.event(ends(r)).latency)); % end of run
        reject(r, 2) = idx_start - onesec;
        reject(r + 1, 1) = idx_end + (7 * onesec); % increased to avoid boundary events being present in version 2 of script where response length is variable
    end

    EEG = eeg_eegrej(EEG, reject);
    
end