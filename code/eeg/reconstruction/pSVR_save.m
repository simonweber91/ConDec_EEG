function pSVR_save(results, predictions, i_sub, p, i_event, i_band, i_label, i_coh)

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
out_file = fullfile(out_dir, [filename '_' datestr(now,'yymmddHHMM') '.mat']);

% Save temporary predictions and analysis parameters
save(out_file, 'p', 'results', 'predictions', '-v7.3');

% Delete temp file if necessary
if exist(fullfile(p.dirs.data, 'psvr', sub_str, [filename '_temp.mat']),'file')
    delete(fullfile(p.dirs.data, 'psvr', sub_str, [filename '_temp.mat']));
end

fprintf('Results saved as %s\n', out_file);

