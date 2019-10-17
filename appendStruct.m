function A = appendStruct(A, B)
fB = fieldnames(B);
nA = numel(A) + 1;
for ifB = 1:numel(fB)
  field = fB{ifB};   % [EDITED, typo, () -> {}]
  A(nA).(field) = B.(field);
end