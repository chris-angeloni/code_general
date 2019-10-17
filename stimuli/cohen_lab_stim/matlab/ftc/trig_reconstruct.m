function [triggers]=trig_reconstruct(Fs,infile)
%
%
%	DESCRIPTION:	For incomplete trigger traces, tries to reconstruct
%			all 675 triggers.  Saves them as files trg_off#.mat,
%			where off is the negative offset in numbers of triggers
%			from the first trigger in the trace.
%
%	Fs:		sampling rate
%	infile:		file with corrupt trigger sequence, in samples
%
%		[triggers]=trig_reconstruct(Fs,infile);

dot=findstr(infile,'.mat');
outfileroot=infile(1:dot-1);

load(infile);
t_old=triggers;
clear triggers;

%mean inter-trig samples
dff = diff(t_old);
delta = mean(dff(find(dff/Fs>.45&dff/Fs<.47)));

%interpolate where trigs missing
loc=find(dff>delta*1.5);
t_interp=[];
for i=1:length(t_old)
   t_interp(end+1)=t_old(i);
   if sum(loc==i)
      missed=round((t_old(i+1)-t_old(i))/delta)-1;
      dmiss=(t_old(i+1)-t_old(i))/(missed+1);
      for j=1:missed
         t_interp(end+1)=t_old(i)+j*dmiss;
      end
   end
end
if length(t_interp)==675
   triggers=t_interp;
   outfile = [outfileroot 'off0.mat'];
   eval(['save ' outfile ' triggers Fs']);
   outstr = [outfile ' saved.'];
   disp(outstr);
end


%reconstruct triggers on ends
num = length(t_interp)
maxoff = 675-num; 	%maximum offset
for offset=1:maxoff
   tn=t_interp;
   first=tn-offset*delta;
   if first > 0 		%i.e. sequence must be positive time
      for k=1:offset
	 tn = [tn(1)-delta  tn];	
      end
      for kk=1:(maxoff-offset)
	 tn=[tn tn(end)+delta ];
      end
      triggers=tn;
      outfile = [outfileroot 'off' num2str(offset) '.mat'];
      eval(['save ' outfile ' triggers Fs']);
      outstr = [outfile ' saved.'];
      disp(outstr);
   end %if first
end %for offset
