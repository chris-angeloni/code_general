
%function [y]=sandwichmodel1(p,Flow,Fs,Nf,fs0);
%
% Function  sandwich model
% Input     
%       p     input, N+1;
%       N     the total number 
%       Flow  the lowest frequency of filters
%       Fs    the sample frequency, the highest frequency filter
%       Nf    the number of filters Nf<3*log2(Fs/Flow)
%       fs0   the cutoff frequency of the low pass filter
%
% Output
%      y      the output



function [y]=sandwichmodel1(p,Flow,Fs,Nf,fs0);

N=length(p)-1;
f=2*Fs/N*(0:N)-Fs;
U=zeros(1,N+1);

figure(1);
%to generate input
%p=sin(2*pi*5000*(0:N)/(2*Fs))+0.5*sin(2*pi*5100*(0:N)/(2*Fs))+0.5*sin(2*pi*4900*(0:N)/(2*Fs));

%p=normrnd(0,1,1,N+1);
%p=randn(1,N+1);
%p=sin(2*pi*5000*(0:N)/(2*Fs));

X=fftshift(fft(p));
subplot(6,1,1);
plot(f,abs(X));
ylabel('P');
%to design filter fk,1=20*2^((k-1)/3),fk,2=20*2^(k/3)
for i=1:Nf,
	%to normalize the cutoff frequency
   Wn(1)=Flow*power(2,(i-1)/3)/Fs;
   Wn(2)=Flow*power(2,i/3)/Fs;
   b(i,:)=fir1(N,Wn);   
   
   subplot(6,1,2);
   hold on;
   H=fftshift(fft(b(i,:)));
   plot(f,abs(H));
   U=U+X.*H;
end;
ylabel('H');

subplot(6,1,3);
plot(f,abs(U));
ylabel('U1');

u1=ifftshift(ifft(fftshift(U)));
u2=1+u1+u1.*u1;
UU=fftshift((fft(u2)));
subplot(6,1,4);
plot(f,abs(UU));
ylabel('U2');

bb=fir1(N,fs0/Fs);
HH=fftshift(fft(bb));
subplot(6,1,5);
plot(f,abs(HH));
ylabel('Hs');

Y=HH.*UU;
subplot(6,1,6);
plot(f,abs(Y));
ylabel('Y');
xlabel('F (Hz) ');
