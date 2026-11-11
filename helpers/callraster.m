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
    o = ts(contains({ts.name}, 'OnsetLog'));
    p = ts(contains({ts.name}, 'Params'));
    onsetlog = readtable(fullfile(o.folder, o.name), 'ReadVariableNames',false);
    params = readtable(fullfile(p.folder, p.name), 'ReadVariableNames',false);
    
    for j = 1:length(callfiles)
        
        % which stim/match to params
        fn = split(callfiles(j).name, '-');
        stimulus = fn{2};
        sn = erase(stimulus, 'Stim');
        block = erase(fn{3}, 'Ch1.wav.songs.not.mat');
        
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
        
        % call onsets
        onsets = sort(data.onsets);
        call_onsets{j} = onsets/1000;
        
        % get timestamps from segmented wav
        idx = find(strcmp(table2cell(onsetlog(:,4)), block));
        
        if isempty(idx)
            idx = 0;
            block_start = 0;
        else
            block_start = table2array(onsetlog(idx, 2));
        end
        
        block_onset = seconds(table2array(onsetlog(idx+1,2)) - block_start);
        block_offset = seconds(table2array(onsetlog(idx+2,2)) - block_start);
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


function plotcallraster(splist, range, color)

if nargin < 3
  color = 'b';
end

hold on

rows = length(splist);

for n = 1:rows
    trial = splist{n};
    block = range{n};
    
    calls = trial(trial > block(1) & trial < block(2));
    y = n/3;

    for i = 1:length(calls)
        set(line,...
            'XData',[1 1]*calls(i),...
            'YData',-[y y+0.25],...
            'Color', color{n},...
            'LineWidth', 1)
    end
end

hold off
