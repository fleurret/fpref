function selectivity_corr2(savedir, cmlist, cm)

d = readtable(fullfile(savedir, 'female_phenotypes.csv'));
subjects = [d.Subject];
si = nan(1, length(subjects));
dprime = nan(1, length(subjects));

% pref test
for i = 1:length(subjects)
    if isfile(fullfile(savedir, subjects(i), 'testing', append(subjects(i), '_calls.csv')))
        prefdata = readtable(cell2mat(fullfile(savedir, subjects(i), 'testing', append(subjects(i), '_calls.csv'))));
    elseif isfile(fullfile(savedir, subjects(i), 'pref_test', append(subjects(i), '_calls.csv')))
        prefdata = readtable(cell2mat(fullfile(savedir, subjects(i), 'pref_test', append(subjects(i), '_calls.csv'))));
    else
        prefdata = [];
    end
    
    if isempty(prefdata)
        continue
    else
        % only blocks
        D = prefdata(strcmp(prefdata.BlockType, 'Block'),:);
        stims = unique(D.Stimulus);
        allcalls = [];
        Dprime = [];
        SI = [];
        
        for j = 1:length(stims)
            stimulusdata = D(contains(D.Stimulus, stims(j)),:);
            otherstimdata = D(~contains(D.Stimulus, stims(j)),:);
            
            allcalls(j) = sum(stimulusdata.NumCalls);
            
            a = stimulusdata.NumCalls;
            b = otherstimdata.NumCalls;
            
            if isnan(calcd(a, b))
                Dprime(j) = 0;
            else
                Dprime(j) = calcd(a, b);
            end
        end

        % selectivity index
        for j = 1:length(stims)
            targetstim = allcalls(j);
            otherstim = allcalls;
            otherstim(j) = [];
            
            Ms = mean(otherstim);
            SI(j) = targetstim/Ms;
        end
        
        si(i) = max(SI);
        dprime(i) = max(Dprime);
    end
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
    match = find(strcmp(subjects(i), cmlist));
    scatter(ax(1), bird.JuvKDE, si(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(match,:),...
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
ylabel(ax(1), 'Max SI')

ax(2) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    match = find(strcmp(subjects(i), cmlist));
    scatter(ax(2), bird.AdultKDE, si(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(match,:),...
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
ylabel(ax(2), 'Max SI')

linkaxes(ax(1:2), 'xy')

ax(3) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    match = find(strcmp(subjects(i), cmlist));
    scatter(ax(3), bird.JuvKDE, dprime(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(match,:),...
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
ylabel(ax(3), 'Max dprime')

ax(4) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    match = find(strcmp(subjects(i), cmlist));
    scatter(ax(4), bird.AdultKDE, dprime(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(match,:),...
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
ylabel(ax(4), 'Max dprime')

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
    D = sortrows(D, ["Stimulus", "GapChange"], 'descend');

    stims = unique(D.StimNum, 'stable');
    allcalls = [];
    SI = [];
    Dprime = [];
    
    for j = 1:length(stims)
        stimulusdata = D(contains(D.StimNum, stims(j)),:);
        otherstimdata = D(~contains(D.StimNum, stims(j)),:);
        
        allcalls(j) = sum(stimulusdata.NormCalls);
        
        % dprime
        a = stimulusdata.NormCalls;
        b = otherstimdata.NormCalls;
        
        Dprime(j) = calcd(a,b);
    end
    
    for j = 1:length(stims)
        
        % selectivity index
        targetstim = allcalls(j);
        otherstim = allcalls;
        otherstim(j) = [];
        
        Ms = mean(otherstim);
        SI(j) = targetstim/Ms;
    end
    
    si(i) = max(SI);
    dprime(i) = max(Dprime);
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
    match = find(strcmp(subjects(i), cmlist));
    scatter(ax(1), bird.JuvKDE, si(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(match,:),...
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
ylabel(ax(1), 'Max SI')

ax(2) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    match = find(strcmp(subjects(i), cmlist));
    scatter(ax(2), bird.AdultKDE, si(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(match,:),...
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
ylabel(ax(2), 'Max SI')

linkaxes(ax(1:2), 'xy')

ax(3) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    match = find(strcmp(subjects(i), cmlist));
    scatter(ax(3), bird.JuvKDE, dprime(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(match,:),...
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
ylabel(ax(3), 'Maximum dprime')

ax(4) = nexttile;
hold on

for i = 1:length(subjects)
    bird = d(i,:);
    match = find(strcmp(subjects(i), cmlist));
    scatter(ax(4), bird.AdultKDE, dprime(i),...
        'Marker', 'o',...
        'MarkerFaceColor', cm(match,:),...
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
ylabel(ax(4), 'Maximum dprime')

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
