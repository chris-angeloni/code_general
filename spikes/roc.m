function [tp, fp] = roc(t, y)
%
% ROC - generate a receiver operating characteristic curve
%
%    [TP,FP] = ROC(T,Y) gives the true-positive rate (TP) and false positive
%    rate (FP), where Y is a column vector giving the score assigned to each
%    pattern and T indicates the true class (a value above zero represents
%    the positive class and anything else represents the negative class).  To
%    plot the ROC curve,
%
%       PLOT(FP,TP);
%       XLABEL('FALSE POSITIVE RATE');
%       YLABEL('TRUE POSITIVE RATE');
%       TITLE('RECEIVER OPERATING CHARACTERISTIC (ROC)');
%
%    See [1] for further information.
%
%    [1] Fawcett, T., "ROC graphs : Notes and practical
%        considerations for researchers", Technical report, HP
%        Laboratories, MS 1143, 1501 Page Mill Road, Palo Alto
%        CA 94304, USA, April 2004.
%
%    See also : ROCCH, AUROC

%
% File        : roc.m
%
% Date        : Wednesday 10th November 2004 
%
% Author      : Dr Gavin C. Cawley
%
% Description : Generate an ROC curve for a two-class classifier.
%
% References  : [1] Fawcett, T., "ROC graphs : Notes and practical
%                   considerations for researchers", Technical report, HP
%                   Laboratories, MS 1143, 1501 Page Mill Road, Palo Alto
%                   CA 94304, USA, April 2004.
%
% History     : 10/11/2004 - v1.00
%
% To do       : Add an option to specify the maximum number of points to
%               consider to minimise memory usage.
%
% Copyright   : (c) G. C. Cawley, November 2004.
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%

% process targets

t = t > 0; %makes t a vector with 1's for values >0, 0's for other values.

% CFA edit... need to rearrange data so it is not in order, b/c of how
% cumsum operates
ind = randperm(length(t));
t = t(ind);
y = y(ind);


% sort by classifier output
[y,idx] = sort(y);
t       = t(idx);

% compute true positive and false positive rates
fp = cumsum(t)/sum(t);
tp = cumsum(1-t)/sum(1-t);

% add trivial end-points
tp = [0 ; tp ; 1];
fp = [0 ; fp ; 1];

% bye bye...

