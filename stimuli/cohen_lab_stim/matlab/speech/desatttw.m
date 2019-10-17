%
%function  [Paxis,ATT,TWNorm] = desatttw(N,minP,stepP,maxP,ftype,flag,Ntaps)
%	
%	FILE NAME 	: desatttw
%	DESCRIPTION 	: Used to find the optimal Filter parameter 
%			  equation for P and N.
%			  Based on the Max Passband Error for the 
%			  Roark/Escabi filter.
%
%	N		: Filter length.
%		     -1	: Uses N=4*minN
%	minP		: Minimum P
%	stepP		: Increment size for P
%	maxP		: Maximum P
%	ftype		: Filter type:
%		     -1 : Uses pi optimal.
%		     -2	: Uses pi optimal with N+1.
%		     -3 : Uses kaiser optimal.
%	Flag		: Determines the ATT criterion:
%		     -1 : Standard.
%		     -2 : Roark modified. 
%	Ntaps		: Number of taps for fft
%	Paxis		: P axis vector
%	ATT		: Attenuation axis vector. In dBs.
%
function  [Paxis,ATT,TWNorm] = desatttw(N,minP,stepP,maxP,ftype,flag,Ntaps)

%Memory Allocation
Err=zeros(maxP-minP+1,1);
Paxis=zeros(maxP-minP+1,1);

%Setting parameters
wc=pi*.4;

%FINDING ATT & TW Norm = TW*N vs P
for p=minP:stepP:maxP,
if N==-1
	N=max([ceil((5.58*p+2.28)/.1/pi)  ceil(p*pi/wc/0.9)] );
end
	%Finds ATT & TW Norm = TW*N
	[ATT((p-minP)/stepP+1) TW((p-minP)/stepP+1)]= atttw(N,p,ftype,wc,flag,Ntaps,'log');
	TWNorm((p-minP)/stepP+1)=N*TW((p-minP)/stepP+1);
end

for p=minP:stepP:maxP,	
	Paxis((p-minP)/stepP+1)= p;
end

%Plotting Design Curve
plot(Paxis,ATT,'go')
grid;
title('ATT vs P');
xlabel('P');
ylabel('ATT (dB)');
figure(2);
plot(Paxis,TWNorm,'ro')
grid;
xlabel('P');
ylabel('Normalized TW');
figure(3);
plot(ATT,TWNorm,'go');
grid;
xlabel('ATT (dB)');
ylabel('Normalized TW');


