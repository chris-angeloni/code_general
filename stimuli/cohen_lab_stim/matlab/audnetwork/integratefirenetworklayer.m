%
%function [Y]=integratefirenetworklayer(X,L,TauE,TauI,Tref,Nsig,SNR,SigE,SigI,EIR,Fs,flag,detrendim,detrendin)
%
%   FILE NAME       : INTEGRATE FIRE NETWORK LAYER
%   DESCRIPTION     : Single-layer Excitatory / Inhibitory Network of 
%                     Integrate and fire model neurons
%
%   X               : Input Spike Train Matrix
%   L               : Number of output nuerons
%   TauE            : Excitatory Integration time constant (msec) - time to
%                     reach maximum EPSP amplitude
%   TauI            : Inhibitory Integration time constant (msec) - time to
%                     reach minimum EPSP amplitude
%   Tref            : Refractory Period (msec)
%   Nsig            : Number of standard deviations of the
%                     intracellular voltage to set the spike threshold
%   SNR             : Signal to Noise Ratio (dB)
%   SigE            : Excitatory spatial gaussian integration width 
%                     standard deviation (spatial axis is normalized from 
%                     0 to 1)
%   SigI            : Inhibitory spatial gaussian integration width 
%                     standard deviation (spatial axis is normalized from 
%                     0 to 1)
%   EIR             : Excitatory to inhibitory ratio - normalized so that: StdE=EIR*StdI
%   Fs              : Sampling Rate (Hz)
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
%   Y               : Output Spike Train Matrix (LxN where L is the number
%                     of output neurons and N is the number of time
%                     samples)
%
% (C) Monty A. Escabi, April 2013
%
function [Y]=integratefirenetworklayer(X,L,TauE,TauI,Tref,Nsig,SNR,SigE,SigI,EIR,Fs,flag,detrendim,detrendin)

%Generating Currents and output spikes
M=size(X,1);
for k=1:L
    
    %Spatial Axis - Normalized between [0,1]
    x=(0:M-1)/(M-1);
    mu=(k-1)/(L-1);
    
    %Excitatory Connection Weights
    WE=exp(-(x-mu).^2/SigE.^2/2);
%    WE=WE/sqrt(sum(WE.^2));             %Normalize for power =1 - L2 Norm
    WE=WE/sum(WE);                      %Normalized for L1 norm = 1 
        
    %Inhibotory Connection Weights
    WI=exp(-(x-mu).^2/SigI.^2/2);      
%    WI=WI/sqrt(sum(WI.^2));             %Normalize for power =1 - L2 Norm
    WI=WI/sum(WI);                      %Normalized for L1 norm = 1 
        
    %Generating composite Excitatory and Inhibitory Currents
    ImE=WE*X;
    ImI=WI*X;

    %Convolving Excitatory / Inhibitory currents with EPSP/IPSP
    N=ceil(6*max(TauE,TauI)/1000*Fs);
    time=(0:N-1)/Fs*1000;
    if TauE>0 || TauI>0
        betaE=[0 TauE 1 0];
        betaI=[0 TauI 1 0];
        [EPSP]=alphafxn1model(betaE,time);
        [IPSP]=alphafxn1model(betaI,time);
%        EPSP=EPSP/sqrt(sum(EPSP.^2));   %Normalize for power - L2 norm
%        IPSP=IPSP/sqrt(sum(IPSP.^2));   %Normalize for power - L2 norm
        EPSP=EPSP/sqrt(sum(EPSP));      %Normalize for L1 norm
        IPSP=IPSP/sqrt(sum(IPSP));      %Normalize for L1 norm
        ImE=conv(ImE,EPSP);
        ImI=conv(ImI,IPSP);
    end
    
    %Total Composite Excitatory/Inhibitory Current
    Itot(k,:)=-ImI+EIR*ImE;
    ItotE(k,:)=ImE;
    ItotI(k,:)=ImI;

end

%Generating Noise Signal 
In=randn(size(Itot(k,:)));

%Normalizing Noise and Signal
Itot=Itot/std(reshape(Itot,1,numel(Itot)))*1E-7;
In=In/std(In)*1E-7;

%Setting Parameters
SNR=10^(SNR/20);

