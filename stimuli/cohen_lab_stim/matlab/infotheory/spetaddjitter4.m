%
%function [spet,spetjr,spetspon]=spetaddjitter4(spet,sigma,p,lambdan,refractory,Fs,T)
%
%   FILE NAME   : SPET ADD JITTER 4
%   DESCRIPTION : Adds spike timming jitter, reproducibility noise
%                 and additive noise to a "spet" action potential
%                 sequence. Trial-to-trial reproducibility is modeled
%                 by a bernoulli process with probability p (p<1). For
%                 the case where p > 1, p represents the number of 
%                 "reliable" spikes and p follows a Poisson distribution
%                 with mean of p. Finally the timmming jitter is modeled by
%                 a gaussian distribution with standard deviation sigma. 
%                 Finally, the model also includes spontaneous Poisson 
%                 noise.
%
%                 This routine is similar to SPETADDJITTER, however, this
%                 version incorporates refractory effects between the
%                 spontaneous and driven spikes.
%
%   spet        : Spike Event Time Array
%   sigma       : Standard deviation of jitter distribution (msec).
%   p           : Trial-to-trial probability of producing an action
%                 potential.
%   lambdan     : Spike Rate for additive Noise component.
%   refractory  : Refractory period if desired (msec)
%                 Default==0, 'no refractory period'
%   Fs          : Sampling frequency of spike train.
%   T           : Spike train duration (sec, Optional). Uses max(spet)/Fs 
%                 if not specified.
%
%RETURNED VARIABLES
%
%   spet        : Noisy Spike Event Time Array
%   spetjr      : Reproducible / jittered spikes
%   spetspon    : Spontaneous spikes
%
%   (C) Monty A. Escabi, Edit Dec 2010
%
function [spet,spetjr,spetspon]=spetaddjitter4(spet,sigma,p,lambdan,refractory,Fs,T)

%Adding spike timing jitter
spetN=[];
for k=1:length(spet)
    if p>1
        Nspikes=poissrnd(p);    %p>=1, p corresponds to mean number of reliable spikes
    else
        Nspikes=1;              %If p<1 then we will later add reliability errors
    end
    for l=1:Nspikes
        %Adding spike timing Jitter
        dt=round(sigma/1000*Fs*randn);
        spetN=[spetN spet(k)+dt];
    end
end
spetj=sort(spetN);
i=find(spetj>=0);
spetj=spetj(i);

%Adding Reproducibility Noise
if p<=1
    X=bernoullirnd(p,1,length(spet));
    ii=find(X==1);
    spetjr=spetj(ii);
end

%Spike train duration
if ~exist('T')
    T=max(spet)/Fs;
end

%Adding spontaneous spikes at a spike rate of lambdan. Spontaneous spikes
%are choosen so that they satisfy refractory requirements
N=poissrnd(lambdan*T);      %Number of spontaneous spikes
count=0;
spetspon=[];
spet=spetjr;
while count<=N
   
    i=round(rand*T*Fs)+1;
    if ~sum(find(abs(i-spet)/Fs<refractory/1000))
        spetspon=[spetspon i];
        spet=[spet i];
        count=count+1;
    end
end
spetspon=sort(spetspon);
spet=sort(spet);