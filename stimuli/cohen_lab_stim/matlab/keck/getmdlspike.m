%
%function [Time,ModelWave]=getmdlspike(infile,mdl)
%
%       FILE NAME       : GET MDL SPIKE
%       DESCRIPTION     : Gets the Nth model waveform from an MDL File 
%
%	infile		: filename 
%	mdl		: Model Number
%
function [Time,ModelWave]=getmdlspike(infile,mdl)

%Reading Input File
fid=fopen(infile);
X=fread(fid,inf,'char')';
List=setstr(X);

%Finding Models
Ret=setstr(10);
indexpound=find(List=='#');
indexret=find(List==Ret);
startindex=find(indexret>indexpound(mdl+1));
startindex=indexret(startindex);
if mdl+1==length(indexpound)
	List=List(startindex(1)+1:length(List));
else
	List=List(startindex(1)+1:indexpound(mdl+2)-1);
end

%Converting the Model
D=[];
index=find(List==setstr(10));
for k=1:length(index)
	D=[D setstr(9)];
end
List(index)=D;
ModelWave=str2num([List;List]);
ModelWave=ModelWave(1,:);
Time=ModelWave(1:2:length(ModelWave));
ModelWave=-ModelWave(2:2:length(ModelWave));
