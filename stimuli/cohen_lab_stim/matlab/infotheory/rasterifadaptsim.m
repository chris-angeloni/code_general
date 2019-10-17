%
%function [taxis,RASTER]=rasterifadaptsim(Im,Tau,Taum,Taus,Gm,Gs,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,L,In,detrendim,detrendin)
%
%       FILE NAME       : RASTER IF ADAPT SIM
%       DESCRIPTION     : Simulates a noisy action potential sequence by 
%			  presenting a reference input to an integrate-
%			  fire model neuron and adding a noise current.
%			  Generates an L trial Rastrergram
%
%	Im		: Input Membrane Current Signal
%	Tau		: Integration time constant (msec)
%        Taum        : Membrane dependent threshold-adaptation time constant (msec)
%        Taus        : Spike dependent threhold-adaptation time constant (msec)
%        Gm          : Threshold-membrane voltage coupling gain
%        Gs          : Threshold-spike coupling gain
%	Tref		: Refractory Period (msec)
% 	Vtresh		: Threshold Membrane Potential (mVolts)
% 	Vrest		: Resting Membrane Potential - Same as the Leackage
% 			  Membrane Potential (mVolts)
% 	Nsig		: Number of standard deviations of the
% 			  intracellular voltage to set the spike
% 			  threshold
% 	SNR		: Signal to Noise Ratio (dB)
% 	Fs		: Sampling Rate
%       flag            : flag = 0: Voltage variance is constant (Default)
%                                   sig_m = (Vtresh-Vrest)/Nsig
%                                   SNR is determined by Current
%                                1: Total Voltage variance is constant
%                                   sig_tot = (Vtresh-Vrest)/Nsig
%                                   SNR is determined by Current
%                                2: Voltage Variance is Constant
%                                   SNR is determined by the Voltage
%                                3: Total Voltage Variance is constant
%                                   sig_tot = (Vtresh-Vrest)/Nsig
%                                   SNR is determined by the Voltage
%
%	L		: Number of Trials for simulation (Default==25)
%	In		: Intracellular Synaptic Noise (Optional, its
%			  duration should be at least twice as long as Im
%			  length(In) > 2*length(Im) ). If not pressent assumes
%			  white noise
%	detrendim       : Removes time constant from Im if desired ('y' or 'n')
%			  (Default=='n'). This detrending is usefull if you
%			  know the desired intracellular voltage Vm, but not
%			  the intracellular current.
%	detrendin       : Removes time constant from Im if desired ('y' or 'n')
%			  (Default=='n'). This detrending is usefull if you
%			  know the desired intracellular noise voltage but
%			  not the intracellular noise current.
%
%Returned Variables
%	taxis		: Time Axis
%	RASTER		: Rastergram Matrix
%
function [taxis,RASTER]=rasterifadaptsim(Im,Tau,Taum,Taus,Gm,Gs,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,L,In,detrendim,detrendin)

%Input Arguments
if nargin<13
	flag=0;
end
if nargin<14
	L=25;
end
if nargin<15
	detrendim='n';
end
if nargin<16
	detrendim='n';
end

%Simulating integrate-fire neuron and generating a response raster
M=length(Im);
RASTER=[];
for k=1:L
	%Displaying Output
	clc,disp(['Generating Rastergram - Trial Number: ' num2str(k)])

	%Generating Intracellular Noise Signal if Necessary
	if ~exist('In')
		Int=randn(size(Im));
	else
		start=round(rand*(length(In)-length(Im)-200)+1);
		Int=In(start+1:start+M);
	end


	%Generating Rastergram
	X=integratefireadapt(Im,Tau,Taum,Taus,Gm,Gs,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,Int,detrendim,detrendin);
	RASTER=[RASTER;X];
end
taxis=(1:size(RASTER,2))/Fs;
