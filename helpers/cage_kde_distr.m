d = readtable('Y:\Brainard\Analysis\Female preference\female_cage_phenotypes.csv');

cages = unique(d.Cage);

f = figure;
f.Position = [0, 0, 800, 800];
tiledlayout(round(length(cages)/2), 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

for i = 1:length(cages)
    ax(i) = nexttile;
    set(ax(i), 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    hold on
    
    cage = d(d.Cage == cages(i),:);
    [f1, x1] = ksdensity(cage.JuvKDE);
    plot(ax(i), x1, f1,...
        'Color', [189,191,245]./255,...
        'LineWidth', 1.5)
    
    if sum(~isnan(cage.AdultKDE)) > 0
        [f2, x2] = ksdensity(cage.AdultKDE);
        plot(ax(i), x2, f2,...
            'Color', [39,43,126]./255,...
            'LineWidth', 1.5)
    end
   
    title(append('Cage ', num2str(cages(i))))
    set(ax(i) ,'Layer', 'Top')
end

legend(ax(i),...
    'Juvenile', 'Adult')
legend(ax(i), 'boxoff')