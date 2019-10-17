%
%function [W]=window(Fs,p,dt,rt)
%
%       FILE NAME       : WINDOW
%       DESCRIPTION     : Ramped window desinged using B-Spline derivation 
%			  by Roark and Escabi
%
%       Fs		: Sampling Rate
%	p		: B-spline window transition region order
%	dt		: B-spline window width ( msec )
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
function [W]=window(Fs,p,dt,rt)

%Recursively computing Smoothing Function Coefficients
rt=rt/1000;
dt=dt/1000;
H1=ones(1,round(rt*Fs/p));
H=ones(1,round(rt*Fs/p));
for k=1:p-1
	H=conv(H,H1);
end

%Convolving Smoothing Fxn with Square Window
NW=length(H);
W=conv(H,ones(1,NW+2));		%Rising Edge
W=[W(1:NW) max(W)*ones(1,round(dt*Fs)-round(rt*Fs)) fliplr(W(1:NW))]/max(W); 

