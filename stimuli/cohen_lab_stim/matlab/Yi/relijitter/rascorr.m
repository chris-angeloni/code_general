function [Rab,Raa]=rascorr(RASTER,Fsd)

T=RASTER(1).T;
[RAS,Fs]=rasterexpand(RASTER,Fsd,T);
L=size(RAS,2);
M=size(RAS,1);

PSTH=sum(RAS,1);
F=fft(PSTH);
R=real(ifft(F.*conj(F)))/Fsd/T;
F=fft(RAS,[],2);
Rdiag=real(ifft(F.*conj(F),[],2)/Fsd/T);
Rshuf=(R-sum(Rdiag))/(M*(M-1));

Rab = Rshuf;
Raa = sum(Rdiag)/M;
    