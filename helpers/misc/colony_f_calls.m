%% load data
d = readtable('D:\Brainard\Analysis\Female preference\colony_f_calls.csv');

nests = unique(d.Nest);
mk = {'o', '^', 'square', 'diamond', 'p', 'v', 'h', '<'};
cm = [200,243,232]./255;

%% by nest
for i = 1:length(nests) %[3, 9, 11, 15]
    f = figure;
    f.Position = [0, 0, 300, 300];
    ax = gca;
    set(ax, 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax,'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    
    nd = d(strcmp(d.Nest, nests(i)),:);
    nd = sortrows(nd, 'Hatched');
    subjs = unique(nd.Subject, 'stable');
    clutches = unique(nd.Hatched);
    
    for j = 1:length(subjs)
        sd = nd(strcmp(nd.Subject, subjs(j)),:);
        
        % match clutch
        idx = find(clutches == sd.Hatched(1));
        
        x = sd.DPH;
        y = sd.KDE;
        
        hold on
        color = cm - ([0.08 0.1 0.05]*(j-1));
        plot(ax, x, y,...
            'Marker', cell2mat(mk(idx)),...
            'MarkerFaceColor', color,...
            'MarkerEdgeColor', 'none',...
            'MarkerSize', 8,...
            'Color', color,...
            'LineWidth', 1.5)
    end
    
    title(nests(i))
    xlabel('Day post-hatch')
    ylabel('CallKDE')
    
    legend(subjs)
    legend('boxoff')
    
    set(ax,'Layer', 'Top')
    clear f
end


%% correlation between juv/adult

d1 = d(d.Series == 1,:);
d2 = d(d.Series == 2,:);

idx = d2.DPH <=365;

d1y = d1(idx,:);
d1o = d1(~idx,:);
d2y = d2(idx,:);
d2o = d2(~idx,:);

f = figure;
f.Position = [0, 0, 300, 300];
ax = gca;
hold on
set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 1.5);
set(findobj(ax,'-property','FontName'),...
    'FontSize', 9,...
    'FontName','Arial')
scatter(ax, d1.KDE, d2.KDE,...
    'Marker', 'o',...
    'MarkerFaceColor', cm,...
    'MarkerEdgeColor', 'none',...
    'SizeData', 80)
% scatter(ax, d1y.KDE, d2y.KDE,...
%     'Marker', 'o',...
%     'MarkerFaceColor', cm,...
%     'MarkerEdgeColor', 'none',...
%     'SizeData', 80)
% scatter(ax, d1o.KDE, d2o.KDE,...
%     'Marker', 'o',...
%     'MarkerFaceColor', cm./2,...
%     'MarkerEdgeColor', 'none',...
%     'SizeData', 80)

xf = d1.KDE;
yf = d2.KDE;

idx = ~isnan(xf) & ~isnan(yf);
xf = xf(idx);
yf = yf(idx);

coefficients = polyfit(xf, yf, 1);
xFit = linspace(min(xf), max(xf), 1000);
yFit = polyval(coefficients, xFit);

line(ax,xFit,yFit, ...
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

legend({'<= 1yr', '> 1yr'},...
    'Location', 'Southeast')
legend('boxoff')

xlim([0.2 1.7])
ylim([0.5 2])
xlabel('Juvenile KDE')
ylabel('Adult 1 KDE')
set(ax,'Layer', 'Top')

%% correlation between adult 1/adult 2

d2 = d(d.Series == 3,:);
s = d2.Subject;

idx = ismember(d.Subject, s);
d1 = d(idx,:);
d1 = d1(d1.Series == 2,:);

f = figure;
f.Position = [0, 0, 300, 300];
ax = gca;
hold on
set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 1.5);
set(findobj(ax,'-property','FontName'),...
    'FontSize', 9,...
    'FontName','Arial')
scatter(ax, d1.KDE, d2.KDE,...
    'Marker', 'o',...
    'MarkerFaceColor', cm,...
    'MarkerEdgeColor', 'none',...
    'SizeData', 80)
