function [wvmse]=waveformmse(waveform)

%computes the mean squared error at every sample point across four channels,
%this give us a sense of how different the mean waveforms are across the
%four channels
%used to get the "input" waveforms because they tend to have uniform
%amlitudes across the four channels

wv1=mean(squeeze(waveform(:,1,:)));
wv2=mean(squeeze(waveform(:,2,:)));
wv3=mean(squeeze(waveform(:,3,:)));
wv4=mean(squeeze(waveform(:,4,:)));

wv=[wv1;wv2;wv3;wv4];   %4 by 75 

ch_var=var(wv');  %% compute energy at every channel
[MIN,j]=min(ch_var);
wv(j,:)=[]; %% ignore channel with smallest energy. this takes care when one of the electrode is probably bad

wvmean=[mean(wv);mean(wv);mean(wv)]; % the mean waveform 

wvdiff=[wv-wvmean];

wvmse=sum(sum(wvdiff.^2))/numel(wvdiff);




