function pass = booltest
% Test boolean operators on chebfuns and quasimatrices.

% init some data to work with
x = chebfun('x',[0,1]);
A = [ x.^1 , x.^2 , x.^3 , x.^4 ];
B = 1 - A;
half = chebfun(0.5,[0,1]);

% test "==" (eq).
[res,xi] = max( A == 0.5 );
pass(1) = ( sum(res) == 4 ) && (norm( xi.^[1:4] - 0.5 , inf ) < 10*eps);
[res,xi] = max( A == B );
pass(2) = ( sum(res) == 4 ) && (norm( xi.^[1:4] - 0.5 , inf ) < 10*eps);
[res,xi] = max( x == half );
pass(3) = ( res == 1 ) && ( xi == 0.5 );

% test "~=" (ne).
[res,xi] = min( A ~= 0.5 );
pass(4) = ( sum(res) == 0 ) && (norm( xi.^[1:4] - 0.5 , inf ) < 10*eps);
[res,xi] = min( A ~= B );
pass(5) = ( sum(res) == 0 ) && (norm( xi.^[1:4] - 0.5 , inf ) < 10*eps);
[res,xi] = min( x ~= half );
pass(6) = ( res == 0 ) && ( xi == 0.5 );

% test ">" (gt)
res = sum( A > 0.5 );
pass(7) = norm( res - (1-0.5.^(1./(1:4))) , inf ) < 10*eps;
res = sum( A > B );
pass(8) = norm( res - (1-0.5.^(1./(1:4))) , inf ) < 10*eps;
res = x > half;
pass(9) = (abs(sum(res)-0.5) < 10*eps) && (res(0.5) == 0);

% test "<" (lt)
res = sum( A < 0.5 );
pass(10) = norm( res - 0.5.^(1./(1:4)) , inf ) < 10*eps;
res = sum( A < B );
pass(11) = norm( res - 0.5.^(1./(1:4)) , inf ) < 10*eps;
res = x < half;
pass(12) = (abs(sum(res)-0.5) < 10*eps) && (res(0.5) == 0);

% test ">=" (ge)
res = sum( A >= 0.5 );
pass(13) = norm( res - (1-0.5.^(1./(1:4))) , inf ) < 10*eps;
res = sum( A >= B );
pass(14) = norm( res - (1-0.5.^(1./(1:4))) , inf ) < 10*eps;
res = x >= half;
pass(15) = (abs(sum(res)-0.5) < 10*eps) && (res(0.5) == 1);

% test "<=" (le)
res = sum( A <= 0.5 );
pass(16) = norm( res - 0.5.^(1./(1:4)) , inf ) < 10*eps;
res = sum( A <= B );
pass(17) = norm( res - 0.5.^(1./(1:4)) , inf ) < 10*eps;
res = x <= half;
pass(18) = (abs(sum(res)-0.5) < 10*eps) && (res(0.5) == 1);
