function CompareAllJamming_file(savedir, birdname, SnippetSubsampleDur, sqf)

% sometimes you just want to run one session

% select individual .wav files (whichever channel for each block)
% CompareAllJamming_file(savedir, birdname, SnippetSubsampleDur, sqf)
% SnippetSubSampleDur: in s
% sqf: square and filter songs (0: no, 1: yes)

        
%load Burdies;
%E:\Data\DyadTest\female_male\dyad4-gr2bu30pk99rd81_Box1
% \2024\_06\_30\20240630091431.wav

cd(fullfile(savedir, birdname, 'testing'))

[fn, d] = uigetfile({'*.wav'}, 'Select file(s)',...
    'MultiSelect', 'on');

if ischar(fn)
    fn = {fn};
end

for i = 1:length(fn)
    
    targetfile = fullfile(d, fn(i));
    
    % which stim
    sn = split(fn(i), '-');
    snx = contains(sn, 'Ch');
    bn = split(sn(snx), '.');
    
    % which channel is this
    if contains(targetfile, 'Ch1')
        wavfile1 = targetfile;
        
        % find other channel
        matchfn = strrep(fn(i), 'Ch1', 'Ch2');
        wavfile2 = fullfile(d, matchfn);
        
        % get matching not.mats
        fil1 = fullfile(d, append(fn(i), '.not.mat'));
        fil2 = fullfile(d, append(matchfn, '.not.mat'));
        
    elseif contains(targetfile, 'Ch2')
        wavfile2 = targetfile;
        
        % find other channel
        matchfn = strrep(fn(i), 'Ch2', 'Ch1');
        wavfile1 = fullfile(d, matchfn);
        
        % get matching not.mats
        fil1 = fullfile(d, append(matchfn, '.not.mat'));
        fil2 = fullfile(d, append(fn(i), '.not.mat'));
    end
    
    fprintf('Processing %s %s %s... \n', birdname, sn{2}, bn{1})
    
    try
        NotMat1=load(cell2mat(fil1));
    catch ME
        error('File not found. Did you run SplitandSeg on the files in this folder?')
    end
    
    NotMat2=load(cell2mat(fil2));
    
    try
        [audiochannel1 fs]=audioread(cell2mat(wavfile1));
        [audiochannel2 fs2]=audioread(cell2mat(wavfile2));
    end
    
    % is there a delay?
    [sims, lags] = xcorr(audiochannel1, audiochannel2);
    [~, idx] = max(abs(sims));
    delay = lags(idx);
    
    if delay > 0
        audiochannel2 = [zeros(delay, 1); audiochannel2(1:end-delay)];
    elseif delay < 0
        delay = abs(delay);
        audiochannel2 = [audiochannel2(delay+1:end); zeros(delay,1)];
    end
    
    rawaudiochannel2=bandpass(audiochannel2, [300 10000], fs);
    rawaudiochannel1=bandpass(audiochannel1, [300 10000], fs2);
    
    audiochannel1rms=rms(audiochannel1);
    audiochannel2rms=rms(audiochannel2);
    
    % normalize by RMS
    audiochannel2=audiochannel2./(audiochannel2rms/audiochannel1rms);
    
    assert(fs==fs2);
    
    len = round(fs*25/1000);
    h = ones(1,len)/len;
        
    if sqf == 1
        % Square + Filter songs.
        squared_song = rawaudiochannel1.^2;
        audiochannel1 = conv(h, squared_song);
        offset = round((length(audiochannel1)-length(rawaudiochannel1))/2);
        audiochannel1=audiochannel1(1+offset:length(rawaudiochannel1)+offset);
        
        squared_song = rawaudiochannel2.^2;
        audiochannel2 = conv(h, squared_song);
        offset = round((length(audiochannel2)-length(rawaudiochannel2))/2);
        audiochannel2=audiochannel2(1+offset:length(rawaudiochannel2)+offset);
    end
    
    trashtrace1=zeros(1,length(audiochannel1)+1000);
    trashtrace2=zeros(1,length(audiochannel2)+1000);
    onset1idx=ceil(NotMat1.onsets.*(fs/1000))+1;
    onset2idx=ceil(NotMat2.onsets.*(fs/1000))+1;
    
    offset1idx=floor(NotMat1.offsets.*(fs/1000))-1;
    offset2idx=floor(NotMat2.offsets.*(fs/1000))-1;
    
    for iii=1:length(onset1idx)
        trashtrace1(onset1idx(iii):offset1idx(iii))=1;
    end
    
    for iii=1:length(onset2idx)
        trashtrace2(onset2idx(iii):offset2idx(iii))=1;
    end
    
    allonsets=[NotMat1.onsets; NotMat2.onsets];
    alloffsets=[NotMat1.offsets; NotMat2.offsets];
    allonsets=floor(allonsets.*(fs/1000));
    alloffsets=ceil(alloffsets.*(fs/1000));
    outputs=zeros(length(audiochannel1),1);
    
    idx=find(allonsets==0);
    allonsets(idx)=1;
    alloffsets(idx)=1;
    offsets1=[];
    offsets2=[];
    onsets2=[];
    onsets1=[];
    
    idx=find(alloffsets>length(audiochannel1));
    allonsets(idx)=[];
    alloffsets(idx)=[];

    for j=1:length(allonsets)
        
        snipstart=allonsets(j);
        snipstop=alloffsets(j);
        
        SnipDur=(snipstop-snipstart)/fs/SnippetSubsampleDur;
        
        SnippetSubsample=floor(SnipDur);
        if SnippetSubsample==0
            SnippetSubsample=1;
        end
        
        chan1mask=trashtrace1(snipstart:snipstop);
        chan2mask=trashtrace2(snipstart:snipstop);
        
        snippet1=audiochannel1(snipstart:snipstop)./32657;
        snippet2=audiochannel2(snipstart:snipstop)./32657;
        
        if snipstop-snipstart>530 %1060 % At least 40ms of vocal data
            
            subsnipstart=1;
            subsnipstop=floor(length(snippet1)/SnippetSubsample);
            Snipchunx=subsnipstop; %length(subsnipstart:snipstop);
            
            subsnip1=snippet1(subsnipstart:subsnipstop);
            subsnip2=snippet2(subsnipstart:subsnipstop);
            
            subchan1mask=chan1mask(subsnipstart:subsnipstop);
            subchan2mask=chan2mask(subsnipstart:subsnipstop);
            
            if mean(subchan1mask)>0
                SubSnip1Vocalization=true;
            else
                SubSnip1Vocalization=false;
            end
            
            if mean(subchan2mask)>0
                SubSnip2Vocalization=true;
            else
                SubSnip2Vocalization=false;
            end
            
            % display(SubSnip1Vocalization)
            % display(SubSnip2Vocalization)
            
            if SubSnip1Vocalization && ~SubSnip2Vocalization % Only Ch 1 has a vocalization
                outputs(snipstart:snipstart+subsnipstop)=1;
                previouspeaksnip=1;
                subsniponsets1=[allonsets(j)];
                subsnipoffsets1=[];
                subsniponsets2=[];
                subsnipoffsets2=[];
            elseif ~SubSnip1Vocalization && SubSnip2Vocalization % Only Ch 2 has a vocalization
                outputs(snipstart:snipstart+subsnipstop)=-1;
                previouspeaksnip=2;
                subsniponsets1=[];
                subsnipoffsets1=[];
                subsniponsets2=[allonsets(j)];
                subsnipoffsets2=[];
            elseif rms(subsnip1)>rms(subsnip2) && SubSnip1Vocalization  % Both have a vocalization
                outputs(snipstart:snipstart+subsnipstop)=1;
                previouspeaksnip=1;
                subsniponsets1=[allonsets(j)];
                subsnipoffsets1=[];
                subsniponsets2=[];
                subsnipoffsets2=[];
            elseif rms(subsnip2)>rms(subsnip1) && SubSnip2Vocalization
                outputs(snipstart:snipstart+subsnipstop)=-1;
                previouspeaksnip=2;
                subsniponsets1=[];
                subsnipoffsets1=[];
                subsniponsets2=[allonsets(j)];
                subsnipoffsets2=[];
            end
            % First part.
            
            for sniploopindex=1:SnippetSubsample-2
                
                subsnipstart=Snipchunx*sniploopindex;
                subsnipend=subsnipstart+Snipchunx;
                snipidx=subsnipstart:subsnipend;
                
                subsnip1=snippet1(snipidx);
                subsnip2=snippet2(snipidx);
                
                subchan1mask=chan1mask(snipidx);
                subchan2mask=chan2mask(snipidx);
                
                
                if mean(subchan1mask)>0
                    SubSnip1Vocalization=true;
                else
                    SubSnip1Vocalization=false;
                end
                
                if mean(subchan2mask)>0
                    SubSnip2Vocalization=true;
                else
                    SubSnip2Vocalization=false;
                end
                %
                % display(SubSnip1Vocalization)
                % display(SubSnip2Vocalization)
                
                if SubSnip1Vocalization && ~SubSnip2Vocalization % Only Ch 1 has a vocalization
                    outputs(snipstart+snipidx)=1;
                    if previouspeaksnip==2 % If we changed, then update onsets/offsets;
                        subsniponsets1=[subsniponsets1 allonsets(j)+Snipchunx*sniploopindex];
                        subsnipoffsets2=[subsnipoffsets2 allonsets(j)+Snipchunx*sniploopindex];
                        % jamonsets1=[jamonsets1 allonsets(j)+Snipchunx*sniploopindex];
                        % jamoffsets1=[jamoffsets1 alloffsets(j)+Snipchunx*sniploopindex];
                        %   display('Jam!')
                    end
                    previouspeaksnip=1;
                elseif ~SubSnip1Vocalization && SubSnip2Vocalization % Only Ch 2 has a vocalization
                    outputs(snipstart+snipidx)=-1;
                    if previouspeaksnip==1 % If we changed, then update onsets/offsets;
                        subsniponsets2=[subsniponsets2 allonsets(j)+Snipchunx*sniploopindex];
                        subsnipoffsets1=[subsnipoffsets1 allonsets(j)+Snipchunx*sniploopindex];
                        % jamonsets2=[jamonsets2 allonsets(j)+Snipchunx*sniploopindex];
                        % jamoffsets2=[jamoffsets2 alloffsets(j)+Snipchunx*sniploopindex];
                        %   display('Jam!')
                    end
                    previouspeaksnip=2;
                elseif rms(subsnip1)>rms(subsnip2) && SubSnip1Vocalization  % Both have a vocalization
                    %    display("1>2")
                    outputs(snipstart+snipidx)=1;
                    if previouspeaksnip==2 % If we changed, then update onsets/offsets;
                        subsniponsets1=[subsniponsets1 allonsets(j)+Snipchunx*sniploopindex];
                        subsnipoffsets2=[subsnipoffsets2 allonsets(j)+Snipchunx*sniploopindex];
                        % jamonsets1=[jamonsets1 allonsets(j)+Snipchunx*sniploopindex];
                        % jamoffsets1=[jamoffsets1 alloffsets(j)+Snipchunx*sniploopindex];
                        %   display('Jam!')
                    end
                    previouspeaksnip=1;
                    
                elseif rms(subsnip2)>rms(subsnip1) && SubSnip2Vocalization
                    %      display("2>1")
                    outputs(snipstart+snipidx)=-1;
                    if previouspeaksnip==1 % If we changed, then update onsets/offsets;
                        subsniponsets2=[subsniponsets2 allonsets(j)+Snipchunx*sniploopindex];
                        subsnipoffsets1=[subsnipoffsets1 allonsets(j)+Snipchunx*sniploopindex];
                        % jamonsets2=[jamonsets2 allonsets(j)+Snipchunx*sniploopindex];
                        % jamoffsets2=[jamoffsets2 alloffsets(j)+Snipchunx*sniploopindex];
                        %  display('Jam!')
                    end
                    previouspeaksnip=2;
                end
                
                
                
            end
            
            % Tack on final offsets
            if previouspeaksnip==1
                subsnipoffsets1=[subsnipoffsets1 alloffsets(j)];
            elseif previouspeaksnip==2
                subsnipoffsets2=[subsnipoffsets2 alloffsets(j)];
            end
            
            % subsnipoffsets=[subsnipoffsets alloffsets(j)];
            onsets1=[onsets1 subsniponsets1];
            offsets1=[offsets1 subsnipoffsets1];
            onsets2=[onsets2 subsniponsets2];
            offsets2=[offsets2 subsnipoffsets2];
            
        else % Short snippet <40 ms, don't subdivide, just whoever is louder.
            
            subsnip1=snippet1;%(subsnipstart:snipstop);
            subsnip2=snippet2;%(subsnipstart:snipstop);
            
            if rms(subsnip1)>rms(subsnip2)
                %    display("1>2")
                outputs(allonsets(j):allonsets(j)+snipstop)=1;
                onsets1=[onsets1 allonsets(j)];
                offsets1=[offsets1 alloffsets(j)];
            elseif rms(subsnip2)>rms(subsnip1)
                %      display("2>1")
                outputs(allonsets(j):allonsets(j)+snipstop)=-1;
                onsets2=[onsets2 allonsets(j)];
                offsets2=[offsets2 alloffsets(j)];
            end
        end
        
        
    end
    
    
    %     keyboard
    
    %outputs(NotMat1.onsets:NotMat1.offsets)=1
    %outputs(NotMat2.onsets:NotMat2.offsets)=-1
    Jam=false;
    
    file1=char(fil1);
    
    outputs(1)=0; % make sure all calls start
    outputs(end-5:end)=0; %make sure all calls end
    
    % find all the bits where either outputs is +1 or -1;
    [onsets1 offsets1]=getThresholds(outputs); % Upgoing
    [onsets2 offsets2]=getThresholds(outputs.*-1); %Downgoing;
    
    jamonsets1=[];
    jamoffsets1=[];
    
    %    if Jam==true
    %       keyboard
    %   end;
    Jam=false;
    
    for kk=1:length(onsets1)-1
        if outputs(onsets1(kk)-1)==-1 % Jamming;       This was +1 at onset but the previous was -1, so bird 1 jammed bird2;
            jamonsets1=[jamonsets1 onsets1(kk)];
            jamoffsets1=[jamoffsets1 offsets1(kk)];
            disp('Jam')
            %      keyboard
        end
    end
    
    badonset=[];
    badoffset=[];
    
    % Check for Jams and correct onsets/offsets to ensure that calls
    % are incorrectly split by short jams from the othe bird
    %
    for kk=1:length(onsets1)-1
        if outputs((offsets1(kk))+1)==-1 && outputs((onsets1(kk+1)-1))==-1 && (((onsets1(kk+1)-offsets1(kk))/44100) < 0.05) % also less than 150ms apart to merge.
            badonset=[badonset kk+1];
            badoffset=[badoffset kk];
            disp('Merge')
        end
    end
    %
    %
    onsets1(badonset)=[];
    offsets1(badoffset)=[];
    
    jamonsets2=[];
    jamoffsets2=[];
    badonset=[];
    badoffset=[];
    
    for kk=1:length(onsets2)-1
        if outputs(onsets2(kk)-1)==1 % Jamming;       This was +1 at onset but the previous was -1, so bird 1 jammed bird2;
            jamonsets2=[jamonsets2 onsets2(kk)];
            jamoffsets2=[jamoffsets2 offsets2(kk)];
            disp('Jam')
            Jam=true;
            %    keyboard
        end
    end
    
    for kk=1:length(onsets2)-1
        if outputs((offsets2(kk))+1)==1 && outputs((onsets2(kk+1)-1))==1 && ((onsets2(kk+1)-offsets2(kk))/44100 < 0.100)
            
            badonset=[badonset kk+1];
            badoffset=[badoffset kk];
            disp('Merge')
            Jam=true;
            %       keyboard
        end;
    end;
    
    onsets2(badonset)=[];
    offsets2(badoffset)=[];
    
    %         audioout=[pad; rawaudiochannel1; pad];
    %         audioout(:,2)=[pad; rawaudiochannel2; pad];
    %         audioout(:,3)=[pad; outputs(1:length(rawaudiochannel1)); pad];
    
    audioout=[rawaudiochannel1];
    audioout(:,2)=[rawaudiochannel2];
    audioout(:,3)=[outputs(1:length(rawaudiochannel1))];
    
    mingap=0.03*fs;
    % if i==15
    %     keyboard
    % end;
    idx=find((onsets1(2:end)-offsets1(1:end-1))< mingap );
    onsets1(idx+1)=[];
    offsets1(idx)=[];
    
    tempout=zeros(length(rawaudiochannel1),1);
    for kk=1:length(onsets1)
        tempout(onsets1(kk):offsets1(kk))=1;
    end
    
    %         audioout(:,4)=[pad; tempout(1:length(rawaudiochannel1)); pad];
    audioout(:,4)=[tempout(1:length(rawaudiochannel1))];
    
    idx=find((onsets2(2:end)-offsets2(1:end-1))< mingap );
    onsets2(idx+1)=[];
    offsets2(idx)=[];
    
    tempout=zeros(length(rawaudiochannel1),1);
    for kk=1:length(onsets2)
        tempout(onsets2(kk):offsets2(kk))=1;
    end
    
    %         audioout(:,5)=[pad; tempout(1:length(rawaudiochannel1)); pad];
    audioout(:,5)=[tempout(1:length(rawaudiochannel1))];
    
    tempout=zeros(length(rawaudiochannel1),1);
    for kk=1:length(jamonsets1)
        tempout(jamonsets1(kk):jamoffsets1(kk))=1;
    end
    
    %         audioout(:,6)=[pad; tempout(1:length(rawaudiochannel1)); pad];
    audioout(:,6)=[tempout(1:length(rawaudiochannel1))];
    
    tempout=zeros(length(rawaudiochannel1),1);
    for kk=1:length(jamonsets2)
        tempout(jamonsets2(kk):jamoffsets2(kk))=1;
    end
    
    %         audioout(:,7)=[pad; tempout(1:length(rawaudiochannel1)); pad];
    audioout(:,7)=[tempout(1:length(rawaudiochannel1))];
    
    NotMat1.onsets=sort((onsets1))/(fs/1000);
    NotMat1.offsets=sort((offsets1))/(fs/1000);
    
    NotMat2.onsets=sort((onsets2))/(fs/1000);
    NotMat2.offsets=sort((offsets2))/(fs/1000);
    
    % make sure number of labels match for evsonganaly
    % right now we dont really care what the labels are
    if length(NotMat1.labels) ~= length(NotMat1.onsets)
        NotMat1.labels = NotMat1.labels(1:length(NotMat1.onsets));
    end
    
    try
        [issongfile1 iscallfile1 iscontig1]=checkforsong(NotMat1.onsets,NotMat1.offsets,4,500);
        [issongfile2 iscallfile2 iscontig2]=checkforsong(NotMat2.onsets,NotMat2.offsets,4,500);
    catch
        keyboard
    end
    
    % #if strcmp(fil1{2}(1:end-8),'20240702203848.wav')
    % if strcmp(fil1{2}(1:end-8),'20240702093956.wav')
    %
    %     keyboard
    % end;
    
    %         if ((length(onsets2)+length(onsets1)>2)) % Are there at least 2 calls? Otherwise, nothing to analyse.
    
    if ~isfolder("./cmpJamm/Ch1")
        mkdir(fullfile('./cmpJamm/', 'Ch1'))
    end
    
    if ~isfolder("./cmpJamm/Ch2")
        mkdir(fullfile('./cmpJamm/', 'Ch2'))
    end
    
    fil1 = cell2mat(fil1);
    fil2 = cell2mat(fil2);
    
    % save separate audios
    wf1 = split(wavfile1, '\');
    wf2 = split(wavfile2, '\');
    audiowrite(cell2mat(fullfile(d, 'cmpJamm', 'Ch1', wf1(end))), audioout, fs);
    audiowrite(cell2mat(fullfile(d, 'cmpJamm', 'Ch2', wf2(end))), audioout, fs2);

    if (iscontig1 | iscontig2)
%         audiowrite(cell2mat(fullfile(d, 'cmpJamm', fn(i))), audioout, fs2);
%         save(cell2mat(fullfile(d, 'cmpJamm', append(fn(i), '.not.mat'))),"NotMat1","NotMat2","jamonsets1","jamonsets2",'jamoffsets2','jamoffsets1')
%         
        f1 = split(fil1, '\');
        f1 = cell2mat(f1(end));
        fn1 = append(f1(1:end-8), '.songs.not.mat');
        f2 = split(fil2, '\');
        f2 = cell2mat(f2(end));
        fn2= append(f2(1:end-8), '.songs.not.mat');
        
        save(fullfile(d, 'cmpJamm', 'Ch1', fn1), '-struct', 'NotMat1')
        save(fullfile(d, 'cmpJamm', 'Ch2', fn2), '-struct', 'NotMat2')
        
    else %if (iscallfile1 && iscallfile2)
        f1 = split(fil1, '\');
        f1 = cell2mat(f1(end));
        fn1 = append(f1(1:end-8), '.calls.not.mat');
        f2 = split(fil2, '\');
        f2 = cell2mat(f2(end));
        fn2= append(f2(1:end-8), '.calls.not.mat');
        
        save(fullfile(d, 'cmpJamm', 'Ch1', fn1), '-struct', 'NotMat1')
        save(fullfile(d, 'cmpJamm', 'Ch2', fn2), '-struct', 'NotMat2')
    end
end

if exist("badoutputs")
    save('badoutputs.mat',"badoutputs");
end

end

function [onsets offsets] = getThresholds(data)
idx=find(data<0);
data(idx)=0;
temp=diff(data);
onsets=find(temp==1)+1;
offsets=find(temp==-1)+1;
end