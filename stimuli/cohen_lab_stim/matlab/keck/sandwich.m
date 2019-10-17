%
%function [Noise,Y,spet] =sandwich(Ha,Hb,Fs,M,T,outfile)
%
%       FILE NAME       : SANDWICH
%       DESCRIPTION     : Sandwich model simulation
%			  Used to obatin Wiener kernel estimates
%
%	Ha		: Input filter
%	Hb		: Output filter
%	Fs		: Sampling rate
%	M		: Noise length for simulation 
%	T		: Threshold . Normalized [0,1] relative to max.
%	outfile		: Output file name 
%			  Optional -> default = no save 
%
function [Noise,Y,spet] =sandwich(Ha,Hb,Fs,M,T,outfile)

%Arguments
if nargin<6
	savef='n';
else
	savef='y';
end

%Generating Noise
Noise=randn(1,M);
Noise=round((norm1d(Noise)-.5)*2*1024*32);

%System response to Noise
%Y=conv(Ha,Noise);
Y=convfft(Ha,Noise,round(length(Ha)/2),M);
%Y=rect(Y);
%Y=Y+.5*rect(Y);
%Y=Y.^2;
%Y=conv(Hb,Y);
Y=convfft(Hb,Y,round(length(Hb)/2),M);
Y=round(.95*1024*32*Y/max(Y));
tresh=max(Y)*T;
n=find(Y>tresh);
spet=n;

%Saving to file
if savef=='y'
	f=['Spike Count: ',num2str(length(n))];
	disp(' ');
	disp(f);
	disp(' ')
	fid=fopen(outfile,'wb');
	fwrite(fid,Noise,'int16');
	fclose(fid);
end
