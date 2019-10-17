%
%function []=mdlspike(spkfile)
%
%       FILE NAME       : MDL SPIKE
%       DESCRIPTION     : Adds Spike models to a SPET File
%
%	infile		: spkfile
%
function []=mdlspike(spkfile)

%SPET File Name
index=find(spkfile=='.');
spetfile=[spkfile(1:index-4) '.mat'];
mdlfile=[spkfile(1:index-1) '.mdl'];

%Loading SpetFile 
f=['load ' spetfile];
eval(f);

%Finding Models Available
ch=setstr(39);
k=0;
f=['save ' spetfile ' Fs '];
while exist(['spet' int2str(k)])
	f=[f ' spet' int2str(k)];
	k=k+1;
end
for l=1:k/2
	f=[f ' ModelWave' int2str(l-1)];
	f2=['[Time,ModelWave' int2str(l-1) ']= getmdlspike(' ch mdlfile ch ',' int2str(l-1) ');'];
	eval(f2);	
end
k=0;
while exist(['SpikeWave' int2str(k)])
        f=[f ' SpikeWave' int2str(k)];
        k=k+1;
end
if exist('Time')
	f=[f ' Time'];
end
if ~strcmp(version,'4.2c')
	f=[f ' -v4'];
end
eval(f);

