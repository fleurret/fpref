function tempo_corr(savedir)

cm = [234,175,59;... % or87yw46
    188,188,188;... % wh26wh27
    201,55,55;... % or25rd67
    108,164,134;... % wh37gr58
    169,116,222]./255; % wh99pu92

f = figure;
f.Position = [0, 0, 600, 600];
ax = gca;
tiledlayout(2, 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

D = readtable(fullfile(savedir, 'female_phenotypes.csv'));
subjects = [D.Subject];

ax(1) = nexttile;
hold on

for i = 1:length(subjects)
    bird = D(i,:);
    scatter(ax(1), bird.JuvKDE, bird.MPTempo,...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

legend(ax(1), subjects,...
    'AutoUpdate', 'off');
legend('boxoff')

xf = D.JuvKDE;
yf = D.MPTempo;

if any(isnan(yf))
    r = ~isnan(yf);
    xf = xf(r);
    yf = yf(r);
end

coefficients1 = polyfit(xf, yf, 1);
xFit1 = linspace(min(xf), max(xf), 1000);
yFit1 = polyval(coefficients1, xFit1);

line(ax(1),xFit1,yFit1, ...
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

xlabel(ax(1), 'Juvenile KDE (calls/sec)')
title('Most preferred stimulus')

ax(2) = nexttile;
hold on

for i = 1:length(subjects)
    bird = D(i,:);
    scatter(ax(2), bird.AdultKDE, bird.MPTempo,...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

xf = D.AdultKDE;
yf = D.MPTempo;

if any(isnan(yf))
    r = ~isnan(yf);
    xf = xf(r);
    yf = yf(r);
end

coefficients2 = polyfit(xf, yf, 1);
xFit2 = linspace(min(xf), max(xf), 1000);
yFit2 = polyval(coefficients2, xFit2);

line(ax(2),xFit2,yFit2, ...
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

xlabel(ax(2), 'Adult KDE (calls/sec)')
title('Most preferred stimulus')

linkaxes(ax(1:2), 'xy')

ax(3) = nexttile;
hold on

for i = 1:length(subjects)
    bird = D(i,:);
    scatter(ax(3), bird.JuvKDE, bird.LPTempo,...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

xf = D.JuvKDE;
yf = D.LPTempo;

if any(isnan(yf))
    r = ~isnan(yf);
    xf = xf(r);
    yf = yf(r);
end

coefficients1 = polyfit(xf, yf, 1);
xFit1 = linspace(min(xf), max(xf), 1000);
yFit1 = polyval(coefficients1, xFit1);

line(ax(3),xFit1,yFit1, ...
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

xlabel(ax(3), 'Juvenile KDE (calls/sec)')
title('Least preferred stimulus')

ax(4) = nexttile;
hold on

for i = 1:length(subjects)
    bird = D(i,:);
    scatter(ax(4), bird.AdultKDE, bird.LPTempo,...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

xf = D.AdultKDE;
yf = D.LPTempo;

if any(isnan(yf))
    r = ~isnan(yf);
    xf = xf(r);
    yf = yf(r);
end

coefficients2 = polyfit(xf, yf, 1);
xFit2 = linspace(min(xf), max(xf), 1000);
yFit2 = polyval(coefficients2, xFit2);

line(ax(4),xFit2,yFit2, ...
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

xlabel(ax(4), 'Adult KDE (calls/sec)')
title('Least preferred stimulus')

linkaxes(ax(3:4), 'xy')

% axes etc
for i = 1:4
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