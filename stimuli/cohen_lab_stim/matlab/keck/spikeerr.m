%
%function []=spikeerr()
%
%       FILE NAME       : SPIKE ERR
%       DESCRIPTION     : 
%
%	SpikeWave	: Spike Waveform Matrix
%	ModelWave	: Model Waveform Array
%	Time		: Time Array for ModelWave
%	Fs		: Sampling Rate ( Hz )
%
function []=spikeerr(SpikeWave,ModelWave,Time,Fs)

SpikeWave=SpikeWave/1024/32;
ModelWave=ModelWave/1024/32;

N=(size(SpikeWave,1)-1)/2;
index=find(Time==0);
ModelWave=[ zeros(1,N+1-index) ModelWave zeros(1,N-(length(ModelWave)-index))];
ModelWaveA=ModelWave';
for k=1:24
	ModelWaveA=[ModelWaveA ModelWave'];
end
Err=SpikeWave-ModelWaveA;
Err=reshape(Err,1,size(SpikeWave,1).*size(SpikeWave,2));



subplot(221)
plot((-N:N)/Fs*1000,SpikeWave,'b')
hold on
plot((-N:N)/Fs*1000,ModelWaveA,'r')
axis([-N/Fs*1000 N/Fs*1000 -1 1])
hold off

subplot(222)
plot((-N:N)/Fs*1000,(SpikeWave-ModelWaveA),'b.')
axis([-N/Fs*1000 N/Fs*1000 -1 1])

subplot(223)
[N,X]=hist(Err,-1:0.05:1);
semilogy(X,N/sum(N),'ro','linewidth',2)
Std=std(Err)
Mean=mean(Err)
E=-1:0.01:1;
P=1/sqrt(2*pi*Std.^2).*exp( - (E-Mean).^2/2/Std.^2 );
hold on
semilogy(E,P,'b')
index=find(N>0);
axis([-1 1 min(N(index)/sum(N)) max([N(index)/sum(N) P])])
hold off

SNR=(SpikeWave(N+1))/Std
