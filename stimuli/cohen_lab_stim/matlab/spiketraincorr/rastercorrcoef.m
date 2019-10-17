%
%function [CC]=rastercorrcoef(RASTER,taxis,sigt)
%
%
%       FILE NAME       : RASTER CORR COEF
%       DESCRIPTION     : Across-trial correlation coefficient. Determines 
%			  the trial standard deviation and p<0.01 and p<0.05 
%			  confidence intervals of Ravg with a Bootstrap 
%			  procedure
%
%	RASTER		: Rastergram
%	taxis		: Time Axis
%	sigt		: Standard deviation for Gaussian Smoothing (msec)
%
%RETURNED VALUES
%	CC		: Across-Trial Correlation Coefficient Array
%
function [CC]=rastercorrcoef(RASTER,taxis,sigt)

%Input Arguments
if nargin<4
	NB=500;
end

%Rastergram Lenght
L=size(RASTER,2);
M=size(RASTER,1);

%Sampling Rate
Fs=1/(taxis(2)-taxis(1));

%Normalizing Rastergram so that maximum bin value is 1/dt=Fs
RASTER=RASTER*Fs;

%Smoothing Rastergram
sigt=sigt/1000;
N=round(3*sigt*Fs);
t=(-N:N)/Fs;
H=exp(-t.^2/2/sigt^2);
H=H/sum(H);
for k=1:M
	RAS(k,:)=conv(H,RASTER(k,:));
end
RASTER=RAS(:,N:L-N);	%Removing Edges
clear RAS

%Finding the Average Cross-Trial Correlation Coefficient
%symetry allows us to reduce computation
R=[];
for k=1:M
	clc
	disp(['Computing cross-channel correlation coefficient for channel: ' num2str(k)])
	for l=1:k-1
		RM=corrcoef(RASTER(k,:),RASTER(l,:));
		R=[R;RM(1,2)];
	end
end
CC=R';
