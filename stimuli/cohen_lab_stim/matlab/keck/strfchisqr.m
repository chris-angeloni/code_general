%
%function [p,X2,V]=strfchisqr(STRF,STRFm,STRFr,MaxFm,MaxRD)
%
%       FILE NAME       : STRF CHI SQR
%       DESCRIPTION     : Chi Square Goodness of Fit Analyisis for STRFm
%			  Determines if residuals: E=STRF-STRFm 
%			  follow a Normal distribution
%
%	STRF		: Original STRF, If significant STRF it uses only
%			  nonzero sample points for analysis
%	STRFm		: Model STRF
%	STRFr		: Noise STRF
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
function [p,X2,V]=strfchisqr(taxis,faxis,STRF,STRFm,STRFr,MaxFm,MaxRD)

%Downsampling so that samples are uncorrelated
dt=taxis(2)-taxis(1);
dX=log2(faxis(2)/faxis(1));
DFt=ceil(1/dt/MaxFm/2);
DFs=ceil(1/dX/MaxRD/2);
Nt=size(STRF,2);
Ns=size(STRF,1);
STRF=STRF(1:DFs:Ns,1:DFt:Nt);
STRFm=STRFm(1:DFs:Ns,1:DFt:Nt);
STRFr=STRFr(1:DFs:Ns,1:DFt:Nt);

%Finding Residuals (nonzero only)
i=find(STRF~=0);
E=STRF(i)-STRFm(i);

%Normalize Residuals for Unit STD
STRFr=reshape(STRFr,1,size(STRFr,1)*size(STRFr,2))/mean(std(E));
STRFr=STRFr/mean(std(STRFr));
E=E/mean(std(E));

%Comparing to Distribution from NonCausal Random Samples (Zar, Eq. 22.1, Pg. 463)
dx=0.3;
X=-3:dx:3;
N=hist(E,X);
i=find(N>30);
%P=normpdf(X,0,1)*dx;
P=hist(STRFr,X);
%NP=NP(i(2:length(i)-1));
N=N(i(2:length(i)-1));
P=P(i(2:length(i)-1));

%Computing X^2
NP=P/sum(P)*sum(N);
X2=sum((N-NP).^2./NP);

%Finding Significance Level
V=length(X)-1;
p=1-chi2cdf(X2,V);

