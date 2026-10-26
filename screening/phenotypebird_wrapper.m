function phenotypebird_wrapper(subjs, datadirs, version)

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

                switch version
                    case 'full'
                        PhenotypeBird(birdname)
                    case 'lite'
                        PhenotypeBird_lite(birdname)
                end
            end
        else
            fprintf('no whisperseg files found in %s \n', filedir)
        end
    end
end