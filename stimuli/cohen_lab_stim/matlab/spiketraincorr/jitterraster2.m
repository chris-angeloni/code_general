%
%function [RASTER]=jitterraster2(spet,sigma,p,lambdan,refractory,Fs,N)
%
%   FILE NAME       : JITTER RASTER 2
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
%                     This program is similar to JITTERRASTER except that
%                     this version also includes refractory effects
%
%	spet        : Spike Event Time Array Input
%	sigma       : Standard deviation of jitter distribution (msec).
%	p           : Trial-to-trial probability of producing an action
%                 potential.
%   lambdan     : Spike Rate for additive Noise component
%   refractory  : Refractory period (msec)
%	Fs          : Sampling frequency for spet array
%	N           : Number of trials for dot-raster
%
%Returned Variables
%	RASTER	: Jittered Rastergram
%
% (C) Monty A. Escabi, Edit Dec 2012
%
function [RASTER]=jitterraster2(spet,sigma,p,lambdan,refractory,Fs,N)

%Rastergram length
L=length(spet2impulse(spet,Fs,Fs));
T=L/Fs;

%Initializing Rastergram
%RASTER=zeros(N,L);

%Adding spike timing Jitter and reproducibility errors
for k=1:N

	%Adding Jitter and Reproducibility Errors
	[spetj,spetjr,spetspon]=spetaddjitter2(spet,sigma,p,lambdan,refractory,Fs);
    RASTER(k).spet=spetj;
    RASTER(k).spetjr=spetjr;
    RASTER(k).spetspon=spetspon;
    RASTER(k).Fs=Fs;
    RASTER(k).T=T;
    
	%Converting SPET sequence to action potential sequences
	%X=spet2impulse(spetj,Fs,Fsd);

	%Generating Raster
	%RASTER(k,1:min(L,length(X)))=X(1:min(L,length(X)));

end