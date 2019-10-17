%
%function [X,Vm,Vt,R,C]=ifneuronadapt2(Im,Tau,Taut,Gt,Gs,Tref,Vtresh,Vrest,Fs,In,detrendim,detrendin)
%
%       FILE NAME   : IF NEURON ADAPT 2
%       DESCRIPTION : Integrate and fire model neuron with spike threshold
%                     adaptation. Includes adapation due to both membrane
%                     voltage hyperpolarization and firing  rate.
%
%       Im          : Input Membrane Current Signal
%       Tau         : Integration time constant (msec)
%       Taut        : Threshold integration time constant (msec)
%       Gt          : Threshold-membrane voltage coupling gain
%       Gs          : Threshold-spike coupling gain
%       Tref        : Refractory Period (msec)
%       Vtresh      : Threshold Membrane Potential (mVolts)
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
%       Vt          : Threshold Voltage
%       R           : Leackage Resistance
%       C           : Membrane Capacitance
%
% (C) Monty A. Escabi, March 2006
%
function [X,Vm,Vt,R,C]=ifneuronadapt2(Im,Tau,Taut,Gt,Gs,Tref,Vtresh,Vrest,Fs,In,detrendim,detrendin)

%Input Arguments
if nargin<11
	detrendim='n';
end
if nargin<12
	detrendin='n';
end

%Initializing Array
Vm=zeros(1,length(Im));

%Setting Parameters
Tau=Tau/1000;               % Integration Time Constant
Taut=Taut/1000;             % Threshold Integration Time Constant
Tref=Tref/1000;             % Refractory Period
dt=1/Fs;                    % Sampling Interval
R=100E6;                    % Membrane Resistance
C=Tau/R;                    % Membrane Capacitance
Ct=Taut/R;                  % Vm-Vt Couppling capacitance
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
Vt=(Vtresh-Vrest)*ones(1,length(Im));
X=zeros(size(Vm));
k=1;
%Itot=Im+In-mean(Im+In);             %Do we need -mean(Im+In)
Itot=Im+In;
while k<length(Im)

	%Integration
	Vm(k+1)=(1-dt/R/C)*Vm(k) + dt/C*( Itot(k) ) ;
    Vt(k+1)=(1-dt/R/Ct)*(Vt(k)-Vtresh+Vrest) + dt/Ct*( Gt*Vm(k)/R ) + Vtresh-Vrest;
    
	%Thresholding Spike Train
	if Vm(k+1)>Vt(k+1)
		%Adding Spike
		X(k+1)=1;
        
        %Resseting Vm and Vt
        Vm(k+1)=Vm(k)-(Vtresh-Vrest);
        Vt(k+1)=(1-dt/R/Ct)*(Vt(k)-Vtresh+Vrest) + dt/Ct*( Gt*Vm(k)/R + Gs*(55-Vrest)/R ) + Vtresh-Vrest;
        
		%Reseting Potential, Computing threshold, and Delaying By Refractory Period
        L=k+1+Nref;
        k=k+1;
        while k<=L & k<length(Im)
            Vt(k+1)=(1-dt/R/Ct)*(Vt(k)-Vtresh+Vrest) + dt/Ct*( Gt*Vm(k)/R ) + Vtresh-Vrest;
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