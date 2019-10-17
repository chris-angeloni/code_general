%
%function [R,std1,std2]=strfcorrcoef(STRF1,STRF2)
%
%       FILE NAME       : STRF CORR COEF
%       DESCRIPTION     : Compares Two STRFs by computing the correlation
%			  coefficient.  For this analysis to be meaningful 
%			  the statistically significant STRFs are assumed 
%			  as the input.  These can be obatained using 
%			  WSTRFSTAT.
%	
%	STRF1		: Spectro-temporal receptive field 1
%	STRF2		: Spectro-temporal receptive field 2
%
%RETURNED VARIABLES
%	R		: Correlation Coefficient
%	std1		: Standard deviation of STRF1
%	std2		: Standard deviation of STRF2
%
function [R,std1,std2]=strfcorrcoef(STRF1,STRF2)

%Finding Non-Zero values and rearanging STRFs to a linear array
index=find(STRF1~=0 | STRF2~=0);
X1=STRF1(index);
X2=STRF2(index);

%Finding Mean Energy and Correlation Coefficient 
%Note that STRF is assumed zero mean and the
%corrcoef function can therefore not be used
std1=sqrt(mean(X1.^2));
std2=sqrt(mean(X2.^2));
R=mean(X1.*X2)/std1/std2;

