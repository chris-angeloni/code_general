%
%function []=ammodsquare(infile,outfile,fam,Fs,p,rt,M,type)
%
%       FILE NAME       : AM MOD
%       DESCRIPTION     : Adds square wave modulations to infile and saves to
%			  outfile
%
%       infile		: Input file name
%       outfile		: Output file name
%       fam		: Upper modulation frequency
%	Fs		: Sampling frequency 
%	p		: B-Spline window order
%	rt		: Rise time ( msec )
%Optional
%	M		: Segment length ( Default=1024*128 )
%	type		: File Type : 'float' or 'int16' ( Default='float' )
%
function []=ammodsquare(infile,outfile,fam,Fs,p,rt,M,type)

%Preliminaries
if nargin<7
	M=1024*128;
end
if nargin<8
	type='float';
end

%Opening Files
index=findstr(outfile,'.');
fidin=fopen(infile,'r');
fidout=fopen(outfile,'w');
fidoutam=fopen([outfile(1:index-1) '.sqr'],'w');

%Adding Square Wave Modulations
k=1;
W=swindow(Fs,p,rt);
W=W/sum(W);
while ~feof(fidin)

	%Generating Modulation signal
	Env=round(noiseunif(fam,Fs,M));
	indexp=find(diff(Env)>0.5);
	Env=Env(indexp(1)+1:indexp(length(indexp)));
	Env=conv(Env,W);
	
	%Adding and Saving Modulation Signal to File
	X=fread(fidin,length(Env),type)';
	N=min(length(Env),length(X));
	if strcmp(type,'float')
		fwrite(fidout,X(1:N).*Env(1:N),type);
		fwrite(fidoutam,Env(1:N),type);
	elseif strcmp(type,'int16')
		X=round( 0.95*1024*32*X(1:N)./max(X(1:N)).*Env(1:N) );
                Env=round( 0.95*1024*32*Env(1:N) );
		fwrite(fidout,X,type);
		fwrite(fidoutam,Env,type);
	end
	clc;
	disp(['Saving Block ' num2str(k)]);
	k=k+1;
end

%Closing Files
fclose(fidin);
fclose(fidout);

