%
%function [HWordt,HSpiket,HSect,HWord,HSpike,HSec,Rate]=infextrapolate(RASTER,taxis,Fsd,B,M,L)
%
%
%       FILE NAME       : INF EXTRAPOLATE
%       DESCRIPTION     : Extrapolates Mutual Iformation Estimate for infinate
%			  Data size using the procedure of Strong et al. and 
%			  INFWORDRASTER
%			  Extrapolation procedure is performed at a fixed
%			  temporal resolution (1/Fsd) and a fixed word 
%			  length (B)
%			  To extrapolate by considering word length, B, use
%			  the routine INFEXTRAPOLATEB
%
%       RASTER		: Rastergram
%	taxis		: Time Axis
%	Fsd		: Sampling rate for generating P(W) and P(W|t)
%	B		: Length of Word, number of bits
%	M		: Number of RASTERs to remove to avoid adaptive 
%			  effects (Default: M=25)
%	L		: Number of Bootstrap Itterations (Default: L=10)
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
function [HWordt,HSpiket,HSect,HWord,HSpike,HSec,Rate]=infextrapolate(RASTER,taxis,Fsd,B,M,L)

%Input Arguments
if nargin<5
	M=25;
end
if nargin<6
	L=10;
end
%Temporal Resolution
dt=taxis(2)-taxis(1);

%Bootstrapping and Estimating Enthorpy as a fxn of Data Fraction
HW=[];
HWt=[];
R=[];
for l=1:L		%Bootstrapping L trials
	for k=1:4	% Measuring at Four Data Fraction conditions

		%Randmly Choosing Rasters for Bootstrap
		N=(1:size(RASTER,1))';
		for n=1:ceil(length(N)*(1-1/k))
			i=1+floor(rand*(length(N)-1));
			N=[N(1:i-1) ; N(i+1:length(N))];
		end
		RASTERtemp=RASTER(N,:);

		%Computing Information for Sample
		[HWordt,HSpiket,HSect,HWord,HSpike,HSec,...
		Rate]=infwordraster(RASTERtemp,taxis,Fsd,B,M);

		%Extracting Enthropy and Noise Enthropy	
		HW(l,k)=HWord(length(HWord));
		HWt(l,k)=mean(HWordt);
		R(l,k)=Rate;

		%Plotting if desired
		%plot(HW(l,1:k),'r')
		%hold on
		%plot(HWt(l,1:k),'r')
		%pause(0)
	end
end

%Fitting Polynomial and Extrapolating Enthropy
HWord=[];
HWordt=[];
X=1:4;
for k=1:size(HW,1)

	%Extrapolating Spike Train Entropy vs. Data Fraction
	[P,S]=polyfit(X,HW(k,:),2);
	HWord=[HWord P(3)];

	%Extrapolating Noise Entropy vs. Data Fraction
	[P,S]=polyfit(X,HWt(k,:),2);
	HWordt=[HWordt P(3)];

end

%Measuring Firing Rate
if M~=0
        RASTER=RASTER(M+1:size(RASTER,1),:);
end
Rate=mean(mean(RASTER))/dt;

%Enthropy per time and per spike
HSect=HWordt/B*Fsd;
HSpiket=HSect/Rate;
HSec=HWord/B*Fsd;
HSpike=HSec/Rate;
