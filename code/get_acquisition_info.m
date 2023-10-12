function p = get_acquisition_info(p)


p.info = readtable(fullfile(p.dirs.data, 'acquisition_notes.xlsx'));
p.info(1,:) = [];
p.info = p.info(:,[2, 9, 10]);
p.info = renamevars(p.info, ["Var9", "Cap_1_Normal_2_58Replacement_"], ["bad_channels", "cap"]);

valid_subects = [1:7, 9:12, 19:35];

p.info = p.info(valid_subects, :);
