% 	function condtc(file_name)
%	Condtc.m converts .dtc tuning curve files to matlab format.
%	Creates a set of matrices named t(msec latency),
%	a one-d array giving 45 frequencies,
%	a scalar giving the number of 2-d matrices (i.e. # of ms)
%	a string containing the legend,
%
%					M.Kilgard and L.Miller 8/95

function condtc(file_name)
	% This section opens and reads the .dtc file.
fid = fopen(file_name, 'r', 'a');

H1 = fread(fid, 70, 'char');    %read file legend as 16 bit character
H2 = fread(fid, 1, 'short');  %read the rest of header
H3 = fread(fid, 6, 'float');	%fmin, octaves, fmax, ampl, window, flag
H4 = fread(fid, 81, 'short');  

fmin= H3(1);
oct= H3(2);
frequency=zeros(1,45);

frequency(1)=fmin;
for y=1:44
	frequency(y+1)= fmin*(2^(oct*y/44));
end

[L, count] = fread(fid, 'short');	%read data

status = fclose(fid);

header  = sprintf('%c', H1(1:69));

index = 2770;		%index within array L, where latency data begins
lengthL = length(L);

L(length(L)+400)=0;   				%makes L longer
maxlat = round(max(L(2767:lengthL))/30);	%find largest value, divide by sampling
				%  rate(kHz) to determine longest latency in ms.
% loop to create time-slice matrices with names 't(ms latency)'
for ii = 1:maxlat+2
	eval(['t', num2str(ii) '= sparse(15,45);']);	
end

for ampl = 1:15				%outermost loop goes through amplitudes
	index = index + 180;		%jumps over blank rows
	for freq = 1:45			%inner for-loop goes through frequencies
		while L(index) > 0
			eval(['t' num2str(ceil((L(index)/30)+1)) '(ampl,freq) = t' num2str(ceil((L(index)/30)+1)) '(ampl,freq) + 1;']);
				%the monstrosity above adds 1 to the proper ampl-freq cell in
				%	the proper sparse time-slice array t(ms latency)
			index = index + 1;
		end	
		index = index + 4;	%jumps past place-holder (01) and spike
			 		% number to spike latency
	end
end

amps=[2.5:(75/14):77.5]; 	%sets variables needed for tcexplore

header = upper(header);
dblocat = findstr(header, 'DB');
if isempty(dblocat) == 0
	dblocat = min(dblocat);
	extatten = header((dblocat-2):(dblocat-1));
	extatten = str2num(extatten);
else
	extatten = 0
	disp(' ')
	disp(' ')
	disp('WARNING: ')
	disp(' ')
	disp('No external attenuation value was found!!!')
	disp(' ')
	disp(' ')
end
if isempty(extatten), disp('ERROR in header. External attenuation is incorrect and has been set to ZERO!!!'), extatten=0; end
amps = amps + (30 - extatten);
duration=maxlat;

end
clear H1 H2 H3 H4 fmin oct fid ii index lengthL freq L y ampl count status dblocat;
save temp   % temp.m is opened later by other m-files that need the variables.
