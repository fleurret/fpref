function output=PhenotypeBird_lite(birdname)

% point this at the directory from WhispSegScreenDir (e.g. the birdname), and you should be
% able to get call rates and song speeds. 

    i=1;
    allfiles=dir(string(birdname) + '/**/calls/*.not.mat');

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

%    catch
%    end;


sf = dir(string(birdname));
fn = fullfile(sf(1).folder, 'output.mat');
save(fn, "output")

% plot hist
F = figure;
F.Position = [0, 0, 500, 300];
ax = gca;
cm = [69,129,92]./255;

set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 1.5);
set(findobj(ax,'-property','FontName'),...
    'FontSize', 9,...
    'FontName','Arial')

histogram(output.callmotifdurs/1000, 100,...
    'FaceColor', cm,...
    'EdgeColor', 'none')

title(birdname)
xlabel(ax, 'Call ITI (s)',...
    'FontWeight', 'bold')
ylabel(ax,'Frequency',...
    'FontWeight', 'bold')
set(ax,'Layer', 'Top')