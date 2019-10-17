%
%function  [tw] = twk(N,beta,wc,resfact)
%		
%	FILE NAME 	: twk
%	DESCRIPTION 	: Finds TW for the kaiser filter.
%	FUNCTION CALL	: TWK(N,beta,wc,resfact)
%	tw		: Calculated Transition Width.
%	N		: Filter Length.
%	p		: Filter Parameter.
%	wc		: Cuttoff Frequency.
%	resfact		: Resolution Factor. Used to increase accuracy.
%			  Must be base 2. (ie. 2,4,8 ... )
%	Example		: [tw]=TWK(10,2,pi/2,512)
%
function  [tw] = twk(N,beta,wc,resfact)

%Defining the discrete time axis - increasing resolution by resfact
Ntaps=2^ceil(log2(resfact*N));
naxis=1E15*ones(1,Ntaps);
for n=-N:N-1,
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

twN=findtw(Hw);
tw=abs(wc-Faxis(twN))*2;

%Finds the Max Passband Error 
E=finderr(Hw);

semilogy(Faxis,Hw.^20,'r-');
axis([0 pi min(abs(Hw))^20 1])
pause(.5)
