%function [F] = convfft(X,Y,delay,N,trun)
%
%	FILE NAME 	: CONVFFT
%	DESCRIPTION 	: Discrete Convolution performed by using FFT
%
%	X		: Signal 1
%	Y		: Signal 2
%	delay		: Used to correct for filter delay
%
%	OPTIONAL
%	N		: FFT length
%	trun		: Truncate to NX + NY -1 -> 'y' or 'n'
%			  Default: 'n'
%
function [F] = convfft(X,Y,delay,N,trun)

%Defining sequence lengths
NY=length(Y);
NX=length(X);

%Checking Arguments
if nargin<4
	N=2^(ceil(max([log10(NX)/log10(2) log10(NY)/log10(2)])));
	%N=2^(ceil(1+max([log10((NY+NX)/2)/log10(2)])));
	trun='n';
elseif nargin<5
	trun='n';
end

%Appending zeros
SX=zeros(1,N*2);
SY=zeros(1,N*2);
SX(1:length(X))=X;
SY(1:length(Y))=Y;

%Performing convolution
Ftemp=real(ifft(fft(SY).*fft(SX)));
F=Ftemp(1+delay:N+delay);

if trun=='y'
	F=F(1:NX+NY-1);
end
