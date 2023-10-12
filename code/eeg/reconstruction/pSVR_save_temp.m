function pSVR_save_temp(results, predictions, i_sub, p, i_event, i_band, i_label, i_coh, i_perm)

% function pSVR_save_temp(sub_id, p, predictions, results, suffix)
%
% Save temporary result file during ongoing analysis. Variables include:
%   - sub_id: ID of the current subject.
%   - p: Structure with analysis parameters.
%   - predictions: Structure with predictions.
%   - results: Structure with reconstruction results.
%   - suffix: Suffix to append to the filename.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Get filename
filename = get_filename_psvr(i_sub, p, i_event, i_band, i_label, i_coh);

% Append 'temp' to filename
sub_str = ['sub-' num2str(i_sub, '%02i')];
out_dir = fullfile(p.dirs.data, 'psvr', sub_str);
if ~exist(out_dir,'dir'), mkdir(out_dir), end
out_file = fullfile(out_dir, [filename '_temp.mat']);

% Save temporary predictions and analysis parameters
save(out_file, 'p', 'results', 'predictions', 'i_perm', '-v7.3');

