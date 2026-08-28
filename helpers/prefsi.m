function prefsi(savedir, birdname)

% load data
cm = [69,129,92; 166,195,177]./255;
d = cell2mat(uigetfile_n_dir(fullfile(savedir, birdname)));
D = readtable(fullfile(d, append(birdname, '_calls.csv')));

% only blocks
D = D(strcmp(D.BlockType, 'Block'),:);

sessions = sort(unique(D.Session));
stims = unique(D.Stimulus);

% plot across sessions
f = figure;
f.Position = [0, 0, 800, 1800];

tiledlayout(round(length(sessions)/2), 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

allY = [];

for i = 1:length(sessions)
    sessiondata = D(D.Session == sessions(i),:);
    Ms = mean(sessiondata.NumCalls);
    sems = std(sessiondata.NumCalls)/sqrt(height(sessiondata));
    
    Y = nan(1, length(stims));
    
    for j = 1:length(stims)
        stimulusdata = sessiondata(contains(sessiondata.Stimulus, stims(j)),:);
        
        if isnan(stimulusdata.NumCalls/Ms)
            Y(j) = 1;
        else
            Y(j) = stimulusdata.NumCalls/Ms;
        end
        
    end
    
    allY = [allY; Y];
    
    ax(i) = nexttile;
    
    set(ax(i), 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    hold on
    
    plot(ax(i), Y,...
        'Marker', 'o',...
        'MarkerSize', 8,...
        'MarkerFaceColor', cm(1,:),...
        'Color', cm(1,:),...
        'LineWidth', 1.5)
    
    xticks(1:length(stims))
    xticklabels(stims)
    xlim([0.5 length(stims)+0.5])
    ylabel(ax,'Selectivity index',...
        'FontWeight', 'bold')
    title(['Session ', num2str(i)])
    set(ax(i) ,'Layer', 'Top')
end

linkaxes(ax, 'y')
sgtitle(birdname)

% save
fn = fullfile(d, append(birdname, '_SI_by_session.pdf'));
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')

clear f

% plot average
f = figure;
f.Position = [0, 0, 400, 250];
ax = gca;
hold on

set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 1.5);
set(findobj(ax,'-property','FontName'),...
    'FontSize', 9,...
    'FontName','Arial')

X = 1:length(stims);
Y = mean(allY);
sem = std(allY)/sqrt(height(allY));

errorbar(X, Y, sem,...
    'Marker', 'o',...
    'MarkerSize', 8,...
    'MarkerFaceColor', cm(1,:),...
    'Color', cm(1,:),...
    'LineWidth', 1.5,...
    'CapSize', 0)

xticks(1:length(stims))
xticklabels(stims)
xlim([0.5 length(stims)+0.5])
ylabel(ax,'Selectivity index',...
    'FontWeight', 'bold')
set(ax, 'Layer', 'Top')

sgtitle(birdname)

% save
fn = fullfile(d, append(birdname, '_SI_average.pdf'));
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')

clear f