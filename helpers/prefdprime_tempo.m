function prefdprime_tempo(savedir, birdname)

% load data
stims = {'ZF', 'MP', 'LP'};
cm = [242,211,137;... % ZF
    35,185,184; ... % MP
    54,97,97]./255; % LP
d = cell2mat(uigetfile_n_dir(fullfile(savedir, birdname)));
D = readtable(fullfile(d, append(birdname, '_calls.csv')));
D.NormCalls = D.NumCalls./D.TimeS;

% only blocks
D = D(strcmp(D.BlockType, 'Block'),:);

sessions = sort(unique(D.Session));

% plot across sessions
f = figure;
f.Position = [0, 0, 800, 1800];

tiledlayout(round(length(sessions)/2), 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

allY = [];

for i = 1:length(sessions)
    ax(i) = nexttile;
    
    set(ax(i), 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    hold on
    
    sessiondata = D(D.Session == sessions(i),:);
    sessiondata = sortrows(sessiondata, ["Stimulus", "GapChange"], 'descend');
    
    stimuli = unique(sessiondata.StimNum, 'stable');

    Y = nan(1, length(stimuli));
    
    for j = 1:length(stimuli)
        stimulusdata = sessiondata(strcmp(sessiondata.StimNum, stimuli(j)),:);
        otherstims = sessiondata(~strcmp(sessiondata.StimNum, stimuli(j)),:);
        
        a = stimulusdata.NormCalls;
        b = otherstims.NormCalls;
        
        Y(j) = calcd(a, b);
        color = cm(strcmp(stims, unique(stimulusdata.Stimulus)), :);
        
        plot(ax(i), j, Y(j),...
            'Marker', 'o',...
            'MarkerSize', 8,...
            'MarkerFaceColor', color,...
            'MarkerEdgeColor', color)
    end
    
    allY = [allY; Y];
    X = 1:length(stimuli);
    
    p = plot(ax(i), X, Y,...
        'Marker', 'none',...
        'Color', 'k',...
        'LineWidth', 1.5);
    uistack(p, 'bottom')

    xticks(1:length(stimuli))
    xticklabels(sessiondata.GapChange)
    xlim([0.5 length(stimuli)+0.5])
    ylim([ax(i).YLim(1)-0.5 ax(i).YLim(2)+0.5])
    ylabel(ax,'d''',...
        'FontWeight', 'bold')
    title(['Session ', num2str(i)])
    set(ax(i) ,'Layer', 'Top')
end


linkaxes(ax, 'y')
sgtitle(birdname)

% save
fn = fullfile(d, append(birdname, '_dprime_by_session.pdf'));
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

X = 1:length(stimuli);
Y = mean(allY);
sem = std(allY)/sqrt(height(allY));

for i = 1:length(stimuli)
    stimulusdata =  D(strcmp(D.StimNum, stimuli(i)),:);
    color = cm(strcmp(stims, unique(stimulusdata.Stimulus)), :);
    errorbar(X(i), Y(i), sem(i),...
        'Marker', 'o',...
        'MarkerSize', 8,...
        'MarkerFaceColor', color,...
        'Color', color,...
        'LineWidth', 1.5,...
        'CapSize', 0)
end

p = plot(X, Y,...
    'Marker', 'none',...
    'Color', 'k',...
    'LineWidth', 1.5);
uistack(p, 'bottom')

xticks(1:length(stimuli))
xticklabels(sessiondata.GapChange)
xlim([0.5 length(stimuli)+0.5])
ylim([ax.YLim(1)-0.5 ax.YLim(2)+0.5])
ylabel(ax,'d''',...
    'FontWeight', 'bold')
set(ax, 'Layer', 'Top')

sgtitle(birdname)

% save
fn = fullfile(d, append(birdname, '_dprime_average.pdf'));
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')

clear f

function d = calcd(a, b)
d = (2*(mean(a)-mean(b)))/(sqrt((std(a)^2) + (std(b)^2)));