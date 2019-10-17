%
%function [taxis,PSTHs,RASTERs]=psthclean(PSTH,RASTER,Fss,p)
%
%       FILE NAME       : PSTH CLEAN
%       DESCRIPTION     : Cleans a PSTH and RASTER plot by finding the
%			  statistically significant events
%
%	PSTH		: PSTH data
%	RASTER		: RASTER data
%	Fss		: Sampling rate for PSTH
%	p		: Significance probability
%
function [taxis,PSTHs,RASTERs]=psthclean(PSTH,RASTER,Fss,p)

%Finding the # STD Threshold required to exceed a Right Tail
%Probability of p
Tresh=sqrt(2)*erfinv(1-2*p);

%Finding Statistically Significant Raster Plot and PSTH
M=size(RASTER,1);
Ts=1/Fss;				%Sampling Period
taxis=(1:length(PSTH))*Ts;
R=sum(sum(RASTER))/M/Ts/length(taxis)	%Mean Rate
p=R*Ts;					%Binomial Probability of spike
MeanN=M*p;				%Mean Number of Coincidences
					%Essentially the mean of a 
					%binomial dist
StdN=M*p*(1-p);				%Std of Number of Coincidences
Tresh=MeanN+Tresh*StdN;			%Threshold = Mean+Tresh*Std

%Finding Number of Coincidences and Checking for Statistical Sig
N=PSTH*M*Ts;
RASTERs=RASTER;
for k=1:length(taxis)
	if N(k)<=Tresh
		RASTERs(:,k)=zeros(M,1);
	end
end 
PSTHs=sum(RASTERs)/M/Ts;
