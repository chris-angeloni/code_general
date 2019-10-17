%
%function []=classbat()
%
%
%       FILE NAME       : CLASS BAT 
%       DESCRIPTION     : Searches for all STA files and Classifies the 
%			  Coresponding RAW File in directory
%
function []=classbat()

%Temporary Batch File
batchfile='classbat.bat';

%Finding All STA Files
[s,List]=unix('ls *.sta');
List=[setstr(10) List setstr(10)];
blockindex=findstr(List,'_b');
returnindex=findstr(List,setstr(10));
staindex=findstr(List,'.sta');

%Classifying all files
for k=1:length(blockindex)

	%Classifying All RAW Files and All BLOCKS
	index=find(blockindex(k) > returnindex);
	startindex=returnindex(index(length(index)))+1;
	headerfile=List(startindex:blockindex(k)+1);

	count=1;
	while exist([headerfile int2str(count) '.raw'])
		rawfile=[headerfile int2str(count) '.raw'];
		spkfile=[headerfile int2str(count) '.spk'];
		mdlfile=[headerfile int2str(count) '.mdl'];
		statefile=[List(startindex:staindex(k)+3)];

		fidout=fopen(batchfile,'w');
		fwrite(fidout,['recall_state ' statefile setstr(10)],'uchar');
		command=['classify ' rawfile ' ' spkfile ' '  mdlfile ' ' setstr(10)];
		fwrite(fidout,command,'uchar');
		fclose(fidout);
		f=['!nice -19 SpikeSort -f ' batchfile];
		eval(f);
		f=['!rm ' batchfile];
		eval(f);
		count=count+1;
	end

end

