%
%function  [C]=ncscohereblock(Data,chan1,chan2,df)
%
%DESCRIPTION: Coherence for multi channel data from NCS file. Uses blocked
%             data which is not concatenated into a single stream. Data is
%             read with WAV2NCSDATABLOCKED.
%
%   Data    : Data structure containg all NCS channels from single
%             recording session (obtained using WAV2NCSDATABLOCKED)
%   chan1   : Array of reference channels to correlate
%   chan2   : Array of secondary channesl to correlate
%   df      : Spectral Resolution in Hz
%
%RETURNED VARIABLES
%
%   C       : Coherence Data Structure for all Channels
%             C.Faxis - Frequency Axis
%             C(k,l).Block(m).Cxy - Coherence for mth block
%             C(k,l).ADChannels - Channels used for coherence
%
%Monty A. Escabi, Decmber 2006
%
function  [C]=ncscohereblock(Data,chan1,chan2,df)

%Choosing Window Function 
Fs=Data(1).Fs;
W=designw(df,40,Fs);
NFFT=2^nextpow2(length(W));

%Quantized Amplitude Scaling Factor
dA=Data(1).ADBitVolts;

%Computing Coherence
for k=1:length(chan1)
	for l=1:length(chan2)
        for m=1:length(Data(1).Block)
            
        %Coherence Estimate	
		[C(k,l).Block(m).Cxy,C(k,l).Faxis]=...
			cohere(dA*Data(chan1(k)).Block(m).X,dA*Data(chan2(l)).Block(m).X,NFFT,Fs,W);
		C(k,l).ADChannels=...
			[Data(chan1(k)).ADChannel Data(chan2(l)).ADChannel];

        %Converting Coherence from Coherence^2
        C(k,l).Block(m).Cxy=sqrt(C(k,l).Block(m).Cxy);                %Monty Escabi, Dec 27 2006
        
        end
	end
end