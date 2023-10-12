function [analysis_complete, predictions, results, first_perm] = pSVR_check_progress(i_sub, p, i_event, i_band, i_label, i_coh, n_tp)

% function [analysis_complete, predictions, results, first_perm, first_tr] = pSVR_check_progress_permute(sub_id, p)
%
% Checks whether a final result file or temporary result file for the
% current subject has already been created. If not, the analysis can start
% from the beginning. If a final result file exists, the current subject
% does not have to be analyzed again. If a temporary result file exists,
% this file is loaded and the analysis can be continued from where it
% stopped.
%
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output:
%   - analysis_complete: 1 if final result file exists, 0 otherwise.
%   - predictions: Temporary predictions structure which is loaded from a
%       temporary result file if it exists.
%   - predictions: Temporary results structure which is loaded from a
%       temporary result file if it exists.
%   - first_perm: Permutation with which to continue the analysis.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Initialize output variable
analysis_complete = 0;

% Get filename of final result file
filename = get_filename_psvr(i_sub, p, i_event, i_band, i_label, i_coh);

% Check if final result file exists
sub_str = ['sub-' num2str(i_sub, '%02i')];
result_file = dir(fullfile(p.dirs.data, 'psvr', sub_str, [filename '_2*.mat']));

% If it exists (and no overwrite is requested) set 'analysis_complete' to 1
% so that this subject is skipped.
if ~isempty(result_file)
    if p.OVERWRITE == 1
        warning('Overwriting existing file. If this is a mistake, abort now!');
        warning('File: %s', result_file.name);
        fprintf('Delete file in %s', num2str(5))
        for i = 5:-1:0
            pause(1)
            fprintf('\b%s', num2str(i))
        end
        fprintf('\n')
        delete(fullfile(result_file.folder, result_file.name))
    else
        analysis_complete = 1;
        predictions = []; results = []; first_perm = [];
        return
    end
end

% Check if temporary result file exists
temp_file = dir(fullfile(p.dirs.data, 'psvr', sub_str, [filename '_temp.mat']));

if isempty(temp_file)

    % If the current subject has not been anylsed yet, initialize result
    % structures
    if p.psvr.save_predictions
        predictions.sin_pred = cell(p.psvr.n_perm, n_tp);
        predictions.cos_pred = cell(p.psvr.n_perm, n_tp);
        predictions.ang_pred = cell(p.psvr.n_perm, n_tp);
    else
        predictions = [];
    end
    results.bfca = zeros(p.psvr.n_perm, n_tp);
    first_perm = 1;

else
    
    % If temporary result file exists, load that file and set analysis
    % parameters accordingly. Otherwise start analysis from the beginning.
    load([filename '_permute_temp.mat'], 'results', 'predictions', 'i_perm');
    first_perm = i_perm + 1;
   
end
