%
%function [taxis,faxis,stft,M,Nt,Nf,dF3dB,dT3dB,dFU,dTU,df,dt]=stfft(data,Fs,df,UT,UF,win,ATT,method,dis,TW)
%	
%	FILE NAME 	: STFFT
%	DESCRIPTION 	: Short time FFT ( Spectogram )
%
%	data		: Input data
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
%			  If UT=inf the STFT will not be downssampled
%			  and will have a temporal resolution of 1/Fs
%	UF		: Frequncy upsampling factor.
%			  Increases spectral sampling resolution.
%			  Must be a positive integer. 1 indicates
%			  no upsampling.
%	win		: 'sinc', 'gauss', 'sincfilt'
%			  'gauss' - gaussian window
%			  'sinc' - b-spline sinc(a,p) window 
%			  'sincfilt' - b-spline sinc(a,p) filter
%			  Default=='sinc'
%	ATT		: Attenution / Sidelobe error in dB (Optional)
%			  Default == 60 dB, ignored if win=='gauss'
%	method		: Method used to determine spectral and temporal 
%			  resolutions - dt and df
%			  '3dB'  - measures the 3dB cutoff frequency and 
%			           temporal bandwidth
%			  'chui' - uses the uncertainty principle
%			  Default == '3dB'
%	dis		: display (optional): 'log' or 'lin' or 'n'
%			  Default=='n'
%	TW		: Filter Transition Width - for win=='sincfilt' only
%			  Default=0.5*df
%
%RETURNED VALUES
%
%	taxis		: Temporal Axis
%	faxis		: Frequency Axis
%	stft		: Short-time Fourier transform
%	M		: Filter/Window order
%	Nt		: Temporal down sampling factor
%			  for time-frequncy grid
%	Nf		: Spectral down sampling factor 
%			  for time-frequncy grid
%   dF3dB   : 3dB filter frequency resolution 
%   dT3dB   : 3dB filter temporal resolution
%   dFU     : Filter frequency resolution (chui)
%   dTU     : Filter temporal resolution (chui)
%   df      : Frequency sampling resolution
%   dt      : Temporal sampling resolution
%
%DETAILS
%
% To satisfy Parsevals identity:
%
%  sum(x[n].^2) = mean( X(w) .* conj(X[w]) ) = 
%			sum( mean( stft .* conj(stft) ) ) * dt/Ts
%
%  Note that the factor dt/Ts where dt=taxis(2) is the temporal resolution
%  of the spectogram and Ts is the sampling period. This is necesary because  
%  the spectogram has been downsampled by that factor.
%
% Sampling Grid Must Satisfy:
%
% 				Nt/Nf<1
%
function [taxis,faxis,stft,M,Nt,Nf,dF3dB,dT3dB,dFU,dTU,df,dt]=stfft(data,Fs,df,UT,UF,win,ATT,method,dis,TW)

%Input Arguments
if nargin<4
	UT=1;
end
if nargin<5
	UF=1;
end
if nargin<6
	win='sinc';
end
if nargin<7
	ATT=60;
end
if nargin<8
	method='3dB';
end
if nargin<9
	dis='n';
end
if nargin<10
	TW=0.5*df;
end

%Finding Windowing Function 
if strcmp(win,'gauss')
	%Finding Gausian / Gabor Window 
    if strcmp(method,'3dB')
		%Note that for exp(-a*t^2) <---> sqrt(pi/a)*exp(-pi^2*f^2/a)
        alpha = lsqnonlin(@(alpha) exp(-pi^2*2*alpha^2*(df/2)^2)-1/sqrt(2),0.0001,0)
        M=round(5*alpha*Fs);
        dt=nan(1);
	else
		%dt=2/2/pi/df;	%Charles Chui Book - Uncertainty Principle
        dt=1/pi/df;     %Charles Chui Book - Uncertainty Principle
        alpha=dt/2;
        M=round(5*alpha*Fs);	
    end
    
	taxis=(-M:M)/Fs;
	W=1/sqrt(4*pi*alpha^2)*exp(-(taxis).^2/4/alpha^2);
%    W2=1/sqrt(2*pi*alpha^2)*exp(-(taxis).^2/2/alpha^2);     %Window for power distribution, May 2010
%    W=sqrt(W2);                                             %Window - obtain the same result as above using this method
elseif strcmp(win,'sinc')
	%Finding Sinc(a,p) window as designed by Roark / Escabi
	%Note that Im defining dt and df differently than in chui 
	%book for uncetainty principle
	%They use: dt=std(W(t))  and df=std(W(w))
	%so tha  : dt * dw > .5
	%I use   : dt=2 * std(W(t)) and df=2 * std(W(f)) 
	%Under these conditions dt * df > 1/pi
	%See finddtdfw.m for more details
	if strcmp(method,'3dB')
		W=designw(df,ATT,Fs,'3dB');	
	else
		W=designw(df,ATT,Fs,'chui');	
	end
	M=(length(W)-1)/2;
