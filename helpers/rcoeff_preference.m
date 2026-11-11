function rcoeff_preference(savedir)

[f, ff] = uigetfile('*.csv',...
    'Select a file', savedir);
R = readtable(fullfile(ff, f));

if ismember('avgSI', R.Properties.VariableNames)
    error('already added :)')
end

% match 
P = readtable(fullfile(savedir, 'female_phenotypes.csv'));

id = erase(f, '_rcoeff.csv');

target = unique(R.Subject);
s = split(target, '_');
target = s(:,1);
        
switch id
    case 'females'
        P = sortrows(P, 'Subject');
        P = P(ismember(P.Subject, target),:);
    case 'moms'
        P = sortrows(P, 'Mom');
        P = P(ismember(P.Mom, target),:);
    case 'dads'
        P = sortrows(P, 'Dad');
        P = P(ismember(P.Dad, target),:);
end

subjects = P.Subject;

newData = [];

for i = 1:length(subjects)
    if isfile(fullfile(savedir, subjects(i), 'testing', append(subjects(i), '_calls.csv')))
        prefdata = readtable(cell2mat(fullfile(savedir, subjects(i), 'testing', append(subjects(i), '_calls.csv'))));
    elseif isfile(fullfile(savedir, subjects(i), 'pref_test', append(subjects(i), '_calls.csv')))
        prefdata = readtable(cell2mat(fullfile(savedir, subjects(i), 'pref_test', append(subjects(i), '_calls.csv'))));
    else
        prefdata = [];
    end
    
    if isempty(prefdata)
        continue
    else
        r = R(contains(R.Subject, target(i)),:);
        D = prefdata(strcmp(prefdata.BlockType, 'Block'),:);
        
        sessions = sort(unique(D.Session));
        stims = sort(unique(D.Stimulus));
        SI = [];
        Dprime = [];
        
        for j = 1:length(sessions)
            sessiondata = D(D.Session == sessions(j),:);

            % selectivity index
            Ms = mean(sessiondata.NumCalls);
            sems = std(sessiondata.NumCalls)/sqrt(height(sessiondata));
            
            Y1 = nan(1, length(stims));
            Y2 = nan(1, length(stims));
            
            for k = 1:length(stims)
                stimulusdata = sessiondata(contains(sessiondata.Stimulus, stims(k)),:);
                otherstims = sessiondata(~contains(sessiondata.Stimulus, stims(k)),:);
                
                if ~isempty(stimulusdata)
                    
                    % selectivity index
                    if isnan(stimulusdata.NumCalls/Ms)
                        Y1(k) = 1;
                    else
                        Y1(k) = stimulusdata.NumCalls/Ms;
                    end
                    
                    % dprime
                    a = stimulusdata.NumCalls;
                    b = otherstims.NumCalls;
                    
                    if isnan(calcd(a, b))
                        Y2(k) = 0;
                    else
                        Y2(k) = calcd(a, b);
                    end
                end
            end
            
            SI = [SI; Y1];
            Dprime = [Dprime; Y2];
        end
    end
    
    si = mean(SI);
    dprime = mean(Dprime);
    
    r.Subject = repelem(subjects(i), height(r))';
    r.avgSI = si(1:6)';
    r.avgdprime = dprime(1:6)';
    
    newData = [newData; r];
end

% save
fprintf('Saving %s ...', f)
writetable(newData, fullfile(savedir, f))
fprintf(' done\n')

function d = calcd(a, b)
d = (2*(mean(a)-mean(b)))/(sqrt((std(a)^2) + (std(b)^2)));
