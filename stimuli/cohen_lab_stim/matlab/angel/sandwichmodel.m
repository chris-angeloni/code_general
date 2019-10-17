
%function [y]=sandwichmodel(p,N,Flow,Fs,Nf,fs0);
%
% Function  sandwich model
% Input     
%       p     input, N+1;
%       N     the total number 
%       Flow  the lowest frequency of filters
%       Fs    half of the sample frequency, the highest frequency filter
%       Nf    the number of filters Nf<3*log2(Fs/Flow)
%       fs0   the cutoff frequency of the low pass filter
%
% Output
%      y      the output



function [y]=sandwichmodel(p,Flow,Fs,Nf,fs0);

N=length(p)-1;
f=2*Fs/N*(0:N)-Fs;
U=zeros(1,N+1);

X=fftshift(fft(p));

%to design filter fk,1=20*2^((k-1)/3),fk,2=20*2^(k/3)
for i=1:Nf,
	%to normalize the cutoff frequency
   Wn(1)=Flow*power(2,(i-1)/3)/Fs;
   Wn(2)=Flow*power(2,i/3)/Fs;
   b(i,:)=fir1(N,Wn);   
   H=fftshift(fft(b(i,:)));
   U=U+X.*H;
end;

u1=ifftshift(ifft(fftshift(U)));
u2=1+u1+u1.*u1;
UU=fftshift((fft(u2)));

bb=fir1(N,fs0/Fs);
HH=fftshift(fft(bb));

Y=HH.*UU;
y=ifftshift(ifft(Y));
