%
%function [Rstd,R05,R01]=rastercorrbootstrap(R,NB)
%
%
%   FILE NAME       : RASTER CORR BOOTSTRAP
%   DESCRIPTION     : Uses a bootstrap procedure to estimate significance
%                     of the shuffled correlogram
%
%	R		: Correlogram bootstrapped data samples
%	NB		: Number of itterations for bootstrap
%
%RETURNED VALUES
%	Rstd    : Correlogram standard deviation array
%	R05		: Correlogram p<0.05 confidence interval. 2xlength(R) matrix 
%             containing the possitive and the negative confidence intervals
%	R01		: Correlogram p<0.01 confidence interval. 2xlength(R) matrix
%             containing the possitive and the negative confidence intervals
%
function [Rstd,R05,R01]=rastercorrbootstrap(R,NB)

%Performing bootstrap on correlation functions
M=size(R,1);
for k=1:NB
	%Finding Significance of Distribution with Bootstrap
	disp(['Performing Correlation Bootstrap: ' int2str(k)])
	i=round(1+(M-1)*rand(1,M));
	Rbs(k,:)=mean(R(i,:));
end
Rstd=std(Rbs);

%Finding 0.01 and 0.05 confidence intervals
Rbs=sort(Rbs);
R05n=Rbs(round(0.05/2*NB),:)-mean(Rbs);
R05p=Rbs(round(NB-0.05/2*NB),:)-mean(Rbs);
R01n=Rbs(round(0.01/2*NB),:)-mean(Rbs);
R01p=Rbs(round(NB-0.01/2*NB),:)-mean(Rbs);
R05=[R05p;R05n];
R01=[R01p;R01n];