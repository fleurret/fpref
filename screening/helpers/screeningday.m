function screeningday(filedir, savedir, birdname, day)

fprintf('Moving files from %s...', birdname)

% pull files from day X
d = dir(filedir);
d = d(~ismember({d.name},{'.','..','.DS_Store'}));
alldays = sort({d.name});

for i = 1:length(alldays)
    alldays(i) = erase(alldays(i), '_');
end

% move any files not on day X
behavdir = fullfile(savedir, birdname, 'calls');
filelist = dir(string(behavdir) + '\*.not.mat');

mkdir(behavdir, 'other')

for i = 1:length(filelist)
    if ~contains(filelist(i).name, alldays(day+1))
        movefile(fullfile(filelist(i).folder, filelist(i).name),  fullfile(filelist(i).folder, 'other', filelist(i).name))
    end
end

fprintf(' done\n')