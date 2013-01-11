function pass = minsamples_adapt
% Test for minsaples in adaptive mode on an infinite domain (unbounded maps)
% Rodrigo Platte, 2009.

shift = 1e3;
f = @(x) exp(-1*((x-shift).^2));

mpref = mappref;
mappref('parinf',[1,0])
mappref('adaptinf',true)
f = chebfun(f,[-inf,inf],'minsamples',1024+1);
mappref('parinf',mpref.parinf); mappref('adaptinf',mpref.adaptinf);

pass = abs(sum(f)-sqrt(pi)) < chebfunpref('eps')*1e5;
