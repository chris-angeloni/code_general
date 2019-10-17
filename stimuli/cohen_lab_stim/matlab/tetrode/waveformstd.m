function [wvstd]=waveformstd(waveform)

%computes the mean of standard deviation at every sample point across four channels,
%this give us a sense of how different the mean waveforms are across the
%four channels
%used to get the "input" waveforms because they tend to have uniform
%amlitudes across the four channels

wv1=mean(squeeze(waveform(:,1,:)));
wv2=mean(squeeze(waveform(:,2,:)));
wv3=mean(squeeze(waveform(:,3,:)));
wv4=mean(squeeze(waveform(:,4,:)));

wvmean=[wv1;wv2;wv3;wv4];   %4 by 75 

ch_var=var(wvmean');  %% compute energy at every channel
[MIN,j]=min(ch_var);

wvmean(j,:)=[]; %% ignore channel with smallest energy. this takes care when one of the electrode is probably bad

wvstd=mean(std(wvmean));


