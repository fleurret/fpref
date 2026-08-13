[wav, fs] = audioread("Y:\public\mikey_public\female_preference\or87yw46\tempo_test\session_1\or87yw4620260807100507-Stim10-Block2.wav");
Ch1 = wav(:,1);
Ch2 = wav(:,3);

test = filterch(Ch1, Ch2);
fn = 'Y:\public\mikey_public\female_preference\or87yw46\tempo_test\test.wav';
audiowrite(fn,test,fs)