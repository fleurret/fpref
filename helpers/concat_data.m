function concat_data(savedir, type)

d = uigetfile_n_dir(savedir);

if isfile(fullfile(savedir, append(type, '_', 'concat.csv')))
    D = readtable(fullfile(savedir, append(type, '_', 'concat.csv')));
    subjects = cellfun(@(x) erase(x, append(savedir, '\')), d, 'UniformOutput', false);
    es = unique(D.Subject);
    
    for i = 1:length(es)
        subjects = subjects(~contains(subjects, es(i)));
    end
    
    if isempty(subjects)
        error('No new data to add :)')
    end
else
    D = [];
    subjects = cellfun(@(x) erase(x, append(savedir, '\')), d, 'UniformOutput', false);
end

for i = 1:length(subjects)
    try
        subjfolder = fullfile(savedir, subjects(i), type);
        subjfile = fullfile(subjfolder, append(subjects(i), '_calls.csv'));
        sd = readtable(cell2mat(subjfile));
    catch ME
        error('Subject %s has no %s data :(')
    end
    
    switch type
        case 'testing'
            svar = 'Stimulus';
            var = 'NumCalls';
        case 'pref_retest'
            svar = 'Stimulus';
            var = 'NumCalls';
        case 'tempo_test'
            sd.NormCalls = sd.NumCalls./sd.TimeS;
            svar = 'StimNum';
            var = 'NormCalls';
    end
    
    % only blocks
    sd = sd(strcmp(sd.BlockType, 'Block'),:);
    SD = [];
    
    % calculate SI and dprime
    sessions = sort(unique(sd.Session));
    for j = 1:length(sessions)
        sessiondata = sd(sd.Session == sessions(j),:);
        
        switch type
            case 'tempo_test'
                sessiondata = sortrows(sessiondata, ["Stimulus", "GapChange"], 'descend');
        end
        
        stimuli = unique(sessiondata.(svar), 'stable');
        Ms = mean(sessiondata.(var));

        si = nan(1, length(stimuli));
        dprime = nan(1, length(stimuli));
        
        for k = 1:length(stimuli)
            stimulusdata = sessiondata(strcmp(sessiondata.(svar), stimuli(k)),:);
            otherstims = sessiondata(~strcmp(sessiondata.(svar), stimuli(k)),:);
            
            a = stimulusdata.(var);
            b = otherstims.(var);
        
            if isnan(stimulusdata.(var)/Ms)
                si(k) = 1;
            else
                si(k) = stimulusdata.(var)/Ms;
            end
            
            if isnan(calcd(a, b))
                dprime(k) = 0;
            else
                dprime(k) = calcd(a, b);
            end
        end
        
        sessiondata.SI = si';
        sessiondata.dprime = dprime';
        
        SD = [SD; sessiondata];
    end
    
    D = [D; SD];
end

sf = fullfile(savedir, append(type, '_', 'concat.csv'));
fprintf('Saving file ...')
writetable(D, sf);
fprintf(' done\n')



function d = calcd(a, b)
d = (2*(mean(a)-mean(b)))/(sqrt((std(a)^2) + (std(b)^2)));