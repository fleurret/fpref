function tempo_corr(savedir, cmlist, cm)

f = figure;
f.Position = [0, 0, 1200, 600];
ax = gca;
tiledlayout(2, 4,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

D = readtable(fullfile(savedir, 'female_phenotypes.csv'));
subjects = [D.Subject];

vars = {'JuvKDE', 'AdultKDE', 'DadSongKDE', 'MomKDE'};

for j = 1:4
    xval = cell2mat(vars(j));
    ax(j) = nexttile;
    hold on
    
    for i = 1:length(subjects)
        bird = D(i,:);
        match = find(strcmp(subjects(i), cmlist));
        scatter(ax(j), bird.(xval), bird.MPTempo,...
            'Marker', 'o',...
            'MarkerFaceColor', cm(match,:),...
            'MarkerEdgeColor', 'none',...
            'MarkerFaceAlpha', 1,...
            'SizeData', 80)
    end
    
    legend(ax(j), subjects,...
        'AutoUpdate', 'off');
    legend('boxoff')
    
    xf = D.(xval);
    yf = D.MPTempo;
    
    if any(isnan(yf))
        r = ~isnan(yf);
        xf = xf(r);
        yf = yf(r);
    end
    
    coefficients = polyfit(xf, yf, 1);
    xFit = linspace(min(xf), max(xf), 1000);
    yFit = polyval(coefficients, xFit);
    
    line(ax(j),xFit,yFit, ...
        'Color', 'k', ...
        'LineWidth',3);
    [R,P] = corrcoef(xf,yf,'rows','complete');
    
    if length(R) > 1
        r = R(2);
        p = P(2);
        
        str = sprintf('R = %1.3f, p = %1.3f \n', r, p);
        T = text(max(xlim), min(ylim), str);
        set(findobj(T),...
            'FontSize', 9,...
            'FontName', 'Arial',...
            'HorizontalAlignment', 'right');
    end
    
    xlabel(ax(j), xval)
    title('Most preferred stimulus')
end

for j = 5:8
    xval = cell2mat(vars(j-4));
    ax(j) = nexttile;
    hold on
    
    for i = 1:length(subjects)
        bird = D(i,:);
        match = find(strcmp(subjects(i), cmlist));
        scatter(ax(j), bird.(xval), bird.LPTempo,...
            'Marker', 'o',...
            'MarkerFaceColor', cm(match,:),...
            'MarkerEdgeColor', 'none',...
            'MarkerFaceAlpha', 1,...
            'SizeData', 80)
    end

    xf = D.(xval);
    yf = D.LPTempo;
    
    if any(isnan(yf))
        r = ~isnan(yf);
        xf = xf(r);
        yf = yf(r);
    end
    
    coefficients = polyfit(xf, yf, 1);
    xFit = linspace(min(xf), max(xf), 1000);
    yFit = polyval(coefficients, xFit);
    
    line(ax(j),xFit,yFit, ...
        'Color', 'k', ...
        'LineWidth',3);
    [R,P] = corrcoef(xf,yf,'rows','complete');
    
    if length(R) > 1
        r = R(2);
        p = P(2);
        
        str = sprintf('R = %1.3f, p = %1.3f \n', r, p);
        T = text(max(xlim), min(ylim), str);
        set(findobj(T),...
            'FontSize', 9,...
            'FontName', 'Arial',...
            'HorizontalAlignment', 'right');
    end
    
    xlabel(ax(j), xval)
    title('Least preferred stimulus')
end

xlim(ax([3 7]), [6 8.5])
ylim(ax, ([3 15]))

linkaxes(ax([3 7]), 'xy')

% axes etc
for i = 1:8
    ylabel(ax(i), 'Preferred stim tempo (syls/sec)')
    
    set(ax(i), 'box', 'off',...
        'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
end

% save
fn = fullfile(savedir, 'group_tempo_corr.pdf');
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')