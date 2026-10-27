%% SET VARIABLES
subjs = {'bk12wh43', 'rd34rd61', 'or6pu10', 'gr22bu12', 'or7pu10', 'pu7bk39', 'bu85bu97'};
sex = 'male';

jdir = 'Y:\public\screening'; % juvenile screening data folder
jsavedir = 'Y:\public\Juvenile_Call_Phenotyping'; % juvenile screening output folder
adir = 'Y:\public\adult_screening'; % adult screening data folder
asavedir = 'Y:\public\adult_screening_whisperseg_output'; % adult screening output folder

datadirs = {jdir, jsavedir; adir, asavedir};

        %% WhisperSeg

        whisperseg_wrapper(subjs, sex, datadirs)
        
        %% PhenotypeBird

        phenotypebird_wrapper(subjs, datadirs, 'lite')
       
        %% PhenotypeBird each day
        
        % subjs = {'yw51gr72'}; %, 'rd10pu97'};

        for i = 1:length(subjs)
            birdname = subjs{i};
            filedir = fullfile('Y:\public\screening\', birdname);
            phenotype_by_day(filedir, savedir, birdname, 'juv')
        end

        %% Check on evsonganaly

        evsonganaly