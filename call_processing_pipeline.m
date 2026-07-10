%% SET VARIABLES

filedir = '\\macaw.ucsf.edu\users\public\mikey_public\female_preference\wh26wh27\exp_data';
birdname = 'wh26wh27'; %'or87yw46'; %'wh37gr58';
sex = 'female';

savedir = 'D:\Brainard\Analysis\Female preference\'; % base folder for save files

%% SCREENING

        %% WhisperSeg

        WhispSegScreenDir(filedir,birdname,sex)

        %% Pull files from screening day X
        % puts WhisperSeg files from all other days into a separate
        % subfolder so that PhenotypeBird doesn't run them
        
        % screeningday(filedir, savedir, birdname, day)

        screeningday(filedir, savedir, birdname, 2)

        %% PhenotypeBird

        PhenotypeBird(birdname)

        %% Check on evsonganaly

        evsonganaly
        
%% PREFERENCE TESTING

        %% Split channels
        
        SplitandSeg(filedir, savedir, birdname)
        
        %% Check to make sure everything is labeled
        
        evsonganaly
        
        %% Compare channels
        
        CompareAllJamming(savedir, birdname)
        
        %% Check again?
        
        evsonganaly
        
        