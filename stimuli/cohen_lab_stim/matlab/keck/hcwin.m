%
%function [Noise,Y,spet] =hcwin(outile,Fs,F1,F2,Fc,Q,N,M,savef)
%
%       FILE NAME       : HC WIN
%       DESCRIPTION     : Non linear hair cell simulation for use with 
%			  wiener kernels extraction program 
%
%	outfile		: Output file name 
%	Fs		: Sampling rate
%	F1		: Noise lower cutoff frequency
%	F2		: Noise upper cutoff frequency 
%	Fc		: Filter center frequency 
%	Q		: Filter Quality factor
%	N		: Filter order
%	M		: Noise length for simulation 
%	savef		: Save to file 'y' or 'n' ( Default: 'n' )
%
function [Noise,Y,spet] =hcwin(outfile,Fs,F1,F2,Fc,Q,N,M,savef)

%Arguments
if nargin<9
	savef='n';
end

%Generating Noise
Noise=noiseblfft(F1,F2,Fs,M);
Noise=(norm1d(Noise)-.5)*2;

%System impulse response 
wa=2*pi*Fc/Q/2/Fs;
wc=2*pi*Fc/Fs;
p=1;
Ha=h(-N:N,wa,p*pi/(N+1)/wa,p);
Ha=Ha.*sin(wc*(1:2*N+1));
N=32*round(Fs/10000);
wb=2*pi*300/Fs;
Hb=h(-N:N,wb,p*pi/(N+1)/wb,p);

%System response to Noise
Y=conv(Ha,Noise);
%Y=rect(Y);
%Y=Y+.5*rect(Y);
Y=Y.^2;
Y=conv(Hb,Y);
tresh=max(Y)*.5;
n=find(Y>tresh);
%O=zeros(1,length(Y));
%O(n)=ones(1,length(n));
%Noise(n)=O(n)*3;
spet=n;

%Saving to file
if savef=='y'
	f=['Spike Count: ',num2str(length(n))];
	disp(' ');
	disp(f);
	disp(' ')
	fid=fopen(outfile,'a');
	fwrite(fid,M,'long');
	fwrite(fid,10000,'float');
	fwrite(fid,Noise,'float');
	fclose(fid);
end
