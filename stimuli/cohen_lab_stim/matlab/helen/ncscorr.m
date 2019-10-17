%
%function  [R]=ncscorr(Data,chan1,chan2,delay)
%
%DESCRIPTION: Correlates multi channel data from NCS file
%
%   Data	: Data structure containg all NCS channels from single 
%		  recording session (obtained using READALLNCS)
%   chan1	: Array of reference channels to correlate
%   chan2 	: Array of secondary channesl to correlate
%   delay	: Time lag for correlation (msec)
%
%RETURNED VARIABLES
%
%   R		: Correlation Data Structure for all Channels
%
%Monty A. Escabi, Feb. 2004
%
function  [R]=ncscorr(Data,chan1,chan2,delay)

%Computing Delay in Samples
Ndelay=ceil(Data(1).Fs*delay/1000);

%Quantized Amplitude Scaling Factor
dA=Data(1).ADBitVolts;

%Computing Cross Correlations
for k=1:length(chan1)

	for l=1:length(chan2)
		R(k,l).Corr=...
			xcorr(dA*Data(chan1(k)).X,dA*Data(chan2(l)).X,Ndelay);
		R(k,l).ADChannels=...
			[Data(chan1(k)).ADChannel Data(chan2(l)).ADChannel];
		R(k,l).Tau=(-Ndelay:Ndelay)/Data(1).Fs;
	end

end
