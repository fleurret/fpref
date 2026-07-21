%% SET VARIABLES

birdname = 'rd47yw4';
savedir = 'D:\Brainard\Analysis\Female preference';

%% ANALYSIS
        
        %% Count number of calls for each stimulus
        % saves a CSV file with number of calls for each block/postblock in
        % each session; plots block/postblok calls by session; plots total 
        % block + postblock calls across sessions
        
        % countcalls(savedir, birdname, sv)
        % sv: 'save' a CSV file for new subject
        %     'load' previously saved CSV file if you just want plots

        countcalls(savedir, birdname, 'load')
        
        %% Count lobes
        
        countlobes(savedir, birdname)

        