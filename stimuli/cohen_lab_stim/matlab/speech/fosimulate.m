%function [Fo,X]=fosimulate(To,F1,F2,Fs,N)
%	
%	FILE NAME 	: FO SIMULATE
%	DESCRIPTION 	: Fits the Power Spectrum of Fo=1/To to a Power Law
%			  in a RMS sense and generates a simulated Fo
%			  signal X(t) with identical Fo statistics
%
%	To		: Measured Fundamental Period Array 
%	F1		: Lower Freqeuncy used for polyfit
%	F2		: Upper Frequency used for polyfit
%	Fs		: Sampling Rate for simulated signal X
%	N		: Number of cycles in X(t)
%
function [Fo,X]=fosimulate(To,F1,F2,Fs,N)

%Fiting Fo Profile
[Po,alpha]=fopsdfit(To,F1,F2);

%Genrating a simulated Fo profile
M=2^nextpow2( N * Fs * mean(To) );
[taxis,Fo]=n1overf(F1,F2,alpha,Fs,M);
Fo=norm1d(Fo)*(max(1./To)-min(1./To))+mean(1./To);
theta=2*pi*intfft(Fo)/Fs;
X=sin(theta);
