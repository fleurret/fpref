function output=PhenotypeBird_dir(screen, date, birdname)

% point this at the directory from WhispSegScreenDir (e.g. the birdname), and you should be
% able to get call rates and song speeds.

i=1;
ff = fullfile(screen, date);
allfiles = dir(ff);
allfiles = allfiles(contains({allfiles.name}, '.not.mat'));

%dirflags=[allfiles.isdir];
%allfiles=dir(allfiles(dirflags)+'/*.not.mat')
motifdurs=[];
filetimes=[];
output=[];
ampval=[];

for j=1:length(allfiles);

    load(string(allfiles(j).folder) +'/'+ string(allfiles(j).name));      % load notfiles
    idx=find(diff(onsets)<2);
    onsets(idx+1)=[];
    offsets(idx+1)=[];
    labels(idx+1)=[];
    gapdurs=(offsets(2:end)-onsets(1:end-1));

    %       gapdurs=diff(onsets);
    %    isSong=checkforsong(onsets,offsets,8,350);
    shortdurs=find(gapdurs<350);
    gapdurs(shortdurs)=[];


    %    if ~isSong

    %durs(shortdurs)=[];
    %      longdurs=find(gapdurs>2500);
    longdurs=find(gapdurs>2500);
    gapdurs(longdurs)=[];
    fs=Fs;
    %      [dat fs]=audioread(fname);

    onsetsidx=onsets*fs/1000+1;
    offsetsidx=offsets*fs/1000-1;


    motifdurs=[motifdurs gapdurs'];
    songmean=1000/mean(gapdurs,"omitmissing");
    filetimes=[filetimes songmean];
    %  end;

end;

output(i).birdname=birdname;

if length(motifdurs)>80
    %[tMs, overallDist, peakTimeMs,  halfMaxWidthMs] = FilterBankKDE(motifdurs/1000);
    output(i).callratemedian=1./(median(motifdurs,"omitmissing")/1000);
    [c d]=ksdensity(motifdurs,'Bandwidth',50);
    [~,idx]=max(c);
    output(i).callratekde=1./(d(idx)/1000);
    output(i).callmotifdurs=motifdurs;
    output(i).callratemean=1./(mean(motifdurs,"omitmissing")/1000);
    output(i).callcount=length(motifdurs);
    %output(i).SmoothedKDE=1./(peakTimeMs/1000);
    %output(i).SmoothedHalfWidthPeak=1./(halfMaxWidthMs/1000);
    % f=figure;
    % hold on;
    % plot(tMs, overallDist, 'LineWidth', 1.5,'Color','red');
    % plot(d,c./max(c).*max(overallDist),'LineWidth', 1.5,'Color','blue');
    % [e f]=hist(motifdurs,max(motifdurs)/50);
    % bar(f,e./max(e).*max(overallDist));
    % plot(tMs, overallDist, 'LineWidth', 1.5,'Color','red');
    % xlabel('Time (ms)');
    % ylabel('Density (a.u.)');
    % title("KDE:"+(d(idx)/1000)+" FiltKDE(r):"+peakTimeMs+"   Median:"+output(i).callratemedian +"  HalfWidth: "+halfMaxWidthMs);
    % grid on;
    %            exportgraphics(gcf,"./Figs/"+string(birdname) + 'KDE.png','Resolution',300)
    %           close(gcf)


else
    output(i).callratekde=NaN;
    output(i).callratemedian=NaN;
    output(i).callmotifdurs=motifdurs;
    output(i).callratemean=NaN;
    output(i).SmoothedKDE=NaN;
    output(i).SmoothedHalfWidthPeak=NaN;
    output(i).callcount=NaN;
end;

output(i).callfiletimes=filetimes;
output(i).callratefilemean=mean(filetimes,"omitmissing");
output(i).callfilestd=std(filetimes,"omitmissing");
output(i).callNumElements=length(motifdurs);
%    catch
%    end;



motifdurs=[];
filetimes=[];
allbouttempos=[];

fn = fullfile(screen, append(date, '.mat'));
save(fn, "output")

%% Now Get Songs
% allfiles=dir(birdname +  "/**/song/*.not.mat");

allfiles=dir(birdname +  "/**/song/*.not.mat");
    if length(allfiles)==0
        %keyboard
    end;
    
    for j=1:length(allfiles);

        load(string(allfiles(j).folder) + "/"+ string(allfiles(j).name));      % load notfiles  

        % idx=find(diff(onsets)<2); % Nothing too short.
        % onsets(idx+1)=[];
        % offsets(idx+1)=[];
        % labels(idx+1)=[];

        idx=find((onsets(2:end)-onsets(1:end-1))<=5); % and no 5ms syls. 

        if length(idx)>0 % Merge syls that are too small. 
            onsets(idx+1)=[];
            offsets(idx)=[];
            labels(idx)=[];
        end;

        idx=find((offsets(2:end)-onsets(1:end-1))<=5); % and no 5ms gaps. 

        if length(idx)>0 % Merge gaps that are too small. 
            onsets(idx)=[];
            offsets(idx+1)=[];
            labels(idx+1)=[];
        end;

        %For poor thresholdind of audio triggers, get rid of 1st/last in
        %case full syllable not there. 

        onsets=onsets(2:end-1)  ;
        offsets=offsets(2:end-1) ; 
        labels=labels(2:end-1)  ;

        idx=find((onsets(2:end)-offsets(1:end-1)) < 500)+1; % Maxmimum gap between 'bouts'
        idxdiff=(diff(idx));       

        f = find(diff([0,idxdiff',0]==1));

        if isempty(f)
            goodidx=[];
            durs=[];
        else;

            % Get contiguous segments of syllables
            startcontigidx = f(1:2:end-1);  % Start indices
            stopcontigidx = f(2:2:end);
            contigdur = f(2:2:end)-startcontigidx; % length of contig sequences

            mincontig=10;
            killidx=find(contigdur<mincontig);
            startcontigidx(killidx)=[];
            stopcontigidx(killidx)=[];
            goodidx=[];
            durs=[];

            for k=1:length(startcontigidx)
                goodtrain=idx(startcontigidx(k):stopcontigidx(k))';
                goodidx=[goodidx goodtrain];

                startbout=onsets(goodtrain(1));
                stopbout=offsets(goodtrain(end));
                bouttempo=length(goodtrain)/((stopbout-startbout)/1000); % Syllables/S
                allbouttempos=[allbouttempos bouttempo];

                % Onset-to-onset intervals within this bout only -- computed per-bout so
                % a long syllable's own duration can never push an interval across a
                % between-bout boundary, and no cross-bout gap is ever included.
                durs=[durs reshape(diff(onsets(goodtrain)),1,[])];

            end;

        end;

       motifdurs=[motifdurs durs];
       songspeed=1./(median(durs,"omitmissing")/1000);
       filetimes=[filetimes songspeed];

    end;
    
    %output(i).birdname=birdname;
    %try

        if length(motifdurs)>300
            [c d]=ksdensity(allbouttempos,'Bandwidth',1); % in S
            [~,idx]=max(c);     
            output(i).songmotifdurs=motifdurs;
            output(i).songtempomean=mean(allbouttempos,"omitmissing");%/1000;
            output(i).songtempokde=(d(idx));            
            output(i).songtempomedian=median(allbouttempos,"omitmissing");%/1000;
            output(i).sylratemedian=1./(median(motifdurs,"omitmissing")/1000);
            output(i).sylratemean=1./(mean(motifdurs,"omitmissing")/1000);
            sortedmotifdirs=sort(motifdurs);
            sortstart=length(sortedmotifdirs)*0.75;
            sortstart=ceil(sortstart);
            output(i).songupperquartile=1./(median(sortedmotifdirs(sortstart:end))/1000);
            sortend=length(sortedmotifdirs)*0.25;
            sortend=ceil(sortend);            
            output(i).songlowerquartile=1./(median(sortedmotifdirs(1:sortend))/1000);
            output(i).songquartileratio=output(i).songupperquartile./output(i).songlowerquartile;
            output(i).songcount=length(motifdurs);
            output(i).allbouttempos=allbouttempos;
            output(i).filetimes=filetimes;
        else
            output(i).songmotifdurs=NaN;
            output(i).songtempomean=NaN;
            output(i).songtempokde=NaN;
            output(i).songtempomedian=NaN;
            output(i).songtempomedian=NaN;
            output(i).sylratemedian=NaN;
            output(i).sylratemean=NaN;
            output(i).songupperquartile=NaN; %median(sortedmotifdirs(sortstart:end));
            output(i).songlowerquartile=NaN;
            output(i).songcount=NaN;
            output(i).allbouttempos=NaN;
            output(i).filetimes=NaN;
            output(i).songquartileratio=NaN;
        end;        
    
                    
   % catch
  %  end;
