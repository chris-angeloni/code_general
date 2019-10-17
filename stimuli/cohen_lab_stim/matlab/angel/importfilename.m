%function [cursmr,cursrn]=importfilename;
%
%Function
%          get a pair of mr and rn filenames from mr_rn Acess Database
%Output
%        cursmr    cursmr.data are mr filenames
%        cursrn    cursrn.data are rn filenames
%
%
%ANQI QIU
%01/20/2002
%

function [cursmr,cursrn]=importfilename;
%connect access database
conn=database('mr_rn','','');
%to check whether it connects database
ping(conn);
%to get the data from database
cursmr=exec(conn,'select MR_name from mr_rn');
cursmr=fetch(cursmr,64);
cursrn=exec(conn,'select RN_name from mr_rn');
cursrn=fetch(cursrn,64);
close(cursmr)
close(cursrn);
close(conn);

