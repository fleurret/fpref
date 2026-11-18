function rhythm(subjs, sex, datadirs,rerunflag)

for i = 1:length(subjs)
    birdname = subjs{i};

    for j = 1:width(datadirs)
        filedir = fullfile(datadirs{j,2}, birdname);

        if isfolder(filedir)
            screenings = dir(filedir);
            screenings = screenings(~ismember({screenings.name},{'.','..','.DS_Store'}));

            for k = 1:length(screenings)
                cd(fullfile(screenings(k).folder, screenings(k).name))
                fprintf('%s %s \n', screenings(k).folder, screenings(k).name)

                if isfile(fullfile(cd, 'rhythm_output.mat')) && rerunflag == 0
                    load(fullfile(cd, 'rhythm_output.mat'))
                else
                    output = [];

                    switch sex
                        case 'female'
                            type = {'calls'};
                        case 'male'
                            type = {'calls', 'song'};
                    end

                    for t = 1:length(type)
                        vocalization = cell2mat(type(t));
                        allfiles = dir(fullfile(cd, vocalization));
                        allfiles = allfiles(~ismember({allfiles.name},{'.','..','.DS_Store'}));

                        ioi = [];

                        for f = 1:length(allfiles)
                            load(string(allfiles(f).folder) +'/'+ string(allfiles(f).name))

                            switch vocalization
                                case 'calls'
                                    idx = find(diff(onsets)<2);
                                    onsets(idx+1) = [];
                                    offsets(idx+1) = [];
                                    labels(idx+1) = [];
                                    gapdurs = (offsets(2:end)-onsets(1:end-1));

                                    shortdurs = find(gapdurs<350);
                                    onsets(shortdurs) = [];
                                    longdurs = find(gapdurs>2500);
                                    onsets(longdurs) = [];

                                    if ~isempty(onsets)
                                        ioi = [ioi [diff(onsets)/1000]'];
                                    else
                                        continue
                                    end

                                case 'song'
                                    idx = find((onsets(2:end)-onsets(1:end-1))<=5);
                                    if length(idx) > 0 % Merge syls that are too small.
                                        onsets(idx+1) = [];
                                        offsets(idx) = [];
                                    end

                                    idx = find((offsets(2:end)-onsets(1:end-1))<= 5); % and no 5ms gaps.
                                    if length(idx) > 0 % Merge gaps that are too small.
                                        onsets(idx) = [];
                                        offsets(idx+1) = [];
                                    end

                                    onsets = onsets(2:end-1);
                                    offsets = offsets(2:end-1);

                                    idx = find((onsets(2:end)-offsets(1:end-1)) < 500)+1; % Maxmimum gap between 'bouts'
                                    idxdiff = (diff(idx));
                                    f = find(diff([0,idxdiff',0]==1));

                                    if isempty(f)
                                        goodidx = [];
                                        durs = [];
                                    else
                                        % Get contiguous segments of syllables
                                        startcontigidx = f(1:2:end-1);  % Start indices
                                        stopcontigidx = f(2:2:end);
                                        contigdur = f(2:2:end)-startcontigidx; % length of contig sequences

                                        mincontig = 10;
                                        killidx = find(contigdur < mincontig);
                                        startcontigidx(killidx) = [];
                                        stopcontigidx(killidx) = [];
                                        goodidx = [];
                                        durs = [];

                                        for m = 1:length(startcontigidx)
                                            goodtrain = idx(startcontigidx(m):stopcontigidx(m))';
                                            goodidx = [goodidx goodtrain];

                                            startbout = onsets(goodtrain(1));
                                            stopbout = offsets(goodtrain(end));

                                            % Onset-to-onset intervals within this bout only -- computed per-bout so
                                            % a long syllable's own duration can never push an interval across a
                                            % between-bout boundary, and no cross-bout gap is ever included.
                                            durs = [durs reshape(diff(onsets(goodtrain)),1,[])];

                                        end
                                    end

                                    ioi = [ioi durs];
                            end
                        end

                        % ioi ratios
                        r = [];

                        for x = 1:length(ioi)-1
                            r(x) = ioi(x)/(ioi(x) + ioi(x+1));
                        end

                        % ioi ratios alt. (van der Aa et al., 2025)
                        r2 = [];

                        for x = 2:length(ioi)-1
                            r2(x) = ioi(x)/(ioi(x) + ioi(x-1));
                        end

                        % % isochrony (annie)
                        % c = sum(r > 0.47 & r < 0.53);
                        % f = sum(r > 0.41 & r <= 0.47) + sum(r >= 0.53 & r < 0.59);
                        % cf = c/f;
                        %
                        % shuf_cf = [];
                        %
                        % for y = 1:20
                        %     shuf_r = [];
                        %     shuffled = ioi(randperm(numel(ioi)));
                        %     for x = 1:length(shuffled)-1
                        %         shuf_r(x) = shuffled(x)/(shuffled(x) + shuffled(x+1));
                        %     end
                        %
                        %     shuf_c = sum(shuf_r > 0.47 & shuf_r < 0.53);
                        %     shuf_f = sum(shuf_r > 0.41 & shuf_r <= 0.47) + sum(shuf_r >= 0.53 & shuf_r < 0.59);
                        %     shuf_cf(y) = shuf_c/shuf_f;
                        % end
                        %
                        % scf = mean(shuf_cf);
                        % score = log2(cf) - log2(scf);

                        output(t).birdname = birdname;
                        output(t).vocalization = vocalization;
                        output(t).iois = ioi;
                        output(t).ioi_ratios = r;
                        output(t).ioi_ratios_alt = r2;
                        % output(t).local_isochrony = score;
                    end

                    ffn = fullfile(cd, 'rhythm_output.mat');
                    fprintf('Saving...')
                    save(ffn, "output")
                    fprintf(' done\n')
                end

                for t = 1:length(output)

                    % plot hist
                    F = figure;
                    F.Position = [0, 0, 500, 300];
                    ax = gca;
                    hold on
                    cm = [69,129,92]./255;
                    [c, d] = ksdensity(output(t).ioi_ratios,'Bandwidth', 'plug-in');
                    [pk, l, ~, pr] = findpeaks(c, d, MinPeakProminence=1);

                    set(ax, 'TickDir', 'out',...
                        'XTickLabelRotation', 0,...
                        'TickLength', [0.02,0.02],...
                        'LineWidth', 1.5);
                    set(findobj(ax,'-property','FontName'),...
                        'FontSize', 9,...
                        'FontName','Arial')
                    plot(d, (c./max(c))*max(histcounts(output(t).ioi_ratios, 50)),...
                        'LineWidth', 1.5,...
                        'Color','k');
                    histogram(output(t).ioi_ratios, 50,...
                        'FaceColor', cm,...
                        'EdgeColor', 'none')
                    xline(l,...
                        'LineStyle', '--')

                    title(append(birdname, ' ', output(t).vocalization))
                    xlim([0 1])
                    xticks([0.3333, 0.5, 0.6666])
                    xticklabels({'1:2', '1:1', '2:1'})
                    xlabel(ax, 'Rhythm ratio',...
                        'FontWeight', 'bold')
                    ylabel(ax,'Frequency',...
                        'FontWeight', 'bold')
                    set(ax,'Layer', 'Top')
                end
            end
        else
            fprintf('no whisperseg files found in %s \n', filedir)
        end
    end
end