%
%function  [CMT]=ncsmtcohere(Data,chan1,chan2,NW)
%
%DESCRIPTION: Multi Taper Coherence for multi channel data from NCS file
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
%             CMT(k,l).Faxis        : Frequency Axis (Hz)
%             CMT(k,l).Cxy          : Coherece (NOT squared coherence)
%             CMT(k,l).Cxyi         : Montecarlo estimate for p<0.05 confidence
%                                     interval on Cxy
%             CMT(k,l).ADChannels   : Data channels used for Cxy
%
%Monty A. Escabi, December 2006
%
function  [CMT]=ncsmtcohere(Data,chan1,chan2,NW)

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
      
		%Coherence Estimate	
		[CMT(k,l).Faxis,CMT(k,l).Cxy,P,CMT(k,l).Cxyi]=...
			cmtm(dA*Data(chan1(k)).X,dA*Data(chan2(l)).X,1/Fs,NW);
		CMT(k,l).ADChannels=...
			[Data(chan1(k)).ADChannel Data(chan2(l)).ADChannel];

        %Transposing Vectors
        CMT(k,l).Faxis=CMT(k,l).Faxis';
        CMT(k,l).Cxy=CMT(k,l).Cxy';
        CMT(k,l).Cxyi=CMT(k,l).Cxyi';
        
	end
end
