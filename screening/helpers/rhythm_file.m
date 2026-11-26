function rhythm_file(savedir, vocalization)

allfiles = uigetfile_n_dir(savedir, 'Select .mat whisperseg outputs');

for i = 1:length(allfiles)
    
    load(string(allfiles(i)))
    s1 = erase(allfiles(i), savedir);
    s2 = split(s1, '_');
    s3 = split(s2(end), ' -');
    birdname = string(s3(1));
    ioi = [];
    
    switch vocalization
        case 'calls'
            idx = find(diff(onsets)<2);
            onsets(idx+1) = [];
            offsets(idx+1) = [];
            gapdurs = (onsets(2:end)-offsets(1:end-1));
            
            shortdurs = find(gapdurs < 350);
            onsets(shortdurs) = [];
            longdurs = find(gapdurs > 2500);
            onsets(longdurs) = [];
            
            if numel(onsets) > 1
                ioi = [ioi [diff(onsets)]'];
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
    end
    
    ioi = [ioi durs];
    
    % cv
    cv = std(ioi)/mean(ioi);
    
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
    
    % fft analysis
    binary = zeros(1, offsets(end));
    binary(round(onsets)) = 1;
    signalfft = abs(fft(binary));
    p0 = signalfft(1);
    sfft = signalfft;
    sfft(1) = 0; % remove dc offset
    pbest = max(sfft);
    pbest_hz = min(find(sfft == pbest));
    nGOF = abs(pbest)/(length(binary)*abs(p0));
    
    output.birdname = birdname;
    output.vocalization = vocalization;
    output.onsets = onsets;
    output.offsets = offsets;
    output.iois = ioi;
    output.global_cv = cv;
    output.ioi_ratios = r;
    output.ioi_ratios_alt = r2;
    output.signalfft = signalfft;
    output.beat_freq = pbest_hz/1000;
    output.beat_freq_GOF = nGOF;
    % output.local_isochrony = score;
    
    
    ffn = fullfile(savedir, append(birdname, '_normalized_stim_output.mat'));
    fprintf('Saving...')
    save(ffn, "output")
    fprintf(' done\n')
end

% % plot hist
% F = figure;
% F.Position = [0, 0, 500, 300];
% ax = gca;
% hold on
% cm = [69,129,92]./255;
% [c, d] = ksdensity(output.ioi_ratios,'Bandwidth', 'plug-in');
% [pk, l, ~, pr] = findpeaks(c, d, MinPeakProminence=1);
% 
% set(ax, 'TickDir', 'out',...
%     'XTickLabelRotation', 0,...
%     'TickLength', [0.02,0.02],...
%     'LineWidth', 1.5);
% set(findobj(ax,'-property','FontName'),...
%     'FontSize', 9,...
%     'FontName','Arial')
% plot(d, (c./max(c))*max(histcounts(output.ioi_ratios, 50)),...
%     'LineWidth', 1.5,...
%     'Color','k');
% histogram(output.ioi_ratios, 50,...
%     'FaceColor', cm,...
%     'EdgeColor', 'none')
% xline(l,...
%     'LineStyle', '--')
% 
% title(append(birdname, ' ', output.vocalization))
% xlim([0 1])
% xticks([0.3333, 0.5, 0.6666])
% xticklabels({'1:2', '1:1', '2:1'})
% xlabel(ax, 'Rhythm ratio',...
%     'FontWeight', 'bold')
% ylabel(ax,'Density',...
%     'FontWeight', 'bold')
% set(ax,'Layer', 'Top')
