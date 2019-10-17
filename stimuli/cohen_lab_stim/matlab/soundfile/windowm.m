%
%function [W]=windowm(Fs,p,M,rt)
%
%       FILE NAME       : WINDOW
%       DESCRIPTION     : Ramped window desinged using B-Spline derivation 
%                         by Roark and Escabi. Same as WINDOW except that
%                         duration is specified in number of samples (M)
%
%   Fs		: Sampling Rate
%	p		: B-spline window transition region order
%	M		: B-spline window duration ( number of samples, M>2*Fs*rt/1000 )
%	rt		: B-spline window rise time ( msec )
%
%                 ______________________
%                /                      \
%               /                        \
%              /                          \
%             /|                          |\
%       _____/_|__________________________|_\_____
%              |                          |
%              |                          |
%              |<-----------dt----------->|
%            <-rt-> 
%            
function [W]=windowm(Fs,p,M,rt)

W=ones(1,M);
[WW]=window(Fs,p,M/Fs*1000-2*rt,rt);
WW=WW(1:floor(length(WW)/2));
W(1:1:length(WW))=WW;
W(length(W):-1:length(W)-length(WW)+1)=WW;
