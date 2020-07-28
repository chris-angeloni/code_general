function l1norm = expNorm(p,x,y,mdl)

l1norm = norm(y - mdl(p,x));