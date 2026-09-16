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

    for j=1:length(allfiles);
        %display(length(allfiles))
        load(string(allfiles(j).folder) +'/'+ string(allfiles(j).name));      % load notfiles  
        %idx=find(diff(onsets) < 300);

        idx=find(diff(onsets)<2);
        onsets(idx+1)=[];
        offsets(idx+1)=[];
        labels(idx+1)=[];

        % 
        % onsets=onsets(2:end-1);
        % offsets=offsets(2:end-1); 
        % labels=labels(2:end-1);

     
        durs=(diff(onsets));
        shortdurs=find(durs<450);

          if isempty(shortdurs)              
           
           %durs(shortdurs)=[];   
           longdurs=find(durs>2500);
           %durs(longdurs)=[];
    
           motifdurs=[motifdurs durs'];
           songmean=1000/mean(durs,"omitmissing");
           filetimes=[filetimes songmean]; 
          end;

    end;
    
        output(i).birdname=birdname;
%        tempfind(motifdurs==NaN)
    %try
        if length(motifdurs)>20

            output(i).callmedian=median(motifdurs,"omitmissing")/1000;
            [c d]=ksdensity(motifdurs,'Bandwidth',50);
            [~,idx]=max(c);
            output(i).callkde=d(idx)/1000;
            output(i).callmotifdurs=motifdurs;
            output(i).callmean=mean(motifdurs,"omitmissing")/1000;
            
            output(i).callcount=length(motifdurs);
        else
            output(i).callkde=NaN;
            output(i).callmedian=NaN;
            output(i).callmotifdurs=NaN;
            output(i).callmean=NaN;
            
            output(i).callcount=NaN;
        end;

        output(i).callfiletimes=filetimes;
        output(i).callfilemean=mean(filetimes,"omitmissing");
        output(i).callfilestd=std(filetimes,"omitmissing");
        output(i).callNumElements=length(motifdurs);
%    catch
%    end;

fn = fullfile(screen, append(date, '.mat'));
save(fn, "output")


    motifdurs=[];    
    filetimes=[];
 %% Now Get Songs   
    % allfiles=dir(birdname +  "/**/song/*.not.mat");

        fd = 'E:\rose\stimuli';
    allfiles=dir(fullfile(fd, '*.not.mat'));

    if length(allfiles)==0
        %keyboard
    end;
    
    for j=1:length(allfiles);

        load(string(allfiles(j).folder) + "/"+ string(allfiles(j).name));      % load notfiles  
        %idx=find(diff(onsets) < 300);

        idx=find(diff(onsets)<2); % Nothing too short.
        onsets(idx+1)=[];
        offsets(idx+1)=[];
        labels(idx+1)=[];

        idx=find((onsets(2:end)-onsets(1:end-1))<=5); % and no 5ms syls. 

        if length(idx)>0 % Merge gaps that are too small. 
            onsets(idx+1)=[];
            offsets(idx)=[];
            labels(idx)=[];
        end;
% 
%         idx=find((offsets(2:end)-offsets(1:end-1))<=0);
%         idx=idx-1;
%         if length(idx)>0
%             onsets(idx)=[];
%             offsets(idx)=[];
%             labels(idx)=[];
%             display(i)
%       %  else
% 
%      %       i=i+1;        
%         end;   
        %For poor thresholdind of audio triggers, get rid of 1st/last in
        %case full syllable not there. 

        onsets=onsets(2:end-1)  ;
        offsets=offsets(2:end-1) ; 
        labels=labels(2:end-1)  ;

        idx=find(diff(offsets(2:end)-onsets(1:end-1)) < 350); % Maxmimum gap between 'bouts'
        idxdiff=(diff(idx));       

        f = find(diff([0,idxdiff',0]==1));

        if isempty(f)            
            goodidx=[];
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

        for k=1:length(startcontigidx)
            goodidx=[goodidx idx(startcontigidx(k):stopcontigidx(k))'];
        end;

        end;

       durs=(diff(onsets(goodidx))); % Find all the onsets=onsets;
     %  find(diff(offsets(2:end)-onsets(1:end-1)) < 350)
    %   longdurs=find(durs>350); % remove the ones between bouts
       longdurs=find((offsets(goodidx(2:end))-onsets(goodidx(1:end-1))) > 350);
       durs(longdurs)=[offsets(longdurs)-onsets(longdurs)];   
       motifdurs=[motifdurs durs'];
       songspeed=1000/median(durs,"omitmissing");
       filetimes=[filetimes songspeed]; 

    end;
    
    %output(i).birdname=birdname;
    try

        if length(motifdurs)>300
            [c d]=ksdensity(motifdurs,'Bandwidth',50);
            [~,idx]=max(c);     
            output(i).songmotifdurs=motifdurs;
            output(i).songmean=mean(motifdurs,"omitmissing")/1000;
            output(i).songkde=1./(d(idx)/1000);            
            output(i).songmedian=median(motifdurs,"omitmissing")/1000;
            sortedmotifdirs=sort(motifdurs);
            sortstart=length(sortedmotifdirs)*0.8;
            sortstart=ceil(sortstart);
            output(i).songuppers=median(sortedmotifdirs(sortstart:end));
            output(i).songcount=length(motifdurs);
        else
            output(i).songmotifdurs=NaN;
            output(i).songmean=NaN;
            output(i).songkde=NaN;
            output(i).songmedian=NaN;
            output(i).songuppers=NaN; %median(sortedmotifdirs(sortstart:end));
            output(i).songcount=NaN;
        end;        
        output(i).songmotifdurs=motifdurs;
        output(i).songmean=1000/mean(motifdurs,"omitmissing");
   
        output(i).songmedian=1000/median(motifdurs,"omitmissing");
        output(i).songfiletimes=filetimes;
        output(i).songfilemean=mean(filetimes,"omitmissing");
        output(i).songfilestd=std(filetimes,"omitmissing");
        output(i).songNumElements=length(motifdurs);
                    
    catch
    end;




