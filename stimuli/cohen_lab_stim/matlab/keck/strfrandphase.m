%
%function [STRFr]=strfrandphase(STRF)
%
%   FILE NAME   : STRF RAND PHASE
%   DESCRIPTION : Randomizes the phase spectrum of an STRF but the
%                 magnitude spectrum is preserved. This yields a random
%                 STRF with identical magnitude spectrum.
%
%   STRF        : Input STRF
%
%RETURNED VARIABLES
%
%	STRFr       : Random phase STRF
%
%	(C) Monty A. Escabi, July 2007
%
function [STRFr]=strfrandphase(STRF)

%Phase shifting the STRF spectrum
NFFT1=size(STRF,1);
NFFT2=size(STRF,2);
MTF=fftshift(fft2(STRF));

if NFFT1/2==floor(NFFT1/2) & NFFT2/2==floor(NFFT2/2)
    
    N1=NFFT1/2-1;
    N2=NFFT2/2-1;
    P=exp(i*2*pi*rand(N1,NFFT2-1));
    PDC=[exp(i*2*pi*rand(1,N2))];
    PDC=[PDC 1 conj(fliplr(PDC))];, 
    P=[P; PDC; conj(fliplr(flipud(P)))];
    Ptop=[exp(i*2*pi*rand(1,N2))];, Ptop=[Ptop 1 conj(fliplr(Ptop))];
    Pleft=[exp(i*2*pi*rand(1,N1))];, Pleft=[1 Pleft 1 conj(fliplr(Pleft))]';
    P=[Pleft [Ptop; P]];
    STRFr=ifft2(ifftshift(P.*MTF));
    
elseif NFFT1/2==floor(NFFT1/2)
     
    N1=NFFT1/2-1;
    N2=(NFFT2-1)/2;
    P=exp(i*2*pi*rand(N1,NFFT2));
    PDC=[exp(i*2*pi*rand(1,N2))];
    PDC=[PDC 1 conj(fliplr(PDC))];  
    P=[P; PDC; conj(fliplr(flipud(P)))];
    Ptop=[exp(i*2*pi*rand(1,N2))];, Ptop=[Ptop 1 conj(fliplr(Ptop))];
    P=[Ptop; P];
    STRFr=ifft2(ifftshift(P.*MTF));
    
elseif NFFT2/2==floor(NFFT2/2)
    
    N1=(NFFT1-1)/2;
    N2=NFFT2/2-1;
    P=exp(i*2*pi*rand(N1,NFFT2-1));
    PDC=[exp(i*2*pi*rand(1,N2))];
    PDC=[PDC 1 conj(fliplr(PDC))];, 
    P=[P; PDC; conj(fliplr(flipud(P)))];
    Pleft=[exp(i*2*pi*rand(1,N1))];, Pleft=[Pleft 1 conj(fliplr(Pleft))]';
    P=[Pleft P];
    STRFr=ifft2(ifftshift(P.*MTF));
    
else

    N1=(NFFT1-1)/2;
    N2=(NFFT2-1)/2;
    P=exp(i*2*pi*rand(N1,NFFT2));
    PDC=[exp(i*2*pi*rand(1,N2))];
    PDC=[PDC 1 conj(fliplr(PDC))];    
    P=[P; PDC; conj(fliplr(flipud(P)))];
    STRFr=ifft2(ifftshift(P.*MTF));
    
end