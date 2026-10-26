%% SET VARIABLES
subjs = {'bu95bu15'};
sex = 'female';

        %% WhisperSeg

        for i = 1:length(subjs)
            birdname = subjs{i};

            % filedir = fullfile('Y:\public\screening', birdname);
            % if isfolder(filedir)
            %     cd(filedir)
            %     WhispSegScreenDir(filedir, birdname, sex)
            % end

            filedir = fullfile('Y:\public\adult_screening', birdname);
            if isfolder(filedir)
                cd(filedir)
                WhispSegScreenDir(filedir, birdname, sex)
            end
        end
        
        %% PhenotypeBird

        for i = 1:length(subjs)
            birdname = subjs{i};
            % 
            filedir = fullfile('Y:\public\Juvenile_Call_Screening\', birdname);
            if isfolder(filedir)
                cd(fullfile(filedir, 'screening_1')
                PhenotypeBird_lite(birdname)
            end

            filedir = fullfile('Y:\public\adult_screening\female', birdname);
            if isfolder(filedir)
                fprintf('Adult\n')
                cd(filedir)
                PhenotypeBird_lite(birdname)
            end
        end
       
        
        %% PhenotypeBird each day
        
        % subjs = {'yw51gr72'}; %, 'rd10pu97'};

        for i = 1:length(subjs)
            birdname = subjs{i};
            filedir = fullfile('Y:\public\screening\', birdname);
            phenotype_by_day(filedir, savedir, birdname, 'juv')
        end

        %% Check on evsonganaly

        evsonganaly