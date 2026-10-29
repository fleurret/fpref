%% SET VARIABLES

birdname = 'bu95bu15';
    %'wh26wh27'; %'or25rd67'; %'yw51gr72'; %'wh37gr58' 'or87yw46'; 'wh99pu92'
savedir = 'Y:\Brainard\Analysis\Female preference';
subf = 'pref_test';

%% EVSONGANALY
        sf = uigetdir(fullfile(savedir, birdname, subf));
        cd(sf)
        
        evsonganaly
%%        
        refilterch(savedir, birdname, subf)
        
%% CONCATENATE DATA FOR R

        %% Combined subject .csv
        % saves a CSV file with all subjects for R analysis
        % concat_data(savedir, type)
        % type: 'testing', 'pref_retest', 'tempo_test'
        
        concat_data(savedir, 'pref_test')

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
        
%% GROUP LEVEL ANALYSIS

cmlist = {'rd76bk40', 'rd68rd95', 'or25rd67', 'or87yw46', 'yw51gr72',...
    'wh37gr58', 'bu95bu15', 'wh99pu92', 'wh26wh27'};
cm = [75,14,33;... % rd62bk49
    222,47,47;... % rd68rd95
    201,55,55;... % or25rd67
    234,175,59;... % or87yw46
    197,230,86;... % yw51gr72
    108,164,134;... % wh37gr58
    75,184,214;... % bu95bu15
    169,116,222;... % wh99pu92
    188,188,188]./255; % wh26wh27
savedir = 'X:\Brainard\Analysis\Female preference';
        
        %% Tempo phenotype v preferred stimulus tempo
        % plots correlation between call tempo/preferred tempo across birds
        
        tempo_corr(savedir, cmlist, cm)

        %% Tempo phenotype v stimulus selectivity
        
        selectivity_corr2(savedir, cmlist, cm)