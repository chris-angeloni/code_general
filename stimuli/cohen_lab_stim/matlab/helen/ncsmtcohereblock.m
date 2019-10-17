%
%function  [CMT]=ncsmtcohereblock(Data,chan1,chan2,NW)
%
%DESCRIPTION: Multi Taper Coherence for multi channel data from NCS file. 
%             Uses blocked data which is not concatenated into a single stream. 
%             Data is read with WAV2NCSDATABLOCKED.
%
%   Data    : Data structure containg all NCS channels from single 
%             recording session (obtained using READALLNCS)
%   chan1   : Array of reference channels to correlate
%   chan2   : Array of secondary channesl to correlate
%   NW      : Number of tapers to use (Default==8)
%
%RETURNED VARIABLES
%
%   CMT     : Multi Taper Coherence Data Structure for all Channels
%             CMT.Faxis - Frequency Axis
%             CMT(k,l).Block(m).Cxy - Coherence for mth block
%             CMT(k,l).Block(m).Cxyi - Confidence interval on coherence
%             CMT(k,l).ADChannels - Channels used for coherence
%
%Monty A. Escabi, Decmber 2006
%
function  [CMT]=ncsmtcohereblock(Data,chan1,chan2,NW)

%Input Arguments
if nargin<4
    NW=8;
end

%Sampling Rate 
Fs=Data(1).Fs;

%Quantized Amplitude Scaling Factor
dA=Data(1).ADBitVolts;

%Computing Coherence
for k=1:length(chan1)

	for l=1:length(chan2)
        
        for m=1:length(Data(1).Block)

		%Coherence Estimate	
		[CMT(k,l).Faxis,CMT(k,l).Block(m).Cxy,CMT(k,l).Block(m).Cxyi]=...
			cmtm(dA*Data(chan1(k)).Block(m).X,dA*Data(chan2(l)).Block(m).X,1/Fs,NW);
		CMT(k,l).ADChannels=...
			[Data(chan1(k)).ADChannel Data(chan2(l)).ADChannel];

        %Transposing Vectors
        CMT(k,l).Faxis=CMT(k,l).Faxis';
        CMT(k,l).Block(m).Cxy=CMT(k,l).Block(m).Cxy';
        CMT(k,l).Block(m).Cxyi=CMT(k,l).Block(m).Cxyi';
        end
	end
end