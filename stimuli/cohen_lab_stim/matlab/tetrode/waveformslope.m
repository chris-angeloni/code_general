function [wvslope,p2pvalue,p2pwidth]=waveformslope(waveform)

%computes the slope/rate of change of waveform at each channel
%obtained by peak to peak value devided by peak to peak width
 

wv1=mean(squeeze(waveform(:,1,:)));
wv2=mean(squeeze(waveform(:,2,:)));
wv3=mean(squeeze(waveform(:,3,:)));
wv4=mean(squeeze(waveform(:,4,:)));
wvmean=cat(1,wv1,wv2,wv3,wv4);

[MAX,I]=max(wv1);
[MIN,J]=min(wv1);
ch1p2p=MAX-MIN;
ch1width=abs(J-I);
ch1slope=ch1p2p/ch1width;

[MAX,I]=max(wv2);
[MIN,J]=min(wv2);
ch2p2p=MAX-MIN;
ch2width=abs(J-I);
ch2slope=ch2p2p/ch2width;

[MAX,I]=max(wv3);
[MIN,J]=min(wv3);
ch3p2p=MAX-MIN;
ch3width=abs(J-I);
ch3slope=ch3p2p/ch3width;

[MAX,I]=max(wv4);
[MIN,J]=min(wv4);
ch4p2p=MAX-MIN;
ch4width=abs(J-I);
ch4slope=ch4p2p/ch4width;

wvslope=[ch1slope ch2slope ch3slope ch4slope];
p2pvalue=[ch1p2p ch2p2p ch3p2p ch4p2p];
p2pwidth=[ch1width ch2width ch3width ch4width];


