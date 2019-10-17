%
%function [Faxis,Pxx,PP]=psdfile(infile,f1,f2,Fs,df,ATT,type,M,Disp,N,Save)
%	
%	FILE NAME 	: PSD FILE
%	DESCRIPTION 	: Computes the power spectral density of a 
%			  given input file.  Uses periodogram average
%			  described in Hayes
%			  Saves to file if desired.
%
%       infile		: Input File Name
%	f1		: Lower cutoff frequency for spectral fit
%	f2		: Upper cutoff frquency for spectral fit
%	Fs		: Sampling Rate
%	ATT		: Stopband and Passband attenuation for smoothing 
%		 	  Roark / Escabi B-Spline Window
%	df		: Spectral Resolution for Periodogram (PSD)
%	type		: Input and Output File Data Type 
%			  Default == 'int16'
%	M		: Data Block Size ( Default==1024*128 )
%			  Must be a dyadic number ( 2^L for some L==integer)
%	Disp		: Display output: 'y' or 'n'
%			  Default = 'n'
%	N		: Order of Polynomial fit for Spectrum
%			  Optional - Default = 2
%	Save		: Save Output: 'y' or 'n'
%			  Default: 'n'
%			  Output Filename: infile '_PSD.mat'
%
%RETURNED VARIABLES
%	Faxis		: Freqeuncy axis for Pxx
%	Pxx		: Signal power spectrum
%	PP		: fitted spectrum to N-th order polynomial
%			  Optional - Returned only if selected
%
function [Faxis,Pxx,PP]=psdfile(infile,f1,f2,Fs,df,ATT,type,M,Disp,N,Save)

%Checking Input Arguments
if nargin<4
	ATT=60;
end
if nargin<5
	type='int16';
end
if nargin<6
	M=1024*128;
end
if nargin<7
	Disp='n';
end
if nargin<8
	N=2;
end	
if nargin<9
	Save='n';
end

%Opening Input and Output Files
fidin=fopen(infile,'r');

%Finding Sinc(a,p)/ B-Spline window as designed by Roark / Escabi
W=designw(df,ATT,Fs);
MW=2^nextpow2(length(W));

%Reading data and Computing Pxx (Power Spectral Density)
[X,Length]=fread(fidin,M,type);
count=0;
Pxx=zeros(MW/2+1,1);
while Length==M & ~feof(fidin)

	%Display
	clc
	disp(['Computing Periodogram Average : Block ' num2str(count+1)])

	%Averaging PSD
	count=count+1;
	[PSD,Faxis]=psd(X,MW,Fs,W);
	Pxx=Pxx+PSD/100;
	[X,Length]=fread(fidin,M,type);

end
Pxx=Pxx/count;

%Noramlizing so that x[n] has unity std
%From parsevals thrm. note : sum(x[n]^2) = mean(X(k)^2)
Pxx=Pxx/mean(Pxx);

%Fitting Spectrum to N-th order polynomial
%Fitting Polynomial to Pxx
index=find(Faxis>f1 & Faxis<f2);
[p,S]=polyfit(Faxis(index),10*log10(Pxx(index)),N);
PP=zeros(size(Pxx));
for k=1:length(p)
        PP=PP+p(k)*Faxis.^(N-k+1);
end
PP=10.^(PP/10);

%Displaying output
if strcmp(Disp,'y')
	plot(Faxis,10*log10(Pxx))
	if nargin>=8
		hold on
		plot(Faxis,10*log10(PP),'r')
		hold off
	end
	pause(0)
end

%Closing Input Files
fclose('all');

%Saving to file
if strcmp(Save,'y')
	index=findstr(infile,'.');
	f=['save ' infile(1:index-1) '_PSD.mat Faxis Pxx PP N'];
	if findstr(version,'5.')
		f=[f ' -v4'];
	end
	eval(f);
end
