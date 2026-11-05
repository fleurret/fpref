%% SET VARIABLES
subjs = {'or14pu27'};

sex = 'male';
callfilen = 500;
songfilen = 250;

% sex = 'female';
% callfilen = 500;
% songfilen = 0;

jdir = 'Y:\public\screening'; % juvenile screening data folder
jsavedir = 'Y:\public\Juvenile_Call_Phenotyping'; % juvenile screening output folder
adir = 'Y:\public\adult_screening'; % adult screening data folder
asavedir = 'Y:\public\adult_screening_whisperseg_output'; % adult screening output folder

datadirs = {jdir, jsavedir; adir, asavedir};

        %% WhisperSeg

        whisperseg_wrapper(subjs, sex, datadirs, callfilen, songfilen, 1)
        
        %% PhenotypeBird

        phenotypebird_wrapper(subjs, datadirs, 'full')
       
        %% PhenotypeBird each day
        
        subjs =  {'pk46bu17'}; %, 'rd10pu97'};

        for i = 1:length(subjs)
            birdname = subjs{i};
            filedir = fullfile(jsavedir, birdname, 'screening_1');
            phenotype_by_day(filedir, savedir, birdname, 'juv')
        end

        %% Check on evsonganaly

        evsonganaly