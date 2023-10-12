% Hi there!
%
% This is the complete pipeline to recreate the analysis and plots in
% "XXXXXXXXX" by Weber, XXXXXXXXX. To create the figures from the
% paper, just complete a few file paths below (look for '...') and then hit
% run (ignore the warning messages). If you have the original data (which
% can be made available upon reasonable request), you can also recreate the
% entire analysis. This might take very (very!) long, so computing clusters
% and parallelisation are key (look for the out-commented 'parfor' and
% 'parallel_pool' lines in the various functions).
%
% In this file, a bunch of analysis parameters are specified and stored in
% a structure 'p' (for 'parameters'), which is passed to all other
% functions along the way. The parameters used for the published analysis
% are the ones you see below. All subsequent functions are commented
% fairly thoroughly, so I hope everything becomes clear with minimal (or at
% least medium) effort. In case it doesn't, or you have questions, feel
% free to email me at sweber@bccn-berlin.de.
%
% There are a few external tools and toolboxes that are required to run the
% analysis. These are listed below, including their respective download
% links. Make sure that you all resources are available on your system and
% added to the Matlab search path.
%
% Cheers!
%
% Simon Weber, sweber@bccn-berlin.de, 2023


%%% Add analysis scripts and required toolboxes to the search path %%%

% Analysis scripts
addpath(genpath('/analysis/sweber/projects/public/Condec_EEG/ConDec_EEG/code/'));

% Toolboxes
% 1. EEGLab
% https://eeglab.org/others/How_to_download_EEGLAB.html
addpath('/analysis/sweber/toolboxes/eeglab2021.1/');
% 2. The Decoding Toolbox (TDT), version 3.999E or higher
% https://sites.google.com/site/tdtdecodingtoolbox/
addpath(genpath('/analysis/sweber/toolboxes/tdt_3.999F'));


%%% Shuffle randomization seed for permutation analysis %%%

rng('shuffle')


%%% Create structure with key analysis parameters %%%

% Basic paramters
p.OVERWRITE             = 0;                                                % Do you want to overwrite already existing result files? Really???
p.dirs.base              = '/analysis/sweber/projects/public/Condec_EEG/ConDec_EEG';                                         % Base directory of the project, where all the stuff is stored.
p.dirs.data              =  '/analysis/sweber/projects/public/Condec_EEG/condec_data'; %fullfile(p.dirs.base, 'data');

% Number of sessions/runs-per-session/trials-per-run of the experiment
p.data.n_sessions       = 2; 
p.data.n_runs           = 15;
p.data.n_trials 	    = 16;
p.data.n_channels 	    = 64;
p.data.coherences       = {'zero', 'mid', 'full'};

% Subject IDs
p.subjects              = 4; %1:28;                              % Subject IDs (i.e. number for the subject-specific BIDS directory)

% EEG acquisition details
p                       = get_acquisition_info(p);

% EEG preprocessing parameters
p.pp.chanlocs           = '/analysis/sweber/toolboxes/eeglab2021.1/plugins/dipfit/standard_BESA/standard-10-5-cap385.elp';
p.pp.bandpass_filter    = [0.1 80];
p.pp.notch_filter       = 50;
p.pp.resample_freq      = 250;
p.pp.ica_highpass       = 1;
p.pp.trial_timewindow   = [-1.5 12];
p.pp.trial_baseline     = [-500 0];
p.pp.epochs             = {'stimulus', 'response'};
p.pp.epoch_timewindows  = {[-0.5 2], [-2 2]};
p.pp.epoch_padding      = 0.5;
p.pp.epoch_trigger      = {'R100', 'R210'};

p.tf.freqs              = [5:100];
p.tf.bands              = {'erp', 'alpha', 'beta', 'gammalow', 'gammahigh'};
p.tf.band_freqs         = {[0 6], [8 12], [15 30], [30 60], [60 100]};
p.tf.save_full_tf       = false;

p.psvr.event            = {'stimulus', 'response'}; % Should be the same names as in p.pp.epochs
p.psvr.bands            = {'erp', 'alpha', 'beta', 'gammalow', 'gammahigh'};
p.psvr.labels           = {'targets', 'reports'};
p.psvr.save_predictions = false;                % This regards the raw pSVR predictions, creates huge files
p.psvr.n_perm           = 10; %1000;

% p.par.n_workers         = 22;                                             % Number of parallel workers 

behavior_analysis(p);
behavior_plot(p);

% Run preprocessing of EEG data
global EEG % The EEG variable must be global to allow for ICA component rejection within pp_reject_ica_components.m
eeg_preprocessing(p);
clear global

eeg_reconstruction(p);
eeg_statistics(p);


