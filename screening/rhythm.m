function rhythm(birdname, sex)

if isfile(fullfile(cd, 'output.mat'))
    load(fullfile(cd, 'output.mat'))
else
    warning('no output.mat file found')
end

switch sex
    case 'female'
        type = {'calls'};
    case 'male'
        type = {'calls', 'song'};
end
