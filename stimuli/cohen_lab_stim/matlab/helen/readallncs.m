%
%function  [Data]=readallncs
%
%DESCRIPTION: Reads aall NCS file in a directory and returns data structure
%
%Monty A. Escabi, April, 14 2004
%
function  [Data]=readallncs

%Search for NCS Files in Directory
List=dir('*Ncs');

%Sorting the List According to Channel Number
for k=1:length(List)
	index1=findstr(List(k).name,'CSC');
	index2=findstr(List(k).name,'.');
	FileNum(k)=str2num(List(k).name(index1+3:index2-1));
end
FileNum=FileNum';
[FileNum,SortIndex]=sort(FileNum);

%Reading All Files According in Increasing Channel Order
for k=1:length(List)
	[D]=readncs(List(SortIndex(k)).name);
	Data(k)=D;
end
