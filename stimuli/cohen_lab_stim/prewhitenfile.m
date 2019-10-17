%
%function [faxis,PP,Faxis,Pxx]=prewhitenfile(infile,outfile,Fs,f1,f2,df,N,type,M)
%	
%	FILE NAME 	: PRE WHITEN FILE
%	DESCRIPTION 	: Pre-Whitens the data in infile in the frequency
%			  bands f1-f2
%			  Output data file is 'float' format
%
%       infile		: Input File Name
%	outfile		: Output File Name 
%	Fs		: Sampling Rate
%	f1		: Lower Cutoff Frequency for Pre-Whitening
%	f2		: Upper Cutoff Frequency for Pre-Whitening
%	df		: Spectral Resolution for Periodogram (PSD)
%	N		: Order of Polynomial fit for Pre-Whitening
%	type		: Input File Data Type 
%			  Default == 'int16'
%	M		: Data Block Size ( Default==1024*256 )
%			  Must be a dyadic number ( 2^L for some L==integer)
%RETURNED VARIABLES
%	faxis		: Frequency axis for PP
%	PP		: Polynomial fit of Spectrum
%	Faxis		: Freqeuncy axis for Pxx
%	Pxx		: Signal power spectrum
%
function [faxis,PP,Faxis,Pxx]=prewhitenfile(infile,outfile,Fs,f1,f2,df,N,type,M)

%Checking Input Arguments
if nargin<7
	N=3;
	type='int16';
	M=1024*256;
elseif nargin<8
	type='int16';
	M=1024*256;
elseif nargin<9
	M=1024*256;
end

%Opening Input and Output Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'w');

%Finding Sinc(a,p) window as designed by Roark / Escabi
ATT=40;
W=designw(df,ATT,Fs,'3dB');
MW=2^nextpow2(length(W));

%Reading data and Computing Pxx (Power Spectral Density)
[X,Length]=fread(fidin,M,type);
if Length~=M
	M=1024*64;			%Try smaller block size
	frewind(fidin);
	[X,Length]=fread(fidin,M,type);
end
count=0;
Pxx=zeros(MW/2+1,1);
while Length==M & ~feof(fidin) 

	%Display
	clc
	disp(['Prewhitenfile       : ' infile])
	disp(['Periodogram Average : Block ' num2str(count+1)])

	%Averaging PSD
	count=count+1;
	[PSD,Faxis]=psd(X,MW,Fs,W);
	Pxx=Pxx+PSD/100;
	[X,Length]=fread(fidin,M,type);

end
Pxx=Pxx/count;
Pxx=10*log10(Pxx);	%Converting to decibels

%Converting f1 and f2 to sample numbers
%M corresponds to Pxx and N corresponds to fft of blocked data
M1=round((length(Pxx)-1)*2*f1/Fs+1);
M2=round((length(Pxx)-1)*2*f2/Fs+1);
N1=round((M-1)*f1/Fs+1);
N2=round((M-1)*f2/Fs);
faxis=(0:M-1)/M*Fs;

%Fitting Polynomial PP to Pxx
[p,S]=polyfit(Faxis(M1:M2),Pxx(M1:M2),N);
P=zeros(1,N2-N1+1);
faxisN=faxis(N1:N2);
for k=1:length(p)
        P=P+p(k)*faxisN.^(N-k+1);
end
P=10.^(P/20);
PP=inf*ones(1,M);
PP(N1:N2)=P;
PP(M:-1:M/2+2)=PP(2:M/2);
faxisPP=(0:length(PP)-1)/length(PP)*Fs;
Pxx=10.^(Pxx/10);	%Converting decibels to linear amplitude

%Reading data and Pre-Whitening
frewind(fidin);
for k=1:count

	%Display
	clc
	disp(['Prewhitenfile       : ' infile])
	disp(['Pre-Whitening Data  : ' int2str(round(k/count*100)) '% done'])

	%Rading Input and Pre-Whitening
	X=fread(fidin,M,type);
	X=fft(X');
	X=real(ifft(X./PP));
	fwrite(fidout,X,'float');

end

%Closing Input and Output Files
fclose('all');
