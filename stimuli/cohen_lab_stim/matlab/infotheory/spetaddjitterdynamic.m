%
%function [spet]=spetaddjitterdynamic(spet,sigma,p,lambdan,Fs)
%
%   FILE NAME   : SPET ADD JITTER DYNAMIC
%   DESCRIPTION : Adds spike timming jitter, reproducibility noise
%                 and additive noise to a "spet" action potential
%                 sequence. Trial-to-trial reproducibility is modeled
%                 by a bernoulli process with probability p (p<1). Finally 
%                 the timmming jitter is modeled by a gaussian distribution
%                 with standard deviation sigma. 
%
%                 The jitter and reliability are choosen dynamically, that
%                 is each spike has its own randomly choosen jitter and
%                 reliability. Both the jitter and reliabilities are
%                 choosen to have a uniform disttribution within a
%                 desginated range. 
%
%                 Finally, the model also includes spontaneous Poisson 
%                 noise.
%
%   spet        : Spike Event Time Array
%   sigma       : Vector containing the minimum and maximum jitter
%                 parameter. If length of vector is > 2, then p corresponds
%                 to the probability for each spike in SPET.
%   p           : Vector containing the miminmum and maximum reliability 
%                 parameter. If length of vector is > 2, then p corresponds
%                 to the probability for each spike in SPET.                 
%   lambdan     : Spike Rate for additive Noise component.
%   Fs          : Sampling frequency of spike train.
%
%RETURNED VARIABLES
%
%   spet        : Noisy Spike Event Time Array
%
%   (C) Monty A. Escabi, Nov 2010
%
function [spet,sigma,p]=spetaddjitterdynamic(spet,sigma,p,lambdan,Fs)

%Generating Jitter and Reliability for each spike
Nspikes=length(spet);
if length(sigma)==2
   sigmamin=sigma(1);
   sigmamax=sigma(2);
   pmin=p(1);
   pmax=p(2);
   p=rand(1,Nspikes)*(pmax-pmin)+pmin;
   sigma=rand(1,Nspikes)*(sigmamax-sigmamin)+sigmamin;
end

%Adding Jitter
spetN=[];
for k=1:Nspikes
        %Adding spike timing Jitter
        dt=round(sigma(k)/1000*Fs*randn);
        spetN=[spetN spet(k)+dt];   
end
spet=sort(spetN);
i=find(spet>=0);
spet=spet(i);

%Adding Reproducibility Noise
XX=[];
for k=1:Nspikes
    X=bernoullirnd(p(k),1,1);
    XX=[XX X];
end
ii=find(XX==1);
spet=spet(ii);

%Adding Additive Spike Noise at Spike Rate of Lambdan
%Added only at time intervals with no spiking
if lambdan~=0
    X=spet2impulse(spet,Fs,Fs);
    index=find(X==0);,clear X
    N=poissrnd(lambdan*max(spet)/Fs); 
    i=1+round((length(index)-2)*rand(1,N));
    spet=sort([spet index(i)]);
end