function behavior_plot_histogram(p)

colors = {[237 177 32]./255, [217 83 25]./255, [0 114 189]./255};

figure;
for i_coh = 1:numel(p.data.coherences)

    subplot(2,numel(p.data.coherences),i_coh); hold on;

    filename = fullfile(p.dirs.data, 'results', 'behavior', ['behavior_' p.data.coherences{i_coh} '.mat']);
    load(filename, 'targets', 'reports')
    
    hi = histogram(targets(:),37,'FaceColor',colors{i_coh},'EdgeColor',[0.2 0.2 0.2]);
    ax = gca;
    ax.XTick = [0 180 360];
    ax.XLim = [0 360];
    ax.YTick = [0 100 200 300];
    ax.YLim = [0 320];
    
    if i_coh == 1, ax.YLabel.String = 'Stimulus Distribution'; end
    
    ax.Title.String = [p.data.coherences{i_coh} ' coherence'];

    axis square
    box off
    
    subplot(2,numel(p.data.coherences),i_coh+numel(p.data.coherences)); hold on;
    
    hi = histogram(reports(:),37,'FaceColor',colors{i_coh},'EdgeColor',[0.2 0.2 0.2]);
    ax = gca;
    ax.XTick = [0 180 360];
    ax.XLim = [0 360];
    ax.YTick = [0 100 200 300];
    ax.YLim = [0 320];
    
    if i_coh == 1, ax.YLabel.String = 'Response Distribution'; end
    
    if i_coh == 2, ax.XLabel.String = 'Direction'; end
    ax.XTick = [0 180 360];
    
    axis square
    box off
    
end
