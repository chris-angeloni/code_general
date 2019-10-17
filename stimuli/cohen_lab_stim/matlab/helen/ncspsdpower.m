%
%function  [P]=ncspsdpower(PSD,f1,f2)
%
%DESCRIPTION: Computes the significant area in the coherence between f1 and f2
%
%   PSD     : Powes spectral density Structure
%   f1      : Lower frequency for area estimate
%   f2      : Upper frequency for area estimate
%
%RETURNED VARIABLES
%
%   P       : Power Data Structure
%             
%Monty A. Escabi, March. 13, 2007 (Edit Jan 2009)
%
function  [P]=ncspsdpower(PSD,f1,f2)

%Computing Power
%Note that Units of X are in V so I normalize by 1e-6 to computed dBre1uV
df=PSD(1,1).Faxis(2)-PSD(1,1).Faxis(1);
for k=1:length(PSD)
        index=find(PSD(k).Faxis>=f1 & PSD(k).Faxis<=f2);
        P(k).Power=sum(PSD(k).Pxx(index))*df;
        P(k).CentroidFrequency=sum(PSD(k).Faxis(index).*( PSD(k).Pxx(index)/sum(PSD(k).Pxx(index)))); %Escabi, Jan 2009
        i=find(PSD(k).Pxx(index)==min(max(PSD(k).Pxx(index))));
        P(k).PeakFrequency=Faxis(index(i)); %Escabi, Jan 2009
        P(k).PowerdBre1uV=10*log10(P(k).Power/(1e-6)^2);
        P(k).PowerdB=10*log10(P(k).Power);
        P(k).ADChannels=PSD(k).ADChannels;
	P(k).f1=f1;
	P(k).f2=f2;
end

%Notes on PWELCH versus PSD
%
%PWELCH is normalized in units of Power per frequency
%PSD is normalized as simply units of power
%
%To compute total energy (according to Parseval's Theorem):
%
%PWELCH: 
%
%   sum(PWelch)*df = var(X) where df=Fs/NFFT
%
%PSD: 
%
%   sum(Pxx)/(NFFT/2) - var((X)
%