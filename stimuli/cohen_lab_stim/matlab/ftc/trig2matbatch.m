function [errorfiles]=trig2matbatch(Fs,trigchan)
%
%	DESCRIPTION:	For all files in the directory with trigger channel,
%			takes the trigger channel file (uploaded from DAT tape)
%			and saves a .mat file with the trigger times samples,
%	Fs:		sampling rate saved as Fs.
%	trigchan:	trigger channel for .raw files
%
%          [errorfiles]=trig2matbatch(Fs,trigchan);
%		

errorfiles=[];

% find and list all ch#b1.raw for all given fileroots
lsstr=['ls *ch' num2str(trigchan) '*b1.raw '];
[s,List]=unix(lsstr);
List=[setstr(10) List setstr(10)];
rawindex=findstr(List,'raw');
returnindex=findstr(List,setstr(10));
for k=1:length(rawindex)
   index=find(rawindex(k) > returnindex);
   startindex=returnindex(index(length(index)))+1;
   files{k}=List(startindex:rawindex(k)+2);
end

for i=1:length(files)
   dstr=['Finding trigs in file ' files{i}];
   disp(dstr);
   [triggers]=trig2mat(Fs,files{i});
   if length(triggers)~=675
      errorfiles{end+1}=files{i};
      estr=['Trigs in file ' files{i} ' = ' num2str(length(triggers))];
      disp(estr);
   end
end



