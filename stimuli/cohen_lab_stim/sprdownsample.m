%
%function []=sprdownsample(infile,ftype,DFt,DFf)
%
%       FILE NAME       : SPR DOWN SAMPLE
%       DESCRIPTION     : Downsamples an SPR file
%
%       infile		: Input file name
%	ftype		: 'float' or 'int16'
%	DFt		: Temporal Down Sampling Factor
%	DFf		: Spectral Down Sampling Factor
%
function []=sprdownsample(infile,ftype,DFt,DFf)

%Opening Files
fidin=fopen(infile,'r');
i=find(infile=='.');
outfile=[infile(1:i-1) '_DFt' int2str(DFt) '_DFf' int2str(DFf) '.spr'];
paramoutfile=[infile(1:i-1) '_DFt' int2str(DFt) '_DFf' int2str(DFf) '_param.mat'];
fidout=fopen(outfile,'a');

%Loading Param File
i=find(infile=='.');
f=['load ' infile(1:i-1) '_param.mat'];
eval(f)

%Down Sampling File
fseek(fidin,0,-1);
X=fread(fidin,NT*NF,ftype);
count=1;
while ~feof(fidin) 
	clc
	disp(['Block Number ' int2str(count)])
	X=reshape(X,NF,NT);
	X=X(1:DFf:NF,1:DFt:NT);
	X=reshape(X,1,size(X,1)*size(X,2));
	fwrite(fidout,X,ftype);
	X=fread(fidin,NT*NF,ftype);
	count=count+1;
end

%Creating Param File
taxis=taxis(1:DFt:NT);
faxis=faxis(1:DFf:NF);
NF=length(faxis);
NT=length(taxis);
DF=DF*DFt;
f=['save ' paramoutfile ' AmpDist App Axis Block DF FM FM1 Fs Fsn K LL M MM MaxFM MaxRD Mn Mnfft N NB NF NT RD RDk RP RPk X XMax count f f1 f2 fFM fRD faxis phase taxis']
eval(f)

%Closing Files
fclose(fidin);
fclose(fidout);

