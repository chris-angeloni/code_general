%
%function [spet]=impulse2spet(X,Fs,Fsd)
%
%       FILE NAME       : SPET 2 IMPULSE
%       DESCRIPTION     : Converts and SPET Array to a sampled impulse 
%			  array
%
%	X		: Returned Array if diract impulses
%	Fs		: Sampling Rate for X
%	Fsd		: Sampling Rate for spet
%
%   (C) Monty A. Escabi, Edit July 2011
%
function [spet]=impulse2spet(X,Fs,Fsd)

%Converting Impulse Spike Train to SPET at Fs
spet=[];
for k=1:max(X)/Fs
    for l=1:k
        spet=[spet find(X==k*Fs)];
    end
end
spet=sort(spet);

%Removed the below code on July 2011; Now use the above
%
% %Converting Spike Array to Spet
% spet=find(X~=0);
% 
% %Resampling to Fsd
% spet=round(spet/Fs*Fsd);


%Trig=round(((k-1)*728+1)/44100*44*24000); 
