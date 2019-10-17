%function [Faxis,W] = wproto(p,alpha,wc,wres,disp)
%
%       FILE NAME       : wproto 
%       
%	DESCRIPTION     : B-Spline implementation of Frequency domain   
%                         Escabi / Roark Windowing Function
%	p		: Smoothing parameter (>1)
%	alpha		: TW Parameter (0,1)
%	wc		: Cutoff Frequency
%	wres		: Resolution in Frequency domain (>0)
%
%OPTIONAL
%	disp            : Display : 'y' or 'n' (Default=='n')
%
function [Faxis,W] = wproto(p,alpha,wc,wres,disp)

%Input Arguments
if nargin<5
	disp='n';
end

%Setting up Arrays
Faxis=-5:0.1:5;
W=zeros(size(Faxis));

%Calculating Window Function from B-Spline Derivation
for k=0:p,
	W=W+(-1)^k*gamma(p+1)/gamma(p-k+1)/gamma(k+1)*( max( 0 , p/2*(Faxis+1) -k) ).^(p-1);
end
W=2*W*p/2*1/gamma(p-1+1);
size(W)
size(Faxis)

%Displaying
if disp=='y'
	plot(Faxis,W)
	axis([-pi pi 0 max(W)])
	xlabel('w (rad)')
	ylabel('W(w)')

	%Finding the Area of the Window
	Area=sum(wres*W)
	title('Area = 2*pi')
end

