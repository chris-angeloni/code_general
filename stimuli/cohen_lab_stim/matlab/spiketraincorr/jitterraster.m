%
%function [RASTER]=jitterraster(spet,sigma,p,lambdan,Fs,Fsd,N)
%
%   FILE NAME       : JITTER RASTER
%   DESCRIPTION     : Generates a jittered spike train rastergram. Spike
%                     timing jitter is modeled by a normal distribution 
%                     with standard deviation sigma. Trial-to-trial 
%                     reproducibility is modeled  by a bernoulli process 
%                     with probability p (p<1). For the case where p > 1, 
%                     p represents the number of "reliable" spikes and p 
%                     follows a Poisson distribution with mean of p. 
%                     Timmming jitter is modeled by a gaussian distribution
%                     with standard deviation sigma. Finally, the model 
%                     also includes spontaneous Poisson noise.
%
%	spet    : Spike Event Time Array Input
%	sigma	: Standard deviation of jitter distribution (msec).
%	p		: Trial-to-trial probability of producing an action
%			  potential.
%   lambdan : Spike Rate for additive Noise component
%	Fs		: Sampling frequency for spet array
%	Fsd		: Sampling frequency for RASTER
%	N		: Number of jittered rasters
%
%Returned Variables
%	RASTER	: Jittered Rastergram
%
% (C) Monty A. Escabi, Edit June 2010
%
function [RASTER]=jitterraster(spet,sigma,p,lambdan,Fs,Fsd,N)

%Rastergram length
L=length(spet2impulse(spet,Fs,Fsd));
T=L/Fsd;

%Initializing Rastergram
%RASTER=zeros(N,L);

%Adding spike timing Jitter and reproducibility errors
for k=1:N

	%Adding Jitter and Reproducibility Errors
	spetj=spetaddjitter(spet,sigma,p,lambdan,Fs);
    RASTER(k).spet=round(spetj/Fs*Fsd)+1;
    RASTER(k).Fs=Fsd;
    RASTER(k).T=T;
    
	%Converting SPET sequence to action potential sequences
	%X=spet2impulse(spetj,Fs,Fsd);

	%Generating Raster
	%RASTER(k,1:min(L,length(X)))=X(1:min(L,length(X)));

end