coefficients = polyfit(d1.KDE, d2.KDE, 1);
xFit = linspace(min(d1.KDE), max(d1.KDE), 1000);
yFit = polyval(coefficients, xFit);

line(ax,xFit,yFit, ...
    'Color', 'k', ...
    'LineWidth',3);
[R,P] = corrcoef(d1.KDE,d2.KDE,'rows','complete');

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

ylim([0.5 2])
xlabel('Adult 1 KDE')
ylabel('Adult 2 KDE')
set(ax,'Layer', 'Top')

%% line plot for adult 1/2

f = figure;
f.Position = [0, 0, 500, 200];
ax = gca;
hold on

subjects = unique(d.Subject);
count = -1;
gs = [];

for i = 1:length(subjects)
    s = d(strcmp(d.Subject, subjects(i)),:);
    if height(s) == 3
        count = count+1;
        s2 = s(s.Series == 2,:);
        s3 = s(s.Series == 3,:);
        color = cm - ([0.07 0.08 0.05].*count);
        plot([s2.DPH s3.DPH], [s2.KDE s3.KDE],...
            'Marker', 'o',...
            'MarkerFaceColor', color,...
            'MarkerEdgeColor', 'none',...
            'MarkerSize', 8,...
            'Color', color,...
            'LineWidth', 1.5)
        gs = [gs, subjects(i)];
        
        %         color = cm - ([0.08 0.1 0.05]*(count-1));
        %         plot([s.DPH], [s.KDE],...
        %             'Marker', 'o',...
        %             'MarkerFaceColor', color,...
        %             'MarkerEdgeColor', 'none',...
        %             'MarkerSize', 8,...
        %             'Color', color,...
        %             'LineWidth', 1.5)
    end
end

ylim([0.5 2])
xlabel('Days post-hatch')
ylabel('Call KDE')

set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 1.5);
set(findobj(ax,'-property','FontName'),...
    'FontSize', 9,...
    'FontName','Arial')

legend(gs,...
    'Location', 'Southeast')
legend('boxoff')

%% correlation between juv/adult and parent phenotypes

d.Diff = (d.DadKDE_1 - d.MomKDE_1);
d1 = d(d.Series == 1,:);
d2 = d(d.Series == 2,:);

stg = {'d1', 'd2'};
var = {'MomKDE_1', 'DadKDE_2', 'DadSongKDE'};

f = figure;
f.Position = [0, 0, 600, 900];
tiledlayout(3, 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');
c = 0;

for i = 1:3
    xval = cell2mat(var(i));
    
    for j = 1:2
        if j == 1
            ds = d1;
            yval = 'Juvenile KDE';
        else
            ds = d2;
            yval = 'Adult 1 KDE';
        end
        
        c = c+1;
        
        ax(c) = nexttile;
        set(ax(c), 'TickDir', 'out',...
            'XTickLabelRotation', 0,...
            'TickLength', [0.02,0.02],...
            'LineWidth', 1.5);
        set(findobj(ax(c),'-property','FontName'),...
            'FontSize', 9,...
            'FontName','Arial')
        hold on
        
        x = ds.(xval);
        y = ds.KDE;
        scatter(ax(c), x, y, ...
            'Marker', 'o',...
            'MarkerFaceColor', cm,...
            'MarkerEdgeColor', 'none',...
            'SizeData', 80)
        
        xf = x(~isnan(x));
        yf = y(~isnan(x));
        xf = xf(~isnan(yf));
        yf = yf(~isnan(yf));
        coefficients = polyfit(xf, yf, 1);
        xFit = linspace(min(xf), max(xf), 1000);
        yFit = polyval(coefficients, xFit);
        
        line(ax(c),xFit,yFit, ...
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
        
        xlabel(xval)
        ylabel(yval)
    end
end

%% PCA

D = d(d.Series == 2,:);

vars = [D.KDE, D.MomKDE_1, D.DadKDE_1, D.DadSongKDE];
svars = (vars - mean(vars, 'omitnan')) ./ std(vars, 'omitnan');
[coeff, score, latent, ts, exp] = pca(svars,...
    'Rows', 'complete');

