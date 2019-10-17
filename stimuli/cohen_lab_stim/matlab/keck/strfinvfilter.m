%function [Hinv,H,Htf]=strfinvfilter(sprfile,L,NFFTt,NFFTf,FMc,RDc,ATT,alpha)
%
%       FILE NAME       : STRF INV FILTER
%       DESCRIPTION     : Finds the inverse filter to detrend the 
%			  STRF estimate 
%
%	sprfile		: Spectro-temporal Envelope File
%	L		: Number of ripple segments to use
%	NFFTt		: Temporal FFT Size (minimum of 128)
%	NFFTf		: Spectral FFT Size (minimum of 128)
%	FMc		: Modulation cutoff frequency (Hz) 
%			  Default = 70 Hz
%	RDc		: Spectral Envelope cutoff frequency (cycles/Hz)
%			  Default = 0.00035
%	ATT		: Filter Attenuation (dB)
%			  Default = 30
%	alpha		: Used for finding the Transition Width (TW)
%			  Where TW is defined as a percentage of the
%			  cutoff frequency
%			  TW = alpha x FMc
%			  Default = 1
%
function [Hinv,H,Htf]=strfinvfilter(sprfile,L,NFFTt,NFFTf,FMc,RDc,ATT,alpha)

%Input Arguments
if nargin<5
	FMc=70;
end
if nargin<6
	RDc=0.00035;
end
if nargin<7
	ATT=30;
end
if nargin<8
	alpha=1;
end

%Load Param File
i=find(sprfile=='.');
paramfile=[sprfile(1:i-1) '_param.mat'];
f=['load ' paramfile];
eval(f);

%Open SPR File
fid=fopen(sprfile);

%Computing Envelope Spectrum
count=1;
M=zeros(NFFTf,NFFTt);
while ~feof(fid) & count<=L
	%Displaying output
	clc
	disp(['Evaluating Spectrum for Segment ' num2str(count)])

	X=reshape(fread(fid,NF*NT,'float'),NF,NT);
	N=2^floor(log2(size(X,2)));
	X=20*log10(X(100:220,:));
	for k=1:floor(N/128)
		XX=X(:,(k-1)*128+1:k*128);
		M=M+abs(fft2(XX-mean(mean(XX)),NFFTf,NFFTt));
		FMAxis=(-NFFTt/2:NFFTt/2-1)/NFFTt/taxis(2);
		RDAxis=(-NFFTf/2:NFFTf/2-1)/NFFTf/faxis(2);
		pause(0)
	end
	count=count+1;
	pcolor(FMAxis,RDAxis,fftshift(M)),shading flat,colormap jet, colorbar
	axis([-300 300 -0.001 0.001])
end

%Closing All Files
fclose('all')

%Make the Filter Symetric
MM=flipud(M);
M=( fftshift([ MM(NFFTf,:); MM(1:NFFTf-1,:)]) + fftshift(M) ) /2 ;

%Finding The Inverse Filter
M=fftshift(M)/max(max(M));
FMAxis=(0:NFFTt-1)/NFFTt/taxis(2);
RDAxis=(0:NFFTf-1)/NFFTf/faxis(2);
Nt=max(find(FMAxis<FMc))-1;
Nf=max(find(RDAxis<RDc))-1;
Mask=inf*ones(NFFTf,NFFTt);
Mask(1:Nf,1:Nt)=ones(Nf,Nt); 
Mask(1:Nf,NFFTt-(0:Nt-2))=ones(Nf,Nt-1); 
Mask(NFFTf-(0:Nf-2),1:Nt)=ones(Nf-1,Nt); 
Mask(NFFTf-(0:Nf-2),NFFTt-(0:Nt-2))=ones(Nf-1,Nt-1); 
index=find(Mask==1);
Minv=ones(NFFTf,NFFTt);
Minv(index)=1./M(index);
Minv(1,1)=0;

%Taking Inverse Fourier Transform
H=ifft2(Minv);
H=fftshift(real(H));

%Applying a Spectro-temporal Low Pass Filter to Limit Ripple Space
%Ht=lowpass(FMc,alpha*FMc,1/taxis(2),ATT,'n');
Hf=lowpass(RDc,alpha*RDc,1/faxis(2),ATT,'n');
dt=1/4/pi/fc;	%Uncertainty Principle
L=round(3*dt*Fs);
Hw=exp( -((-L:L)/Fs).^2/2/dt.^2);
Htf=Hf'*Ht;

%Composite Inverse Filter
Hinv=conv2(Htf,H);

%Plotting Ripple Spectrum and Inverse Filter
subplot(221)
FMAxis=(-NFFTt/2:NFFTt/2-1)/NFFTt/taxis(2);
RDAxis=(-NFFTf/2:NFFTf/2-1)/NFFTf/faxis(2);
pcolor(FMAxis,RDAxis*1000,fftshift(M)),shading flat,colormap jet, colorbar
axis([-600 600 -5 5])
title('Envelope Spectrum')

subplot(222)
pcolor(FMAxis,RDAxis*1000,fftshift(Minv)),shading flat,colormap jet, colorbar
axis([-600 600 -5 5])
title('Inverse Filter (No Lowpass)')

subplot(223)
NFFTt=2^nextpow2(size(Hinv,2));
NFFTf=2^nextpow2(size(Hinv,1));
FMAxis=(-NFFTt/2:NFFTt/2-1)/NFFTt/taxis(2);
RDAxis=(-NFFTf/2:NFFTf/2-1)/NFFTf/faxis(2);
Minv=fftshift(abs(fft2(Hinv,NFFTf,NFFTt)));
pcolor(FMAxis,RDAxis*1000,Minv),shading flat,colormap jet, colorbar
axis([-600 600 -5 5])
xlabel('Modulation Rate (Hz)')
ylabel('Spectral Frequency (x 10^-3 ; cycles/Hz)')
title('Composite Inverse Filter')

subplot(224)
Mfinal=convfft2(real(ifft2(M)),Hinv);
NFFTt=2^nextpow2(size(M,2));
NFFTf=2^nextpow2(size(M,1));
FMAxis=(-NFFTt/2:NFFTt/2-1)/NFFTt/taxis(2);
RDAxis=(-NFFTf/2:NFFTf/2-1)/NFFTf/faxis(2);
Mfinal=fftshift(abs(fft2(Mfinal,NFFTf,NFFTt)));
Mfinal=Mfinal/max(max(Mfinal));
pcolor(FMAxis,RDAxis*1000,Mfinal),shading flat,colormap jet, colorbar
axis([-600 600 -5 5])
title('Filtered Envelope Spectrum')
