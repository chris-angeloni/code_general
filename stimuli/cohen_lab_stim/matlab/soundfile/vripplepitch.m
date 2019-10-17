%
%function [Y]=vripplepitch(f1,f2,Fm1,Fm2,FM,RD,M,Fs,NS,RP)
%
%	FILE NAME 	: V RIPPLE PITCH
%	DESCRIPTION 	: Virtual Pitch Ripple Sound
%
%	f1		: Minimum Frequency
%	f2		: Maximum Frequency
%	Maxdf		: Maximum pitch perturbation 
%	FM		: Ripple temporal modulation rate
%	RD		: Ripple Density Bandlimit Frequency
%       M               : Number of Samples
%       Fs              : Sampling Rate
%	NS		: Number of sinusoid carriers
%	RP		: Ripple Phase [0,2*pi]
%			  Default choosen randomly
%
function [Y]=vripplepitch(f1,f2,Fn,Maxdf,FM,RD,M,Fs,NS,RP)

%Linear Frequency Axis
faxis=f1+(f2-f1)/NS*(0:NS-1);
X=log2(faxis/faxis(1));

%Time Axis
time=(1:M)/Fs;
dt=1/Fs;

%Generating synchronous uniformly distributed temporal noise envelope
%As=noiseunif(Fn,Fs,M);
As=0

%Generating asynchronous uniformly distributed temporal noise envelope
Ans=noiseunif(Fn,Fs,M*2)*2-1;

%Generating virtual ripple noise
Y=zeros(1,M);
for k=1:NS

	%Ripple Correlation Coefficients
	p=0.5*sin( 2*pi*RD*X(k) + 2*pi*FM*time + RP ) + 0.5;
	alpha=(p.^2-sqrt(p.^2-p.^4))./(2*p.^2-1);
	beta=1-alpha;

	%Randomly choosing asynchronous segment
	Flip=round(rand);	
	L=round( 0.9*M*rand );		%Starting Position
	if Flip==1
		An=Ans(L+M:-1:L+1);
	else
		An=Ans(L+1:L+M);
	end

	%Differential Pitch and Phase component
%subplot(311)
%plot(alpha)
%subplot(312)
%plot(beta)
        df=Maxdf/2*(alpha.*As + beta.*An);
%subplot(313)
%plot(df)
	Phase=2*pi*intfft(df)*dt + 2*pi*rand;

	%Virtual Pitch Ripple Sound
	Y=Y+sin(2*pi*faxis(k)*time + Phase);

end

