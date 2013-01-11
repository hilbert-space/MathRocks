function pass = difforder
% Check to see whether difforder of systems are computed correctly.
%
% Nick Hale, Nov 2010.

% Construct the basis linops
d = domain(-1,1);
D = diff(d); I = eye(d); Z = zeros(d);

% Make a system
A = [ D I ; Z D ];

% Check mtimes
B = A*A;
C = [ D^2 2*D ; Z D^2 ];
pass(1) = ~(any(any(B.difforder-C.difforder)));

% Check mpower
B = A^2;
pass(2) = ~(any(any(B.difforder-C.difforder)));

B = A^3;
C = C*A;
pass(3) = ~(any(any(B.difforder-C.difforder)));

% Check plus
B = B+1;
pass(4) = ~(any(any(B.difforder-C.difforder)));

% Check constant mtime
B = pi*B;
pass(5) = ~(any(any(B.difforder-C.difforder)));

B = 0*B;
pass(6) = ~(any(any(B.difforder)));

% Check blkdiag
B = blkdiag(C,D,C,[I D]);
do = [ 3     2     0     0     0     0     0
       0     3     0     0     0     0     0
       0     0     1     0     0     0     0
       0     0     0     3     2     0     0
       0     0     0     0     3     0     0
       0     0     0     0     0     0     1 ];
pass(7) = ~(any(any(B.difforder-do)));

% Check 3x3
A = [ D I Z ; Z Z D ; D^2 I Z];
E = [ diff(d,2) D D ; diff(d,3) D 0 ; diff(d,3) diff(d,2) D];

% Check mtimes
B = A*A;
pass(8) = ~(any(any(B.difforder-E.difforder)));
C = A^2;
pass(9) = ~(any(any(C.difforder-E.difforder)));

% Check the 3rd power
E = A*[ diff(d,2) D D ; diff(d,3) D 0 ; diff(d,3) diff(d,2) D];
C = A^3;
pass(10) = ~(any(any(C.difforder-E.difforder)));

% Final test
A = [D I Z];
B = D*A;
pass(11) = ~(any(any(B.difforder-[2 1 0])));

