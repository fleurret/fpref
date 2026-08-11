function exportfiles(savedir, birdname, subf)

fprintf('Collecting for export...')

if ~isfolder(fullfile(savedir, birdname, subf, 'export'))
    mkdir(fullfile(savedir, birdname, subf, 'export'))
end

d = uigetfile_n_dir(fullfile(savedir, birdname, subf));

for f = 1:length(d)
    parts = split(d(f), '\');
    session = cell2mat(parts(end));

    if ~isfolder(fullfile(savedir, birdname, subf, 'export', session))
        mkdir(fullfile(savedir, birdname, subf, 'export', session))
        mkdir(fullfile(savedir, birdname, subf, 'export', session, 'cmpJamm'))
    end

    expf = fullfile(savedir, birdname, subf, 'export', session);
    copyfile(fullfile(cell2mat(d(f)), 'cmpJamm', 'Ch1'), fullfile(expf, 'cmpJamm', 'Ch1'))

    ts = dir(fullfile(cell2mat(d(f)), '*.txt'));
    o = ts(contains({ts.name}, 'OnsetLog'));
    p = ts(contains({ts.name}, 'Params'));
    
    copyfile(fullfile(o.folder, o.name), fullfile(expf, o.name))
    copyfile(fullfile(p.folder, p.name), fullfile(expf, p.name))
end

fprintf('done \n')
