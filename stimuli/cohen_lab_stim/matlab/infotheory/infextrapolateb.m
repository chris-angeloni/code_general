%
%function [HWordt,HSpiket,HSect,HWord,HSpike,HSec,Rate]=infextrapolateb(RASTER,taxis,Fsd,B,M,L)
%
%
%       FILE NAME       : INF EXTRAPOLATE B
%       DESCRIPTION     : Extrapolates Mutual Iformation Estimate for infinate
%			  Data size using the procedure of Strong et al. and 
%			  INFEXTRAPOLATE
%			  Extrapolation procedure is performed at a fixed
%			  temporal resolution (1/Fsd) and variable word 
%			  length (B)
%
%       RASTER		: Rastergram
%	taxis		: Time Axis
%	Fsd		: Sampling rate for generating P(W) and P(W|t)
%	B		: Array of Word lengths, number of bits
%	M		: Number of RASTERs to remove to avoid adaptive 
%			  effects (Default: M=25)
%	L		: Number of Bootstrap Iterations (Default: L=10)
%
%Returned Variables
%	HWordt		: Conditional Enthropy per Word
%	HSpiket		: Conditional Enthropy per Spike
%	HSect		: Conditional Enthropy per Second
%	HWord		: Enthropy per Word
%	HSpike		: Enthropy per Spike
%	HSec		: Enthropy per Second
%	Rate		: Mean Spike Rate
%
function [HWordt,HSpiket,HSect,HWord,HSpike,HSec,Rate]=infextrapolateb(RASTER,taxis,Fsd,B,M,L)

%Input Arguments
if nargin<5
	M=25;
end
if nargin<6
	L=10;
end

%Temporal Resolution
dt=taxis(2)-taxis(1);

%Changing the word length, B
%B=[5 10 20 40 80 160];
count=1;
for b=B
	%Extrapolating Enthropy
	[HWordt(count,:),HSpiket(count,:),HSect(count,:),HWord(count,:),...
	HSpike(count,:),HSec(count,:),Rate(count,:)]=infextrapolate(RASTER,...
	taxis,Fsd,b,M,L);

	%Incrementing Count Variable
	count=count+1;
end

