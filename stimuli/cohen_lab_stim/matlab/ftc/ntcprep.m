function [] = ntcprep(motherfile,spikefile,triggerfile,varargin)
%
%	DESCRIPTION:	Convert kvale-derived .mat files to single-unit,
%			tcexplore-compatable .mat files.
%	motherfile:	The .dtc file to be emulated (whose path is included in
%			the mfile and must be changed ther if necessary.
%	spikefile:	The .mat file with spet event time variables.
%
%	OPTIONAL
%	triggerfile: 	Optional, b/c mfile just looks for ch6trg.mat file
%			which corresponds to the spikefile. 
%	varargin:	Arrays with the UNIT numbers (spet#'s +1) to be
%			combined for multiunit, if desired.
%			If varargin is not included, the default is to make
%			an ntc file for each model.
%
%	WARNING: this uses u1 for model 0, and so on.
% 							Lee Miller 8/97
%
%		[] = ntcprep(motherfile,spikefile,triggerfile,varargin);



%			HEADER INFO INHERITANCE
%Path = ['/net/schubert/lmiller/93BQT5/dtc/'];		%append path onto motherfilename
Path = ['./'];	
motherfile = [Path motherfile];

fid = fopen(motherfile, 'r', 'a');

if fid == -1	%if motherfile opening unsucessful
   disp(' ');
   disp('   WARNING:  Motherfile was not opened sucessfully.');
   disp('     Default values have been assigned to fMin (2.5) and nOctaves (5).');
   disp('     You must make a note of this, as the values will be wrong!');
   disp(' ');
   header = ['Motherfile not found.  Default (incorrect) values were assigned to fMin and nOctaves.'];
   fMin = 2.5;		%just to have a value
   nOctaves = 5;
else		%if motherfile was opened successfully
   H1 = fread(fid, 70, 'char');    %read file legend as 16 bit character
   H2 = fread(fid, 1, 'short');  %read the rest of header
   H3 = fread(fid, 6, 'float');	%fmin, octaves, fmax, ampl, window, flag
   disp(' ');
   header = sprintf('%c', H1(1:69));
   disp(header);
   fMin = H3(1)
   nOctaves = H3(2)
   status = fclose(fid);
end %if

%			LOAD TRIGGERS
if nargin < 3
   loc = findstr(spikefile,'ch') + 1;
   triggerfile = [spikefile(1:loc) '6trg.mat'];
end
loc = findstr(triggerfile,'.');
ext = triggerfile(loc:loc+3);
if ext == '.bin'
   trig2mat(triggerfile,24000); 
   where = findstr(triggerfile,'_b');
   triggerfile = [triggerfile(1:(where-1)) 'trg.mat'];
   
end
eval(['load ' triggerfile]);
%triggers=TrigTimes/Fs*1000;
triggers=Trig/Fs*1000;
if length(triggers)~=675
   disp('WARNING:  NUMBER OF TRIGGERS != 675.')
   return
end
if ~all(abs(diff(diff(triggers)))<10)		%check spacing to within 3 ms (~error of trigger generation)
   disp('WARNING:  TRIGGERS NOT EQUALLY SPACED.')
   %return
   triggers
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
   eval(['spet' num2str(k) '=spet' num2str(k) '/Fs*1000;']);	%and convert them to ms
   spet_names{k+1}=['spet' num2str(k)];		% make a cell array containing the variable names
   k = k+1;
   spetname = ['spet' num2str(k)];
end
num_units=k/2;					% k/2 doesn't count the outliers


if nargin < 4			%in case no spike trains specified, use all models
   for k = 1:length(spet_names)/2
     varargin{k} = [k];
   end
end
load order;		%the order from 1 to 675, stored in order.mat	


for j = 1:length(varargin)	%for each spiketrain(-combination) in varargin
   spike = [];			%initialize array for spike times
   for i = 1:length(varargin{j})	%for compounding more than one .spk file into a single tc
      eval(['inspike = ' spet_names{varargin{j}(i)} ';'])	%generically name the input array "inspike"
      spike = [spike inspike];		%concatenate w/ previous files
   end
   spike=sort(spike);		%in case more than one file, order the latencies



   %		 CONSTRUCT LATENCY ARRAY TO BE WRITTEN IN .mat FILE

   triggers(676) = triggers(675) + (triggers(675)-triggers(674));	%artificially put cap on trigger array
   spike(length(spike)+1) = triggers(676)+1;			%and on spike array (so no indices overrun)
   
   latencies = zeros(1,3);	%initialize the latency array
   load order;		%the order from 1 to 675, stored in order.mat	


   index=1;
   for ampl = 1:15				%outermost loop goes through amplitudes
      for freq = 1:45			%inner for-loop goes through frequencies
         trgindex = find(order==(ampl-1)*45+freq);
         trgtime = triggers(trgindex);
         nexttrig = triggers(trgindex + 1) -5;	%(-5) to make sure not to overlap next presentation
         spkindex = min(find(spike>trgtime));
	    while (spike(spkindex)<nexttrig) & spkindex		
	       latencies(index,:) = [spike(spkindex)-trgtime freq ampl];
	       spkindex = spkindex+1;
               index = index+1;
	    end
         end
   end

   [y ii] = sort(latencies(:,1));	%sort the latencies array by latency (first column)
   latencies = latencies(ii,:);



   %			SAVE .mat FILE
   %for outputfile name use .dtc motherfile, change to ntc.mat extention, and give model#s index

   unitstring = [];
   for k = 1:length(varargin{j})
      unitstring = [unitstring 'u' num2str(varargin{j}(k))];
   end
   loc = findstr(spikefile,'.') - 1;
   fileout = [spikefile(1:loc) '_' unitstring '_ntc'];

   if exist([fileout '.mat'])
      disp('WARNING:  FILE ALREADY EXISTS FOR THIS MOTHERFILE AND UNIT(S).')
      disp('Press any key to continue writing to/over generic file with unit designation XX')
      disp('   or press control-C to break out.')
      pause
      fileout = [spikefile(1:loc) '_' 'XX' '_ntc'];
   end


%   extAttenC=30;		%*************get this from the header!
%   extAttenI=30;
extAttenVect=[30 30];



   eval(['save ' fileout ' fMin nOctaves extAttenVect latencies header'])
   outscript = ['Saved to file ' fileout '.mat'];  disp('');
   disp(outscript);
   clear spike index latencies ampl freq trgindex trgtime nextrg spkindex y ii unitstring loc fileout outscript
end %for j all spiketrains
