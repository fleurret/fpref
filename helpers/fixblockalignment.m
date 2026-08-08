filedir = 'Y:\public\mikey_public\female_preference\or87yw46\tempo_test\session_1';
onsetlog = 'Y:\public\mikey_public\female_preference\or87yw46\tempo_test\session_1\or87yw46_OnsetLog20260807100207.txt';
params = 'Y:\public\mikey_public\female_preference\or87yw46\tempo_test\session_1\or87yw46_Params20260807100207.txt';
stimfolder = 'Y:\public\mikey_public\female_preference\or87yw46\tempo_test\stimuli';

o = readtable(onsetlog);
p = readtable(params, 'ReadVariableNames',false);
[mats, wavs] = filelist(filedir);

pbwavs = wavs(contains({wavs.name}, 'Post'));
bwavs = wavs(~contains({wavs.name}, 'Post'));
% pbmats = mats(contains({mats.name}, 'Post'));
% bmats = mats(~contains({mats.name}, 'Post'));

for i = 1:length(bwavs)
    
    % load wavs
    [wf1, fs1] = audioread(fullfile(bwavs(i).folder, bwavs(i).name));
    [wf2, fs2] = audioread(fullfile(pbwavs(i).folder, pbwavs(i).name));
    
    % concat
    wf3 = [wf1; wf2];
    
    % match params
    P = p(i,:);

    [stimwav, sfs] = audioread(cell2mat(fullfile(stimfolder, P.Var10, P.Var11)));
    stimdur = duration(seconds(length(stimwav)/sfs), 'format', 'hh:mm:ss.SSS');

    parts = split(pbwavs(i).name, '-');
    block = parts{3};

    % find timestamps
    if strcmp(block, 'Block0')
        blockstart = duration(seconds(0), 'format', 'hh:mm:ss.SSS');
        onset = o.Var2(1);
        offset = o.Var2(2);
    else
        idx = strcmp(o.Var4, block);
        brow = find(idx == 1);
        blockstart = o.Var2(brow);
        onset = o.Var2(brow+1);
        offset = o.Var2(brow+2);
    end

    jitter = seconds(onset-blockstart)*2;
    blockdur = seconds(stimdur) + jitter;

    B = wf3(1:blockdur*fs1, 1:3);
    PB = wf3(blockdur*fs1 + 1:end, 1:3);
    
    % save
    if ~isfolder(fullfile(filedir, 'fixed'))
        mkdir(fullfile(filedir, 'fixed'))
    end
    
    fn = fullfile(filedir, 'fixed');
    audiowrite(fullfile(fn, bwavs(i).name), B, fs1);
    audiowrite(fullfile(fn, pbwavs(i).name), PB, fs2);
end

function [mats, wavs] = filelist(filedir)

d = dir(filedir);
d = d(~ismember({d.name},{'.','..','fixed'}));
mats = d(contains({d.name}, '.not.mat'));
wavs = d(~contains({d.name}, '.not.mat') & contains({d.name}, '.wav'));

end
