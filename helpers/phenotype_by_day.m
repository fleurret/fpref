function phenotype_by_day(filedir, savedir, birdname)

f = uigetdir(filedir);

% sort into folders
d = dir(f);
d = d(~ismember({d.name},{'.','..','.DS_Store'}));
allfiles = sort({d.name});
allfiles = erase(allfiles, append(birdname, '_'));

dates = {};
for i = 1:length(allfiles)
    temp = cell2mat(allfiles(i));
    dates{i} = temp(1:8);
end

dates = unique(dates);
for i = 1:length(dates)
   mkdir(fullfile(savedir, 'screen', dates(i)))
   idx = contains({d.name}, dates(i));
   dayfiles = d(idx);
   
   for j = 1:length(dayfiles)
       movefile(fullfile(dayfiles(j).folder, dayfiles(i).name),  fullfile(savedir, 'screen', dates(i), dayfiles(i).name))
   end
   
   % phenotypebird
   cd(fullfile(savedir, 'screen', dates(i)))
   PhenotypeBird
end
