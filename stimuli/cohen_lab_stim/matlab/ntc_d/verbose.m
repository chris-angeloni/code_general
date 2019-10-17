function vLevel = verbose(new_vLevel)
% function vLevel = verbose(new_vLevel)
%
%  sets global variable VERBOSE 
%
%  Global variable VERBOSE is used by many of my functions to determine 
%    level of verbosity in running commentary.
%  verbose with no input and no output arguments toggles VERBOSE (the verbosity 
%    level) between 0 and 1.
%  verbose(new_vLevel) sets VERBOSE to new_vLevel.  
%  verbose returns VERBOSE.

global VERBOSE

if isempty(VERBOSE)
    VERBOSE = 0;
  end

if nargin ~= 0,
    VERBOSE = new_vLevel;
  elseif nargout == 0,
    VERBOSE = ~VERBOSE;
  end

if nargout == 1
    vLevel = VERBOSE;
  end

return
