function callamount_corr(savedir, cmlist, cm)

d = readtable(fullfile(savedir, 'female_phenotypes.csv'));
subjects = [d.Subject];
allcalls = nan(1, length(subjects));

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
        daycalls = [];
        
        days = unique(D.Session);
        
        for j = 1:length(days)
           DD = D(D.Session == days(j),:); 
           daycalls(j) = sum(DD.NumCalls);
        end
        
        allcalls(i) = mean(daycalls);
    end
end

f = figure;
f.Position = [0, 0, 600, 300];
ax = gca;
tiledlayout(1, 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');
vars = {'JuvKDE', 'AdultKDE1'};

for j = 1:length(vars)
    ax(j) = nexttile;
    hold on
    
    for i = 1:length(subjects)
        bird = d(i,:);
        match = find(strcmp(subjects(i), cmlist));
        xval = vars{j};
        scatter(ax(j), bird.(xval), allcalls(i),...
            'Marker', 'o',...
            'MarkerFaceColor', cm(match,:),...
            'MarkerEdgeColor', 'none',...
            'MarkerFaceAlpha', 1,...
            'SizeData', 80)
    end
    
%     legend(ax(j), subjects,...
%         'AutoUpdate', 'off');
%     legend('boxoff')
    
    xf = d.(xval);
    yf = allcalls;
    
    if any(isnan(yf))
        r = ~isnan(yf);
        xf = xf(r);
        yf = yf(r);
    end
    
    coefficients1 = polyfit(xf, yf, 1);
    xFit1 = linspace(min(xf), max(xf), 1000);
    yFit1 = polyval(coefficients1, xFit1);
    
    line(ax(j),xFit1,yFit1, ...
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
    
    xlabel(ax(j), append(vars{j}, ' (calls/sec)'))
    ylabel(ax(j), 'Average calls/day')
    
    set(ax(j), 'box', 'off',...
        'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(j),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
end

linkaxes(ax, 'xy')

% save
fn = fullfile(savedir, 'group_callamount_corr_pref.pdf');
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')