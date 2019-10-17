function [J,ncol] = sfdnls(xcurr,valx,Jstr,group,alpha,DiffMinChange, ...
                            DiffMaxChange,fun,XDATA,YDATA,varargin)
%SFDNLS    Sparse Jacobian via finite differences
%
% J = sfdnls(xcurr,valx,Jstr,group,[],DiffMinChange,DiffMaxChange,fun, ...
% YDATA,varargin) returns the sparse finite difference approximation J of 
% the Jacobian matrix of the function 'fun' at the current point xcurr. The 
% vector group indicates how to use sparse finite differencing: group(i) = j 
% means that column i belongs to group (or color) j. Each group (or color) 
% corresponds to a function difference. The input varargin contains the extra 
% parameters (possibly) needed by function 'fun'. 
% DiffMinChange and DiffMaxChange indicate, respectively, the minimum and 
% maximum change in variables during the finite difference calculation.
%
% A non-empty input alpha overrides the default finite differencing stepsize.
%
% [J,ncol] = sfdnls(...) returns the number of function evaluations used
% in ncol.

%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/11 22:46:43 $

%
if nargin < 8
   error('optim:sfdnls:RequiresEightArguments','SFDNLS requires at least eight arguments.')
elseif nargin < 10
   YDATA = [];
elseif nargin < 9
   XDATA = [];
end

scalealpha = false;
x = xcurr(:); % make it a vector
[m,n] = size(Jstr); 
ncol = max(group); 
if isempty(alpha)
    scalealpha = true;
    alpha = repmat(sqrt(eps),ncol,1);
end
J = spones(Jstr);

% If lsqcurvefit, then add XDATA to objective's input list.
% xargin{1} will be updated right before each evaluation
if ~isempty(XDATA)
    xargin = {xcurr,XDATA};
else
    xargin = {xcurr};
end

if ncol < n
   for k = 1:ncol
      d = (group == k);
      if scalealpha
         xnrm = norm(x(d));
         xnrm = max(xnrm,1);
         alpha(k) = alpha(k)*xnrm;
      end
      
      % Ensure magnitude of step-size lies within interval 
      % [DiffMinChange, DiffMaxChange]
      alpha(k) = sign(alpha(k))*min(max(abs(alpha(k)),DiffMinChange), ...
                                  DiffMaxChange);      
      y = x + alpha(k)*d;
      
      xcurr(:) = y;  % reshape for userfunction
      xargin{1} = xcurr; % update x in list of input arguments to objective
      v = feval(fun,xargin{:},varargin{:});
      if ~isempty(YDATA)
         v = v - YDATA;
      end
      v = v(:);
      
      w = (v-valx)/alpha(k);
      cols = find(d); 
      
      A = sparse(m,n);
      A(:,cols) = J(:,cols);
      J(:,cols) = J(:,cols) - A(:,cols);
      [i,j,val] = find(A);
      [p,ind] = sort(i);
      val(ind) = w(p);
      A = sparse(i,j,full(val),m,n);
      J = J + A;
   end
else % ncol ==n
   J = full(J);
   for k = 1:n
      if scalealpha
         xnrm = norm(x(k));
         xnrm = max(xnrm,1);
         alpha(k) = alpha(k)*xnrm;
      end
      
      % Ensure magnitude of step-size lies within interval 
      % [DiffMinChange, DiffMaxChange]
      alpha(k) = sign(alpha(k))*min(max(abs(alpha(k)),DiffMinChange), ...
                                  DiffMaxChange);      
      y = x;
      y(k) = y(k) + alpha(k);

      xcurr(:) = y;  % reshape for userfunction
      xargin{1} = xcurr; % update x in list of input arguments to objective
      v = feval(fun,xargin{:},varargin{:});
      if ~isempty(YDATA)
         v = v - YDATA;
      end
      v = v(:);
      J(:,k) = (v-valx)/alpha(k);
   end
end


