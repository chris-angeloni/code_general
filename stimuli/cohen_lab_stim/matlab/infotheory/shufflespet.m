%
%function [spet]=shufflespet(spet)
%
%   FILE NAME       : SHUFFLE SPET
%   DESCRIPTION     : Shuffles a 'spet' variable by randmozing the ISI. The
%                     first order ISI statistics are preserved
%
%	spet            : Array of spike event times
%
% (C) Monty A. Escabi, Edit Dec 2010
%
function [spet]=shufflespet(spet)

%Computing the Inter-Event Variable -> diff(spet)
Nspet=length(spet);
diffspet=diff(spet);
Minspet=min(spet);

%Suffling the diff(spet) Variable
index=randperm(length(diffspet));
diffspet=diffspet(index);

%Generating Spet (Changed Dec 29, 2010)
spet(1)=diffspet(1);
for k=2:length(diffspet)
    spet(k)=spet(k-1)+diffspet(k);
end

%Integrating the shuffled diff(spet) variable
%N=2^(ceil(log2(length(diffspet))));
%diffspet=[diffspet zeros(1,N-length(diffspet))];
%spet=intfft(diffspet);
%spet=round(spet(1:Nspet))-min(spet)+Minspet;
%spet=round(spet);
