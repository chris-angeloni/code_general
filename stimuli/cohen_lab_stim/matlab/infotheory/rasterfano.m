%
%function [Var,Mean]=rasterfano(RASTER,taxis,Fsd)
%
%
%       FILE NAME       : RASTER FANO
%       DESCRIPTION     : Fano Factor from Rastergram
%
%	RASTER		: Rastergram
%	taxis		: Time Axis
%	Fsd		: Sampling rate for computing CV
%
function [Var,Mean]=rasterfano(RASTER,taxis,Fsd)

%Temporal Resolution
dt=1/Fsd;

%Making A Smoothing Window
W=ones(1,ceil(dt/taxis(1)));

%Convolving Smoothing Window With RASTER
if length(W)>1
	for k=1:size(RASTER,1)
		RASTERc(k,:)=conv(RASTER(k,:),W);
	end
else
	RASTERc=RASTER;
end

%Finding Variance and Mean
Var=var(RASTERc);
Mean=mean(RASTERc);

