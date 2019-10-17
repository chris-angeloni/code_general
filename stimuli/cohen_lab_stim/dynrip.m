%function [Y,RD,RP,fphase]=dynrip(f1,f2,fRP1,fRP2,fRD1,fRD2,beta,gamma,App,RDL,RDU,RPhase,M,Fs,dt)
%
%	
%	FILE NAME 	: dynrip
%	DESCRIPTION 	: Dynamic Ripple Spectrum Noise
% 
%       f1              : Lower Ripple Frequency
%       f2              : Upper Ripple Frequency
%	fRP1		: Lower Ripple Phase Frequency
%	fRP2		: Upper Ripple Phase Frequency
%	fRD1		: Lower Ripple Density Frequency
%	fRD2		: Upper Ripple Density Frequency
%
%	beta		: 1 : dB Amplitude Ripple Spectrum
%			  2 : Liner Amplitude Ripple Spectrum
%
%       gamma           : 1 : Random Ripple Phase  
%			  2 : Random Ripple Density 
%			  3 : Random Ripple Phase and Density
%
%       App             : Peak to Peak Riple Amplitude 
%			  if beta ==
%			  1 : App is in dB 
%			  2 : App E [0,1]
%	RDU		: Upper Ripple Density
%	RDL		: Lower Ripple Density
%	RPhase		: Maximum Ripple Phase if gamma==1 or 3
%			  OtherWise Constant Ripple Phase
%       M               : Number of Samples
%       Fs              : Sampling Rate
%	dt		: Temporal window size used for reconstruction
%
function [Y,RD,RP,fphase]=dynrip(f1,f2,fRP1,fRP2,fRD1,fRD2,beta,gamma,App,RDL,RDU,RPhase,M,Fs,dt)

%Finding Window (W) and Window Order (N)
N=2^(ceil(log2((dt*Fs))));
W=zeros(1,N+1);
n=1:N+1;
W(1:N/2+1)=2/N*(n(1:N/2+1)-N/4-1)+.5;
W(N+1:-1:N/2+1)=W(1:N/2+1);

%Finding Number of Windows (L) and Signal Length (M-increased for edge effects)
L=ceil(M/N*2);
M=N/2*L+N/2;

%Setting up Frequency Axis for Spectrum
Faxis=(1:2*N)/2/N*Fs;
FaxisLog2=log2(Faxis)-log2(f1);
N1=max([round(f1/Fs*2*N) 2]);
N2=min([round(f2/Fs*2*N) N]);

%Generating the Ripple Phase signal 
if gamma==1 | gamma==3
	RP=noiseblh(fRP1,fRP2,Fs*(L-1)/M,L-1);
	RP=RPhase*(RP-min(RP))/(max(RP)-min(RP));
elseif gamma==2
	RP=RPhase*ones(1,L-1);
end

%Generating Ripple Density Signal
if gamma==2 | gamma==3
	RD=noiseblh(fRD1,fRD2,Fs*(L-1)/M,L-1);
	RD=RDL+(RDU-RDL)*(RD-min(RD))/(max(RD)-min(RD));
elseif gamma==1
	RD=RDU*ones(1,L-1);
end


%Finding dB Ripple Spectrum 
if beta==1
	stft=ones(2*N,L-1);
	for k=1:L-1
		MagSpec=zeros(1,N*2);
		MagSpec(N1:N2)=App/2+App/2*sin(2*pi*RD(k)*FaxisLog2(N1:N2)+RP(k));
		MagSpec=10.^(MagSpec/20);
		fphase(k,:)=rand(size(N1:N2));
		MagSpec(N1:N2)=MagSpec(N1:N2).*exp(i*(2*pi*fphase(k,:)));
		MagSpec=[0 MagSpec(2:N) 0  conj(MagSpec(N:-1:2))];
		stft(:,k)=stft(:,k).*MagSpec';

		%Use this For displaying
		%loglog(Faxis,abs(MagSpec))
		%axis([f1 f2 10^(1/20) 10^(App/20)])
		%pause

	end
end

%Finding Linear Ripple Spectrum 
if beta==2
	stft=ones(2*N,L-1);
	for k=1:L-1
		MagSpec=-zeros(1,N*2);
		MagSpec(N1:N2)=App/2+App/2*sin(2*pi*RD(k)*FaxisLog2(N1:N2)+RP(k));
		fphase(k,:)=rand(size(N1:N2));
		MagSpec(N1:N2)=MagSpec(N1:N2).*exp(i*(2*pi*fphase(k,:)));
		MagSpec=[0 MagSpec(2:N) 0  conj(MagSpec(N:-1:2))];
		stft(:,k)=stft(:,k).*MagSpec';

		%Use this For displaying
		%semilogx(Faxis,abs(MagSpec))
		%axis([f1 f2 0 App])
		%pause
	end
end

%For Dysplaying Only
taxis=(0:L-2)/(Fs*(L-1)/M);
pcolor(taxis,Faxis,abs(stft)),axis([0 max(taxis) f1 f2]),colormap bone, shading flat,pause
pause

%Finding Inverse STFFT
stft=real(ifft(stft));
Y=zeros(1,N/2*L+1);
for k=1:L-1
	Y(1+(k-1)*N/2:k*N/2+N/2+1)=stft(1:N+1,k)'+Y(1+(k-1)*N/2:k*N/2+N/2+1).*W;
end
Y=Y(1:L*N/2);

%Filtering To Smooth out Junctions with 80dB ER Filter
P=3.5366;
M=128;
wc=2*pi*(f2-f1)/2/Fs;
H=2*h(-M:M,wc,P*pi/(M+1)/wc,P).*sin(2*pi*(f1+f2)/2/Fs*(1:2*M+1));
Y=conv(Y,H);


