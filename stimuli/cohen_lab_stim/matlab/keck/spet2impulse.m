%
%function [X]=spet2impulse(spet,Fs,Fsd,T)
%
%   FILE NAME   : SPET 2 IMPULSE
%   DESCRIPTION : Converts and SPET Array to a sampled impulse 
%                 array
%
%   spet        : Spike Event Time Array
%   Fs          : Sampling Rate
%   Fsd         : Desired Sampling Rate for X ( Default = 1000 )
%   T           : Total spike train duration (sec) (OPTIONAL)
%
%RETURNED VARIABLE
%	X           : Returned Array if diract impulses
%
%   (C) Monty A. Escabi, July 2011 (Last Edit)
%
function [X]=spet2impulse(spet,Fs,Fsd,T)

%Preliminaries
more off
if nargin<4
    N=ceil(max(spet)/Fs*Fsd)+1;
else
    N=round(Fsd*T);
end

%Generating Impulse Array
X=zeros(1,N);
%index=floor(spet/Fs*Fsd+)+1;   %Removed July 2011
index=round(spet/Fs*Fsd); %Edit Aug 2009, added back July 2011
i=find(index<=N & index>0);
index=index(i);

%Generating Spike Array
for k=1:length(index)
	%Adding impulses at sampled bins
	X(index(k))=X(index(k))+Fsd;
end
%X(index)=ones(size(index))*Fsd;

%Normalizing the Spike Train
%X=X*Fsd;
%X=X(1:N-2);
