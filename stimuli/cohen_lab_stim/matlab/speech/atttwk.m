%function  [ATT,TW] = atttwk(N,beta,wc,flag,Ntaps)
%
%	FILE NAME 	: errk
%	DESCRIPTION 	: Finds Passband Error for the kaiser filter
%			  For a given set of parameters. 
%	FUNCTION CALL	: errk(N,beta,wc,resfact)
%	E		: Calculated Error.
%	N		: Filter Length
%	p		: Filter Parameter
%	wc		: Cuttoff Frequency
%       Ntaps           : FFT length. Used to increase accuracy.
%
function  [ATT,TW] = atttwk(N,beta,wc,flag,Ntaps)

%Defining the discrete time axis
naxis=1E15*ones(1,Ntaps);
for n=-N:N,
	naxis(n+N+1)=n;
end

%Defining the Frequency axis
Faxis=zeros(size(naxis));
for i=1:Ntaps,
Faxis(i)=(i-1)/Ntaps*2*pi;
end

%Taking FFT
hw=hk(naxis,wc,N,beta);
Hw=abs(fft(hw));

%Finds the Max Error
delta=max([finderr(Hw,flag) finderr(1-Hw(length(Hw)/2:-1:1),flag)]);
ATT=-20*log10(delta);

%Finding the TW
[twN1 twN2]=findtw(Hw,flag);
TW=( interp1(Hw(twN2:twN2+1),Faxis(twN2:twN2+1),delta) - interp1(Hw(twN1:twN1+1),Faxis(twN1:twN1+1),1-delta)   ) * 1/ pi;
semilogy(Faxis,Hw.^20,'r');
%plot(Faxis/pi,Hw,'r')
%plot(Faxis,Hw,'go')
axis([0 pi min(Hw.^20) 1])
pause(.5)
