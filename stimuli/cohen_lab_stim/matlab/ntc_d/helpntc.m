function helpntc()

hlptxt=' ';
rdline=' ';
fid=fopen('ntchelp.txt','r');
while(rdline~=-1),
  hlptxt=strvcat(hlptxt,rdline);
  rdline=fgetl(fid);
  end % (while)
fclose(fid);
hlptxt = cellstr(hlptxt);

helpwin(hlptxt,'ntc');

return
