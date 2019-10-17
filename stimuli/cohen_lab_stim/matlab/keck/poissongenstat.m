%
%function [spet]=poissongenstat(L,T,Fsd,refractory,seed)
%
%       FILE NAME       : POISSON GEN STAT
%       DESCRIPTION     : Stationary Poison Spike Train Generator
%
%       L               : Lambda. Mean spike rate.
%   	T               : Spike Train Duration
%       Fsd             : Sampling Rate for spet
%       refractory      : Refractory period if desired (msec)
%                         Default==0, 'no refractory period'
%                         Must obey: refractory >> 1/lambda
%       seed            : Starting seed for random number generator (Optional)
%
%   (C) Monty A. Escabi, Edited September 2006 (Edit Aug 2009)
%
function [spet]=poissongenstat(L,T,Fsd,refractory,seed)

%Input Arguments
if nargin<4
	refractory=0;
end

%Random Generator Seed 
if nargin==5
	rand('state',seed);
end

%Refractory Period
dTMin=refractory/1000;

%Finding Necessary Spike Rate to account for Refractory
% Note that if you add a refractory period naively, the effective
% spike rate goes down. Given a desired spike rate, LD, and 
% refractory period, RP, the spike rate for exponentially distributed
% spike event times with parameter lambda, L, is related to LD by
%
%	Mean Interevent Time = 1/LD = 1/L + RP 
%
% We need to solve for L
%
L=1/(1/L-dTMin);

%Generating Exponentially Distributed Interevent Times
dT=[];
while sum(dT)<T   
    dT=[dT exprnd(1/L,1,ceil(L*T))];
    i=find(dT>dTMin);
    dT=dT(i);
end
%hist(dT,1000)

%Converting Inter-Event Times to Spike Times
%spet=round(dT*Fsd);
spet=dT*Fsd;
N=length(spet);
spet1=spet(1);
% spet=intfft(round(spet));     %Seems to be creating oscillatory behavior?
% spet=spet(1:N);
S(1)=spet(1);
for k=2:length(spet)            %Edit Aug, 2009
   S(k)=S(k-1)+spet(k); 
end
spet=S(1:N);
spet=spet-min(spet)+spet1;
i=find(spet<T*Fsd);
spet=round(spet(i));
spet=sort(spet);
