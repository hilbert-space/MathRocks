function pass = diff_matrices
% Test the construction of differentiation matrices 
% that involve maps and breaks.
% 
% Nick Hale, Aug 2010

%% Differentiation, map / no breaks
d = domain([-sqrt(2),0]);
m = maps('kte',.9,d);
D = diff(d);
f = chebfun(@sin,'map',m,d);

N = length(f);
DN = feval(D,N.',[],m,d.endsandbreaks);

fpvals = DN*f.vals;
fp = diff(f);

err = norm(fpvals - fp(f.pts),inf);
pass(1) = err < 1e4*chebfunpref('eps');

% plot(fp); hold on
% plot(f.pts,fpvals,'or'); hold off

%% Differentiation, map and breaks

d = domain([-sqrt(2),0,1.5]);
m = maps('kte',.9,d(1:2));
m(2) = maps('kte',.9,d(2:3));
D = diff(d);
f = chebfun(@sin,'map',{'kte',.9},d);

N = zeros(f.nfuns,1);
for k = 1:f.nfuns
    N(k) = length(f.funs(k));
end
DN = feval(D,N.',[],m,d.endsandbreaks);

fpvals = DN*f.vals;
fp = diff(f);

err = norm(fpvals - fp(f.pts));
pass(2) = err < 1e4*chebfunpref('eps');

% figure
% plot(fp); hold on
% plot(f.pts,fpvals,'or'); hold off

%% Integration, map / no breaks

d = domain([-sqrt(2) 0]);
m = maps('kte',.9,d);
C = cumsum(d);
f = chebfun(@sin,'map',m,d);

N = length(f);
CN = feval(C,N.',[],m,d.endsandbreaks);

Fvals = CN*f.vals;
F = cumsum(f);

err = norm(Fvals - F(f.pts),inf);
pass(3) = err < 1e4*chebfunpref('eps');

% figure
% plot(fp); hold on
% plot(f.pts,fpvals,'or'); hold off

%% Integration, no map / breaks

d = domain([-2,0,1]);
C = cumsum(d);
f = chebfun(@sin,d);

N = zeros(f.nfuns,1);
for k = 1:f.nfuns
    N(k) = length(f.funs(k));
end
CN = feval(C,N.',[],[],d.endsandbreaks);

Fvals = CN*f.vals;
F = cumsum(f);

err = norm(Fvals - F(f.pts));
pass(4) = err < 1e4*chebfunpref('eps');

% figure
% plot(fp); hold on
% plot(f.pts,fpvals,'or'); hold off

%% Integration, map and breaks

d = domain([-sqrt(2),0,2.5,5]);
m = maps('kte',.9,d(1:2));
m(2) = maps('kte',.9,d(2:3));
m(3) = maps('kte',.9,d(3:4));
C = cumsum(d);
f = chebfun(@sin,'map',{'kte',.9},d);

N = zeros(f.nfuns,1);
for k = 1:f.nfuns
    N(k) = length(f.funs(k));
end
CN = feval(C,N.',[],m,d.endsandbreaks);

Fvals = CN*f.vals;
F = cumsum(f);

err = norm(Fvals - F(f.pts));
pass(5) = err < 1e4*chebfunpref('eps');

% figure
% plot(fp); hold on
% plot(f.pts,fpvals,'or'); hold off

%% Sum, map and breaks

d = domain([-sqrt(2),0,2.5,5]);
m = maps('kte',.9,d(1:2));
m(2) = maps('kte',.9,d(2:3));
m(3) = maps('kte',.9,d(3:4));
C = sum(d);
f = chebfun(@sin,'map',{'kte',.9},d);

N = zeros(f.nfuns,1);
for k = 1:f.nfuns
    N(k) = length(f.funs(k));
end
CN = feval(C,N.',[],m,d.endsandbreaks);

s = CN*f.vals;
S = sum(f);

err = norm(s-S);
pass(5) = err < 1e4*chebfunpref('eps');

% figure
% plot(fp); hold on
% plot(f.pts,fpvals,'or'); hold off

