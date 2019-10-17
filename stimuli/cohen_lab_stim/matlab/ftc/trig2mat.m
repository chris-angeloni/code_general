function [triggers]=trig2mat(Fs,raw_file)
%
%	DESCRIPTION:	Takes a trigger channel file (uploaded from DAT tape)
%			and saves a .mat file with the trigger times samples,
%	Fs:		sampling rate saved as Fs.
%	raw_file:	DAT file .raw
%
%	triggers:	trigger values, in samples
%
%          [triggers]=trig2mat(Fs,raw_file);
%		

fid=fopen(raw_file,'r');


meg = 1024*1024;

[L,count]=fread(fid,meg,'short');
loc = min(find(L(100:meg)>0))+99;	%+99 to skip header
DC = L(loc);
L(1:(loc-1)) = DC;
L = L - DC;		%take out the DC

trigmin = min(L);
%threshold = trigmin/1.2;
threshold = trigmin/5;
triglocs = find(L<threshold);


count=meg;
i = 1;
while ~feof(fid)
   [L,count]=fread(fid,meg,'short');
   L = L - DC;		%take out the DC
   temp = find(L<threshold);
   temp = temp + (i*meg);
   triglocs = [triglocs ; temp];
   i = i+1;
   clear L
end

fclose(fid);

diffs = diff(triglocs);

triggers(1) = triglocs(1);
index=2;		
for k = 1:length(diffs)
   if diffs(k) > 10
      triggers(index) = triglocs(k+1);
      index = index +1;
   end
end

if length(triggers)~=675
   outstr = ['   THIS MAY NOT BE A TRIGGER FILE.  NUMBER OF TRIGGERS IS NOT 675. ITS ' num2str(length(triggers)) '.'];
%   disp(outstr)
%   disp('   Hit any key to try to reconstruct.  Otherwise, break out with control-C.');
%   pause
%   where = findstr(raw_file,'_b');
%   outfileroot = [raw_file(1:(where-1)) 'trg_'];
%   triggers_old = triggers;			%rename variable before passing it
%   trig_reconstruct(Fs,triggers_old,outfileroot);
%   return
end

where = findstr(raw_file,'_ch');
outfile = [raw_file(1:(where)) 'Trig.mat'];

eval(['save ' outfile ' triggers Fs']);
outstr = [outfile ' saved.'];
disp(outstr);

