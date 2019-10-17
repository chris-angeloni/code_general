%
%function [R,P]=spikecorrcoef(SpikeFile1,SpikeFile2,unit1,unit2,T1,T2,L)
%
%       FILE NAME       : SPIKE CORR COEF
%       DESCRIPTION     : Compares Two sets of Spike Waveforms by computing 
%			  the mean corrcoeff for the two spike sets
%	
%	SpikeFile1	: Spike File 1
%	SpikeFile2	: Spike File 2
%	unit1		: Unit Number for SpikeFile1
%	unit2		: Unit Number for SpikeFile2
%	T1, T2		: Delay used to compute corrcoef -> [T1 T2] (msec)
%	L		: Number of Spike Waveforms to use (Optinal)
%
%RETURNED VARIABLES
%	R		: Mean Correlation Coefficient
%	P		: Ratio of Standard Deviation - Relative to Spike2
%			  std1 / std2
%
function [R,P]=spikecorrcoef(SpikeFile1,SpikeFile2,unit1,unit2,T1,T2,L)

%Loading Input Files
f=['load ' SpikeFile1];
eval(f);
f=['Spike1=SpikeWave' int2str(unit1) ';'];
eval(f);
f=['load ' SpikeFile2];
eval(f);
f=['Spike2=SpikeWave' int2str(unit2) ';'];
eval(f);

%Spike Size for Analyzis
N1=Fs*T1/1000;
N2=Fs*T2/1000;
N=(size(Spike1,1)-1)/2;
Spike1=Spike1(N-N1:N+N2,:)';
Spike2=Spike2(N-N1:N+N2,:)';

%Checking to see if Spike1 and Spike2 are the same
if sum(size(Spike1)==size(Spike2))/2==1 %In case 1 file has fewer spikes
	if mean(mean(Spike1==Spike2))==1
		Same=1;
	else
		Same=0;
	end
else
	Same=0;
end

%Computing Mean Correlation Coefficient
R=0;
P=0;
if nargin<7
	L1=size(Spike1,1);
	L2=size(Spike2,1);
else
	L1=L;
	L2=L;
end
for j=1:L1
	for k=1:L2
		if k~=j

			RR=corrcoef(Spike1(j,:),Spike2(k,:))/L1/L2 ;
			R=R + RR(1,2);
			P=P + std(Spike2(k,:))/std(Spike1(j,:))/L1/L2;

		elseif Same==0

			RR=corrcoef(Spike1(j,:),Spike2(k,:))/L1/L2 ;
			R=R + RR(1,2);
			P=P + std(Spike2(k,:))/std(Spike1(j,:))/L1/L2;

		end
	end
end
