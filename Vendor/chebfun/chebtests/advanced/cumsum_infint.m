function pass = cumsum_infint
% Check CUMSUM on for functions which diverge over an infnite
% interval, but not over a finite interval. We test relatively 
% simple cases where he exponents are positive integers.

pass = zeros(1,4);

for n = 1:2
    % Unbounded function on [-inf inf]
    myfun = @(x) x.^n;

    % Construct on an unbounded interval
    f = chebfun(@(x) myfun(x),[-inf inf],'exps',[n n]);
    F = cumsum(f);

    % Also on a finite interval
    g = chebfun(@(x) myfun(x),[-10 10]);
    G = cumsum(g);

    % Look at the error
    xx = linspace(-10,10);
%     plot(xx,F(xx)-F(0),'b',xx,G(xx)-G(0),'--r')
    err = norm((F(xx)-F(0))-(G(xx)-G(0)),inf);

    pass(n) = err<1e5*chebfunpref('eps');

end

for n = 1:2
    % Unbounded function on [0 inf]
    myfun = @(x) x.^n;

    % Construct on an unbounded interval
    f = chebfun(@(x) myfun(x),[0 inf],'exps',[0 n]);
    F = cumsum(f);

    % Also on a finite interval
    g = chebfun(@(x) myfun(x),[0 10]);
    G = cumsum(g);

    % Look at the error
    xx = linspace(0,10);
    % plot(xx,F(xx)-F(0),'b',xx,G(xx)-G(0),'--r')
    err = norm((F(xx)-F(0))-(G(xx)-G(0)),inf);

    pass(n+2) = err<1e5*chebfunpref('eps');
end
