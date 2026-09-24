function selectivity_corr(savedir)

cm = [234,175,59;... % or87yw46
    188,188,188;... % wh26wh27
    201,55,55;... % or25rd67
    108,164,134;... % wh37gr58
    169,116,222]./255; % wh99pu92

d = readtable(fullfile(savedir, 'female_phenotypes.csv'));
subjects = [d.Subject];
si = nan(1, length(subjects));
dprime = nan(1, length(subjects));

% pref test
% calculate selectivity and dprime
for i = 1:length(subjects)
    prefdata = readtable(cell2mat(fullfile(savedir, subjects(i), 'testing', append(subjects(i), '_calls.csv'))));
    
    % only blocks
    D = prefdata(strcmp(prefdata.BlockType, 'Block'),:);
    
    sessions = sort(unique(D.Session));
    stims = unique(D.Stimulus);
    SI = [];
    Dprime = [];
    
    for j = 1:length(sessions)
        sessiondata = D(D.Session == sessions(j),:);
        
        % selectivity index
        Ms = mean(sessiondata.NumCalls);
        sems = std(sessiondata.NumCalls)/sqrt(height(sessiondata));
        
        Y1 = nan(1, length(stims));
        Y2 = nan(1, length(stims));
        
        for k = 1:length(stims)
            stimulusdata = sessiondata(contains(sessiondata.Stimulus, stims(k)),:);
            otherstims = sessiondata(~contains(sessiondata.Stimulus, stims(k)),:);
            
            % selectivity index
            if isnan(stimulusdata.NumCalls/Ms)
                Y1(k) = 1;
            else
                Y1(k) = stimulusdata.NumCalls/Ms;
            end
            
            % dprime
            a = stimulusdata.NumCalls;
            b = otherstims.NumCalls;
            
            if isnan(calcd(a, b))
                Y2(k) = 0;
            else
                Y2(k) = calcd(a, b);
            end
            
        end
        
        SI = [SI; Y1];
        Dprime = [Dprime; Y2];
    end
    
    si(i) = max(mean(SI));
    dprime(i) = max(mean(Dprime));
end

f = figure;
f.Position = [0, 0, 600, 600];
ax = gca;
tiledlayout(2, 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

ax(1) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    scatter(ax(1), bird.JuvKDE, si(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

legend(ax(1), subjects,...
    'AutoUpdate', 'off');
legend('boxoff')

xf = d.JuvKDE;
yf = si;

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
ylabel(ax(1), 'Maximum avg SI')

ax(2) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    scatter(ax(2), bird.AdultKDE, si(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

xf = d.AdultKDE;
yf = si;

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
ylabel(ax(2), 'Maximum avg SI')

linkaxes(ax(1:2), 'xy')

ax(3) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    scatter(ax(3), bird.JuvKDE, dprime(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

xf = d.JuvKDE;
yf = dprime;

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
ylabel(ax(3), 'Maximum avg dprime')

ax(4) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    scatter(ax(4), bird.AdultKDE, dprime(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

xf = d.AdultKDE;
yf = dprime;

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
ylabel(ax(4), 'Maximum avg dprime')

linkaxes(ax(3:4), 'xy')

% axes etc
for i = 1:4
    set(ax(i), 'box', 'off',...
        'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
end

sgtitle('Preference test')

% save
fn = fullfile(savedir, 'group_selectivity_corr_pref.pdf');
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')



% tempo test
% calculate selectivity and dprime

si = nan(1, length(subjects));
dprime = nan(1, length(subjects));

for i = 1:length(subjects)
    if isfile(fullfile(savedir, subjects(i), 'tempo_test', append(subjects(i), '_calls.csv')))
        tempodata = readtable(cell2mat(fullfile(savedir, subjects(i), 'tempo_test', append(subjects(i), '_calls.csv'))));
    else
        continue
    end
    
    % only blocks
    D = tempodata(strcmp(tempodata.BlockType, 'Block'),:);
    D.NormCalls = D.NumCalls./D.TimeS;
    
    sessions = sort(unique(D.Session));
    stims = unique(D.Stimulus);
    SI = [];
    Dprime = [];
    
    for j = 1:length(sessions)
        sessiondata = D(D.Session == sessions(j),:);
        sessiondata = sortrows(sessiondata, ["Stimulus", "GapChange"], 'descend');
    
        stimuli = unique(sessiondata.StimNum, 'stable');
    
        % selectivity index
        Ms = mean(sessiondata.NormCalls);
        Y1 = nan(1, length(stimuli));
        Y2 = nan(1, length(stimuli));
        
        for k = 1:length(stimuli)
            stimulusdata = sessiondata(strcmp(sessiondata.StimNum, stimuli(k)),:);
            otherstims = sessiondata(~strcmp(sessiondata.StimNum, stimuli(k)),:);
            
            % selectivity index
            if isnan(stimulusdata.NormCalls/Ms)
                Y1(k) = 1;
            else
                Y1(k) = stimulusdata.NormCalls/Ms;
            end
            
            % dprime
            a = stimulusdata.NormCalls;
            b = otherstims.NormCalls;
            
            if isnan(calcd(a, b))
                Y2(k) = 0;
            else
                Y2(k) = calcd(a, b);
            end
            
        end
        
        SI = [SI; Y1];
        Dprime = [Dprime; Y2];
    end
    
    si(i) = max(mean(SI));
    dprime(i) = max(mean(Dprime));
end

f = figure;
f.Position = [0, 0, 600, 600];
ax = gca;
tiledlayout(2, 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

ax(1) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    scatter(ax(1), bird.JuvKDE, si(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

legend(ax(1), subjects,...
    'AutoUpdate', 'off');
legend('boxoff')

xf = d.JuvKDE;
yf = si;

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
ylabel(ax(1), 'Maximum avg SI')

ax(2) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    scatter(ax(2), bird.AdultKDE, si(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

xf = d.AdultKDE;
yf = si;

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
ylabel(ax(2), 'Maximum avg SI')

linkaxes(ax(1:2), 'xy')

ax(3) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    scatter(ax(3), bird.JuvKDE, dprime(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

xf = d.JuvKDE;
yf = dprime;

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
ylabel(ax(3), 'Maximum avg dprime')

ax(4) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    scatter(ax(4), bird.AdultKDE, dprime(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(i,:),...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

xf = d.AdultKDE;
yf = dprime;

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
ylabel(ax(4), 'Maximum avg dprime')

linkaxes(ax(3:4), 'xy')

% axes etc
for i = 1:4
    set(ax(i), 'box', 'off',...
        'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
end

sgtitle('Tempo test')

% save
fn = fullfile(savedir, 'group_selectivity_corr_tempo.pdf');
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')

function d = calcd(a, b)
d = (2*(mean(a)-mean(b)))/(sqrt((std(a)^2) + (std(b)^2)));
