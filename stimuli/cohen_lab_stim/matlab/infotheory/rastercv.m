%
%function [cv]=rastercv(RASTER,taxis,Fsd)
%
%
%       FILE NAME       : RASTER CV
%       DESCRIPTION     : Coefficient of Variation from Rastergram
%
%	RASTER		: Rastergram
%	taxis		: Time Axis
%	Fsd		: Sampling rate for computing CV
%
function [cv]=rastercv(RASTER,taxis,Fsd)

%Temporal Resolution
dt=1/Fsd;

%Making A Smoothing Window
W=ones(1,ceil(dt/taxis(1)));

%Convolving Smoothing Window With RASTER
for k=1:size(RASTER,1)
	RASTERc(k,:)=conv(RASTER(k,:),W);
end

%Finding Variance and Mean
PSTH=sum(RASTERc)/size(RASTERc,1);
for k=1:size(RASTERc,1)
	Var(k,:)=(RASTERc(k,:)-PSTH).^2;
end
Var=mean(Var);
plot(sqrt(Var))
hold on
plot(PSTH,'r')
hold off
cv=mean( (sqrt(Var)+1E-10)./(PSTH+1E-10) );

