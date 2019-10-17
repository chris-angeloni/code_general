%
%function [Y,Vm,R,C,sigma_m,sigma_i,sigma_n,sigma_tot]=msintegratefire(spetp,Fsp,Tau,Tref,tdelay,Vtresh,Vrest,Nsig,SNR,Fs,flag,In)
%
%       FILE NAME       : MS INTEGRATE FIRE
%       DESCRIPTION     : Mono-Synaptic Integrate and fire model neuron
%			  Membrane Current is Generated Dynamically from 
%			  spetp using EPSP
%
%	spetp		: Pre-Synaptic Spike Event Times Input
%	Fsp		: Sampling Rate for Presynaptic SPET
%	Tau		: Integration time constant (msec)
%	Tref		: Refractory Period (msec)
%	tdelay		: Mono-Synaptic Time Delay
%	Vtresh		: Threshold Membrane Potential (mVolts)
%	Vrest		: Resting Membrane Potential - Same as the Leackage
%			  Membrane Potential (mVolts)
%	Nsig		: Number of standard deviations of the
%			  intracellular voltage to set the spike
%			  threshold
%	SNR		: Signal to Noise Ratio ( SNR~=0 )
%			  SNR = sigma_in^2/sigma_n^2
%	Fs		: Sampling Rate
%	flag		: flag = 0: Input current variance is constant (Default)
%			            sig_tot^2 = sig_i^2 + sig_n^2
%				    where sig_n = sig_i/sqrt(SNR)  and 
%				    sig_i=constant is choosen so that 
%				    sig_m = (Vtresh-Vrest)/Nsig
%				 1: Total current variance is constant
%				    Same as 0 except that sig_tot is chosen so
%				    so that sig_m = (Vtresh-Vrest)/Nsig
%	In		: Noise current signal (Optional: Default = 1/f noise)
%
%OUTPUT SIGNAL
%	Y		: Post-Synaptic Spike Train
%	Vout		: Output Voltage Signal
%	R		: Leackage Resistance
%	C		: Membrane Capacitance
%	sigma_m		: Standard Deviation for membrane potential, Vm(t)
%	sigma_i		: Standard Deviation of input current, Im(t)
%	sigma_n		: Standard Deviation of Noise current, n(t)
%	sigma_tot	: Standard Deviation for total current, Im(t)+n(t)
%
function [Y,Vm,R,C,sigma_m,sigma_i,sigma_n,sigma_tot]=msintegratefire(spetp,Fsp,Tau,Tref,tdelay,Vtresh,Vrest,Nsig,SNR,Fs,flag,In)

%Input Arguments
if nargin<11
	flag=0;
end

%Setting Parameters
Tau=Tau/1000;			% Integration Time Constant
Tref=Tref/1000;			% Refractory Period
tdelay=tdelay/1000;		% Monosynaptic Delay
Ndelay=round(tdelay*Fs);	% Monosynaptic Delay in Samples
dt=1/Fs;			% Sampling Interval
R=100E6;			% Membrane Resistance
C=Tau/R;			% Membrane Capacitance
Nref=ceil(Tref*Fs);		% Number of Samples for Refractory Period
sigma_m=(Vtresh-Vrest)/Nsig;	% Standard deviation for Vm(t)

%Generating Presynamptic Spike Train
X=[spet2impulse(spetp,Fsp,Fs) zeros(1,1000)];

%Initializing Array
Vm=zeros(1,length(X));

d1=1;
d2=3;
alpha=1;

%Generating Intracellular Membrane Current, Im (No Spikes)
%Need This to Derive the Membrane Current Im
k=1;
Im=zeros(size(X));
while k<length(Vm)
	
	%Generating EPSC (Excitatory Post Synaptic Current)
	if X(k)~=0
		EPSC=epsp(d1,d2,alpha,Fs);
		Im(k+Ndelay:k+Ndelay+length(EPSC)-1)=EPSC ... 
			+Im(k+Ndelay:k+Ndelay+length(EPSC)-1);
	end

	%Integration
	Vm(k+1)=(1-dt/R/C)*Vm(k) + dt/C*( Im(k) ) ;
	k=k+1;
end

%Generating Internal Noise Signal

if nargin<12
%	[time,Noise]=n1overf(0,Fs/2,1,Fs,length(Vm));
	Noise=randn(1,length(Vm));
else
	Noise=In;
end

%Normalizing Im or Im+Noise for unity STD and zero mean
if flag==0
	Itot=(Im-mean(Im))/std(Im);
	Itot=Itot-min(Itot);
	Im=Itot;
else
	%Input Current
	Im=(Im-mean(Im))/std(Im);
	Im=Im-min(Im);

	%Finding Noise Level
	Noise=(Noise-mean(Noise))/std(Noise)/sqrt(SNR);
	Itot=Im+Noise;

	%Normalizing sig_tot=1
	Im=(Im-mean(Im))/std(Itot);
	Im=Im-min(Im);
	Noise=(Noise-mean(Noise))/std(Itot);
	Itot=Im+Noise;
end


%Integrating Membrane Potential to determine STD WITHOUT SPIKES!!!
Vm=zeros(1,length(Im));
k=1;
while k<length(Vm)
	%Integration
	Vm(k+1)=(1-dt/R/C)*Vm(k) + dt/C*( Itot(k) ) ;
	k=k+1;
end

% Matching the Standard Devation for Im(t) to Give the 
% Required Standard Deviation for Vm(t)
if flag==0
	%Current STD
	sigma_i=sigma_m/std(Vm);

	%Normalizing Threshold and Noise
	%Vth=NSig*Std;
	Im=sigma_i*Im;
	Noise=sigma_i/sqrt(SNR)*Noise/std(Noise);
	sigma_n=std(Noise);

	%Total Intracellular Current
	Itot=Im+Noise;
	sigma_tot=std(Itot);
else
	%Total Current STD
	sigma_tot=sigma_m/std(Vm);

	%Normalizing Threshold and Noise
	%Vth=NSig*Std;
	Itot=sigma_tot*Itot;
	sigma_n=sigma_tot/sqrt(1+SNR);
	sigma_i=sigma_n*sqrt(SNR);
end

%Integrating Membrane Potential
Vm=zeros(1,length(Im));
Y=zeros(size(Vm));
k=1;
%Itot=Noise;
Itot=Itot;
while k<length(Im)

	%Generating EPSC (Excitatory Post Synaptic Current)
%	if X(k)~=0
%		EPSC=epsp(d1,d2,alpha,Fs);
%		Itot(k+Ndelay:k+Ndelay+length(EPSC)-1)=EPSC ... 
%			+Itot(k+Ndelay:k+Ndelay+length(EPSC)-1);
%	end

	%Integration
	Vm(k+1)=(1-dt/R/C)*Vm(k) + dt/C*( Itot(k) ) ;

	%Thresholding Spike Train
	if Vm(k+1)>Vtresh-Vrest
		%Adding Spike
		Y(k+1)=1;

		%Reseting Potential and Delaying By Refractory Period
		Vm(k+1)=55-Vrest;	%Action Potential
		k=k+Nref;
	else
		k=k+1;
	end
end


