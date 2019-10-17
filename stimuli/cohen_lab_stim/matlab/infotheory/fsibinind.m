%
%function [FSIind]=fsibinind(p1,p2,p1r,p2r)
%
%	FILE NAME       : FSI BIN IND
%	DESCRIPTION     : Evaluates the binaural feature selectivity index
%			  using the strfvar data derived from dBVar
%			  and LinVar Analysis
%			  Assumes the contra and ipsi responses are
%			  INDEPENDENT
%
%	p1		: Array of correlation coefficients for chan 1
%	p1r		: Array of correlation coefficients for 
%			  random spikes for chan 1
%	p2		: Array of correlation coefficients for chan 2 
%	p2r		: Array of correlation coefficients for 
%			  random spikes for chan 1
%
%RETURNED VALUE
%	FSIind		: Feature selectivity index - derived from CDF
%			  Assumes independent contra and ipsi responses
%
function [FSIind]=fsibinind(p1,p2,p1r,p2r)

%Generating Cummulative Distribution Function - Ch1
[N1,X1]=hist(p1,-3:.0626:1);
N1=N1/sum(N1);
[N1r,X1r]=hist(p1r,-3:.0626:1);
N1r=N1r/sum(N1r);
CDF1=(intfft(N1)-min(intfft(N1))) / (max(intfft(N1))-min(intfft(N1)));
CDF1r=(intfft(N1r)-min(intfft(N1r))) / (max(intfft(N1r))-min(intfft(N1r)));

%Generating Cummulative Distribution Function - Ch2
[N2,X2]=hist(p2,-3:.0626:1);
N2=N2/sum(N2);
[N2r,X2r]=hist(p2r,-3:.0626:1);
N2r=N2r/sum(N2r);
CDF2=(intfft(N2)-min(intfft(N2))) / (max(intfft(N2))-min(intfft(N2)));
CDF2r=(intfft(N2r)-min(intfft(N2r))) / (max(intfft(N2r))-min(intfft(N2r)));

%Generating Cummulative Distribution Function - Ideal Feature Detector
CDFi=zeros(1,64);
CDFi(64)=1;

%Feature Selectivity Index for Independent Contra and Ipsi Channels
FSIind=(sum(CDF1r)*sum(CDF2r)-sum(CDF1)*sum(CDF2))/(sum(CDF1r)*sum(CDF2r)-sum(CDFi)*sum(CDFi));
