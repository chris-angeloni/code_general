%function [Y]=dynrbuild(filename)
%
%	
%	FILE NAME 	: dynrbuild
%	DESCRIPTION 	: Dynamic Ripple Spectrum Noise Rebuild.
% 			  Used to regenarete Noise for frequency domain
%			  kernel estimation.
%
%	filename	: Parameter Data File 
%
function [Y]=dynrbuild(filename)

%Loading Parameter data and extracting File Prefix
%Filename Variable Automatically updated duriong load!!!!!
f=['load ' filename];
eval(f);
filename
f=['load ' filename '.1.mat']
eval(f)




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

%Rebuilding dB Ripple Spectrum 
if beta==1
	stft=ones(N2-N1+1,L-1);
	for k=1:L-1
		MagSpec(1:N2-N1+1)=App/2+App/2*sin(2*pi*RD(k)*FaxisLog2(N1:N2)+RP(k));
		MagSpec=10.^(MagSpec/20);
		MagSpec(1:N2-N1+1)=MagSpec(1:N2-N1+1).*exp(i*(2*pi*fphase(k,:)));
		stft(:,k)=stft(:,k).*MagSpec';

		%Use this For displaying
		%loglog(Faxis,abs(MagSpec))
		%axis([f1 f2 10^(1/20) 10^(App/20)])
		%pause

	end
end

%Rebuilding Linear Ripple Spectrum 
if beta==2
	stft=ones(2*N,L-1);
	for k=1:L-1
		MagSpec=-zeros(1,2*N);
		MagSpec(N1:N2)=App/2+App/2*sin(2*pi*RD(k)*FaxisLog2(N1:N2)+RP(k));
		MagSpec(N1:N2)=MagSpec(N1:N2).*exp(i*(2*pi*fphase(k,:)));
		MagSpec=[0 MagSpec(2:N) 0  conj(MagSpec(N:-1:2))];
		stft(:,k)=stft(:,k).*MagSpec';

		%Use this For displaying
		%semilogx(Faxis,abs(MagSpec))
		%axis([f1 f2 0 App])
		%pause
	end
end

