%function [Faxis,H] = hprotosum(p,alpha,wc,wres)
%
%       FILE NAME       : Hprotosum 
%       DESCRIPTION     : B-Spline implementation of Frequency domain   
%                         Escabi / Roark Filter Function. Sums two Orthogonal 
%			  Filter prototypes.
%	p		: Smoothing parameter (>1)
%	alpha		: TW Parameter (0,1)
%	wc		: Cutoff Frequency
%	wres		: Resolution in Frequency domain (>0)
%
function [Faxis,H] = hprotosum(p,alpha,wc,wres)

%Setting up Arrays
Faxis=-pi:wres:2*pi;
H=zeros(size(Faxis));
H2=zeros(size(Faxis));

%Calculating Filter Function from B-Spline Derivation
for k=0:p,
	H=H+(-1)^k*gamma(p+1)/gamma(p-k+1)/gamma(k+1)*( ( max( 0 , p/2*((abs(Faxis)-wc)/alpha/wc+1)-k )).^p - (p-k).^p);
H2=H2+(-1)^k*gamma(p+1)/gamma(p-k+1)/gamma(k+1)*( ( max( 0 , p/2*((abs(Faxis-2*wc)-wc)/alpha/wc+1)-k)).^p-(p-k).^p);

end
H=-H/gamma(p+1);
H2=-H2/gamma(p+1);

%Displaying
figure(1)
hold off
plot(Faxis,H)
hold on
plot(Faxis,H2,'-g')
axis([-pi 2*pi 0 max(H)])
xlabel('w (rad)')
ylabel('H(w)')
hold on
figure(2)
plot(Faxis,H+H2)
axis([-pi 2*pi 0 max(H)])
