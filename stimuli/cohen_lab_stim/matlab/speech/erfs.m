%
%function [Fs,dTomax,dToc]=erfs(Fo,Fs,NdB,NoiseMdl,M,K,ATT,TW)
%	
%	FILE NAME 	: ERFS
%	DESCRIPTION 	: Finds cycle to cycle Fo Error using Escabi/Roark
%			  Interpolation Method. Simulated for perfect
%			  sinusoids at multiple Fs and conditions of Noise 
%
%	Fo		: Fundamental Frequency
%	Fs		: Sampling Frequency Array
%	NdB		: Signal to Noise Ration in dB
%
%Optional
%       NoiseMdl        : Noise model: 'rand' or 'noiseunif'
%                         Default: 'rand' uses the standard uniformly 
%                         distributed noise generator from MATALB. Note
%                         that the maximum frequency for this noise model
%                         is Fn=Fs/2.  'noiseblfft' will use a bandlimited
%                         gaussianly distributed noise model where the 
%                         maximum frequency is Fn=Fo.  This model is used
%                         to avoid artifacts wich can occur at low SNR for 
%                         because of multiple zerocrossings that can occur.
%	M		: Aproximate Number of Periods used in simulation
%			  ( Default = 50 )
%	K		: Number of Values for theta ( Default = 50 )
%	ATT		: Filter Attenuation ( Default = 120 dB )
%	TW		: Normalized Tranzition Width ( Default=.1*pi=.1*wc )
%
function [Fs,dTomax,dToc]=erfs(Fo,Fs,NdB,NoiseMdl,M,K,ATT,TW)

%Checking Arguments
if nargin<4
	NoiseMdl='rand';
end
if nargin<5
	M=50;
end
if nargin<6
	K=50;
end
if nargin<7
	ATT=120;
end
if nargin<8
	TW=.1*pi;
end

%Finding Max Noise
Nmax=10^(-NdB/20);

%Number of extra samples for edge effects 
LN=6*99;
wc=pi;
[m,LN,alpha,wc] = fdesignh(ATT,TW,wc);
LN=LN*2;

%Finding To Error Curves vs Fs
Ts=1./Fs;
for k=1:length(Fs)

	%Finding Error For Different Phases
	theta=2*pi*rand(1,K);
	dTmax=0;
        for l=1:length(theta)

		%Signal and Noise
                N=ceil((M+5)*Fs(k)/Fo);
		if strcmp(NoiseMdl,'rand')
			n=2*Nmax*(rand(1,N+LN)-.5);
		else
			n=noiseblfft(0,Fo,Fs(k),N+LN);
			n=Nmax*n/max(abs(n));
		end
                x=sin(2*pi*Fo*Ts(k)*(1:N+LN)+theta(l)) + n ;
	
		%Finding To Array
		[To,L]=er(x,Fs(k),1E-10,ATT,TW);
                dTmax=max([abs(To-1/Fo) dTmax]);

        end

        %Compund Error
	dToc(:,k)=abs(To(1:M)-1/Fo)';

        %Finding Max dTo
        dTomax(k)=dTmax;

	%Updating Display
	disp(['Done for Fs = ',num2str(Fs(k))])

end

%Plotting Simulated Results
%loglog(Fs,dTmax)

