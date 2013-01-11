function pass = guide2tests
% Perform various tests from chapter 2 of the Chebfun Guide.
% LNT 25 May 2008
  splitting on

  f = chebfun('log(1+tan(x))',[0 pi/4]);
  I = sum(f); Iexact = pi*log(2)/8;
  err1 = I-Iexact; 
  pass(1) = err1<chebfunpref('eps')*10;

  f = chebfun('sin(sin(x))',[0 1]);
  I = sum(f); Iexact = 0.4306061031206906049;
  err2 = I-Iexact; 
  pass(2) = err2<chebfunpref('eps')*10;

  t = chebfun('t',[0,1]);
  f = 2*exp(-t.^2)/sqrt(pi);
  I = sum(f); Iexact = erf(1);
  err3 = I-Iexact; 
  pass(3) = err3<chebfunpref('eps')*10;

  f = chebfun(@(x) abs(besselj(0,x)),[0 20]);
  I = sum(f); Iexact = 4.4450316030016;
  err4 = I-Iexact; 
  pass(4) = err4<chebfunpref('eps')*1e3;

% Commented out to save time

% x = chebfun('x');
% f = sech(3*sin(10*x));
% g = sin(9*x); h = min(f,g);
% I = sum(h); Iexact = -0.38155644885025;
% err5 = I-Iexact; 
% pass(5) = err5<chebfunpref('eps')*10;

% splitting off
% x = chebfun('x',[0 1]);
% f = sech(10*(x-0.2)).^2 + sech(100*(x-0.4)).^4 + sech(1000*(x-0.6)).^6;
% I = sum(f); Iexact = 0.210802735500549;
% err6 = I-Iexact; pass6 = err6<chebfunpref('eps')*10;

% splitting on
% f = sech(10*(x-0.2)).^2 + sech(100*(x-0.4)).^4 + sech(1000*(x-0.6)).^6;
% I = sum(f);
% err7 = I-Iexact; pass7 = err7<1e2*chebfunpref('eps');
