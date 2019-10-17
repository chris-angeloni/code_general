%
%function [SI1,SI2,PDF,CDF]=sipdfcdf(p1,p2,p1r,p2r,spindex1,spindex2)
%
%	FILE NAME       : SI PDF CDF
%	DESCRIPTION     : Computed the feature selectivity index
%			  PDF and CDF using the strfvar data derived from 
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
%	SI1		: Similarity Index for Chan. 1 
%	SI2		: Similarity Index for Chan. 2
%	PDF		: SI Probability Distribution Function
%	CDF		: SI Cummulative Distribution Function
%	PDFr		: SI Probability Distribution Function for random 
%			  response condition
%	CDFr		: SI Cummulative Distribution Function for random
%			  response condition
%
function [SI1,SI2,PDF,CDF,PDFr,CDFr]=sipdfcdf(p1,p2,p1r,p2r,spindex1,spindex2)

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
[SI1,SI2,PDF]=hist2(p1,p2,-0.984:0.064:1,-0.984:0.064:1);
PDF=PDF/sum(sum(PDF));
[SI1,SI2,PDFr]=hist2(p1r,p2r,-0.984:0.064:1,-0.984:0.064:1);
PDFr=PDFr/sum(sum(PDFr));
CDF=intfft2(PDF,'y');
CDF=(CDF-min(min(CDF)))/(max(max(CDF))-min(min(CDF)));
CDFr=intfft2(PDFr,'y');
CDFr=(CDFr-min(min(CDFr)))/(max(max(CDFr))-min(min(CDFr)));


