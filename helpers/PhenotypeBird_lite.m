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