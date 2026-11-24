function call_similarity(subjs, datadirs, savedir, timepoints, rerunflag)

if rerunflag == 0
    d = uigetfile(savedir);
    load(fullfile(savedir, d))
else
    for t = 1:timepoints
        for i = 1:length(subjs)
            birdname = subjs{i};
            filedir = fullfile(datadirs{2,2}, birdname);

            if isfolder(filedir)
                msg = append('Select screening folder for ', birdname, ' at timepoint ', num2str(t));
                screening = uigetdir(filedir, msg);
                cd(screening)
                fprintf('%s \n', screening)

                if isfile(fullfile(cd, 'output.mat'))
                    load(fullfile(cd, 'output.mat'))
                    [c d] = ksdensity(output.callmotifdurs,'Bandwidth',50);

                    cage(t).(birdname).callmotifdurs = output.callmotifdurs;
                    cage(t).(birdname).kde = [d; c];
                else
                    fprintf('no whisperseg output files found in %s \n', filedir)
                end
            end
        end
    end


    sn = input('File name (.mat)')
    ffn = fullfile(savedir, 'fastcage.mat');
    save(ffn, "cage")
end


% plot
F = figure;
F.Position = [0, 0, 500, 500];
ax = gca;
tiledlayout(2, round(numel(cage)/2),...
    'Padding', 'compact',...
    'TileSpacing', 'compact');
cm = [29,36,50]./255;
dph = {'Juvenile screening', '120dph', '180dph', '240dph'};

for i = 1:numel(cage)
    ax(i) = nexttile;
    hold on

    time = cage(i);
    birds = fieldnames(time);

    D = {};
    C = {};

    for j = 1:length(birds)
        subj = cell2mat(birds(j));
        data = time.(subj);
        d = data.kde(1,:);
        c = data.kde(2,:);

        D{j} = d;
        C{j} = c;

        plot(d, c,...
            'LineWidth', 1.5,...
            'Color', cm*j);
        fill(d, c, cm*j,...
            'FaceAlpha', 0.2,...
            'EdgeColor', 'none')
        xline(1/max(c),...
            'Color', cm*j, ...
            'LineStyle', '--', ...
            'LineWidth', 1.5)
    end

    xlabel('ICI (ms)')
    ylabel('Density')
    legend(birds)
    legend('boxoff')
    title(dph(i))
    set(ax(i), 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')

    X = linspace(min(cellfun(@(x) min(x), D)), ...
             max(cellfun(@(x) max(x), D)), 1000);
    for j = 1:length(birds)
        interp_c{j} = interp1(D{j}, C{j}, X, 'linear', 0);
    end

    bdmatrix = zeros(length(birds), length(birds));
    for j = 1:length(birds)
        for k = j+1:length(birds)
            bc = trapz(X, sqrt(interp_c{j}.*interp_c{k}));
            bdmatrix(j,k) = -log(bc);
            bdmatrix(k,j) = bdmatrix(j,k);
        end
    end

    fprintf('Bhattacharyya distance matrix for timepoint %0f \n', i)
    disp(bdmatrix)
end