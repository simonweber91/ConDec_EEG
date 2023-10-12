function behavior_plot_angular_deviation(p)

colors = {[237 177 32]./255, [217 83 25]./255, [0 114 189]./255};

figure;
for i_coh = 1:numel(p.data.coherences)

    subplot(1,numel(p.data.coherences),i_coh); hold on;

    filename = fullfile(p.dirs.data, 'results', 'behavior', ['behavior_' p.data.coherences{i_coh} '.mat']);
    load(filename, 'ang_dev')

    hc = histcounts(ang_dev,36)./numel(ang_dev);
    b = bar(hc,'FaceColor',colors{i_coh},'EdgeColor',[0.2 0.2 0.2], 'FaceAlpha', 0.6);
    b.BarWidth = 1;
    
    ax = gca;
    
    ax.XTick = [0.5 18.5 36.5];
    ax.XLim = [0.5 36.5];
    ax.XTickLabel = {'-180' '0' '180'};
    ax.YTick = [0 0.1 0.2 0.3];
    ax.YLim = [0 0.35];
    
    if i_coh == 1, ax.YLabel.String = 'Proportion of responses'; end
    if i_coh == 2, ax.XLabel.String = 'Response deviation from stimulus [°]'; end
    
    ax.Title.String = [p.data.coherences{i_coh} ' coherence'];
    
    box off
    
end
