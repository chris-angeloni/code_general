%function [Faxis,H] = hproto(p,alpha,wc,wres,disp)
%
%       FILE NAME       : Hproto 
%       DESCRIPTION     : B-Spline implementation of Frequency domain   
%                         Escabi / Roark Filter Function
%	p		: Smoothing parameter (>1)
%	alpha		: TW Parameter (0,1)
%	wc		: Cutoff Frequency
%	wres		: Resolution in Frequency domain (>0)
%
%OPTIONAL
%	disp		: Display : 'y' or 'n' (Default=='n')
%
function [Faxis,H] = hproto(p,alpha,wc,wres,disp)

%Preliminaries
if nargin<5
	disp='n';
end

%Setting up Arrays
if length(wres)==1
	Faxis=-pi:wres:pi;
else
	Faxis=wres;
end

H=zeros(size(Faxis));

%Calculating Filter Function from B-Spline Derivation
for k=0:p,
	H=H+(-1)^k*gamma(p+1)/gamma(p-k+1)/gamma(k+1)*( ( max( 0 , p/2*((abs(Faxis)-wc)/alpha/wc+1)-k )).^p - (p-k).^p);
end
H=-H/gamma(p+1);

%Displaying
if disp=='y'
	plot(Faxis,H)
	axis([-pi pi 0 max(H)])
	xlabel('w (rad)')
	ylabel('H(w)')
end
