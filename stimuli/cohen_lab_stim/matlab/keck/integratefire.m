%
%function [X,Vm,R,C,sigma_m,sigma_i]=integratefire(Im,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,In,detrendim,detrendin)
%
%   FILE NAME       : INTEGRATE FIRE
%   DESCRIPTION     : Integrate and fire model neuron
%
%   Im              : Input Membrane Current Signal
%   Tau             : Integration time constant (msec)
%   Tref            : Refractory Period (msec)
%   Vtresh          : Threshold Membrane Potential (mVolts)
%   Vrest           : Resting Membrane Potential - Same as the Leackage
%                     Membrane Potential (mVolts)
%   Nsig            : Number of standard deviations of the
%                     intracellular voltage to set the spike threshold
%   SNR             : Signal to Noise Ratio (dB)
%   Fs              : Sampling Rate
%   flag            : flag = 0: Voltage variance is constant (Default)
%                     sig_m = (Vtresh-Vrest)/Nsig
%                     SNR is determined by Current
%                     1: Total Voltage variance is constant
%                        sig_tot = (Vtresh-Vrest)/Nsig
%                        SNR is determined by Current
%                     2: Voltage Variance is Constant
%                        SNR is determined by the Voltage
%                     3: Total Voltage Variance is constant
%                        sig_tot = (Vtresh-Vrest)/Nsig
%                        SNR is determined by the Voltage
%   In              : Noise current signal (Optional: Default = synaptic noise)
%   detrendim       : Removes time constant from Im if desired ('y' or 'n')
%                     (Default=='n'). This detrending is usefull if you 
%                     know the desired intracellular voltage Vm, but not
%                     the intracellular current.
%   detrendin       : Removes time constant from Im if desired ('y' or 'n')
%                     (Default=='n'). This detrending is usefull if you
%                     know the desired intracellular noise voltage but 
%                     not the intracellular noise current.
%
%OUTPUT VARIABLES
%
%   X               : Spike Train
%   Vout            : Output Voltage Signal
%   R               : Leackage Resistance
%   C               : Membrane Capacitance
%   sigma_m         : Standard Deviation for membrane potential, Vm(t)
%   sigma_i         : Standard Deviation of input current, Im(t)
%
% (C) Monty A. Escabi, 2005
%
function [X,Vm,R,C,sigma_m,sigma_i]=integratefire(Im,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,In,detrendim,detrendin)

%Input Arguments
if nargin<9
	flag=0;
end
if nargin<11
	detrendim='n';
end
if nargin<12
	detrendin='n';
end

%Generating Internal Noise Signal
if nargin<10
	In=synapticnoise(25,3,5,1,1,3,100,1,Fs,length(Im));
end

%Setting Parameters
SNR=10^(SNR/20);

%Removing Means and Scaling
Im=Im-mean(Im);
In=In-mean(In);
Im=Im/std(Im)*1E-7;
In=In/std(In)*1E-7;

% Matching the Standard Devation for Im(t) to Give the 
% Required Standard Deviation for Vm(t)
if flag==0	%Current SNR, Nsig determined by Im

	Im=Im;
    In=In/SNR;

	%Matching the Voltage signal to noise ratio
	[X,VIm]=ifneuron(Im,Tau,Tref,1000,Vrest,Fs,zeros(size(Im)),detrendim,detrendin);
	[X,VIn]=ifneuron(zeros(size(Im)),Tau,Tref,1000,Vrest,Fs,In,detrendim,detrendin);

	%Scaling Currents for desired Nsig and voltage SNR
	sigma_m=(Vtresh-Vrest)/Nsig;
	Im=Im*sigma_m/std(VIm);
	In=In*sigma_m/std(VIm);

end
if flag==1	%Current SNR, Nsig determined by Im+In


	Im=Im;
	In=In/SNR;	
	
	%Matching the Voltage signal to noise ratio
	[X,VIm]=ifneuron(Im,Tau,Tref,1000,Vrest,Fs,zeros(size(Im)),detrendim,detrendin);
	[X,VIn]=ifneuron(zeros(size(Im)),Tau,Tref,1000,Vrest,Fs,In,detrendim,detrendin);

	%Scaling Currents for desired voltage SNR
	sigma_m=(Vtresh-Vrest)/Nsig;
	Im=Im*sigma_m/std(VIm);
	In=In*sigma_m/std(VIm);

	%Matching the Voltage signal Nsig
	[X,VIm]=ifneuron(Im,Tau,Tref,1000,Vrest,Fs,zeros(size(Im)),detrendim,detrendin);
	[X,VIn]=ifneuron(zeros(size(Im)),Tau,Tref,1000,Vrest,Fs,In,detrendim,detrendin);

	%Scaling Currents for desired voltage Nsig
	Im=Im*sigma_m/std(VIm+VIn);
	In=In*sigma_m/std(VIm+VIn);

end
if flag==2	%Voltage SNR, Nsig determined by Im

	%Matching the Voltage signal to noise ratio
	[X,VIm]=ifneuron(Im,Tau,Tref,1000,Vrest,Fs,zeros(size(Im)),detrendim,detrendin);
	[X,VIn]=ifneuron(zeros(size(Im)),Tau,Tref,1000,Vrest,Fs,In,detrendim,detrendin);

	%Scaling Currents for desired Nsig and voltage SNR
	sigma_m=(Vtresh-Vrest)/Nsig;
	Im=Im*sigma_m/std(VIm);
	In=In*sigma_m/std(VIm)*std(VIm)/std(VIn)/SNR;

end
if flag==3	%Voltage SNR, Nsig determined by Im+In

	
	%Matching the Voltage signal to noise ratio
	[X,VIm]=ifneuron(Im,Tau,Tref,1000,Vrest,Fs,zeros(size(Im)),detrendim,detrendin);
	[X,VIn]=ifneuron(zeros(size(Im)),Tau,Tref,1000,Vrest,Fs,In,detrendim,detrendin);

	%Scaling Currents for desired Nsig and voltage SNR
	sigma_m=(Vtresh-Vrest)/Nsig;
	Im=Im*sigma_m/std(VIm)*sigma_m/sqrt(sigma_m^2+(sigma_m/SNR)^2);
	In=In*sigma_m/std(VIm)*std(VIm)/std(VIn)/SNR*sigma_m/sqrt(sigma_m^2+(sigma_m/SNR)^2);

end

%Simulating Integrate & Fire Neuron
[X,Vm,R,C]=ifneuron(Im,Tau,Tref,Vtresh,Vrest,Fs,In,detrendim,detrendin);

%Estimating Input Current STD
sigma_i=std(Im);
