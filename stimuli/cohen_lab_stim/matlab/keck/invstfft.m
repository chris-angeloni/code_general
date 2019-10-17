%
%function [taxis,faxis,stft]=invstfft(specg,Fs,df,UT,UF,win,ATT)
%	
%	FILE NAME 	: INVSTFFT
%	DESCRIPTION 	: Inverse Spectogram 
%
%	specg		: Spectogram Distribution
%	Fs		: Sampling Rate
%	df		: Frequency Window Resolution (Hz)
%			  Note that by uncertainty principle 
%			  (Chui and Cohen Books)
%			  dt * df > 1/pi
%			  Equality holding for the gaussian case!!!
%
%Optional Parameters
%	UT		: Temporal upsampling factor.
%			  Increases temporal sampling resolution.
%			  Must be a positive integer. 1 indicates 
%			  no upsampling.
%	UF		: Frequncy upsampling factor.
%			  Increases spectral sampling resolution.
%			  Must be a positive integer. 1 indicates
%			  no upsampling.
%	ATT		: Attenution / Sidelobe error in dB (Optional)
%			  Default == 60 dB, ignored if win=='gauss'
% 
function [taxis,faxis,stft]=invstfft(specg,Fs,df,UT,UF,win,ATT)

%Input Arguments
if nargin==3
	UT=1;
	UF=1;
	win='gauss';
	ATT=60;
elseif nargin==4
	UF=1;
	win='gauss';
	ATT=60;
elseif nargin==5
	win='gauss';
	ATT=60;
elseif nargin==6
	ATT=60;
end

%Finding Windowing Function 
if strcmp(win,'gauss')
	%Finding Gausian / Gabor Window 
	dt=2/2/pi/df;	%Charles Chui Book - Uncertainty Principle 
	alpha=dt/2;
	M=round(5*alpha*Fs);
	taxis=(-M:M)/Fs;
	W=1/sqrt(4*pi*alpha^2)*exp(-(taxis).^2/4/alpha^2);
elseif strcmp(win,'sinc')
	%Finding Sinc(a,p) window as designed by Roark / Escabi
	W=designw(df,ATT,Fs);
	M=(length(W)-1)/2;
end

%Normalizing Window for unit Energy
W=W/sqrt(sum(W.^2));

%Finding Spectro-Temporal Resolution of Window
[dT,dF]=finddtdfw(W,Fs,1024*32);

%Finding Resolution Parameters (ie, FFT size, Temporal Resolution etc...)
fres=dF/UF;
tres=dT/2/UT;		%Must sample at twice dT to satisfy Nyquist
Nf=max(2^ceil(log2(Fs/fres)),2^ceil(log2(2*M)));
Nt=max([ceil(tres*Fs) 1]);
Ndata=length(data);

%Temporary data buffers
dtemp=zeros(1,length(data)+2*M);
dtemp(M+1:Ndata+M)=data;

%Finding Window Ambiguity Function
k=0;
Ah=zeros(Nf,floor((Ndata)/Nt));
for j=M+1:Nt:Ndata+M
	k=k+1;
	hh=W.*W;
	ss=data.*data;
	AsAh(:,k)=
end
