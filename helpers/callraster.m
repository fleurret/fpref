function callraster(savedir, birdname)

stims = {'ZF', 'MP', 'LP'};
cm = [242,211,137;... % ZF
    35,185,184; ... % MP
    54,97,97]./255; % LP
d = cell2mat(uigetfile_n_dir(fullfile(savedir, birdname)));
D = [];
sessions = dir(d);
sessions = sessions(~ismember({sessions.name},{'.','..'}));
sessions = sessions([sessions.isdir]);

% plot
f = figure;
f.Position = [0, 0, 800, 1800];
tiledlayout(round(length(sessions)/2), 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

for i = 1:length(sessions)
    session = erase(sessions(i).name, 'session_');
    
    if isfolder(fullfile(sessions(i).folder, sessions(i).name, 'cmpJamm'))
        sd = fullfile(sessions(i).folder, sessions(i).name, 'cmpJamm', 'Ch1');
    else
        sd = fullfile(sessions(i).folder, sessions(i).name);
    end
    
    allfiles = dir(sd);
    allfiles = allfiles(~ismember({allfiles.name}, {'.','..'}));
    callfiles = allfiles(endsWith({allfiles.name}, '.not.mat'));
    callfiles = callfiles(~contains({callfiles.name}, 'PostBlock'));
    wavfiles = allfiles(endsWith({allfiles.name}, '.wav'));
    wavfiles = wavfiles(~contains({wavfiles.name}, 'PostBlock'));
    
    ax(i) = nexttile;
    set(ax(i), 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    hold on
    
    % load params
    ts = dir(fullfile(d, sessions(i).name, '*.txt'));
    p = ts(contains({ts.name}, 'Params'));
    params = readtable(fullfile(p.folder, p.name), 'ReadVariableNames',false);
    
    for j = 1:length(callfiles)
        
        % which stim/match to params
        fn = split(callfiles(j).name, '-');
        stimulus = fn{2};
        sn = erase(stimulus, 'Stim');
        
        pinfo = params(contains(params.Var1, 'C:') & contains(params.Var1, sn), :);
        
        if height(pinfo) > 1
            var1 = pinfo.Var1;
            n = {};
            for k = 1:length(var1)
                n(k) = extract(var1(k), digitsPattern);
            end
            
            idx = strcmp(n, sn);
            pinfo = pinfo(idx,:);
        end
        
        type = pinfo.Var10;
        cf = strcmp(stims, type);
        color{j} = cm(cf,:);
                
        % load data
        data = load(fullfile(callfiles(j).folder, callfiles(j).name));
        [wf, fs] = audioread(fullfile(wavfiles(j).folder, wavfiles(j).name));
        
        % call onsets
        onsets = sort(data.onsets);
        call_onsets{j} = onsets/1000;
        
        % get timestamps from segmented wav
        ch2seg = round(wf(:,5));
        block_onset = min(find(ch2seg == 1)/fs);
        block_offset = max(find(ch2seg == 1)/fs);
        t{j} = [block_onset block_offset];
    end
    
    plotcallraster(call_onsets, t, color);
    
    xlabel(ax, 'Time (s)')
    title(['Session ', num2str(i)])
    set(ax(i) ,'Layer', 'Top')
    
end

legend(ax(i), stims)
legend(ax(i), 'boxoff')
linkaxes(ax, 'y')
sgtitle(birdname)

% save
fn = fullfile(d, append(birdname, '_callraster.pdf'));
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')