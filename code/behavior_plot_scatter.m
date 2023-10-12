function behavior_plot_scatter(p)

colors = {[237 177 32]./255, [217 83 25]./255, [0 114 189]./255};

figure;
for i_coh = 1:numel(p.data.coherences)

    subplot(1,numel(p.data.coherences),i_coh); hold on;

    filename = fullfile(p.dirs.data, 'results', 'behavior', ['behavior_' p.data.coherences{i_coh} '.mat']);
    load(filename, 'targets', 'reports')
    
    s = scatter(targets(:), reports(:), 10, colors{i_coh}, '.');
    line([0 360], [0 360], 'Color', [0.2 0.2 0.2], 'LineStyle', '--', 'LineWidth', 1.5)
   
    ax = gca;
    
    if i_coh == 2, ax.XLabel.String = 'Stimulus Direction [°]'; end
    ax.XTick = [0 180 360];
    ax.XLim = [0 360];
    
    if i_coh == 1, ax.YLabel.String = 'Response Direction [°]'; end
    ax.YTick = [0 180 360];
    ax.YLim = [0 360];
    
    ax.Title.String = [p.data.coherences{i_coh} ' coherence'];
    
    axis square
    box off

end