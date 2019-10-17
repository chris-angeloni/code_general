%function [F] = xcorrbined(X,Y,Fs,T,Lag)
%
%	FILE NAME 	: XCORR BINED
%	DESCRIPTION 	: Discrete Cross Correlation performed by binning
%			  X and Y using bins of lenth T sec
%
%	X,Y		: Input Signals
%	Fs		: Sampling Rate
%	T		: Bin Size  (sec)
%	Lag		: X-Correlation Lag (sec)
%			  T > Lag
%
function [R] = xcorrbined(X,Y,Fs,T,Lag)

%Bin Size and Lag in Number of Samples
N=round(T*Fs);
M=round(Lag*Fs);

%Computing X-Correlation
count=1;
R=zeros(1,2*M+1);
while count*N<min(length(X),length(Y))
	XB=X((count-1)*N+1:count*N);
	YB=Y((count-1)*N+1:count*N);
	R=R+xcorr(XB,YB,M);		
	count=count+1;
end
%R=R/(count-1)/N;
