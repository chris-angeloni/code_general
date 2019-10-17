function [Dprime]=waveformDprime (wv1, wv2)

%input waveforms: N x M (N: number of spikes, M: number of samples in each spike)
Dist1=zeros(1,size(wv1,1));
Dist2=zeros(1,size(wv2,1));

meanwv1=mean(wv1);
for i=1:size(wv1,1)
    Dist1(i)=dist(wv1(i,:),meanwv1');
end
meanwv2=mean(wv2);
for i=1:size(wv2,1)
    Dist2(i)=dist(wv2(i,:),meanwv2');
end

Dprime=2*dist(mean(wv1),mean(wv2)')/(sqrt(sum(Dist1.^2)/length(Dist1)+sum(Dist2.^2)/length(Dist2)));
