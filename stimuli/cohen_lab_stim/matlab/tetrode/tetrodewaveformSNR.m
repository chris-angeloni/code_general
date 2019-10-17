function [wvSNR]=tetrodewaveformSNR(waveform)

%waveform:N x 4 x M (N: number of spikes, M: number of samples in each
%spike)
SNR=zeros(1,4);

wv1=squeeze(waveform(:,1,:));
wv2=squeeze(waveform(:,2,:));
wv3=squeeze(waveform(:,3,:));
wv4=squeeze(waveform(:,4,:));

if nargin<2
    SNR(1)=waveformSNR(wv1);
    SNR(2)=waveformSNR(wv2);
    SNR(3)=waveformSNR(wv3);
    SNR(4)=waveformSNR(wv4);
else
    SNR(1)=waveformSNR(wv1);
    SNR(2)=waveformSNR(wv2);
    SNR(3)=waveformSNR(wv3);
    SNR(4)=waveformSNR(wv4);
end
[wvSNR]=SNR;