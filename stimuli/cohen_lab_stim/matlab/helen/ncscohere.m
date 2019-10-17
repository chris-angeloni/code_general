%
%function  [C]=ncscohere(Data,chan1,chan2,df)
%
%DESCRIPTION: Coherence for multi channel data from NCS file
%
%   Data	: Data structure containg all NCS channels from single 
%		  recording session (obtained using READALLNCS)
%   chan1	: Array of reference channels to correlate
%   chan2 	: Array of secondary channesl to correlate
%   df		: Spectral Resolution in Hz
%
%RETURNED VARIABLES
%
%    C		: Coherence Data Structure for all Channels
%
%Monty A. Escabi, Aug. 24, 2004 (Edit Dec 27 2006)
%
function  [C]=ncscohere(Data,chan1,chan2,df)

%Choosing Window Function 
Fs=Data(1).Fs;
W=designw(df,40,Fs);
NFFT=2^nextpow2(length(W));

%Quantized Amplitude Scaling Factor
dA=Data(1).ADBitVolts;

%Computing Coherence
for k=1:length(chan1)
	for l=1:length(chan2)

		%Coherence Estimate	
		[C(k,l).Cxy,C(k,l).Faxis]=...
			cohere(dA*Data(chan1(k)).X,dA*Data(chan2(l)).X,NFFT,Fs,W);
		C(k,l).ADChannels=...
			[Data(chan1(k)).ADChannel Data(chan2(l)).ADChannel];

        %Converting Coherence from Coherence^2
        C(k,l).Cxy=sqrt(C(k,l).Cxy);                %Monty Escabi, Dec 27 2006
        
	end
end
