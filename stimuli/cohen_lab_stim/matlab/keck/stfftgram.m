%
%function [Data]=stfftgram(data,Fs,df,UT,UF,win,ATT,method,dis,TW)
%	
%	FILE NAME       : STFFT GRAM
%	DESCRIPTION 	: Short time FFT ( Spectrogram )
%
%	data    : Input data
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
%   Data    : Data structure containing 
%               .taxis  : Temporal Axis
%               .faxis  : Frequency Axis
%               .S      : Short-time Fourier transform
%               .M		: Filter/Window order
%               .Nt		: Temporal down sampling factor
%                         for time-frequncy grid
%               .Nf		: Spectral down sampling factor 
%                         for time-frequncy grid
%               .dF3dB  : 3dB filter frequency resolution 
%               .dT3dB  : 3dB filter temporal resolution
%               .dFU    : Filter frequency resolution (chui)
%               .dTU    : Filter temporal resolution (chui)
%               .df     : Frequency sampling resolution
%               .dt     : Temporal sampling resolution
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
function [Data]=stfftgram(data,Fs,df,UT,UF,win,ATT,method,dis,TW)

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

%Generating STFT
[taxis,faxis,stft,M,Nt,Nf,dF3dB,dT3dB,dFU,dTU,df,dt]=stfft(data,Fs,df,UT,UF,win,ATT,method,dis,TW);

%Saving data in data structure
Data.taxis=taxis;
Data.faxis=faxis;
Data.S=abs(stft);
Data.M=M;
Data.Nt=Nt;
Data.Nf=Nf;
Data.dF3dB=dF3dB;
Data.dT3dB=dT3dB;
Data.dFU=dFU;
Data.dTU=dTU;
Data.df=df;
Data.dt=dt;