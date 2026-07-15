function SplitandSeg(filedir, savedir, birdname)

d = uigetfile_n_dir(filedir);

for f = 1:length(d)
    fnames = dir(cell2mat(fullfile(d(f), '*.wav')));
    
    % which session
    dd = split(d(f), '\');
    session = cell2mat(dd(contains(dd, 'session')));
    
    if ~isfolder(fullfile(savedir, birdname))
        mkdir(fullfile(savedir, birdname))
    end

    try
        cd(fullfile(savedir, birdname, 'testing', session))
    catch ME
        if strcmp(ME.identifier,'MATLAB:cd:NonExistentFolder')
           mkdir(fullfile(savedir, birdname, 'testing', session))
           cd(fullfile(savedir, birdname, 'testing', session))
        end
    end
    
    for i = 1:length(fnames)
        [dat fs] = audioread(fullfile(fnames(i).folder,fnames(i).name));
        Ch1Dat = dat(:,1);
        Ch2Dat = dat(:,3);
        Ch1Name = replace(fnames(i).name,'.wav','Ch1.wav');
        Ch2Name = replace(fnames(i).name,'.wav','Ch2.wav');
        audiowrite(Ch1Name,Ch1Dat,fs)
        audiowrite(Ch2Name,Ch2Dat,fs)
        WhispSegFile(Ch1Name)
        WhispSegFile(Ch2Name)
    end
    
    % copy over the OnsetLog also
    ts = dir(fullfile(filedir, session, '*.txt'));
    ts = ts(contains([ts.name], 'OnsetLog'));
    
    copyfile(fullfile(ts.folder, ts.name), fullfile(savedir, birdname, 'testing', session, ts.name))
end