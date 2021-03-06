function [a,fid,status,error_msg]=read_file_chunk(fname,n,offset,precision)
% function to read a specified chunk of a file
%
% form:  [a,fid,status,error_msg]=read_file_chunk('fname',n,offset,'precision');
%
% n is how many samples to read
% offset how many samples in to start reading 
% precision=string with precision (e.g. 'float32', 'int16') for fread
% fname is string with full file name (including suffix)
%
% currently works for .ch1 and .call/.call1 files

error_msg=[];
pindx=strfind(fname,'.');
suffix=fname(pindx:end);

if strcmp(suffix(1:3),'.ch')==1
    file_type='bin';
    scale=4;
elseif strcmp(suffix,'.call')==1 || strcmp(suffix,'.call1')==1
    file_type='bin';
    scale=2;
end;

if strcmp(file_type,'bin')==1
    fid=fopen(fname);
    status=fseek(fid,(offset*scale),'bof'); 
    error_msg=ferror(fid);
    a=fread(fid,n,precision);
    fclose(fid);    
end;