% Matching the Standard Devation for Im(t) to Give the 
% Required Standard Deviation for Vm(t)
Vtresh=-10;
Vrest=-65;
if flag==0	%Current SNR, Nsig determined by Im

	Itot=Itot;
    In=In/SNR;

	%Matching the Voltage signal to noise ratio
	for k=1:size(Itot,1)
        [X,VIm(k,:)]=ifneuron(Itot(k,:),TauE,Tref,inf,Vrest,Fs,In*0,detrendim,detrendin);
    end
    VIm=reshape(VIm,1,numel(VIm));
    [X,VIn]=ifneuron(Itot(k,:)*0,TauE,Tref,inf,Vrest,Fs,In,detrendim,detrendin);

	%Scaling Currents for desired Nsig and voltage SNR
	sigma_m=(Vtresh-Vrest)/Nsig;
	Itot=Itot*sigma_m/std(VIm);
	In=In*sigma_m/std(VIm);

end
if flag==1	%Current SNR, Nsig determined by Im+In

	Itot=Itot;
	In=In/SNR;	
	
	%Matching the Voltage signal to noise ratio
	for k=1:size(Itot,1)
        [X,VIm(k,:)]=ifneuron(Itot(k,:),TauE,Tref,inf,Vrest,Fs,In*0,detrendim,detrendin);
    end
    VIm=reshape(VIm,1,numel(VIm));
    [X,VIn]=ifneuron(Itot(k,:)*0,TauE,Tref,inf,Vrest,Fs,In,detrendim,detrendin);
    
	%Scaling Currents for desired voltage SNR
	sigma_m=(Vtresh-Vrest)/Nsig;
	Itot=Itot*sigma_m/std(VIm);
	In=In*sigma_m/std(VIm);

	%Matching the Voltage signal Nsig
    clear VIm
	for k=1:size(Itot,1)
        [X,VIm(k,:)]=ifneuron(Itot(k,:),TauE,Tref,inf,Vrest,Fs,In*0,detrendim,detrendin);
    end
    VIm=reshape(VIm,1,numel(VIm));
    [X,VIn]=ifneuron(Itot(k,:)*0,TauE,Tref,inf,Vrest,Fs,In,detrendim,detrendin);
    
	%Scaling Currents for desired voltage Nsig
	Itot=Itot*sigma_m/sqrt(var(VIm)+var(VIn));
	In=In*sigma_m/sqrt(var(VIm)+var(VIn));

end
if flag==2	%Voltage SNR, Nsig determined by Im

	%Matching the Voltage signal to noise ratio
    for k=1:size(Itot,1)
        [X,VIm(k,:)]=ifneuron(Itot(k,:),TauE,Tref,inf,Vrest,Fs,In*0,detrendim,detrendin);
    end
    VIm=reshape(VIm,1,numel(VIm));
    [X,VIn]=ifneuron(Itot(k,:)*0,TauE,Tref,inf,Vrest,Fs,In,detrendim,detrendin);
    
	%Scaling Currents for desired Nsig and voltage SNR
	sigma_m=(Vtresh-Vrest)/Nsig;
	Itot=Itot*sigma_m/std(VIm);
	In=In*sigma_m/std(VIm)*std(VIm)/std(VIn)/SNR;
    
end
if flag==3	%Voltage SNR, Nsig determined by Im+In

	%Matching the Voltage signal to noise ratio
    for k=1:size(Itot,1)
        [X,VIm(k,:)]=ifneuron(Itot(k,:),TauE,Tref,inf,Vrest,Fs,In*0,detrendim,detrendin);
    end
    VIm=reshape(VIm,1,numel(VIm));
    [X,VIn]=ifneuron(Itot(k,:)*0,TauE,Tref,inf,Vrest,Fs,In,detrendim,detrendin);
    
	%Scaling Currents for desired Nsig and voltage SNR
	sigma_m=(Vtresh-Vrest)/Nsig;
	Itot=Itot*sigma_m/std(VIm)*sigma_m/sqrt(sigma_m^2+(sigma_m/SNR)^2);
	In=In*sigma_m/std(VIm)*std(VIm)/std(VIn)/SNR*sigma_m/sqrt(sigma_m^2+(sigma_m/SNR)^2);
    
end

%Generating Output Spike Trains
Y=zeros(L,size(Itot,2));
for k=1:L
    Ink=randn(size(Itot(k,:)))*std(In);
    [Y(k,:)]=ifneuron(Itot(k,:),TauE,Tref,Vtresh,Vrest,Fs,Ink,detrendim,detrendin);
end