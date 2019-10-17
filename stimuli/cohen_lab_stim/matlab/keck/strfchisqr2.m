%
%function [p,X2,V]=strfchisqr(taxis,faxis,STRF,STRFm1,STRFm2,MaxFm,MaxRD)
%
%       FILE NAME       : STRF CHI SQR 2
%       DESCRIPTION     : Chi Square Goodness of Fit Analyisis for STRFm
%			  Determines if residuals for a first order model
%			  E1=STRF-STRFm1 and compares to residuals from a 
%			  second order model E2=STRF-STRFm2
%
%	STRF		: Original STRF, If significant STRF it uses only
%			  nonzero sample points for analysis
%	STRFm1		: First order Model STRF
%	STRFm2		: Second order Model STRF
%	MaxFm		: Maximum temperal modulation
%	MaxRD		: Maximu ripple density
%
%RETURNED VARIABLES
%	p		: Significance Level
%	X2		: Chi Square Value
%	V		: degrees of freedom
%
%	For details see Zar Eq. 22.1, Pg. 463
%
function [p,X2,V]=strfchisqr(taxis,faxis,STRF,STRFm1,STRFm2,MaxFm,MaxRD)

%Downsampling so that samples are uncorrelated
dt=taxis(2)-taxis(1);
dX=log2(faxis(2)/faxis(1));
DFt=ceil(1/dt/MaxFm/2);
DFs=ceil(1/dX/MaxRD/2);
Nt=size(STRF,2);
Ns=size(STRF,1);
STRF=STRF(1:DFs:Ns,1:DFt:Nt);
STRFm1=STRFm1(1:DFs:Ns,1:DFt:Nt);
STRFm2=STRFm2(1:DFs:Ns,1:DFt:Nt);

%Finding Residuals (nonzero only)
i=find(STRF~=0);
E1=STRF(i)-STRFm1(i);
E2=STRF(i)-STRFm2(i);

%Normalize Residuals for Unit STD
STRFr=reshape(STRFr,1,size(STRFr,1)*size(STRFr,2))/mean(std(E));
STRFr=STRFr/mean(std(STRFr));
E=E/mean(std(E));

%Comparing to Distribution from NonCausal Random Samples (Zar, Eq. 22.1, Pg. 463)
dx=0.3;
X=-3:dx:3;
N1=hist(E1,X);
N2=hist(E2,X);
i1=find(N1>30 & N2>30);
N1=N1(i(2:length(i)-1));
N2=N2(i(2:length(i)-1));

%Computing X^2
X2=sum((N1-N2).^2./N2);

%Finding Significance Level
V=length(X)-1;
p=1-chi2cdf(X2,V);

