%
%function [FSI1,FSI2,FSI3]=fsibin2(p1A,p1B,p2A,p2B,p1r,p2r,spindex1A,spindex1B,spindex2A,spindex2B)
%
%	FILE NAME       : FSI BIN 2
%	DESCRIPTION     : Evaluates the binaural feature selectivity index
%			  using the strfvar data derived from dBVar and LinVar
%			  Analysis. Derived for reapeated sound presentations.
%
%	p1A		: Array of correlation coefficients for chan 1 trial A
%	p1B		: Array of correlation coefficients for chan 1 trial B
%	p1r		: Array of correlation coefficients for random spikes 
%			  for chan 1
%	p2A		: Array of correlation coefficients for chan 2 trial A
%	p2B		: Array of correlation coefficients for chan 2 trial B
%	p2r		: Array of correlation coefficients for random spikes
%			  for chan 1
%	spindex1A	: Spike index array for channel 1 trial A
%	spindex1B	: Spike index array for channel 1 trial B
%	spindex2A	: Spike index array for channel 2 trial A
%	spindex2B	: Spike index array for channel 2 trial B
%
%RETURNED VALUE
%	FSI1		: Feature selectivity index - derived from CDF
%	FSI2		: Feature selectivity index - derived from Mean
%	FSI3		: Feature selectivity index - derived from Median
%
function [FSI1,FSI2,FSI3]=fsibin2(p1A,p1B,p2A,p2B,p1r,p2r,spindex1A,spindex1B,spindex2A,spindex2B)

%Aligning p1 and p2 - This is brute force but it works!!!
L=length(spindex1A);
count=1;
for k=1:L
	i=find(spindex2A==spindex1A(k));
	if ~isempty(i)
		p2Atemp(count)=p2A(i);
		p1Atemp(count)=p1A(k);
		count=count+1;
	end
end
p2A=p2Atemp;
p1A=p1Atemp;
clear p2Atemp p1Atemp;
L=length(spindex1B);
count=1;
for k=1:L
	i=find(spindex2B==spindex1B(k));
	if ~isempty(i)
		p2Btemp(count)=p2B(i);
		p1Btemp(count)=p1B(k);
		count=count+1;
	end
end
p2B=p2Btemp;
p1B=p1Btemp;
clear p2Btemp p1Btemp;

%Truncating Random Arrays
L=min(length(p1r),length(p2r));
p1r=p1r(1:L); 
p2r=p2r(1:L); 

%Generating Cummulative Distribution Function
[X,Y,NA]=hist2(p1A,p2A,-0.984:0.064:1,-0.984:0.064:1);
[X,Y,NB]=hist2(p1B,p2B,-0.984:0.064:1,-0.984:0.064:1);
N=(NA+NB)/(sum(sum(NB))+sum(sum(NA))); 
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
Mean=sqrt(mean([p1A p2A])^2+mean([p2A p2B])^2);
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
