function countcalls_tempo(savedir, birdname, sv)

% savedir: base folder for save files
% (e.g. D:\Analysis)

% savedir should have folders for each subject
% (e.g. D:\Analysis\or87yw46)

% within each subject folder, should have separate folder with session
% folders and onset log (e.g. D:\Analysis\or87yw46\session_1,
% D:\Analysis\or87yw46\session_2, etc. and
% D:\Analysis\or87yw46\or87yw46_OnsetLog.txt)

stims = {'ZF', 'MP', 'LP'};
cm = [242,211,137;... % ZF
    35,185,184; ... % MP
    54,97,97]./255; % LP
d = cell2mat(uigetfile_n_dir(fullfile(savedir, birdname)));

switch sv
    case 'load'
        try
            D = readtable(fullfile(d, append(birdname, '_calls.csv')));
        catch ME
            error('File not found. Did you run this function with ''save'' first?')
        end
        
    case 'save'
        if isfile(fullfile(d, append(birdname, '_calls.csv')))
            D = readtable(fullfile(d, append(birdname, '_calls.csv')));
            sessions = dir(d);
            sessions = sessions(~ismember({sessions.name},{'.','..'}));
            sessions = sessions([sessions.isdir]);
            
            es = unique(D.Session);
            
            for i = 1:length(es)
               done = append('session_', num2str(es(i))); 
               sessions = sessions(~contains({sessions.name}, done));
            end
            
            if isempty(sessions)
                error('No new data to add :)')
            end
        else
            D = [];
            sessions = dir(d);
            sessions = sessions(~ismember({sessions.name},{'.','..'}));
            sessions = sessions([sessions.isdir]);
        end
        
        % table headers
        headers = {'Subject', 'Session', 'Stimulus', 'StimNum', 'GapChange', 'Block', 'BlockType',...
            'NumCalls', 'TimeS', 'Q1Pct', 'Q2Pct', 'Q3Pct', 'Q4Pct'};
        
        % sessions
        for i = 1:length(sessions)
            
            session = erase(sessions(i).name, 'session_');
            
            % load timestamps and params
            ts = dir(fullfile(d, sessions(i).name, '*.txt'));
%             o = ts(contains({ts.name}, 'OnsetLog'));
            p = ts(contains({ts.name}, 'Params'));
            
%             timestamps = readtable(fullfile(o.folder, o.name), 'ReadVariableNames',false);
            params = readtable(fullfile(p.folder, p.name), 'ReadVariableNames',false);
            
            if isfolder(fullfile(sessions(i).folder, sessions(i).name, 'cmpJamm'))
                sd = fullfile(sessions(i).folder, sessions(i).name, 'cmpJamm', 'Ch1');
            else
                sd = fullfile(sessions(i).folder, sessions(i).name);
            end
            
            allfiles = dir(sd);
            allfiles = allfiles(~ismember({allfiles.name}, {'.','..'}));
            callfiles = allfiles(endsWith({allfiles.name}, '.not.mat'));
            wavfiles = allfiles(endsWith({allfiles.name}, '.wav'));
            
            % create tables
            blockdata = table('size',[length(callfiles) 13],...
                'variabletypes',["string","string", "string","string","string","string","string",...
                "double","double","double","double","double","double"],...
                'variablenames', headers);
            
            % load file
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
                ver = pinfo.Var11;
                
                parts = split(ver, '_');
                if contains(ver, 'increase')
                    V = parts{2};
                elseif contains(ver, 'decrease')
                    V = append('-', parts{2});
                else
                    V = {0};
                end

                % load wav
                bn = split(fn(end), '.');
                if contains(bn{1}, 'Ch1')
                    block = erase(bn{1}, 'Ch1');
                end
                
                rbn = fn(1:end-1);
                fp = '';
                for k = 1:length(rbn)
                    if k ==- length(rbn)
                        fp = append(fp, rbn(k));
                    else
                        fp = append(fp, rbn(k), '-');
                    end
                end
                
                wfn = append(fp, bn(1), '.wav');
                wav = wavfiles(contains({wavfiles.name}, wfn));
                [wf, fs] = audioread(fullfile(wav.folder, wav.name));
                
                % load mat data
                data = load(fullfile(callfiles(j).folder, callfiles(j).name));
                
                % is it a block or post block
                if contains(data.fname, 'Post')
                    block = fn{3};
                    t = length(wf)/fs;
                    
                    blockdata(j,:).Subject = birdname;
                    blockdata(j,:).Session = session;
                    blockdata(j,:).Stimulus = type;
                    blockdata(j,:).StimNum = stimulus;
                    blockdata(j,:).GapChange = V;
                    blockdata(j,:).Block = block;
                    blockdata(j,:).BlockType = 'PostBlock';
                    blockdata(j,:).NumCalls = length(data.onsets);
                    blockdata(j,:).TimeS = t;
                    blockdata(j,:).Q1Pct = NaN;
                    blockdata(j,:).Q2Pct = NaN;
                    blockdata(j,:).Q3Pct = NaN;
                    blockdata(j,:).Q4Pct = NaN;
                
                else
                    
                    % match timestamps

