function refilterch(savedir, birdname, subf)
% for files run before filterch update oops!

fprintf('Refiltering... ')

d = uigetfile_n_dir(fullfile(savedir, birdname, subf));

for i = 1:length(d)
    
    % ch1 folder
    cf = fullfile(d(i).folder, d(i).name, 'cmpJamm', 'Ch1');
    fnames = dir(cell2mat(fullfile(cf, '*.wav')));

    for j = 1:length(fnames)
        ffn = fullfile(fnames(j).folder, fnames(j).name);
        [wav, fs] = audioread(ffn);
        Ch1 = wav(:,1);
        Ch2 = wav(:,3);

        filterCh1 = filterch(Ch1, Ch2);
        wav(:,1) = filterCh1;

        audiowrite(ffn, wav, fs)
    end
end

fprintf('done \n')