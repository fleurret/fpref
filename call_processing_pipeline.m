%% SET VARIABLES

birdname = 'rd68rd95';
%'or25rd67', 'wh26wh27', 'wh37gr58', 'or87yw46', 'wh99pu92',
% 'yw51gr72', 'rd76bk40', 'bu95bu15'
sex = 'female';

% filedir = fullfile('Y:\public\screening', birdname);
% filedir = fullfile('Y:\public\adult_screening\female', birdname);
filedir = fullfile('Y:\public\mikey_public\female_preference', birdname);
savedir = 'F:\rose\analysis\female preference'; % base folder for save files
subf = 'pref_test';


%% Split channels
% select session folder(s)
% SplitandSeg(filedir, savedir, birdname, subf)

SplitandSeg(filedir, savedir, birdname, subf)

%% Compare channels
% select session folder(s)
% CompareAllJamming(savedir, birdname, subf, SnippetSubsampleDur, sqf)
% subf: subfolder name
% SnippetSubSampleDur: in s
% sqf: square and filter songs (0: no, 1: yes)

CompareAllJamming(savedir, birdname, subf, 0.02, 0)

%% Compare channels for specific files
% select individual .wav files (whichever channel for each block)
% CompareAllJamming_file(savedir, birdname, subf, SnippetSubsampleDur, sqf)
% SnippetSubSampleDur: in s
% sqf: square and filter songs
%   0: no, 1: yes

CompareAllJamming_file(savedir, birdname, subf, 0.02, 1)

%% Organize files f or export
exportfiles(savedir, birdname, subf)

%% Check for missing/mislabeled calls

evsonganaly

