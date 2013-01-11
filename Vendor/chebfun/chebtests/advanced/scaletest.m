function pass = scale

% Tests for scale invariance. 
% (A Level 1 Chebtest)
% Rodrigo Platte, May 2009.

tol = chebfunpref('eps');

parpref = mappref('parinf');
adaptpref = mappref('adaptinf');

% Semi-infinite case
mappref('adaptinf',false,'parinf',[1 0])
f1 = chebfun(@(x) exp(-x),[1,inf]);
i1 = sum(f1);

pass = [];
for s = 2.^(4:8:32)
    mappref('parinf',[s 0]);
    f2 = chebfun(@(x) exp(-x/s),[s,inf]);
    i2 = sum(f2);
    pass(end+1) = (i2==s*i1) && (length(f1) == length(f2));
end

for s = 2.^(4:8:32)
    mappref('parinf',[s 0]);
    f2 = chebfun(@(x) exp(x/s),[-inf -s]);
    i2 = sum(f2);
    pass(end+1) = (i2==s*i1) && (length(f1) == length(f2));
end

% [-inf,inf] case
mappref('parinf',[1 0]);
f1 = chebfun(@(x) exp(-x.^2),[-inf,inf]);
i1 = sum(f1);

for s = 2.^(4:8:32)
    mappref('parinf',[s 0]);
    f2 = chebfun(@(x) exp(-(x/s).^2),[-inf,inf]);
    i2 = sum(f2);
    pass(end+1) = (i2==s*i1) && (length(f1) == length(f2));
end

% [-inf,inf]-shifted case

for s = 2.^(4:8:12)
    mappref('parinf',[1 s]);
    f2 = chebfun(@(x) exp(-(x-s).^2),[-inf,inf]);
    i2 = sum(f2);
    pass(end+1) = abs(i1-i2)/s<tol*200;
end

mappref('adaptinf',adaptpref,'parinf',parpref)
