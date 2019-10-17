%
%function [Fm,TTF]=strf2ttf(taxis,faxis,STRF,MaxFm,MaxRD,N,flag,Display)
%
%       FILE NAME       : STRF 2 TTF
%       DESCRIPTION     : Converts an STRF to a Temporal Transfer Function (TTF)
%	
%	taxis		: Time Axis
%	faxis		: Frequency Axis
%	STRF		: Spectro Temporal Receptive Field
%	MaxFm		: Maximum Modulation Rate for Experiment
%	MaxRD		: Maximum Ripple Density for Experiment
%	N		: Number of singular values to keep	
%	flag		: Procedure for computing TTF
%			  1: SVD applied to STRF
%			  2: SVD Applied to RTF
%			  3: Direct Procedure
%	Display		: Display : 'y' or 'n'
%			  Default : 'n'
%
%RETURNED VARIABLE
%
%	Fm		: Modulation Rate Axis
%	TTF		: Temporal Transfer Function
%
function [Fm,TTF]=strf2ttf(taxis,faxis,STRF,MaxFm,MaxRD,N,flag,Display)

%Checking Input arguments
if nargin<8
	Display='n';
end

if flag==1

	%SVD on STRF
	[U,S,V] = svd(STRF);
	SS=zeros(size(S));
	SS(1:N,1:N)=S(1:N,1:N);
	STRF=U*SS*V';
	[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRF,MaxFm,MaxRD,'n');

elseif flag==2

	%SVD on RTF
	[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRF,MaxFm,MaxRD,'n');
	[U,S,V] = svd(RTF);
        SS=zeros(size(S));
        SS(1:N,1:N)=S(1:N,1:N);
	RTF=U*SS*V';

elseif flag==3

	%Direct Approeach Based on STRF
	[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRF,MaxFm,MaxRD,'n');

end

%Computing Temporal Transfer Function (Normalized for Unit Area)
TTF=sum(RTF)
NTTF=(length(TTF)-1)/2+1;
TTF=TTF(NTTF:-1:1)+TTF(NTTF:length(TTF));
dFm=Fm(2)-Fm(1);
TTF=TTF/sum(TTF)/dFm;
Fm=Fm(NTTF:length(Fm));

%Plotting TTF
if Display=='y'
	plot(Fm,TTF,'b')
	hold on
	plot(Fm,TTF,'ro')
	hold off
	xlabel('Temporal Modulation Frequency (Hz)')
	ylabel('Normalized Magnitude')
end

