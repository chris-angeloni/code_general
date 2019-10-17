%
%function [T,Y,Y1,Y2]=strf2pre(S,taxis,faxis,STRF1,STRF2,MdB,Display)
%
%       FILE NAME       : STRF 2 PRE
%       DESCRIPTION     : Prediction using STRF
%
%	S		: Normalized spectro-temporal envelope
%	taxis		: Time Axis for STRF
%	faxis		: Frequency Axis for STRF
%	STRF1		: Contra STRF
%	STRF2		: Ipsi STRF
%	MdB		: Modulation Depth
%	Disp		: Display : 'y' or 'n'
%			  Default : 'y' 
%
%OUTPUT VARIABLES
%	T		: Time Axis
%	Y		: Predicted Output
%	Y1		: Predicted output for STRF1 only
%	Y2		: Predicted output for STRF2 only
%
function [T,Y,Y1,Y2]=strf2pre(S,taxis,faxis,STRF1,STRF2,MdB,Display)

%Preliminaries
if nargin<7
	Display='y';
end

%Normalizing S
S=MdB*(S+.5);

%Computing Binaural Spectrotemporal Convolution Integral
N1=length(STRF1(:,1));
N2=length(STRF1(1,:));

%Summing Convolution from spectral and binaural channels
if sum(sum(STRF1))~=0
	Y1=convlinfft(STRF1,S);
end
if sum(sum(STRF2))~=0
	Y2=convlinfft(STRF2,fliplr(S));
end
if exist('Y1','var') & exist('Y2','var')
	Y1=sum(Y1);
	Y2=sum(Y2);
	Y=Y1+Y2;
elseif exist('Y1','var')
	Y1=sum(Y1);
	Y2=zeros(1,length(Y1));
	Y=Y1;
else
	Y2=sum(Y2);
	Y1=zeros(1,length(Y2));
	Y=Y2;
end

%Time Axis
T=(0:length(Y)-1)*taxis(2);

%Displaying if Desired
if strcmp(Display,'y')
	plot(T,Y,'b')
end
