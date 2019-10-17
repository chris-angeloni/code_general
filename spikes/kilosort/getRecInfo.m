function [startTime,fs,softStart,softFS] = getRecInfo(fn)

% function [startTime,fs,softStart,softFS] = getRecInfo(fn)
% 
% reads out the start time, sample rate of the software clock and
% sample clock of the openEphys system from the file
% 'sync_messages.txt' written in flat binary format

% open the file
fid = fopen(fn,'r');
msg = textscan(fid,'%s', 'delimiter',{'\n'});
fclose(fid);

% get software timing
t = regexp(msg{1}{1},'(?<time>\d+)@(?<fs>\d+)Hz','names');
softStart = str2num(t.time);
softFS = str2num(t.fs);

% get sample timing
t = regexp(msg{1}{2},'(?<time>\d+)@(?<fs>\d+)Hz','names');
startTime = str2num(t.time);
fs = str2num(t.fs);