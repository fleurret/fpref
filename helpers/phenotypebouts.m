birdname = 'pu15bk16'; %'rd18gr48';
filedir = fullfile('D:\Brainard\Analysis\Female preference\Stimuli', birdname);

d = getdirs(filedir);

% find normal stim
nsdir = d(contains({d.name}, 'natural_tempo'));
nsdirpth = fullfile(nsdir.folder, nsdir.name);
nsfiles = dir(fullfile(nsdirpth, '*.not.mat'));

headers = {'bout_id', 'change', 'syllables', 'length'};
alldata = table('size', [length(nsfiles) 4],...
    'variabletypes',["string", "double", "double", "double"],...
    'variablenames', headers);

for i = 1:length(nsfiles)
    b = split(nsfiles(i).name, '_');
    [syls, t] = phenotype(nsfiles(i).folder, nsfiles(i).name);
    
    alldata(i,:).bout_id = b(2);
    alldata(i,:).change = 0;
    alldata(i,:).syllables = syls;
    alldata(i,:).length = t;
end

% loop through adjusted stim
asdir = d(contains({d.name}, 'adjusted_tempo'));
asdirpth = fullfile(asdir.folder, asdir.name);
asfolders = getdirs(asdirpth);

for i = 1:length(asfolders)
    
    f = fullfile(asfolders(i).folder, asfolders(i).name);
    b = split(asfolders(i).name, '_');
    
    % find syls from table
    bd = alldata(strcmp(alldata.bout_id, b(2)),:);
    bsyls = bd.syllables;
    
    wavs = dir(fullfile(f, '*.wav'));
    
    tempdata = table('size', [length(wavs) 4],...
        'variabletypes',["string", "double", "double", "double"],...
        'variablenames', headers);
    
    for j = 1:length(wavs)
        [wav, fs] = audioread(fullfile(wavs(j).folder, wavs(j).name));
        t = length(wav)/fs;
        
        parts = split(wavs(j).name, '_');
        if contains(parts{5}, 'increase')
            c = str2num(parts{3});
        elseif contains(parts{5}, 'decrease')
            c = str2num(append('-', parts{3}));
        end
        
        tempdata(j,:).bout_id = parts{2};
        tempdata(j,:).change = c;
        tempdata(j,:).syllables = bsyls;
        tempdata(j,:).length = t;
    end
    
    alldata = [alldata; tempdata];
end

% get final tempo
variants = unique(alldata.change);

findata = table('size', [length(variants) 3],...
    'variabletypes',["double", "double", "double"],...
    'variablenames', {'change', 'tempo', 'sem'});

for i = 1:length(variants)
   v = alldata(alldata.change == variants(i),:); 
   bts = v.syllables./v.length;
   
   findata(i,:).change = variants(i);
   findata(i,:).tempo = mean(v.syllables./v.length);
   findata(i,:).sem = std(v.syllables./v.length)/sqrt(height(v));
end

% plot

f = figure;
f.Position = [0, 0, 500, 300];

ax = gca;
hold on

errorbar(findata.change, findata.tempo, findata.sem,...
    'Marker', 'o',...
    'MarkerSize', 8,...
    'MarkerFaceColor', 'k',...
    'Color', 'k',...
    'LineWidth', 1.5,...
    'CapSize', 0)
xticks(findata.change)
xlabel('gap change (%)',...
    'FontWeight', 'bold')
ylabel('tempo (syls/sec)',...
    'FontWeight', 'bold')

set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 1.5);
set(findobj(ax,'-property','FontName'),...
    'FontSize', 9,...
    'FontName','Arial')
set(ax,'Layer', 'Top')
title(b{1})

function d = getdirs(filedir)

d = dir(filedir);
d = d(~ismember({d.name},{'.','..'}));
d = d([d.isdir]);

end

function [syls, t] = phenotype(foldername, filename)

data = load(fullfile(foldername, filename));
syls = length(data.onsets);

% find wav file
wf = erase(filename, '.not.mat');
[wav, fs] = audioread(fullfile(foldername, wf));
t = length(wav)/fs;

end