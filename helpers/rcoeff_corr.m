function rcoeff_corr(savedir, cmlist, cm, id)

fn = append(id, '_rcoeff.csv');
R = readtable(fullfile(savedir, fn));

% match
D = readtable(fullfile(savedir, 'female_phenotypes.csv'));

subjects = unique(R.Subject);
s = split(subjects, '_');
subjects = s(:,1);

vars = {'avgSI', 'avgdprime'};

f = figure;
f.Position = [0, 0, 250, 250];
Ax = gca;
hold on

X = [];
Y = [];
MP = nan(1, length(subjects));
LP = nan(1, length(subjects));

for i = 1:length(subjects)
    r = R(contains(R.Subject, subjects(i)),:);
    d = D(contains(D.Subject, subjects(i)),:);
    den = max(r.r);
    
    rmp = r(contains(r.Stim, d.MP),:);
    MP(i) = rmp.r/den;
    rlp = r(contains(r.Stim, d.LP),:);
    LP(i) = rlp.r/den;
    
    f = figure;
    f.Position = [0, 0, 500, 250];
    ax = gca;
    hold on
    
    match = find(strcmp(subjects(i), cmlist));
    color = cm(match,:);
    
    for j = 1:length(vars)
        ax(j) = nexttile;
        hold on
        
        yval = cell2mat(vars(j));
        x = r.r;
        y = r.(yval);
        
        scatter(ax(j), x, y,...
            'Marker', 'o',...
            'MarkerFaceColor', color,...
            'MarkerEdgeColor', 'none',...
            'MarkerFaceAlpha', 1,...
            'SizeData', 80)
        
        coefficients = polyfit(x, y, 1);
        xFit = linspace(min(x), max(x), 1000);
        yFit = polyval(coefficients, xFit);
        
        line(ax(j),xFit,yFit, ...
            'Color', 'k', ...
            'LineWidth',3);
        [R1,P] = corrcoef(x,y,'rows','complete');
        
        if length(R1) > 1
            r1 = R1(2);
            p = P(2);
            
            str = sprintf('R = %1.3f, p = %1.3f \n', r1, p);
            T = text(max(xlim), min(ylim), str);
            set(findobj(T),...
                'FontSize', 9,...
                'FontName', 'Arial',...
                'HorizontalAlignment', 'right');
        end
        
        xlabel(ax(j), append(id, ' relationship coefficient'))
        ylabel(ax(j), vars(j))
        
        set(ax(j), 'box', 'off',...
            'TickDir', 'out',...
            'XTickLabelRotation', 0,...
            'TickLength', [0.02,0.02],...
            'LineWidth', 1.5);
        set(findobj(ax(j),'-property','FontName'),...
            'FontSize', 9,...
            'FontName','Arial')
    end
    
    sgtitle(subjects(i))
    
    X = [X; x];
    Y = [Y; y];
    
    scatter(Ax, x, y,...
        'Marker', 'o',...
        'MarkerFaceColor', color,...
        'MarkerEdgeColor', 'none',...
        'MarkerFaceAlpha', 1,...
        'SizeData', 80)
end

coefficients = polyfit(X, Y, 1);
xFit = linspace(min(X), max(X), 1000);
yFit = polyval(coefficients, xFit);

line(Ax,xFit,yFit, ...
    'Color', 'k', ...
    'LineWidth',3);
[R1,P] = corrcoef(X,Y,'rows','complete');

if length(R1) > 1
    r1 = R1(2);
    p = P(2);
    
    str = sprintf('R = %1.3f, p = %1.3f \n', r1, p);
    T = text(Ax, max(xlim), min(ylim), str);
    set(findobj(T),...
        'FontSize', 9,...
        'FontName', 'Arial',...
        'HorizontalAlignment', 'right');
end

% relatedness for most/least preferred
f = figure;
f.Position = [0, 0, 250, 250];
ax = gca;
hold on

x = [1, 2];
y = [mean(MP, 'omitnan'), mean(LP, 'omitnan')];
sem = [std(MP, 'omitnan')/sqrt(height(MP)), std(LP, 'omitnan')/sqrt(height(LP))];
bar(ax, x, y,...
    'FaceColor', color,...
    'LineStyle', 'none',...
    'LineWidth', 1)
errorbar(ax, x, y, sem,'k',...
    'LineStyle','none',...
    'LineWidth', 1.5);
xlabel(ax, {'MP', 'LP'})
ylabel(ax, 'Relative relationship coefficient')

set(ax, 'box', 'off',...
    'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 1.5);
set(findobj(ax,'-property','FontName'),...
    'FontSize', 9,...
    'FontName','Arial')