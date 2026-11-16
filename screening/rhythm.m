function rhythm(birdname, sex)

if isfile(fullfile(cd, 'output.mat'))
    load(fullfile(cd, 'output.mat'))
else
    warning('no output.mat file found')
end

switch sex
    case 'female'
        type = {'callmotifdurs'};
    case 'male'
        type = {'callmotifdurs', 'songmotfdurs'};
end

ioi = output.songmotifdurs;
r = [];

for j = 1:length(ioi)-1
    i1 = ioi(j);
    i2 = ioi(j+1);
    r(j) = i1/(i1+i2);
end

% plot hist
F = figure;
F.Position = [0, 0, 500, 300];
ax = gca;
hold on
cm = [69,129,92]./255;

[c d] = ksdensity(r,'Bandwidth',50);
[~,idx] = max(c);
d = d/1000;

set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 1.5);
set(findobj(ax,'-property','FontName'),...
    'FontSize', 9,...
    'FontName','Arial')
plot(d, (c./max(c))*max(histcounts(r, 50)),...
    'LineWidth', 1.5,...
    'Color','k');
histogram(r, 50,...
    'FaceColor', cm,...
    'EdgeColor', 'none')
xline(d(idx),...
    'LineStyle', '--')

title(birdname)
xlim([0 1])
xlabel(ax, 'ICI (s)',...
    'FontWeight', 'bold')
ylabel(ax,'Frequency',...
    'FontWeight', 'bold')
set(ax,'Layer', 'Top')