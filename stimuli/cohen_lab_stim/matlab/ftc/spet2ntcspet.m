function [] = spet2ntcspet(triggerfile,spikefile,start,ende)
%
%	DESCRIPTION:	TakeS .mat-files containing spike event time "spet"
%			variables and writes new .mat file who's event times
%			fall within a certain time window after each trigger
%			of the dtc program.  The resultant files may then be
%			used to run correlograms on those particular time
%			windows, with respect to a stimulus.
%	triggerfile:	File containing trigger times.
%	spikefile:	.mat file with spet spike event time variables.
%	start,ende	Start and end times, in ms, following the triggers,
%			e.g., start=5, ende=60.
%
%
%		[] = spet2ntcspet(triggerfile,spikefile,start,ende);


dotloc = findstr(spikefile,'.');
outfile = [spikefile(1:(dotloc-1)) '_tc' spikefile(dotloc:(length(spikefile)))];

%			LOAD TRIGGERS
loc = findstr(triggerfile,'.');
ext = triggerfile(loc:loc+3);
if ext == '.bin'
   trig2mat(triggerfile,24000); 
   where = findstr(triggerfile,'_b');
   triggerfile = [triggerfile(1:(where-1)) 'trg.mat'];
   
end
eval(['load ' triggerfile]);
if length(triggers)!=675
   disp('WARNING:  NUMBER OF TRIGGERS != 675.')
   return
end
if ~all(abs(diff(diff(triggers)))<3)		%check spacing to within 3 ms (~error of trigger generation)
   disp('WARNING:  TRIGGERS NOT EQUALLY SPACED.')
   return
end


% 		 LOAD AND SORT THE SPIKE LATENCIES
eval(['load ' spikefile]);

if ~exist('Fs','var')
   disp('WARNING: .mat file lacks sampling rate varible Fs.')
   disp('	It may be an old file in ms, not samples.')
end

k = 0;						%count how many unit models there are (ignore the outliers)
spetname = ['spet' num2str(k)];			
while exist(spetname)
   eval(['spet' k '=spet' k '/Fs*1000;']);	%and convert them to ms
   spet_names{k+1}=['spet' num2str(k)];		% make a cell array containing the variable names
   k = k+1;
   spetname = ['spet' num2str(k)];
end


for k = 1:length(spet_names)
   varargin{k} = [k];
end

for j = 1:length(varargin)	%for each spiketrain(-combination) in varargin
   spike = [];			%initialize array for spike times
   eval(['spike = ' spet_names{varargin{j}} ';'])	%generically name the input array "inspike"
   eval(['clear 'spet_names{varargin{j}} ';'])          %get rid of the old to make room for the new
   spike = sort(spike);
   
   %		 CONSTRUCT NEW SPETs TO BE WRITTEN IN .mat FILE
   triggers(676) = triggers(675) + (triggers(675)-triggers(674));
   
   spetindex = 1;

   for i = 1:675
      spkindex = min(find(spike>(triggers(i)+start)));
      while spike(spkindex)<(triggers(i)+ende)			
         eval([spet_names{varargin{j}} ' (spetindex) = spike(spkindex);'])
         if spkindex == length(spike)
            break
         end
         spkindex = spkindex +1;
         spetindex = spetindex +1;
      end %while
   end %for



   %			SAVE .mat FILE
   clear spike index spkindex spetindex dotloc
   if j==1
      eval(['save ' outfile ' ' spet_names{varargin{j}}])
   else
      eval(['save ' outfile ' ' spet_names{varargin{j}} ' -append'] )
   end
   outscript = ['Saved ' spet_names{varargin{j}} ' to file ' outfile];  disp('');
   disp(outscript);

end %for j all spiketrains
