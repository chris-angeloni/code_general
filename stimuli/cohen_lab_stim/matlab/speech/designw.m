%
%function [W]=designw(df,ATT,Fs,method)
%
%
%	FILE NAME 	: DESIGN W
%	DESCRIPTION 	: Design a Sinc(a,p) Window given the Spectral 
%			  Resolution (dF)
%
%	df		: Spectral Window resolution as defined by Chui
%			  Note that the overall Fileter Bank Bandwidth is
%			  2*df and the temporal window width is 2*dt
%			  See Note Below!!!
%	ATT		: Attenuation in dB
%	Fs		: Sampling Rate
%	method		: Method used to measure bandwidth and temporal 
%			  resolution
%			  "chui" - measured based on the uncertainty principle
%			  "3dB'  - measured by finding the 3dB points
%			  Default - '3dB' 
% 
% 	Note: By the uncertainty principle  dt*dw > 1/2 or dt*df>1/4/pi
% 		dt = std(W(t))
% 		dw = std(W(w)) or df=std(W(f))
%
% 	This is the Chui deffinition but I will use slightly different
%       definition.  Instead I use:
%
%        	dt = 2 * std(W(t))
%        	df = 2 * std(W(f))
%
%        under these conditions the uncertainty principle becomes:
%        
%        	dt * df > 1/pi
%
function [W]=designw(df,ATT,Fs,method)

%Input Arguments
if nargin<4
	method='3dB';
end

%Finding Sinc(a,p) window as designed by Roark / Escabi
%Initial Guess At parameters
%Note that ATT for Lowpass Sinci(a,p) Filter is 20.96 dB more
%than for the Sinc(a,p) window alone - Because filter has 
%convolved component from GIBBS Fenomenon
Ts=1/Fs;
dw=2*2*pi*df/Fs;
[p,M,alpha,wc] = fdesignh(ATT+20.96,dw,pi/4);
naxis=-M:M;
W=w(naxis,wc,alpha,p);

if strcmp(method,'chui')
	%Recuresively Re-estimating Parameters
	[dT,dF]=finddtdfw(W,Fs,1024*32);
	count=1;
	while abs(df-dF)/df>0.05 & count<=10
	
		if (df-dF)>0	
			dw=dw*1.24;
		else
			dw=dw*0.8;
		end
	
		[p,M,alpha,wc] = fdesignh(ATT+20.096,dw,pi/4);
		naxis=-M:M;
		W=w(naxis,wc,alpha,p);
		W=W./sqrt(sum(W.^2)*Ts);	%So that Window has Unit Energy
		[dT,dF]=finddtdfw(W,Fs,1024*32);
		count=count+1;

	end
else
	%Recuresively Re-estimating Parameters
	[dT,dF,dT3dB,dF3dB]=finddtdfw(W,Fs,1024*32);
	count=1;
	while abs(df-dF3dB)/df>0.025 & count<=100
	
		if (df-dF3dB)>0	
			dw=dw*1.01;
		else
			dw=dw*0.99;
		end
	
		[p,M,alpha,wc] = fdesignh(ATT+20.096,dw,pi/4);
		naxis=-M:M;
		W=w(naxis,wc,alpha,p);
		W=W./sqrt(sum(W.^2)*Ts);	%So that Window has Unit Energy
		[dT,dF,dT3dB,dF3dB]=finddtdfw(W,Fs,1024*32);
		count=count+1;
	end
end


