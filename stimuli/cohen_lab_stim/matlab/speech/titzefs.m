%
%function [Fs,dTomax,dToc]=titzefs(Fo,Fs,NdB,NoiseMdl,M,K)
%	
%	FILE NAME 	: TITZEFO
%	DESCRIPTION 	: Finds cycle to cycle To using Linear 
%			  Interpolation.  Plots theoretical and simulated 
%			  To (or Fo) Error / Perturbation curves vs Fs.
%
%	Fo		: Fundamental Frequency
%	Fs		: Desired Sampling Frequencies Array
%	NdB		: Signal to Noise Ration in dB 
%
%Optional
%	NoiseMdl	: Noise model: 'rand' or 'noiseunif'
%			  Default: 'rand' uses the standard uniformly 
%			  distributed noise generator from MATALB. Note
%			  that the maximum frequency for this noise model
%			  is Fn=Fs/2.  'noiseblfft' will use a bandlimited
%			  uniformly distributed noise model where the 
%			  maximum frequency is Fn=Fo.  This model is used
%			  to avoid artifacts wich can occur at low SNR for 
%			  because of multiple zerocrossings that can occur.
%	M		: Aproximate Number of Periods used in simulation
%			  ( Default = 50 )
%	K		: Number of Values for theta ( Default = 50 )
%
%Output
%	dTomax		: Maximum dT vs Fs curve
%	dToc		: Compund dT vs Fs curve
%
function [Fs,dTomax,dToc]=titzefs(Fo,Fs,NdB,NoiseMdl,M,K)

%Checking Input Arguments
if nargin<4
	NoiseMdl='rand';
end
if nargin<5
	M=50;
end
if nargin<6
	K=50;
end

%Finding Max Noise
Nmax=10^(-NdB/20);

%Finding To Error Curves vs Fs 
Ts=1./Fs;
for k=1:length(Fs)

	%Finding Error For Different Phases
	theta=2*pi*rand(1,K);
	dTmax=0;
	for l=1:length(theta)

		%Signal and Noise
		N=floor(2^8*Ts(1)/Ts(k));
		if strcmp(NoiseMdl,'rand')
			n=2*Nmax*(rand(1,N)-.5);
		else
			n=noiseblfft(0,Fo,Fs(k),N);
			n=Nmax*n/max(abs(n));
		end
		x=sin(2*pi*Fo*Ts(k)*(1:N)+theta(l)) + n;

		%Finding To Array
		To=titze(x,Fs(k));
		dTmax=max([dTmax abs(To-1/Fo)]);

	end

	%Compund Error
	if k==1
		M=length(To);
	end
	dToc(:,k)=abs(To(1:M)-1/Fo)';

	%Finding Max dTo
	dTomax(k)=dTmax;

	%Updating Display
        disp(['Done for Fs = ',num2str(Fs(k),6)])

end


%Finding Theoretical Max Curve
dT=2*abs(-.2*Ts + Ts.*sin(.4*pi*Ts*Fo)./(sin(.4*pi*Ts*Fo)+sin(1.6*pi*Ts*Fo)) ) + Nmax/pi/Fo;

%Plotting Theoretical and Simulated Results
loglog(Fs,dToc*Fo./(1+dToc*Fo)*100,'y.',Fs,Fo*dT./(1+dT*Fo)*100,'r',Fs,dTomax*Fo./(1+dTomax*Fo)*100,'y')
