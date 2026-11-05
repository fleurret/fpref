function whisperseg_wrapper(subjs, sex, datadirs, callfilen, songfilen, rerunflag)

for i = 1:length(subjs)
    birdname = subjs{i};

    switch sex
        case 'male'
            datadirs = {datadirs{2,1}, datadirs{2,2}}; % ignore juvenile
    end

    for j = 1:height(datadirs)
        filedir = fullfile(datadirs{j,1}, birdname);
        savedir = fullfile(datadirs{j,2}, birdname);

        if isfolder(filedir)
            screenings = dir(filedir);
            screenings = screenings(~ismember({screenings.name},{'.','..','.DS_Store'}));
            screenings = screenings(contains({screenings.name}, 'screening'));

            if isempty(screenings)
                warning('no screening folders found')
            end

            for k = 1:length(screenings)
                if isfolder(fullfile(savedir, screenings(k).name))
                    if rerunflag == 1
                        cd(fullfile(screenings(k).folder, screenings(k).name))
                        WhispSegScreenDir(cd, birdname, sex, 'maxcallfiles', callfilen, 'maxsongfiles', songfilen)
                      
                        movefile(fullfile(screenings(k).folder, screenings(k).name, birdname), append(fullfile(savedir, screenings(k).name), '_new'))
                    else
                        fprintf('someone already ran whisperseg on this data :) \n')
                    end
                else
                    cd(fullfile(screenings(k).folder, screenings(k).name))
                    WhispSegScreenDir(cd, birdname, sex, 'maxcallfiles', callfilen, 'maxsongfiles', songfilen)

                    if ~exist(savedir)
                        mkdir(savedir)
                    end
                    
                    movefile(fullfile(screenings(k).folder, screenings(k).name, birdname), fullfile(savedir, screenings(k).name))
                end
            end
        end
    end
end