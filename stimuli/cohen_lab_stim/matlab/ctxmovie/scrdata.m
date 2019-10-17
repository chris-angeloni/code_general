%function [data] = scrdata(scriptfile,sequence)
%
%	FILE NAME 	: scrdata
%	DESCRIPTION 	: Gets information from a script file.  Called 
%			  by PSTHMV for relevant information from script.
%
%	scriptfile	: Script File - including path and extension
%	sequence	: Sequence Number
%
%	data		: Returned information
%			  Col 1: Unit number
%			  Col 2: X-Coordinate
%			  Col 3: Y-Coordinate
%			  COL 4: Normalization Factor
%			  Col 5: File number
%
function [data] = scrdata(scriptfile,sequence)

%Loading Script
f=['load ',scriptfile,';'];
eval(f);

%Extracting Script Filename and Path from string
t1=max( [find(scriptfile=='\') find(scriptfile=='/')] );
t2=max([find(scriptfile=='.') 0])-1;
if t2==-1
	t2=length(scriptfile);
end
path=scriptfile(1:t1);
scr=scriptfile(t1+1:t2);
f=['scrdat=',scr,';'];
eval(f);

%Extracting data
data(:,1)=scrdat(:,1);
data(:,2)=scrdat(:,2);
data(:,3)=scrdat(:,3);
data(:,4)=scrdat(:,4);
data(:,5)=scrdat(:,sequence+4);
