function phenotype_by_day(filedir, savedir, birdname, age)

f = uigetdir(filedir);
cd(f)

% WhispSegScreenDir(f, birdname, 'female')

if ~isfolder(fullfile(f, birdname, 'calls'))
    WhispSegScreenDir(f, birdname, 'female')
end

% sort into folders
d = dir(fullfile(f, birdname, 'calls'));
d = d(~ismember({d.name},{'.','..','.DS_Store'}));
allfiles = sort({d.name});
allfiles = erase(allfiles, append(birdname, '_'));

dates = {};
for i = 1:length(allfiles)
    temp = cell2mat(allfiles(i));
    dates{i} = temp(1:8);
end

dates = unique(dates);
screen = fullfile(savedir, birdname, 'screen', age);

for i = 1:length(dates)
    date = cell2mat(dates(i));

    if ~isfolder(fullfile(screen, date))
        mkdir(fullfile(screen, date))
        idx = contains({d.name}, date);
        dayfiles = d(idx);

        for j = 1:length(dayfiles)
            copyfile(fullfile(dayfiles(j).folder, dayfiles(j).name),  fullfile(screen, date, dayfiles(j).name))
        end
    end

    % phenotypebird
    PhenotypeBird_dir(screen, date, birdname)
end

% plot histogram
mats = dir(screen);
mats = mats(contains({mats.name},{'.mat'}));

F = figure;
F.Position = [0, 0, 750, 500];
tiledlayout(round(length(mats)/2), 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact')
cm = [69,129,92]./255;

kde = nan(1, length(mats));
med = nan(1, length(mats));
M = nan(1, length(mats));
sem = nan(1, length(mats));

for i = 1:length(mats)
    load(fullfile(mats(i).folder, mats(i).name))

    kde(i) = output.callkde;
    med(i) = output.callmedian;
    M(i) = output.callfilemean;
    sem(i) = output.callfilestd/sqrt(length(output.callfiletimes));

    ax(i) = nexttile;
    set(ax(i), 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    hold on

    histogram(output.callmotifdurs/1000, 25,...
        'FaceColor', cm,...
        'EdgeColor', 'none')

    xlabel(ax(i), 'Call ITI (s)',...
        'FontWeight', 'bold')
    ylabel(ax(i),'Frequency',...
        'FontWeight', 'bold')
    title(['Day ', num2str(i)])
    set(ax(i) ,'Layer', 'Top')
end

linkaxes(ax, 'x')
sgtitle(birdname)

% save
fn = fullfile(screen, append(birdname, '_screening_day_hist.pdf'));
fprintf('Saving %s ...', fn)
exportgraphics(F, fn,...
    'ContentType', 'vector')
fprintf(' done\n')

clear F

% plot metrics
F = figure;
F.Position = [0, 0, 500, 900];
tiledlayout(1, 3,...
    'Padding', 'compact',...
    'TileSpacing', 'compact')
ax = gca;

ax(1) = nexttile;
plot(ax(1), 1:length(kde), kde,...
    'Color', cm,...
    'LineWidth', 1.5,...
    'Marker', 'o',...
    'MarkerSize', 9,...
    'MarkerFaceColor', cm,...
    'MarkerEdgeColor', 'none')
ylabel(ax(1), 'Call KDE',...
    'FontWeight', 'bold')

ax(2) = nexttile;
plot(ax(2), 1:length(med), med,...
    'Color', cm,...
    'LineWidth', 1.5,...
    'Marker', 'o',...
    'MarkerSize', 9,...
    'MarkerFaceColor', cm,...
    'MarkerEdgeColor', 'none')
ylabel(ax(2), 'Call median',...
    'FontWeight', 'bold')

ax(3) = nexttile;
errorbar(ax(3), 1:length(M), M, sem,...
    'Marker', 'o',...
    'MarkerSize', 8,...
    'MarkerFaceColor', cm,...
    'Color', cm,...
    'LineWidth', 1.5,...
    'CapSize', 0)
ylabel(ax(3), 'Call mean',...
    'FontWeight', 'bold')


% axes etc
for i = 1:3
    xlabel(ax(i), 'Screening day',...
        'FontWeight', 'bold')
    ylim(ax(i), [round(ax(i).YLim(1)*0.75, 1) round(ax(i).YLim(2)*1.25, 1)])
    yticks(ax(i),  linspace(ax(i).YLim(1), ax(i).YLim(2), 5))
    set(ax(i), 'box', 'off',...
        'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    set(ax(i),'Layer', 'Top')
end

linkaxes(ax, 'x')
xlim([0.5 length(mats) + 0.5])
xticks(ax, [1:length(mats)])

sgtitle(birdname)

% save
fn = fullfile(screen, append(birdname, '_screening_call_metrics.pdf'));
fprintf('Saving %s ...', fn)
exportgraphics(F, fn,...
    'ContentType', 'vector')
fprintf(' done\n')
