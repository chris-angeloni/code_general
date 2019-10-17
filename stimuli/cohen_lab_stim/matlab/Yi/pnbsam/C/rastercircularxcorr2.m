function [Ravg,Rstd,R05,R01,R]=rastercircularxcorr2(RASTER,Fsd,NB)

T=RASTER(1).T;
[RAS,Fs]=rasterexpand(RASTER,Fsd,T);
ntrial = size(RAS,1);

RASv=matrixh2v(RAS);
rmatrix = mexrascxcorr(RASv,ntrial);
rmatrix = rmatrix/Fsd/T;

R = matrixv2h(rmatrix);

if size(R,1)>1
	Ravg=mean(R);
else
	Ravg=R;
end
if NB~=0
	[Rstd,R05,R01]=rastercorrbootstrap(R,NB);
else
	R05=-9999;
	R01=-9999;
end
