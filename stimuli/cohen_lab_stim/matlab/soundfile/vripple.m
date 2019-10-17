%
%function []=vripple(outfile,f1,f2,Fm1,Fm2,FM,RD,M,Fs,NS,RP,pmax,env,DF)
%
%	FILE NAME 	: V RIPPLE
%	DESCRIPTION 	: Virtual Ripple Sound
%
%	outfile		: Output File Name - No Extension
%	f1		: Minimum Carrier Frequency
%	f2		: Maximum Carrier Frequency
%	Fm1		: Minimum temporal modulation rate
%	Fm2		: Maximum temporal modulation rate
%	FM		: Ripple temporal modulation rate
%	RD		: Ripple density
%       M               : Number of Samples
%       Fs              : Sampling Rate
%	NS		: Number of sinusoid carriers per spectral cycle
%	RP		: Ripple Phase [0,2*pi]
%			  Default : Choosen randomly
%	pmax		: Maximum Correlation Coefficient
%			  Default : pmax==1
%	env		: Envelope Type  ( Default = 'square' )
%			  'square' - Square Wave Noise Envelope
%			  'noise'  - Uniformly Distributed Noise Envelope
%	DF		: Down sampling factor for envelop
%			  Default = 100
%
function []=vripple(outfile,f1,f2,Fm1,Fm2,FM,RD,M,Fs,NS,RP,pmax,env,DF)

%Input Arguments
if nargin<11
	RP=2*pi*rand;
end
if nargin<12
	pmax=1;
end
if nargin<13
	env='square';
end
if nargin<14
	DF=100;
end

%Octave Frequency Axis
XMax=ceil(log2(f2/f1)*RD)/RD;
NS=NS*XMax*RD;
X=(0:NS-1)/(NS-1)*XMax;
faxis=f1*2.^X;

%Random Carrier Phase
rand('seed',1);
Phase=2*pi*rand(NS,1);

%Generating synchronous uniformly distributed temporal noise envelope
%As=noiseunifh(Fm1,Fm2,Fs,M);

%Generating a long asynchronous uniformly distributed temporal noise envelope
Ans=noiseunifh(Fm1,Fm2,Fs,M*2);

%Time Axis
time=(1:M)/Fs;

%Generating virtual ripple noise
Y=zeros(1,M);
Envd=[];
for k=1:NS/XMax/RD

	%Randomly choosing synchronous segment
	Flip=round(rand);	
	L=round( 0.9*M*rand );		%Starting Position
	if Flip==1
		As=Ans(L+M:-1:L+1);
	else
		As=Ans(L+1:L+M);
	end

	for l=1:XMax*RD

		%Ripple Correlation
		p=pmax * ( 0.5*sin( 2*pi*RD*X(k) + 2*pi*FM*time + RP ) + 0.5 ) ;
p=round(p);
		if strcmp(env,'noise')
			alpha=(p.^2-sqrt(p.^2-p.^4))./(2*p.^2-1);
		elseif strcmp(env,'square')
			index=find(p<0.5);
			alpha=zeros(1,length(p));
			alpha(index)=p(index)./(p(index)+0.5);
			index=find(p>=0.5);
			alpha(index)=1-(1-p(index))./(1.5-p(index));
		end
		beta=1-alpha;
	
		%Randomly choosing asynchronous segment
		Flip=round(rand);	
		L=round( 0.9*M*rand );		%Starting Position
		if Flip==1
			An=Ans(L+M:-1:L+1);
		else
			An=Ans(L+1:L+M);
		end
	
		%Virtual Ripple Noise Envelope
		Env=(alpha.*As + beta.*An);
	
		%Making Square Wave Envelope if Desired
		if strcmp(env,'square')
			Env=round(Env);
			W=swindow(Fs,4,5);
			N=floor((length(W)-1)/2);
			Env=conv(Env,W);
			Env=Env(N+1:N+M);
		end
	
%		psd(Env-mean(Env),1024*4,Fs)
%		axis([0 225 0 50])
%		pause(0)
	
		%Adding Modulations to Carriers and Summing
		j=k+(l-1)*NS/XMax/RD;
		Y=Y+Env.*sin(2*pi*faxis(j).*time + Phase(j) );
	
		%Down sampling the envelope	
		if isempty(Envd)
			Envd=zeros(NS,length(1:DF:length(Env)));
		end
		Envd(j,:)=Env(1:DF:length(Env));
	
		%Output Display
		clc
		disp(['Modulating Carrier : ' num2str(j)])

	end
end

%Normalizing Sound - [-1024*32,1024*32]
Y=round( 0.95*1024*32*Y/max(abs(Y)) );

%Opening and Saving To Output SW File
fid=fopen([outfile '.sw'],'w');
fwrite(fid,Y,'int16');
fclose(fid);

%Converting to WAV file
outfile2=[outfile '.wav'];
f=['!sox -r ' int2str(Fs) ' -c 2 ' outfile '.sw ' outfile2];
eval(f) 

%Saving Correlation Envelope
save Envelope Envd
