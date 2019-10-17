%
%function [fighandel]=plotspikes(SpikeFile,T,inverts,invertm)
%
%       FILE NAME       : PLOT SPIKES
%       DESCRIPTION     : Plots all the Spikes and Models from a File
%	
%	SpikeFile	: Spike Filename
%	T		: Delay to plot Spikes ( msec ) -> [-T T]
%			  If T is a two element array -> [T1 T2]
%			  spikes will be shown in the interval [-T1 T2]
%	inverts		: Inverts the Spike Waveform
%			  'y' or 'n', Default='n'
%	invertm		: Inverts the Model Waveform
%			  'y' or 'n', Default='n'
%
function [fighandel]=plotspikes(SpikeFile,T,inverts,invertm)

%Input Arguments
if nargin<3
	inverts='n';
end
if nargin<4
	invertm='n';
end
if length(T)==1
	T1=T;
	T2=T;
else
	T1=T(1);
	T2=T(2);
end


%Invert Variable
if strcmp(inverts,'y')
	inverts=-1;
else
	inverts=1;
end
if strcmp(invertm,'y')
	invertm=-1;
else
	invertm=1;
end

%Preliminaries
more off

%Loading Data files
f=['load ' SpikeFile];
eval(f);

%Finding All Non-Outlier Spet Variables
count=-1;
while exist(['spet' int2str(count+1)])
	count=count+1;
end
Nspet=(count+1)/2;

%Number of Subplots
if Nspet<=4
	N1=2;
	N2=2;
	Height=.35;
elseif Nspet<=6
	N1=3;
	N2=2;
	Height=.2;
else
	N1=3;
	N2=3;
	Height=.2;
end

%Finding Maximum Value for all Spikes
MaxAll=-9999;
for k=0:Nspet-1
	%Finding Spike Waveforms
	f=['SpikeWave=SpikeWave' int2str(k) ';'];
	eval(f);
	MaxAll=max([MaxAll max(max(abs(SpikeWave)))]);
end

%Finding RMS Value of Noise
RMS=0;
count=0;
for k=0:Nspet-1

	%Finding Model and Spike Waveforms
	f=['SpikeWave=SpikeWave' int2str(k) ';'];
	eval(f);

	if ~isempty(SpikeWave)
		RMS=RMS+mean(std(SpikeWave(1:10,:)))/1024/32;	
		count=count+1;
	end
end
RMS=RMS/count;


%Plotting Spike Waveform and Models
fighandel=figure;
for k=0:Nspet-1

		%Finding Model and Spike Waveforms
		f=['SpikeWave=SpikeWave' int2str(k) ';'];
		eval(f);
		f=['ModelWave=ModelWave' int2str(k) ';'];
		eval(f);

		%Setting Subplot
		s=subplot(N1,N2,k+1);
		Pos=get(s,'Position');,Pos(4)=Height;
		set(s,'Position',Pos);

		if ~isempty(SpikeWave)
			%Finding SNR~ Max/RMS
			N=size(SpikeWave,1);
			N=(N-1)/2;
			Max=mean(max(abs(SpikeWave(N-1:N+1,:))))/1024/32;
			SNR=Max/RMS;

			%Plotting Spike Waveforms
			plot((-N:N)/Fs*1000,inverts*SpikeWave/1024/32,'b')
			hold on
		end

		%Plotting Model Waveforms
		plot(Time,invertm*ModelWave/1024/32,'r','linewidth',2)
		axis([-T1 T2 -1 1 ])
		f=['L=length(spet' int2str(k) ');'];
		eval(f)
		title(['U=' int2str(k) ', snr=' num2str(SNR,3) ', N=' int2str(L)])


end
hold off
