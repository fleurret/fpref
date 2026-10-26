function whisperseg_wrapper(subjs, sex, datadirs)

for i = 1:length(subjs)
    birdname = subjs{i};

    for j = 1:width(datadirs)
        filedir = fullfile(datadirs{j,1}, birdname);
        savedir = fullfile(datadirs{j,2}, birdname);

        if isfolder(filedir)
            screenings = dir(filedir);
            screenings = screenings(~ismember({screenings.name},{'.','..','.DS_Store'}));

            for k = 1:length(screenings)
                if isfolder(fullfile(savedir, screenings(k).name))
                    fprintf('someone already ran whisperseg on this data :) \n')
                    % code an override later for if you want to rerun
                else
                    cd(fullfile(screenings(k).folder, screenings(k).name))
                    WhispSegScreenDir(cd, birdname, sex)
                end
            end
        end
    end
end