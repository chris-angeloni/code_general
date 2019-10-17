%
%function [DFIR] = dtf2fir(Faxis,DTF,M)
%
%	FILE NAME 	: DTF 2 FIR
%	DESCRIPTION : Converts DTF data from Tolin to FIR filter
%
%	Faxis       : Frequency Axis
%   DTFr        : Right DTF
%   DTFl        : Left DTF
%   El          : Elevation Array
%   Az          : Azimuth Array
%   Beta        : Kaiser window order
%	M           : Number of FIR filter coefficients
%
%RETURNED VARIABLES
%   DFIR        : Data structure containing all of the FIR DTFs
%                   .Hl - Left FIR coefficients
%                   .Hr - Right FIR coefficients
%                   .Az - Azimuth
%                   .El - Elevation
%
% (C) Monty A. Escabi, June 2008
%
function [DFIR] = dtf2fir(Faxis,DTFr,DTFl,El,Az,Beta,M)

%Generating Smooting Kaiser Window
W=kaiser(M,Beta)';
Fs=max(Faxis)/(length(Faxis)-1)*length(Faxis);

%Converting to finite impulse response filter
%Note that Tolin applied log() to DTF data
NFFT=size(DTFr,3);
for k=1:length(Az)
    for l=1:length(El)
        Hl=real(fftshift(ifft(reshape(exp(DTFl(k,l,:)),1,NFFT))));
        Hr=real(fftshift(ifft(reshape(exp(DTFr(k,l,:)),1,NFFT))));    
        DFIR(k,l).Hl=W.*Hl(NFFT/2+1-M/2:NFFT/2+M/2);
        DFIR(k,l).Hr=W.*Hr(NFFT/2+1-M/2:NFFT/2+M/2);
        DFIR(k,l).Az=Az(k);
        DFIR(k,l).El=El(l);
    end
end

%Plotting Data
N=1024*8;
Az=Az(1:4:length(Az));
El=El(1:4:length(El));
for k=1:length(Az)
    for l=1:length(El)
   
        subplot(length(Az),length(El),k+(l-1)*length(Az))
        plot(Faxis,20*log10(exp(reshape(DTFr(k,l,:),1,length(Faxis)))))
        hold on
        Hr=20*log10(abs(fft(DFIR(k,l).Hr,N)));
        plot((0:N-1)/N*Fs,Hr,'r')
        axis([0 Fs/2 min(Hr) max(Hr)])
        
    end
end