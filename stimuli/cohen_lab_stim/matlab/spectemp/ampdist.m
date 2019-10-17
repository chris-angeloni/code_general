%
%function [Amp,P,AmpdB,PdB,Taxis,StdLin,StddB,MeandB]=ampdist(filename,M,Disp)
%
%	FILE NAME 	: AMP DIST
%	DESCRIPTION 	: Emperically estimates the Linear and Decibel
%			  amplitude distributions of a 16 bit sampled 
%			  waveform ( .sw )
%
%	filename	: Input File Name
%	M		: Block Size 
%	Disp		: Display output: 'y' or 'n' , Default='y'
%
%RETUERNED VARIABLES
%
%	Amp		: Linear amplitude
%	P		: Linear amplitude distribution
%	AmpdB		: Decibel amplitude
%	PdB		: Decibel amplitude distribution
%	Taxis		: Time axis for trajectories
%	StdLin		: Linear amplitude STD trajectory
%	StddB		: dB amplitude STD trajectory
%	MeandB		: dB amplitude MEAN trajectory
%
function [Amp,P,AmpdB,PdB,Taxis,StdLin,StddB,MeandB]=ampdist(filename,M,Disp)

%Input arguments
if nargin<3
	Disp='y';
end

%Opening Input File
fid=fopen(filename);

%Reading first input block
X=fread(fid,M,'int16');

%Generating Amplitude Axis
[N1,AmpdB]=hist(rand(1,10),-90:1:90);
[N2,Amp]=hist(rand(1,10),-1024*32:128:1024*32);
PdB=zeros(1,length(N1));
P=zeros(1,length(N2));

%Reading first input block
frewind(fid);
X=fread(fid,M,'int16');

%Reading data and computing distributions
count=1;
while ~feof(fid)

	%Displaying output
	clc
	disp(['Analyzing Block Number: ' num2str(count)])

	%Computing instantenous distributions
	Z=zeros(1,length(X));
	i=find(X>0);
	Z(i)=20*log10(1+X(i));
	i=find(X<0);
	Z(i)=-( 20*log10(1+abs(X(i))) );
	N1=hist(Z,-90:1:90);
	N2=hist(X,-1024*32:128:1024*32);

	%Averaging distributions	
	PdB=PdB+N1;
	P=P+N2;

	%Finding Standard Deviation
	StdLin(count)=std(X);	
	StddB(count)=std(abs(Z));
	MeandB(count)=mean(abs(Z));

	%Reading input
	X=fread(fid,M,'int16');

	%Incrementing counter
	count=count+1;
	
	%Displaying Output
	if strcmp(Disp,'y')
		subplot(211)
		plot(AmpdB,PdB/sum(PdB))
		subplot(212)
		semilogy(Amp,P/sum(P))
		axis([-1024*32 1024*32 0 max(N2)])
		pause(0)
	end

end

%Temporal Axis For STD and Mean Trajectories
Fs=44100;
Taxis=(0:length(StdLin)-1)*M/Fs;
