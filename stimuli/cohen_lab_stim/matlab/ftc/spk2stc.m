function [H1] = spk2stc(motherfile,triggerfile,spikefile,spiketrains)
%mfile to convert kvale-derived .mat files to single-unit, tcexplore-compatable .stc files.
% motherfile is the .dtc file to be emulated, triggerfile is .mat, 
% spikefile is the .mat file with spet event time variables,
% and spiketrains is an array with the spet#'s (0+) to be combined for multiunit if desired.
% Lee Miller 8/97
%
%		[H1] = spk2dtc(motherfile,triggerfile,spikefile,spiketrains)


eval(['load ' triggerfile]);
if length(triggers)!=675
   disp('WARNING:  NUMBER OF TRIGGERS != 675.')
   return
end
%if ~all(diff(diff(trigger))==0)
%   disp('WARNING:  TRIGGERS NOT EQUALLY SPACED.')
%   return
%end



eval(['load ' spikefile]);
spet_names=who('-file',spikefile);	%a cell array containing the variable names

spike = [];			%initialize array for spike times
for i = 1:length(spiketrains)	%for compounding more than one .spk file into a single tc
   eval(['inspike = ' spet_names{spiketrains(i)+1} ';'])	%generically name the input array "inspike"
   spike = [spike inspike];		%concatenate w/ previous files
end
sort(spike);		%in case more than one file, order the latencies
spike = spike*30;	%convert times to dtc sampling rate of 30(kHz)
triggers = triggers*30;



%		 CONSTRUCT LATENCY ARRAY TO BE WRITTEN AS .STC FILE

latlength = 2766 + 15*80 + 45*4 + length(spike);	%including all the spaces, how long latency must be
latency = zeros(latlength,1);			%allocate memory
increment = triggers(2)-triggers(1);

load order;		%the pseudorandom order from 1 to 675, stored in order.mat

index = 2770;		

for ampl = 1:15				%outermost loop goes through amplitudes
   index = index + 180;		%jumps over blank rows
   for freq = 1:45			%inner for-loop goes through frequencies
      trgtime = triggers(order((ampl-1)*45+freq));
      nexttrig = trgtime+increment;
      spkindex = min(find(spike>trgtime));
	while(spike(spkindex)<nexttrig)
	   latency(index) = spike(spkindex)-trgtime;
	   spkindex = spkindex+1;
	   index = index+1;
	end
	index = index + 4;	%jumps past place-holder (01) and spike
			 		% number to spike latency
	  
   end
end


%			HEADER INHERITANCE
fid = fopen(motherfile, 'r', 'a');

H1 = fread(fid, 70, 'char');    %read file legend as 16 bit character
H2 = fread(fid, 1, 'short');  %read the rest of header
H3 = fread(fid, 6, 'float');	%fmin, octaves, fmax, ampl, window, flag
H4 = fread(fid, 81, 'short');  

status = fclose(fid);



%			WRITE .STC FILE
%for outputfile name use .dtc motherfile, change to .stc extention, and give numeric index


%	this is just to index fileout up to 9, and tell you if you topped out with 10
fileout = ['1_' motherfile(3:length(motherfile)-3) 'stc'];
n=1;
while exist(fileout) == 2 & n<10
   n = n+1;
   fileout = [num2str(n) '_' motherfile(3:length(motherfile)-3) 'stc'];
end
if n>10
   disp('WARNING:  NINE .STC FILES ALREADY EXIST FOR THIS MOTHERFILE.')
   disp('Press any key to continue writing to/over generic file with prefix xx')
   disp('   or press control-C to break out.')
   pause
   fileout = ['xx' motherfile(3:length(motherfile)-3) 'stc'];
end


fid = fopen(fileout, 'w', 'a');

fwrite(fid, H1, 'char');       %write file legend as 16 bit character
fwrite(fid, H2, 'short');      %write the rest of header
fwrite(fid, H3, 'float');	%fmin, octaves, fmax, ampl, window, flag
fwrite(fid, H4, 'short');

fwrite(fid, latency, 'short');	%write latency data

status = fclose(fid);

if status == 0
   string = ['File ' fileout ' successfully written.'];
   disp(string)
else
   disp('WARNING:  FILE WRITE ERROR.')
end
   




