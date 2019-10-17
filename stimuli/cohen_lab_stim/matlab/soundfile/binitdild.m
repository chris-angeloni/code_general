%
%function []=binitdild(outfile,Fs,cf,itd,ild,N,p,dt,rt,ist)
%
%       FILE NAME       : BIN ITD ILD
%       DESCRIPTION     : Binaural Sound Generator
%			  Generates a binaural sound file for testing
%			  ITD vs. ILD sensitivity of a neuron at the neurons 
%			  CF.  The sound consist of a carrier at the neurons 
%			  CF with a white noise envelope superimposed on the
%			  carrier
%
%       outfile		: Output file name - no extension
%       Fs		: Sampling Rate
%       cf		: Neurons center frequency
%       itd		: Array of inter aural time  differences ( usec ) 
%	ild		: Array of inter aural level differneces ( dB )
%	N		: Number of repetitions for each condition
%	p		: B-spline window transition region order
%	dt		: B-spline window width ( msec )
%	rt		: B-spline window rise time ( msec )
%	ist		: Inter stimulus time ( msec )
%	BW		: BandWidth of white noise modulation envelope 
%			  superimposed on signal carrier.  If BW==0 
%			  then no envelope is superimposed
%	M		: Block Size (Default==1024*32)
%	
function []=binitdild(outfile,Fs,cf,itd,ild,N,p,dt,rt,ist,BW,M)

if nargin<12
	M=1024*32;
end

%Generating B-Spline Window Function
[W]=splinewindow(Fs,p,dt,rt);

%Generating sound segment
L=ist/1000*Fs;
X=zeros(1,L);
X(1:length(W))=.98*1024*32*W.*sin(2*pi*cf*(1:length(W))/44100);

%Adding Modulation Envelope
if BW~=0
	A=noiseunif(BW,Fs,length(W));
	X(1:length(W))=A.*X(1:length(W));
end

%Opening Output File
fid1=fopen([outfile '.sw'],'w');

%Generating Binaural Sound File
dL=round(itd*1E-6*Fs/2);
maxdL=max(abs(dL));
midILD=max(ild)/2;
Y=zeros(1,2*(length(X)+maxdL));
for j=1:N
	for k=1:length(itd)
		for l=1:length(ild)

			%Generating Sound Segments
			if floor((maxdL+dL(k)+2)/2)==(maxdL+dL(k)+2)/2
				Y(maxdL+dL(k)+(1:2:2*length(X)))=round(10.^((ild(l)/2-midILD)/20).*X);
				Y(maxdL-dL(k)+(2:2:2*length(X)))=round(10.^((-ild(l)/2-midILD)/20).*X);
			else
				Y(maxdL+1+dL(k)+(1:2:2*length(X)))=round(10.^((ild(l)/2-midILD)/20).*X);
				Y(maxdL+1-dL(k)+(2:2:2*length(X)))=round(10.^((-ild(l)/2-midILD)/20).*X);
			end

			%Writing Output SW File
			fwrite(fid1,Y,'int16');
%plot(Y(1:2:length(Y)))
%hold on
%plot(Y(2:2:length(Y)),'r')
%axis([0 1000 -32000 32000])
%hold off
%pause(1)
		end
	end
end

%Generating Trigger
fid2=fopen('trig.raw','w');
Trig=zeros(1,length(Y));
Trig(1:1000)=1024*32*ones(1,1000);
for j=1:N
	for k=1:length(itd)
		for l=1:length(ild)

			if k==1	& l==1
				Trig(2001:3000)=1024*32*ones(1,1000);
			else
				Trig(2001:3000)=zeros(1,1000);
			end
			fwrite(fid2,Trig,'int16');

		end
	end
end


%Generating 4channel SW File
fid3=fopen([outfile '4ch.sw'],'w');
frewind(fid1);
frewind(fid2);
Z=zeros(1,4*M);
while ~feof(fid1)
	Y=fread(fid1,M*2,'int16');
	T=freadi(fid2,M,'int16');
	Z(1:4:4*M)=Y(1:2:length(Y));
	Z(2:4:4*M)=Y(2:2:length(Y));
	Z(3:4:4*M)=T;
	Z(4:4:4*M)=T;
	
	fwrite(fid3,Z,'int16');
end

%Converting SW File to Wav File
f=['!sox -r ' int2str(Fs) ' -c ' int2str(2) ' ' outfile '.sw ' outfile '.wav'];
eval(f);
f=['!rm ' outfile '.sw'];
eval(f);

%Saving Parameter File


%Closing Output File
fclose('all');
