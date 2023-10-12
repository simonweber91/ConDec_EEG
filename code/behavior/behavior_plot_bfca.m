function behavior_plot_bfca(p)

colors = {[237 177 32]./255, [217 83 25]./255, [0 114 189]./255};

for i_coh = 1:numel(p.data.coherences)

    filename = fullfile(p.dirs.data, 'results', 'behavior', ['behavior_' p.data.coherences{i_coh} '.mat']);
    load(filename, 'bfca')
    bfca_all(:,i_coh) = bfca;

end
bfca_all = (bfca_all - 0.5) .* 100;

figure; hold on;

bx = boxchart(bfca_all);
bx.MarkerStyle = '.';
bx.BoxFaceAlpha = 0;

% Plot chance level
yline(0, '--' , 'Color', [0.5 0.5 0.5]);

ax = gca;
ax.YLim = [-5 55];
ax.YTick = 0:10:50;
ax.YLabel.String = 'BFCA above chance [%]';
ax.XTickLabel = p.data.coherences;
ax.XLabel.String = 'Coherence level';

box off
