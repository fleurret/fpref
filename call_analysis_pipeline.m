%% SET VARIABLES

filedir = '\\macaw.ucsf.edu\users\public\mikey_public\female_preference\wh37gr58\screen';
birdname = 'or87yw46'; %'wh37gr58';
sex = 'female';

savedir = 'D:\Brainard\Analysis\Female preference';

%% PROCESSING

        %% WhisperSeg

        WhispSegScreenDir(filedir,birdname,sex)

        %% Pull files from screening day X
        % puts WhisperSeg files from all other days into a separate
        % subfolder so that PhenotypeBird doesn't run them
        
        % screeningday(filedir, savedir, birdname, day)

        screeningday(filedir, savedir, birdname, 2)

        %% PhenotypeBird

        PhenotypeBird(birdname)

        %% evsonganaly

        evsonganaly

%% ANALYSIS
        
        %% Count number of calls for each stimulus
        % saves a CSV file with number of calls for each block/postblock in
        % each session; plots calls by session; plots total calls across
        % sessions
        
        % countcalls(savedir, birdname, sv)
        % sv: 'save' a CSV file for new subject
        %     'load' previously saved CSV file if you just want plots

        countcalls(savedir, birdname, 'load')
