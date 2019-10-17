function [OStype, OSversion] = getOSinfo

% function [OStype, OSversion] = getOSinfo
%
%    Kluge to determine what operating system is running, for customizing MatLab's behavior 
%    (a.k.a. correcting its inconsistencies) across platforms.  Determines the OS by matching 
%    OS-specific path characters ( '/' for UNIX, '\' for Windows, ':' for Macintosh).  Returns
%    two text strings indicating the general type of operating system and (where possible)
%    the specific version.
%
%    There must be more elegant ways to determine this....

%    Written 2/99 by pj.

pathSeparator = filesep;

if pathSeparator == '\'
   OStype = 'windows';
   [exitStatus, OSversion] = dos('ver');
elseif pathSeparator == '/'
   OStype = 'unix';
   [exitStatus, unamePath] = unix('which uname');
   if ~isempty(unamePath)
      [exitStatus, OSversion] = unix('uname -rs');
   else  % 'uname' command is not on the user's path
      OSversion = 'OS version unknown';
   end
elseif pathSeparator == ':'
   OStype = 'mac';
   OSversion = 'OS version unknown';
end

   
return   
