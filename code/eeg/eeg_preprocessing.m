function eeg_preprocessing(p)

eeglab; close;

% Basic Preprocessing and ICA
% parallel_pool(p.par.n_workers);
% parfor i_sub = p.subjects
for i_sub = p.subjects
    pp_basic(i_sub, p);
    pp_run_ica(i_sub, p);
end

% Manual removal of ICA components
% global EEG  <-- uncomment if you manually call the script from here
for i_sub = p.subjects
    pp_reject_ica_components(i_sub, p);
end

for i_sub = p.subjects
    pp_extract_trial(i_sub, p);
    pp_epoch(i_sub, p);
    pp_extract_frequency_bands(i_sub, p);
end