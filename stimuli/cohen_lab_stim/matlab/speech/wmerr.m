%
%function [Fo,Fi]=wmerr(Fo,Fs,M,gamma,f1,f2,alpha,Phase)
%
%       FILE NAME       : WM ERR
%       DESCRIPTION     : Evaluates the Error that results from the 
%			  Milenkovich's aproach of finding To.
%			  Generates a Phase modulated sinusoid and
%			  extracts phase function to evaluatre error.
%
%	Fo		: Mean Fundamental Frequency
%	Fs		: Sampling frequency
%	M		: Number of samples
%	gamma		: Phase Modulation index
%	f1		: Phase Signal Lower Cutoff
%	f2		: Phase Signal Upper Cutoff 
%	alpha		: Phase Signal Fractal Dimension / Power 
%			  log Spectrum Exponent
%       Phase           : Phase Signal - Optional
%
%	Fo		: Extracted Fo Array
%	Fi		: Instantenous Fo Array
%       Phase           : Phase Signal
%
function [Fo,Fi]=wmerr(Fo,Fs,M,gamma,f1,f2,alpha,Phase)

%Checking Phase Signal / Argument
if nargin < 8
        [tp,Phase]=n1overf(f1,f2,alpha,Fs,M);
	Phase=2*(norm1d(Phase)-.5);
	Phase=gamma*Phase;
end

%Phase Modulated Sinusoid
x=sin(2*pi*Fo/Fs*(1:M)+gamma*Phase);

%Phase Modulated Sinusoid
x=sin(2*pi*Fo/Fs*(1:M)+gamma*Phase);

%Finding Instantenous Frequency from original signal
Fi=Fo+diff(gamma*Phase)*Fs/2/pi;
ti=(1:M-1)/Fs;

%Finding Instantenous Frequency Using WM aproach
[To,MO]=wm1(x,Fs);
Fo=1./To;
tt=0;
for k=2:length(To)
	tt(k)=To(k-1)+tt(k-1);
end

%Interpolating Fo
Fo=interp1(tt,Fo,(1:max(tt)*Fs)/Fs,'spline')';
tt=(0:length(Fo)-1)/Fs;

%Matching Wavefornms
[Fo,Fi]=fomatch(Fo,Fi);
tt=(0:length(Fo)-1)/Fs;
ti=(0:length(Fo)-1)/Fs;

plot(ti,Fi,'y.')
hold on
plot(tt,Fo,'r')
