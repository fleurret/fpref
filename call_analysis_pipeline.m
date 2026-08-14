%% SET VARIABLES

birdname = 'wh26wh27';
    %'wh26wh27'; %'or25rd67'; %'rd47yw4'; %'wh37gr58' 'or87yw46'
savedir = 'D:\Brainard\Analysis\Female preference';

%% ANALYSIS
        
        %% Count number of calls for each stimulus
        % saves a CSV file with number of calls for each block/postblock in
        % each session
        % plots block/postblock calls by session;
        %       total block + postblock calls across sessions
        %       call persistence across sessions
        
        % countcalls(savedir, birdname, sv)
        % sv: 'save' a CSV file for new subject
        %     'load' previously saved CSV file if you just want plots

        countcalls(savedir, birdname, 'save')
        
        % modification for tempo preference test
%         countcalls_tempo(savedir, birdname, 'load')
        
        %% Count lobes
        % TBD
        countlobes(savedir, birdname)

        