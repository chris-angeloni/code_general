%
%function  [PSD]=ncspsd(Data,chan,df)
%
%DESCRIPTION: Power spectral density  for multi channel data from NCS file
%
%   Data	: Data structure containg all NCS channels from single 
%             recording session (obtained using READALLNCS)
%   chan	: Array of reference channels to correlate
%   df		: Spectral Resolution in Hz
%
%RETURNED VARIABLES
%
%    PSD	: Power Spectral Density Data Structure for all Channels
%
%Monty A. Escabi, March 2007
%
function  [PSD]=ncspsd(Data,chan,df)

%Choosing Window Function 
Fs=Data(1).Fs;
W=designw(df,40,Fs);
NFFT=2^nextpow2(length(W));

%Quantized Amplitude Scaling Factor
dA=Data(1).ADBitVolts;

%Computing Coherence
for k=1:length(chan)

    %PSD Estimate	
    [PSD(k).Pxx,PSD(k).Faxis]=...
        pwelch(dA*Data(chan(k)).X,W,[],NFFT,Fs);
    PSD(k).PxxdB=10*log10(PSD(k).Pxx);
    PSD(k).PxxdBre1uV=10*log10(PSD(k).Pxx/(1e-6)^2);
    PSD(k).ADChannels=...
        [Data(chan(k)).ADChannel];

end