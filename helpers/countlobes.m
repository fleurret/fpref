function countlobes(savedir, birdname)

d = cell2mat(uigetfile_n_dir(fullfile(savedir, birdname)));

sessions = dir(d);
sessions = sessions(~ismember({sessions.name},{'.','..'}));
sessions = sessions([sessions.isdir]);

% sessions
for i = 1:length(sessions)
    
    % load timestamps
    ts = dir(fullfile(sessions(i).folder, sessions(i).name, '*.txt'));
    
    if isempty(ts)
        error('Timestamps file is missing :(')
    end
    
    timestamps = readtable(fullfile(ts.folder, ts.name));
    
    sd = fullfile(sessions(i).folder, sessions(i).name);
    
    % check for cmpJamm
    if isfolder(fullfile(sd, 'cmpJamm'))
        sd = fullfile(sd, 'cmpJamm');
    end

    % load .wav for Ch1
    wavs = dir(fullfile(sd, '*.wav'));
    wavs = wavs(contains(wavs.name, 'Ch1'));
    
    for j = 1:length(wavs)
        wavfile = fullfile(wavs(j).folder, wavs(j).name);
        audio = audioread(wavfile);
    end
end