%                     idx = strcmp(timestamps.Var4, block);
%                     
%                     if sum(idx) == 0
%                         brow = 0;
%                         block_onset = timestamps.Var2(brow+1);
%                     else
%                         brow = find(idx == 1);
%                         block_onset = timestamps.Var2(brow+1) - timestamps.Var2(brow);
%                     end
%                     
%                     block_offset = block_onset + duration(seconds(t), 'format', 'hh:mm:ss.SSS');
%                     
                    % get timestamps from segmented wavs - more accurate
                    ch2seg = round(wf(:,5));
                    block_onset = duration(seconds(min(find(ch2seg == 1))/fs), 'format', 'hh:mm:ss.SSS');
                    block_offset = duration(seconds(max(find(ch2seg == 1))/fs), 'format', 'hh:mm:ss.SSS');
                    t = seconds(block_offset - block_onset);
                    
                    % remove preblock calls
                    onsets = sort(data.onsets);
                    call_onsets = duration(seconds(onsets/1000), 'format', 'hh:mm:ss.SSS');
                    call_onsets = call_onsets(call_onsets > block_onset);
                    
                    % remove postblock calls
                    calls = call_onsets(call_onsets < block_offset);
                    
                    blockdata(j,:).Subject = birdname;
                    blockdata(j,:).Session = session;
                    blockdata(j,:).Stimulus = type;
                    blockdata(j,:).StimNum = stimulus;
                    blockdata(j,:).GapChange = V;
                    blockdata(j,:).TimeS = t;
                    blockdata(j,:).Block = block;
                    blockdata(j,:).BlockType = 'Block';
                    blockdata(j,:).NumCalls = length(calls);
                    
                    % calculate call consistency
                    quarterblock = (block_offset - block_onset)/4;
                    q = block_onset:quarterblock:block_offset;
                    
                    blockdata(j,:).Q1Pct = (sum(calls <= q(2) & calls > q(1))/length(calls))*100;
                    blockdata(j,:).Q2Pct = (sum(calls <= q(3) & calls > q(2))/length(calls))*100;
                    blockdata(j,:).Q3Pct = (sum(calls <= q(4) & calls > q(3))/length(calls))*100;
                    blockdata(j,:).Q4Pct = (sum(calls <= q(5) & calls > q(4))/length(calls))*100;
                    
                    % add postblock calls to the right place
                    postblockcalls = length(call_onsets(call_onsets > block_offset));
                    postblock = contains(blockdata.Block, block) & contains(blockdata.BlockType, 'PostBlock');
                    blockdata(postblock,:).NumCalls = blockdata(postblock,:).NumCalls + postblockcalls;
                end
            end
            
            D = [D; blockdata];
        end
        
        sf = fullfile(d, append(birdname, '_calls.csv'));
        fprintf('Saving file ...')
        writetable(D, sf);
        fprintf(' done\n')
end

if ismatrix(D.Session)
    D.Session = string(D.Session);
end

% only blocks
D = D(strcmp(D.BlockType, 'Block'),:);
sessions = sort(str2double(unique(D.Session)));

