function [curs]=trydbimportdemo

%connect access database
conn=database('try','','');



%to check whether it connects database
ping(conn);



%to get the data from database
%curs is the object that includes attributes, 
                                  %Data, DatabaseObject,
%                   RowLimit,SQLQuery, Message, type, ResultSet, 
%                   Cursor, Statement,Fetch
curs=exec(conn,'select Name from Orders');
curs=fetch(curs,10);



% to get information of database
attribute=attr(curs); %curs.Attributes
numcrows=rows(curs);
numcols=cols(curs);
colnames=columnnames(curs);
colsize=width(curs,1);





close(curs);
close(conn);

