%
%function [RD,STF]=strf2stf(taxis,faxis,STRF,MaxFm,MaxRD,N,flag,Display)
%
%       FILE NAME       : STRF 2 STF
%       DESCRIPTION     : Converts an STRF to a Spectral Transfer Function (STF)
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
%RETURNED VARIABLES
%
%	RD		: Ripple Density
%	STF		: Spectral Transfer Function
%
function [RD,STF]=strf2stf(taxis,faxis,STRF,MaxFm,MaxRD,N,flag,Display)

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

%Computing Spectral Transfer Function (Normalized for Unit Area)
STF=sum(RTF')';
NSTF=(length(STF)-1)/2+1;
STF=STF(NSTF:-1:1)+STF(NSTF:length(STF));
dRD=RD(2)-RD(1);
STF=STF/sum(STF)/dRD;
RD=RD(NSTF:length(RD));

%Plotting TTF
if Display=='y'
	plot(RD,STF,'b')
	hold on
	plot(RD,STF,'ro')
	hold off
	xlabel('Spectral Modulation Frequency (cycles/oct.)')
	ylabel('Normalized Magnitude')
end

