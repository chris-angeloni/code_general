%
%function [dBAxis,SPLAxis,Var,Mean,Rate,Level]=dbvssplsim(dBAxis,SPLAxis,RMax,RMin,MeanSPL,dSPL,Fx,Tx,Fsd,N)
%
%       FILE NAME       : DB VS SPL SIM
%       DESCRIPTION     : Generates the VAR and MEAN simulated tunning 
%			  curve at multiple MdB and SPL
%
%	dBAxis		: Modulation Axis
%	SPLAxis		: Intensity Axis
%	Rmax		: Maximum firing rate
%	Rmin		: Minimum firing rate
%	MeanSPL		: Mean SPL of Rate Level Function
%	dSPL		: SPL Difference from MeanSPL at which
%		   	  Rate Level Function is .05 and 
%			  .095 of its overall range
%	Fx		: Maximum Frequency of X (input)
%	Tx		: Length of X ( sec )
%	Fsd		: Desired Sampling Rate for Mean and Var
%	N		: Number of Averages 
%
%Returned Variables
%
%	dBAxis		: Modulation Axis
%	SPLAxis		: Intensity Axis
%	Var		: Var Matrix as a function of dB vs SPL
%	Mean		: Mean Matrix as a function of dB vs SPL
%	Rate		: Spike rate array
%	Level		: Intensity array
%
function [dBAxis,SPLAxis,Var,Mean,Rate,Level]=dbvssplsim(dBAxis,SPLAxis,RMax,RMin,MeanSPL,dSPL,Fx,Tx,Fsd,N)

%Input Arguments
if nargin<8
	Disp='y';
end

%Finding Alpha for Rate Level Function
%    0.05=1/(1+exp(-alpha*(x-xo)))
alpha=log(19)/dSPL;

%Computing Mean and Var as a function of dB vs SPL
Var=zeros(length(SPLAxis),length(dBAxis));
Mean=zeros(length(SPLAxis),length(dBAxis));
for j=1:length(SPLAxis)
	for k=1:length(dBAxis)
		for l=1:N

			%Display
			clc
			disp(['Evaluating at SPL=' int2str(SPLAxis(j)),...
			' dB , MdB=' int2str(dBAxis(k)) ' dB , ',...
			'Average=' int2str(l) ' of ' int2str(N)])

			%Input Signal
			X=noiseunif(Fx,1000,round(Tx*1000));
			X=SPLAxis(j)+dBAxis(k)*(X-.5);

			%Output Signal
			Y=hcnl(X,RMax,RMin,MeanSPL,alpha);

			%Output Converted to Spike Train
			spet=poisongen(Y,1000,1000);

			%Output Spike Train Sampled at Fsd
			Y=spet2impulse(spet,1000,Fsd);

			%Finding Mean and Var at resoultion of Fsd
			Mean(j,k)=Mean(j,k)+mean(Y/20)/N;
			Var(j,k)=Var(j,k)+var(Y/20)/N;
		end
	end
end

%Rate Level Function
Level=SPLAxis;
Rate=hcnl(SPLAxis,RMax,RMin,MeanSPL,alpha);
