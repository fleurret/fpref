function refilterch(savedir, birdname, subf)
% for files run before filterch update oops!

fprintf('Refiltering... ')

d = uigetfile_n_dir(fullfile(savedir, birdname, subf));

for i = 1:length(d)
    
    % ch1 folder
    
    if length(d) > 1
        cf = fullfile(d(i).folder, d(i).name, 'cmpJamm', 'Ch1');
    else
        cf = fullfile(d, 'cmpJamm', 'Ch1');
    end
    
    fnames = dir(cell2mat(fullfile(cf, '*.wav')));
    fnames = fnames(~contains({fnames.name}, 'PostBlock'));
    
    for j = 1:length(fnames)
        ffn = fullfile(fnames(j).folder, fnames(j).name);
        [wav, fs] = audioread(ffn);
        
        s = size(wav); 
        
        if s(2) == 5
            continue
        else
            Ch1 = wav(:,1);
            Ch2 = wav(:,2);
            
            filterCh1 = filterch(Ch1, Ch2);
            nwav = [filterCh1, wav(:, 1:4)];
            
            audiowrite(ffn, nwav, fs)
        end
    end
end

fprintf('done \n')