%
%function [fighandel]=plotjitter(SpikeFile,T,inverts,invertm)
%
%       FILE NAME       : PLOT JITTER
%       DESCRIPTION     : Plots all the jitter correlations from a single File
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
function [fighandel]=plotjitter(JitterFile,T,inverts,invertm)

clf

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


%Invert spet Variable
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

%Loading Spet files
i=findstr(JitterFile,'ch');
SpikeFile=JitterFile(1:i+2);
f=['load ' SpikeFile];
eval(f);

%Loading Jitter File
f=['load ' JitterFile];
eval(f);

%ISI Array
i=findstr(JitterFile,'u');
unit=JitterFile(i+1);
if exist(['SpikeWave' unit])
	f=['SpikeWave=SpikeWave' unit ';'];
	eval(f)
	f=['ModelWave=ModelWave' unit ';'];
	eval(f)
	f=['spet=spet' unit ';'];
	eval(f)
else
	SpikeWave=[];
end

%Setting Subplot
%s=subplot(N1,N2,k+1);
%Pos=get(s,'Position');,Pos(4)=Height;
%set(s,'Position',Pos);

%Plotting
subplot(2,1.5,1)
plot(Tau*1000,Raa,'r')
hold on
plot(Tau*1000,Rab,'b')
axis([-15 15 -.25*max([Raa Rab]) 1.2*max([Raa Rab])])
hold off

i=findstr(SpikeFile,'_');
SpikeFile(i)=setstr(32*ones(size(i)));
title([SpikeFile ' u' unit ]);

subplot(2,1.5,2.5)
plot(Tau*1000,Rpp,'r')
hold on
plot(Tau*1000,Rmodel,'b')
hold off
axis([-15 15 min(min([Rpp]),-max(abs(Rpp))) 1.2*max([Rpp])])
xlabel('Delay (msec)')

if ~isempty(SpikeWave)
subplot(233)
N=(size(SpikeWave,1)-1)/2;
plot((-N:N)/Fs*1000,inverts*SpikeWave/1024/32,'k')
hold on
plot(Time,invertm*ModelWave/1024/32,'r')
Max=max(max(abs(SpikeWave/1024/32)));
axis([-1 1 -Max*1.2 Max*1.2])
hold off
title(['N = ' int2str(length(spet))])
xlabel('Time (msec)')
end
