function pass = blowup_scale
% Tests scale invariance for functions with blowups (integer exponents
% at the endpoints).
% Rodrigo Platte Nov 2009

s = 2^20;

a = -1;
b = -2;

% Horizontal 
fh = @(x) 1./(1-x).^b./(1+x).^a;
f = chebfun(fh,'exps',[a b]);
f1 = chebfun(@(x) fh(x/s), [-s s],'exps',[a b]);
pass(1) = all(f.vals == f1.vals);

% Vertical
fh = @(x) sin(x)./(1-x).^b./(1+x).^a;
f = chebfun(fh,'exps',[a b]);
f1 = chebfun(@(x) s*fh(x),'exps',[a b]);
pass(2) = all(f.vals == f1.vals/s);


