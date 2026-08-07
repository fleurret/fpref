filedir = 'D:\Brainard\Analysis\Female preference\or87yw46\tempo_test\session_1\cmpJamm\Ch1';
onsetlog = 'D:\Brainard\Analysis\Female preference\or87yw46\tempo_test\session_1\or87yw46_OnsetLog20260807100207.txt';

o = readtable(onsetlog);
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
    
    parts = split(pbwavs(i).name, '-');
    stim = parts{2};
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
    
    blockdur = seconds(offset-blockstart);
    B = wf3(1:blockdur*fs1);
    PB = wf3(blockdur*fs1 + 1:end);
    
    % save
    if ~isfolder(fullfile(filedir, 'fixed'))
        mkdir(fullfile(filedir, 'fixed'))
    end
    
    fn = fullfile(filedir, 'fixed');
    audiowrite(ffn(fn, bwavs(i).name), B, fs1);
    audiowrite(ffn(fn, pbwavs(i).name), PB, fs2);
end

function [mats, wavs] = filelist(filedir)

d = dir(filedir);
d = d(~ismember({d.name},{'.','..'}));
mats = d(contains({d.name}, '.not.mat'));
wavs = d(~contains({d.name}, '.not.mat'));

end
