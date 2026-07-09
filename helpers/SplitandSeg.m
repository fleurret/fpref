fnames=dir('*.wav')
for i=1:length(fnames)
    [dat fs]=audioread(fnames(i).name);
    Ch1Dat=dat(:,1);
    Ch2Dat=dat(:,3);
    Ch1Name=replace(fnames(i).name,'.wav','Ch1.wav');
    Ch2Name=replace(fnames(i).name,'.wav','Ch2.wav');
    audiowrite(Ch1Name,Ch1Dat,fs)
    audiowrite(Ch2Name,Ch2Dat,fs)
    WhispSegFile(Ch1Name)
    WhispSegFile(Ch2Name)
end;