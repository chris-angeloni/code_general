function normA = normz1(A)

% this function normalizes input matrix A so that its minimum
% values are zero and its maximum values are 1.

normA = A - min(A(:));
normA = normA ./ max(normA(:));