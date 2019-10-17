%
%function [X,Vm]=ifneuron(Im,Tau,Tref,Vtresh,Vrest,Fs,In,detrendim,detrendin)
%
%   FILE NAME       : IF NEURON C
%   DESCRIPTION     : Integrate and fire model neuron. C versions for MEX
%                     file generation
%
%   Im              : Input Membrane Current Signal
%   Tau             : Integration time constant (msec)
%   Tref            : Refractory Period (msec)
%   Vtresh          : Threshold Membrane Potential (mVolts)
%   Vrest           : Resting Membrane Potential - Same as the Leackage
%                     Membrane Potential (mVolts)
%   Fs              : Sampling Rate
%   In              : Noise current signal
%   detrendim       : Removes time constant from Im if desired ('y' or 'n')
%                     (Default=='n'). This detrending is usefull if you 
%                     know the desired intracellular voltage Vm, but not
%                     the intracellular current.
%   detrendin       : Removes time constant from Im if desired ('y' or 'n')
%                     (Default=='n'). This detrending is usefull if you
%                     know the desired intracellular noise voltage but 
%                     not the intracellular noise current.
%
%OUTPUT SIGNAL
%
%   X               : Spike Train
%   Vout            : Output Voltage Signal
%   R               : Leackage Resistance
%   C               : Membrane Capacitance
%   sigma_m         : Standard Deviation for membrane potential, Vm(t)
%   sigma_i         : Standard Deviation of input current, Im(t)
%   sigma_n         : Standard Deviation of Noise current, n(t)
%   sigma_tot       : Standard Deviation for total current, Im(t)+n(t)
%
% (C) Monty A. Escabi, 2015
%
function [X,Vm]=ifneuronc(Im,Tau,Tref,Vtresh,Vrest,Fs,In,detrendim,detrendin)
%#codegen
coder.inline('never')

%Input Arguments
if nargin<8
	detrendim='n';
end
if nargin<9
	detrendin='n';
end

%Setting Parameters
Tau=Tau/1000;               % Integration Time Constant
Tref=Tref/1000;             % Refractory Period
dt=1/Fs;                    % Sampling Interval
R=100E6;                    % Membrane Resistance
C=Tau/R;                    % Membrane Capacitance
Nref=max(round(Tref*Fs),1);	% Number of Samples for Refractory Period

%Removing Time Constant from Im and In if desired
if strcmp(detrendim,'y')
	Im(1:length(Im)-1)=diff(Im)*Fs*Tau/R+Im(1:length(Im)-1)/R;
	Im(length(Im))=Im(length(Im))*(Tau*Fs+1)/R;
end
if strcmp(detrendin,'y')
	In(1:length(In)-1)=diff(In)*Fs*Tau/R+In(1:length(In)-1)/R;
	In(length(In))=In(length(In))*(Tau*Fs+1)/R;
end

%Integrating Membrane Potential
Vm=zeros(1,length(Im));
X=zeros(size(Vm));
k=1;
%Itot=Im+In-mean(Im+In);
Itot=Im+In;
while k<length(Im)

	%Integration
	Vm(k+1)=(1-dt/R/C)*Vm(k) + dt/C*( Itot(k) ) ;

	%Thresholding Spike Train
	if Vm(k+1)>Vtresh-Vrest
		%Adding Spike
		X(k+1)=Fs;

		%Reseting Potential and Delaying By Refractory Period
		Vm(k+1)=55-Vrest;	%Action Potential
		k=k+1+Nref;
	else
		k=k+1;
	end
end