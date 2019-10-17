%
%function [X,Vm,Vt,Vtm,Vs,R,C]=ifneuronadapt3(Im,Tau,Taum,Taus,Gm,Gs,Tref,Vtresh,Vrest,Fs,In,detrendim,detrendin)
%
%       FILE NAME   : IF NEURON ADAPT 3
%       DESCRIPTION : Integrate and fire model neuron with spike threshold
%                     adaptation. Includes spike threhold adapation due to
%                     both membrane hyperpolarization and firing  rate. Uses
%                     separate time constants for spike and membrane
%                     adaptation components.
%
%       Im          : Input Membrane Current Signal
%       Tau         : Integration time constant (msec)
%       Taum        : Membrane dependent threshold-adaptation time constant (msec)
%       Taus        : Spike dependent threhold-adaptation time constant (msec)
%       Gm          : Threshold-membrane voltage coupling gain
%       Gs          : Threshold-spike coupling gain
%       Tref        : Refractory Period (msec)
%       Vtresh      : Average (DC) Threshold Membrane Potential (mVolts)
%       Vrest       : Resting Membrane Potential - Same as the Leackage
%                     Membrane Potential (mVolts)
%       Fs          : Sampling Rate
%       In          : Noise current signal
%       detrendim   : Removes time constant from Im if desired ('y' or 'n')
%                     (Default=='n'). This detrending is usefull if you 
%                     know the desired intracellular voltage Vm, but not
%                     the intracellular current.
%       detrendin   : Removes time constant from Im if desired ('y' or 'n')
%                     (Default=='n'). This detrending is usefull if you
%                     know the desired intracellular noise voltage but 
%                     not the intracellular noise current.
%
%OUTPUT SIGNAL
%       X           : Spike Train
%       Vm          : Membrane Voltage
%       Vt          : Threshold Voltage ( Note: Vt=Vtm+Vs+Vthresh-Vrest )
%       Vtm         : Membrane adaptation threshold component
%       Vs          : Spike adaptation threshold component
%       R           : Leackage Resistance
%       C           : Membrane Capacitance
%
% (C) Monty A. Escabi, March 2006
%
function [X,Vm,Vt,Vtm,Vs,R,C]=ifneuronadapt3(Im,Tau,Taum,Taus,Gm,Gs,Tref,Vtresh,Vrest,Fs,In,detrendim,detrendin)

%Input Arguments
if nargin<12
	detrendim='n';
end
if nargin<13
	detrendin='n';
end

%Initializing Array
Vm=zeros(1,length(Im));

%Setting Parameters
Tau=Tau/1000;               % Integration Time Constant
Taum=Taum/1000;             % Membrane threshold adaptation time constant
Taus=Taus/1000;             % Spike threshold adaptation time constant
Tref=Tref/1000;             % Refractory Period
dt=1/Fs;                    % Sampling Interval
R=100E6;                    % Membrane Resistance
C=Tau/R;                    % Membrane Capacitance
Cm=Taum/R;                  % Vm-Vt Couppling capacitance
Cs=Taus/R;                  % Spike-Vt Couppling capacitance
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
Vtm=zeros(1,length(Im));
Vt=(Vtresh-Vrest)*ones(1,length(Im));
Vs=zeros(1,length(Im));
X=zeros(size(Vm));
k=1;
%Itot=Im+In-mean(Im+In);             %Do we need -mean(Im+In)
Itot=Im+In;
while k<length(Im)

	%Membrane Integration
	Vm(k+1)=(1-dt/R/C)*Vm(k) + dt/C*( Itot(k) );
    
    %Threshold Integration
    Vtm(k+1)=(1-dt/R/Cm)*(Vtm(k)) + dt/Cm*( Gm*Vm(k)/R );
    Vs(k+1)=(1-dt/R/Cs)*(Vs(k));    %Spike Adaptation, does not require input except at time of spike
    Vt(k+1)=Vtm(k+1)+Vs(k+1)+Vtresh-Vrest;
    
	%Thresholding Spike Train
	if Vm(k+1)>Vt(k+1)
		%Adding Spike
		X(k+1)=1;
        
        %Resseting Vm, Vtm & Vs
        Vm(k+1)=Vm(k)-(Vtresh-Vrest);
        Vtm(k+1)=(1-dt/R/Cm)*(Vtm(k)) + dt/Cm*( Gm*Vm(k)/R );
        Vs(k+1)=(1-dt/R/Cs)*(Vs(k)) + dt/Cs*( Gs*(55-Vrest)/R ) ;   %Spike Input
        Vt(k+1)=Vtm(k+1)+Vs(k+1)+Vtresh-Vrest;
        
		%Reseting Potential, Computing threshold, and Delaying By Refractory Period
        L=k+1+Nref;
        k=k+1;
        while k<=L & k<length(Im)
            %Threshold Integration
            Vtm(k+1)=(1-dt/R/Cm)*(Vtm(k)) + dt/Cm*( Gm*Vm(k)/R );
            Vs(k+1)=(1-dt/R/Cs)*(Vs(k));    %Spike Adaptation, does not require input except at time of spike
            Vt(k+1)=Vtm(k+1)+Vs(k+1)+Vtresh-Vrest;
            
            %Membrane Integration
            Vm(k+1)=Vm(k);
            k=k+1;
        end
	else
		k=k+1;
	end
end

%Adding Action Potentials
index=find(X==1);
Vm(index)=(55-Vrest)*ones(1,length(index));