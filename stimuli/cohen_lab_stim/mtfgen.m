%function []=mtfgen(outfile,fc,famlow,famhigh,gamma,Texp,Tam,Tpause,Fs,ModType,M)
%
%       FILE NAME       : MTF GEN
%       DESCRIPTION     : Generates a .WAV file which is used for 
%			  MTF experiments
%
%	outfile		: Output file name (No Extension)
%	fc		: Center Frequency 
%       famlow		: Minimum modulation frequency
%       famhigh		: Maximum modulation frequency
%	gamma		: Modulation Index : 0 < gamma < 1
%	Texp		: Experiment time (sec)
%	Tam		: Modulation interval time (sec)
%	Tpause		: Pause time (sec) between presentations
%	Fs		: Sampling frequency
%Optional
%	ModType		: Modulation Type: Linear or dB  
%			  'lin' or 'dB', Default 'lin'
%	M		: Segment length ( Default=1024*128 )
%
function []=mtfgen(outfile,fc,famlow,famhigh,gamma,Texp,Tam,Tpause,Fs,ModType,M)

%Preliminaries
if nargin<10
	ModType='lin';
	M=1024*128;
elseif nargin< 11
	M=1024*128;
end

%Opening Files
L=findstr(outfile,'wav');
if ~isempty(L)
	swoutfile=outfile(1:L-2);
else
	swoutfile=outfile;
end
fidsw=fopen([swoutfile '.sw'],'w');

%Getting Parameters
App=20*log10(1-gamma);			%Modulation Depth in dB
NTrig=round(1/famhigh*Fs/4); 		%Trigger Length
NP=Tpause*Fs;
M=ceil((Texp+Tpause)/(Tpause+Tam));	%M==number of AM segments
B=10^(1/M*log10(famhigh/famlow));	%B==Logarithm Base
N=ceil(Tam*Fs);
NH=.5*Fs;				%Ramp Length
[Faxis,H]=hproto(4,1,.5*pi,pi/NH);	%Ramp Function
H=H(1:floor(length(H)/2));		%Ramp Function

%Generating RAW Sound File with Triggers
Pause=zeros(1,2*NP);
Y=zeros(1,2*N);
for k=0:M
	fam=famlow*B^k;
	if strcmp(ModType,'lin')
	X=.5*(1-gamma*cos(2*pi*fam*(1:N)/Fs)).*sin(2*pi*fc*(1:N)/Fs+rand*2*pi);
	else
	X=10.^(App/40+App/40*cos(2*pi*fam*(1:N)/Fs)).*sin(2*pi*fc*(1:N)/Fs+rand*2*pi);
	end

	X(1:length(H))=X(1:length(H)).*H;
	X(N-length(H)+1:N)=X(N-length(H)+1:N).*fliplr(H);
	X=round(X*1024*32*.95);

	Trig=zeros(1,N);
	l=0;
	while round(l/fam*Fs)+NTrig<N
		LTrig=round(l/fam*Fs);	%Trigger Location
		Trig(LTrig+1:LTrig+NTrig)=1024*31*ones(1,NTrig);
		l=l+1;
	end

	Y(1:2:2*N)=X;
	Y(2:2:2*N)=Trig;
	if k<M
		fwrite(fidsw,[Y Pause],'int16');
	else
		fwrite(fidsw,[Y],'int16');
	end

	clc
	disp(['Generating: fm=' num2str(fam,4)]);
end

%Closing File
fclose('all');

%Generating WAV file using SOX command line program
f=['!sox -r ' int2str(Fs) ' -c 2 ' swoutfile '.sw ' swoutfile '.wav'];
eval(f);
