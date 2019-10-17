%function  [h]=mff(gtw,beta,Nfft)
%
%	FILE NAME 	: MFF
%	DESCRIPTION 	: MAX FLAT FILTER Design
%	gtw		: Transition width.
%	Beta		: wc
%	Nfft		: FFT length for increasing plot resolution
%	h		: Impulse response
%
function [h]=mff(gtw,beta,Nfft)

%Finding the necessary parameters
ML=ceil( (pi/gtw)^2);
p=(1+cos(beta))/2;

%Finding filter order
Mp=ML:2*ML;
Kp=round(p*Mp);
P=Kp./Mp;
PN=P/p;

Pmin=min(abs(PN-1));
j=1;
while Pmin~=abs(PN(j)-1)
	j=j+1;	
end

K=Kp(j);
L=Mp(j)-Kp(j);
M=Mp(j)-1
naxis=0:L-1;

%Frequency Axis
waxis=0:2^(ceil(log10(M)/log10(2)))*2-1;
waxis=waxis./2^(ceil(log10(M)/log10(2)));

%Filter Frequency Response
for j=2:2:2*length(waxis),
	H(j/2)=(cos(waxis(j/2)*pi/2)).^(2*K)  .* sum( d1(K,naxis).*(sin(waxis(j/2)*pi/2)).^(2*naxis) ) ;
end
H=H.*exp(i*(-waxis*pi));
w=(0:length(H)-1)/length(H)*2*pi;

%Filter Impulse Response
h1=ifft(H);
h2=zeros(1,length(h1));
h2(length(h1)/2-1:length(h1))=h1(1:length(h1)/2+2);
h2(1:length(h1)/2-2)=h1(length(h1)/2+3:length(h1));
h=real(h2);

%Frequency sampled Frequency response
Hrec=fft(h,Nfft);
wrec=(1:length(Hrec))/length(Hrec)*2*pi;

%Plottting Original
plot(w,abs(H))
title('H(w)')
xlabel('w')
disp('Press enter to Continue ...');
pause
plot(w,angle(H))
title('angle( H(w) )')
xlabel('w')
disp('Press enter to Continue ...');
pause

%Plotting Impulse Response
plot(h)
title('h[n]')
xlabel('n')
disp('Press enter to Continue ...');
pause

%Plotting Frequency Sampled Version
semilogy(wrec,abs(Hrec).^20)
title('frequency Sampled H(w)  ( dB )')
xlabel('w')
disp('Press enter to Continue ...');
pause
plot(wrec,abs(Hrec),'r-')
title('frequency Sampled H(w)')
xlabel('w')
disp('Press enter to Continue ...');
pause
plot(wrec,angle(Hrec),'g-')
title('frequency Sampled angle( H(w) )')
xlabel('w')
