%
%function [fighandel]=plotautocorr(SpikeFile,T,inverts,invertm)
%
%       FILE NAME       : PLOT AUTOCORR
%       DESCRIPTION     : Plots all the autocorrelations from a single File
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
function [fighandel]=plotautocorr(SpikeFile,T,Fsd,inverts,invertm)

%Input Arguments
if nargin<4
	inverts='n';
end
if nargin<5
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

%Plotting Autocorrelations
fighandel=figure;
for k=0:Nspet-1

		%Finding Spike ISI arrays
		f=['spet=spet' int2str(k) ';'];
		eval(f);

		%Setting Subplot
		s=subplot(N1,N2,k+1);
		Pos=get(s,'Position');,Pos(4)=Height;
		set(s,'Position',Pos);

		%Obtaining Autocorrelation
		[R]=xcorrspike(spet,spet,Fs,Fsd,T,'y','n','n');
		N=(length(R)-1)/2;
		R(N+1)=0;
		Tau=(-N:N)/Fsd;
		
		%Plotting Autocorrelation
		plot(Tau*1000,R,'k')
		hold on
		plot(Tau*1000,R,'ro')
		hold off
		L=length(spet);
		title(['U=' int2str(k) ', N=' int2str(L)])

end
hold off
