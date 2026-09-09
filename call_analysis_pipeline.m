%% SET VARIABLES

birdname = 'or25rd67';
    %'wh26wh27'; %'or25rd67'; %'rd47yw4'; %'wh37gr58' 'or87yw46'
savedir = 'X:\Brainard\Analysis\Female preference';
subf = 'tempo_test';


%% EVSONGANALY
        sf = uigetdir(fullfile(savedir, birdname, subf));
        cd(sf)
        evsonganaly
        
%% CONCATENATE DATA FOR R

        %% Combined subject .csv
        % saves a CSV file with all subjects for R analysis
        % concat_data(savedir, type)
        % type: 'testing', 'pref_retest', 'tempo_test'
        
        concat_data(savedir, 'testing')

%% ANALYSIS -- STIMULUS PREFERENCE
        
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
        
        %% Selectivity index
        % calculates and plots selectivity index for each session/average
        % across sessions
        
        prefsi(savedir, birdname)
        
        %% dprime
        % calculates and plots d' for each session/average across sessions
        
        prefdprime(savedir, birdname)

%% ANALYSIS -- TEMPO PREFERENCE

        %% Plot session call raster
        % plots raster for block calls by session
        % callraster(savedir, birdname)
        
        callraster(savedir, birdname)
        
        %% Count normalized calls per stimulus
        % saves a CSV file with number of calls for each block/postblock in
        % each session
        % plots block/postblock calls by session;
        %       total block + postblock calls across sessions
        %       call persistence across sessions
        
        % countcalls_tempo(savedir, birdname, sv)
        % sv: 'save' a CSV file for new subject
        %     'load' previously saved CSV file if you just want plots
        
        countcalls_tempo(savedir, birdname, 'load')
        
        %% Selectivity index
        % calculates and plots selectivity index for each session/average
        % across sessions
        
        prefsi_tempo(savedir, birdname)
        
        %% dprime
        % calculates and plots d' for each session/average across sessions
        
        prefdprime_tempo(savedir, birdname)

        