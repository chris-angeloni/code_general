%
%function [spet,spetjr,spetspon]=spetaddjitter3(spet,sigma,p,lambdan,refractory,Fs,T)
%
%   FILE NAME   : SPET ADD JITTER 3
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
function [spet,spetjr,spetspont]=spetaddjitter3(spet,sigma,p,lambdan,refractory,Fs,T)

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

%Adding Additive Spike Noise at Spike Rate of Lambdan
%Added only at time intervals with no spiking so as to satisfy the
%refractory period requirements
spetspont=[];
if lambdan~=0
    N=poissrnd(lambdan*T);
    count=0;
    while count<N
        i=rand*T*Fs;
        if length(find(abs(([spetjr spetspont]-i)/Fs)*1000<refractory))==0
            spetspont=sort([spetspont i]);
            count=count+1;    
        end
    end
    
    %Removed Dec 2010. A bit slower but new code now includes refractory 
    %period for spont spikes
    %
    %    X=spet2impulse(spet,Fs,Fs);    
    %    index=find(X==0);,clear X
    %    N=poissrnd(lambdan*max(spet)/Fs); 
    %    i=1+round((length(index)-2)*rand(1,N));
    %    spet=sort([spet index(i)]);

end
spet=sort([spetjr spetspont]);

%Finding fraction of spikes that fall outside refractory period
ir=find(diff(spet)/Fs>refractory/1000);
F=length(ir)/length(spet);

%Adding Reproducibility Noise - reliability is now scaled by F
if p<=1
    X=bernoullirnd(p/F,1,length(spetj));
    ii=find(X==1);
    spetjr=spetj(ii);
end

%Spike train duration
if ~exist('T')
    T=max(spet)/Fs;
end

%Adding Additive Spike Noise at Spike Rate of Lambdan
%Added only at time intervals with no spiking so as to satisfy the
%refractory period requirements - lambdas is now scaled by F
spetspont=[];
if lambdan~=0
    N=poissrnd(lambdan/F*T);
    count=0;
    while count<N
        i=rand*T*Fs;
        if length(find(abs(([spetjr spetspont]-i)/Fs)*1000<refractory))==0
            spetspont=sort([spetspont i]);
            count=count+1;    
        end
    end
end
spet=sort([spetjr spetspont]);

%Deleting spikes within refractory period
i=find(diff(spet)/Fs>refractory/1000);
spet=spet(i);