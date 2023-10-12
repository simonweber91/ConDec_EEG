function setup_directories(p)

% Create all directories that are necessary for the following analyses.
% This is where data/results are stored.

base_dir = p.dirs.base;
if ~exist(base_dir,'dir')
    mkdir(base_dir)
end

data_dir = fullfile(p.dirs.base, 'data');
if ~exist(data_dir,'dir')
    mkdir(data_dir)
end
eeg_dir = fullfile(data_dir, 'eeg');
if ~exist(eeg_dir,'dir')
    mkdir(eeg_dir)
end

