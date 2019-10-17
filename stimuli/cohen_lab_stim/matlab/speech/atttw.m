%function  [ATT0,ATTPI,ATT,TW] = atttw(N,p,alpha,wc,flag,Ntaps,disp)
%
%	FILE NAME 	: atttw
%	DESCRIPTION 	: Finds Passband ATT & TW for the Roark/Escabi filter
%			  For a given set of parameters. 
%
%	ATT		: Calculated Attenuation.
%	N		: Filter Length
%	p		: Filter Parameter
%	alpha		: Filter Parameter
%		     -1 : Uses pi optimal.
%		     -2	: Uses pi optimal with N+1.
%		     -3 : Uses kaiser optimal.
%	wc		: Cuttoff Frequency
%	Ntaps		: FFT length. Used to increase accuracy.
%	Flag		: Determines the ATT criterion:
%		     -1 : Standard.
%		     -2 : Roark modified.
%	TW		: Normalized TW -> TW/pi
%	ATT		: Attenuation in (dB) 
%	ATT0		: Attenuation at w=0 in (dB)
%	disp 		: display: 'log' or 'lin'
%
function  [ATT0,ATTPI,ATT,TW] = atttw(N,p,alpha,wc,flag,Ntaps,disp)

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

%Choosing pi optimal alpha
if alpha==-1 
	alpha=p*pi/wc/N;
end
%Choosing pi optimal alpha using N+1
if alpha ==-2
	alpha=p*pi/wc/(N+1)
end
%Choosing Kaiser Optimal Alpha
if alpha==-3 
	ATT=ptoatt(p);
	[Beta,nk,wck] = fdesignk(ATT,.04*pi,wc);
	a=1/( 1 + 1/besseli(0,Beta)^(1/p) );
	%a=.8565;

	%if p <= 5.5
	%	a=0.0036*p^2-.0218*p+.8735;
	%else
	%	a=.86;
	%end
	alpha=a*p*pi/wc/N;
	%clear nk;
	%clear wck;
end

%Taking FFT
hw=h(naxis,wc,alpha,p);
Hw=abs(fft(hw));

%Finds the Max Passband Error - ATT
delta=max([finderr(Hw,flag) finderr(1-Hw(length(Hw)/2:-1:1),flag)]);
ATT=-20*log10(delta);

%Finding the TW
[twN1 twN2]=findtw(Hw,flag);
TW=( interp1(Hw(twN2:twN2+1),Faxis(twN2:twN2+1),delta) -  interp1(Hw(twN1:twN1+1),Faxis(twN1:twN1+1),1-delta)   ) * 1/ pi;

%Finding ATT at w=0 and w=pi
[Err0,Errpi] = attopi(Hw);
ATT0=-20*log10(Err0);
ATTPI=-20*log10(Errpi);

if disp=='log'
	semilogy(Faxis/pi,(abs(Hw)).^20,'y.');
	hold on
	semilogy(Faxis/pi,abs(1-Hw).^20,'r.')
	hold off
	axis([0 1 min([Hw.^20 (1-Hw).^20]) 1])
	pause(.5)
end
if disp=='lin'
	plot(Faxis/pi,abs(Hw))
	axis([0 1 min(Hw) 1])
	pause(.5)
end