% plot across sessions
f = figure;
f.Position = [0, 0, 800, 1800];
tiledlayout(round(length(sessions)/2), 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

for i = 1:length(sessions)
    sessiondata = D(str2double(D.Session) == sessions(i),:);
    sessiondata = sortrows(sessiondata, ["Stimulus", "GapChange"], 'descend');
    
    ax(i) = nexttile;
    set(ax(i), 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    hold on
    
    start = 0;
    
    for j = 1:length(stims)

        typedata = sessiondata(strcmp(sessiondata.Stimulus, stims(j)),:);
%         typedata = sessiondata(j,:);
    
        X = start+1:start+height(typedata);
        Y = typedata.NumCalls ./ typedata.TimeS;
        
        start = start + height(typedata);
        
        bar(ax(i), X, Y,...
            'LineStyle', 'none',...
            'FaceColor', cm(j,:));
    end
    
    xticks(1:height(sessiondata))
    xticklabels(sessiondata.GapChange)
    xlabel(ax, 'Gap change (%)')
    ylabel(ax,'Calls/sec',...
        'FontWeight', 'bold')
    title(['Session ', num2str(i)])
    set(ax(i) ,'Layer', 'Top')
end

legend(ax(i), stims)
legend(ax(i), 'boxoff')
linkaxes(ax, 'y')
sgtitle(birdname)

% save
fn = fullfile(d, append(birdname, '_calls_by_session.pdf'));
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')

clear f

% plot average
f = figure;
f.Position = [0, 0, 500, 300];

start = 0;

ax = gca;
hold on

start = 0;

for i = 1:length(stims)
    stimulusdata = D(contains(D.Stimulus, stims(i)),:);
    stimulusdata = sortrows(stimulusdata, "GapChange", 'descend');
    
    Y = [];
    sem = [];
    
    if strcmp(stims(i), 'ZF')
        variants = unique(stimulusdata.StimNum);
        for j = 1:length(variants)
            stimdata = stimulusdata(contains(stimulusdata.StimNum, variants(j)),:);
            normcalls = stimdata.NumCalls ./ stimdata.TimeS;
            Y(j) = mean(normcalls);
            sem(j) = std(normcalls)/sqrt(length(normcalls));
        end
    else
        variants = flip(unique(stimulusdata.GapChange));
        for j = 1:length(variants)
            stimdata = stimulusdata(stimulusdata.GapChange== variants(j),:);
            normcalls = stimdata.NumCalls ./ stimdata.TimeS;
            Y(j) = mean(normcalls);
            sem(j) = std(normcalls)/sqrt(length(normcalls));
        end
    end
    
    X = [start+1:start+length(variants)];
    start = start+length(variants);   

    b(i) = bar(ax, X, Y,...
        'LineStyle', 'none',...
        'FaceColor', cm(i,:));
    errorbar(ax, X, Y, sem,...
        'Marker', 'none',...
        'Color', 'k',...
        'LineStyle', 'none',...
        'LineWidth', 1.5,...
        'CapSize', 0)
end

xticks(1:length(sessiondata.GapChange))
xticklabels(sessiondata.GapChange)
xlabel(ax, 'Gap change (%)')
ylabel(ax,'Mean calls/sec',...
    'FontWeight', 'bold')

% axes etc
for i = 1:2
    set(ax, 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax,'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    set(ax,'Layer', 'Top')
end

% legend
legend(b, stims);
legend('boxoff')

sgtitle(birdname)

% save
fn = fullfile(d, append(birdname, '_total_calls.pdf'));
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')

clear f

% % plot consistency of calls
f = figure;
f.Position = [0, 0, 800, 350];
tiledlayout(2, 2,...
    'Padding', 'compact',...
    'TileSpacing', 'compact');

D = sortrows(D, ["Stimulus", "GapChange"], 'descend');
stimuli = unique(D.StimNum, 'stable');

for i = 1:4
    Q = nan(1, length(stimuli));
    sem = nan(1, length(stimuli));
    
    ax(i) = nexttile;
    hold on
    
    for j = 1:length(stimuli)
        stimulusdata = D(strcmp(D.StimNum, stimuli(j)),:);
        
        Qi = stimulusdata(:, contains(stimulusdata.Properties.VariableNames, 'Q'));
        X = j;
        Y = mean(table2array(Qi(:,i)), 'omitnan');
        sem = std(table2array(Qi(:,i)), 'omitnan')/sqrt(height(Qi));
        
        color = cm(strcmp(stims, unique(stimulusdata.Stimulus)), :);
        
        bar(ax(i), X, Y,...
            'FaceColor', color,...
            'LineStyle', 'none')
        errorbar(X, Y, sem,...
            'Marker', 'none',...
            'Color', 'k',...
            'LineStyle', 'none',...
            'LineWidth', 1.5,...
            'CapSize', 0)
    end
    
    xticks(1:length(stimuli))
    xticklabels(sessiondata.GapChange)
    xlabel(ax(i), 'Gap change (%)',...
        'FontWeight', 'bold')
    ylabel(ax(i),'% total calls to song',...
        'FontWeight', 'bold')
    
    set(ax(i), 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 1.5);
    set(findobj(ax(i),'-property','FontName'),...
        'FontSize', 9,...
        'FontName','Arial')
    set(ax(i),'Layer', 'Top')
    title(ax(i), append('Q ', num2str(i)));  
end

sgtitle(birdname)

% % save
fn = fullfile(d, append(birdname, '_call_consistency.pdf'));
fprintf('Saving %s ...', fn)
exportgraphics(f, fn,...
    'ContentType', 'vector')
fprintf(' done\n')