elseif strcmp(win,'sincfilt')
	%Finding Sinc(a,p) filter as designed by Roark / Escabi
	W=lowpass(df/2,TW,Fs,ATT,'off');
	M=(length(W)-1)/2;
end

%Normalizing Window for Unit Energy
W=W/sqrt(sum(W.^2));

%Finding Spectro-Temporal Resolution of Window
if strcmp(win,'sinc') | strcmp(win,'gauss')
	if strcmp(method,'3dB')
		[dTU,dFU,dT3dB,dF3dB]=finddtdfw(W,Fs,1024*32);
		dT=dT3dB;, dF=dF3dB;
	else
		[dTU,dFU,dT3dB,dF3dB]=finddtdfw(W,Fs,1024*32);
		dT=dTU;, dF=dFU;
	end
else
	if strcmp(method,'3dB')
		[dTU,dFU,dT3dB,dF3dB]=finddtdfh(W,Fs,1024*32);
		dT=dT3dB;, dF=dF3dB;
	else
		[dTU,dFU,dT3dB,dF3dB]=finddtdfh(W,Fs,1024*32);
		dT=dTU;, dF=dFU;
	end
end

%Finding Resolution Parameters (i.e., FFT size, Temporal Resolution, etc.)
%Note that minimal sampling grid must be choosen to satisfy: 
%
%		dt*df < 1    or    dt*dw<2*pi
%
%Where dt is the temporal window "width", i.e the temporal sampling period 
%and df is the window bandwidth in the frequency domain, i.e. the spectral
%sampling distance in Hz. Note that dw=2*pi*df.
%
%When using a discrete sampling grid we have:
%
%		Nt/Nf<1
%
%where Nt is the temporal downsampling factor and Nf is the spectral 
%downsampling factor from Fs and 1/Fs respectively. This is exactly 
%as above since dt=Nt/Fs and since df=Fs/Nf
%
%Ref 1: Multi Rate Systems and Filter Banks, P.P. Vaidyanathan, Pg. 481
%Ref 2: Discrete Time Signal Processing, Oppenheim and Schafer
%Ref 3: Time Frequency Analaysis, Cohen
%
fres=dF/UF;
Nf=max(2^ceil(log2(Fs/fres)),2^ceil(log2(2*M)));
if 2^ceil(log2(2*M)) > 2^ceil(log2(Fs/fres))
	OF=2^ceil(log2(2*M+1)) /  2^ceil(log2(Fs/fres)); %Spectral Oversampling
else
	OF=1;
end
if UT==inf		%Do not downsample time signal
	tres=1/Fs;
	Nt=1;
else
	tres=dT/UT;
	Nt=max([ceil(tres*Fs) 1]);
end
Ndata=length(data);

%Temporary data buffers
dtemp=zeros(1,length(data)+2*M);
dtemp(M+1:Ndata+M)=data;

%Finding Spectogram
k=0;
stft=zeros(Nf,floor((Ndata)/Nt));
for j=M+1:Nt:Ndata+M
	k=k+1;
	WData=dtemp(j-M:j+M).*W;
	stft(:,k)=fft(WData,Nf)';
end
stft=stft(1:OF:Nf/2,:);
Nf=Nf/OF;

%Finding faxis/taxis
faxis=( 0:Nf/2 - 1 ) / Nf*2 * Fs/2;
taxis=( 0:k-1 ) / k * Ndata/Fs;

%Diplay Spectogram
if strcmp(dis,'log')
	figure
	pcolor(taxis,faxis,10*log10(real(stft.*conj(stft))))
	colormap jet
	shading flat
elseif strcmp(dis,'lin')
	figure
	pcolor(taxis,faxis,stft.*conj(stft))
	colormap jet
	shading flat
end

%Diplaying parameters
if dis=='lin' | dis=='log'
disp(' ')
S=sprintf('Frequency Window Resolution - 3dB       : dF = %4.1f\t(Hz)',dF3dB);
disp(S)
S=sprintf('Temporal Window Resolution - 3dB        : dT = %2.5f\t(sec)',dT3dB);
disp(S)
S=sprintf('Frequency Window Resolution             : dF = %4.1f\t(Hz)',dFU);
disp(S)
S=sprintf('Temporal Window Resolution              : dT = %2.5f\t(sec)',dTU);
disp(S)
S=sprintf('Frequency Sampling Resolution           : df = %4.1f\t(Hz)',Fs/Nf);
disp(S)
S=sprintf('Temporal Sampling Resolution            : dt = %2.5f\t(sec)',Ndata/k/Fs);
disp(S)
end

