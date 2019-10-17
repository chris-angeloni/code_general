%
%function [FSI1,FSI2,FSI3]=fsibin(p1,p2,p1r,p2r,spindex1,spindex2)
%
%	FILE NAME       : FSI BIN
%	DESCRIPTION     : Evaluates the binaural feature selectivity index
%			  using the strfvar data derived from 
%			  dBVar and LinVar Analysis
%
%	p1		: Array of correlation coefficients for chan 1
%	p1r		: Array of correlation coefficients for 
%			  random spikes for chan 1
%	p2		: Array of correlation coefficients for chan 2 
%	p2r		: Array of correlation coefficients for 
%			  random spikes for chan 1
%	spindex1	: Spike index array for channel 1 
%	spindex2	: Spike index array for channel 2 
%
%RETURNED VALUE
%	FSI1		: Feature selectivity index - derived from CDF
%	FSI2		: Feature selectivity index - derived from Mean
%	FSI3		: Feature selectivity index - derived from Median
%
function [FSI1,FSI2,FSI3]=fsibin(p1,p2,p1r,p2r,spindex1,spindex2)

%Aligning p1 and p2 - This is brute force but it works!!!
L=length(spindex1);
count=1;
for k=1:L
	i=find(spindex2==spindex1(k));
	if ~isempty(i)
		p2temp(count)=p2(i);
		p1temp(count)=p1(k);
		count=count+1;
	end
end
p2=p2temp;
p1=p1temp;
clear p2temp p1temp;

%Truncating Random Arrays
L=min(length(p1r),length(p2r));
p1r=p1r(1:L); 
p2r=p2r(1:L); 

%Generating Cummulative Distribution Function
[X,Y,N]=hist2(p1,p2,-0.984:0.064:1,-0.984:0.064:1);
N=N/sum(sum(N));
[X,Y,Nr]=hist2(p1r,p2r,-0.984:0.064:1,-0.984:0.064:1);
Nr=Nr/sum(sum(Nr));
CDF=intfft2(N,'y');
CDF=(CDF-min(min(CDF)))/(max(max(CDF))-min(min(CDF)));
CDFr=intfft2(Nr,'y');
CDFr=(CDFr-min(min(CDFr)))/(max(max(CDFr))-min(min(CDFr)));

%Feature Selectivity Index - CDF
CDFi=zeros(32,32);
CDFi(32,32)=1;
FSI1=sum(sum(CDFr-CDF))/sum(sum(CDFr-CDFi));

%Feature Selectivity Index - Mean
Mean=sqrt(mean(p1)^2+mean(p2)^2);
Meanr=sqrt(mean(p1r)^2+mean(p2r)^2);
Meanfd=sqrt(1^2+1^2);
FSI2=(Mean-Meanr)/(Meanfd-Meanr);

%Feature Selectivity Index - Median
i=find(CDF>0.5);
k=find(CDF(i)==min(CDF(i)));
[i,j]=find(CDF==CDF(i(k)));
Median=sqrt(X(i)^2+Y(j)^2);
i=find(CDFr>0.5);
k=find(CDFr(i)==min(CDFr(i)));
[i,j]=find(CDFr==CDFr(i(k)));
Medianr=sqrt(X(i)^2+Y(j)^2);
Medianfd=sqrt(1^2+1^2);
FSI3=(Median-Medianr)/(Medianfd-Medianr);
