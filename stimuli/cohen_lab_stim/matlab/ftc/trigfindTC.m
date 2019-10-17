function [TrigTimes]=trigfindTC(infile,Fs);

[TrigTimes]=trigfind(infile,Fs);
if length(TrigTimes)~=675
   disp('WARNING:  wrong number of triggers.')
   return
end

TrigTimes'


loc=findstr('_ch',infile);
outfile=[infile(1:loc-1) 'tctrg.mat'];
evalstr=['save ' outfile ' TrigTimes Fs '];
eval(evalstr);
