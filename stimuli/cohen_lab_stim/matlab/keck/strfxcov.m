%
%function []=strfxcov(STRF1,STRF2)
%
%       FILE NAME       : STRF X COV
%       DESCRIPTION     : Cross covariance computed for two STRFs 
%	
%	STRF1		: 1st Spectro Temporal Receptive Field
%	STRF2		: 2nd Spectro Temporal Receptive Field
%
function [R,Std1,Std2]=strfxcov(STRF1,STRF2)

%Finding statistically significant points
[i,j]=find(abs(STRF1)>0 | abs(STRF2)>0);
for k=1:length(i)
	X1(k)=STRF1(i(k),j(k));
	X2(k)=STRF2(i(k),j(k));
end

%Computing corr-coef from statistically significant points
R=corrcoef(X1,X2);
Std1=std(X1);
Std2=std(X2);

