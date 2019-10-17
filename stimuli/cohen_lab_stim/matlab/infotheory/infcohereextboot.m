%
%function [MI,Rate]=infcohereextboot(I,IS,Rate,Fsd,D,df,LB,NB)
%
%
%       FILE NAME   : INF COHERE EXTRAPOLATE BOOTSTRAP
%       DESCRIPTION : Extrapolates & Bootstraps based on data fraction,
%                     and spectral resolution to remove bias from 
%                     mutual information upper bound estimate using 
%                     coherence approach
%                     
%                     Data for I, IS, and Rate are generated using:
%
%                     INFCOHEREBIAS or
%                     INFCOHERERASTERBIAS
%
%       I           : Information Measurments
%       IS          : Spike-Shifted information Measurments
%       Rate        : Spike Rate Matrix at all conditions
%       Fsd         : Sampling rate array for generating Coherence
%       D           : Inverse Data fractions
%       LB          : Desired number of bootstrap itterations
%       NB          : The largest NB spectral resolution to use for
%                     analysis. 
%                     Uses: df(length(df)-NB+1:length(df))
%                     Note: spectral resolution, df, is inversly related
%                     to 1/T where 'T=word length' from Strong et al.
%
%RETURNED VARIABLES
%       MI          : Extrapolated Mutual Information
%       Rate		: Spike Rate
%
%   (C) Monty A. Escabi, Aug. 2005
%
function [MI,Rate]=infcohereextboot(I,IS,Rate,Fsd,D,df,LB,NB)

%Extrapolating Over Inverse Data Fraction
for k=1:length(Fsd)
	for m=1:length(df)
		for n=1:LB
			for l=1:length(D)

				%Choosing bootstrap samples
				NN=round(rand*(size(I,4)-1)+1);
				II(l)=I(k,l,m,NN)-IS(k,l,m,NN);

			end

			%Extrapolating Mutual Information
			[P,S]=polyfit(D,II,2);
			MI1(k,m,n)=polyval(P,0);

		end
	end
end

%Extrapolating Over Spectral Resolution
for k=1:length(Fsd)
	for n=1:LB
		for m=1:length(df)

			%Choosing bootstrap samples
			NN=round(rand*(LB-1)+1);
			II2(m)=MI1(k,m,NN);

		end

		%Extrapolating Mutual Information - over last NB elements
		[P,S]=polyfit(df(length(df)-NB+1:length(df)),...
			II2(length(df)-NB+1:length(df)),1);
		MI(k,n)=polyval(P,0);

	end
end

%Finding the Mean Firing Rate
Rate=mean(mean(mean(Rate)));
