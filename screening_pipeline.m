%% SET VARIABLES
subjs = {'wh53pu44', 'bu7bu97', 'bu10bu100'};

% sex = 'male';
% callfilen = 500;
% songfilen = 250;

sex = 'female';
callfilen = 500;
songfilen = 0;

jdir = 'Y:\public\screening'; % juvenile screening data folder
jsavedir = 'Y:\public\Juvenile_Call_Phenotyping'; % juvenile screening output folder
adir = 'Y:\public\adult_screening'; % adult screening data folder
asavedir = 'Y:\public\adult_screening_whisperseg_output'; % adult screening output folder

datadirs = {jdir, jsavedir; adir, asavedir};

        %% WhisperSeg

        whisperseg_wrapper(subjs, sex, datadirs, callfilen, songfilen, 0)
        
        %% PhenotypeBird

        phenotypebird_wrapper(subjs, datadirs, 'lite', 0)
       
        %% PhenotypeBird each day
        
        subjs =  {'pk46bu17'}; %, 'rd10pu97'};

        for i = 1:length(subjs)
            birdname = subjs{i};
            filedir = fullfile(jsavedir, birdname, 'screening_1');
            phenotype_by_day(filedir, savedir, birdname, 'juv')
        end

        %% Rhythm

        % rhythm(subjs, sex, datadirs, 0)

        savedir = 'F:\rose\analysis\female preference';
        call_similarity(subjs, datadirs, savedir, 2, 0)
       

        %% Check on evsonganaly

        evsonganaly