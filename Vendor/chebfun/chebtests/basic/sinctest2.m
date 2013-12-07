function pass = sinctest
% Test sinc function and related functions
% Kuan Xu, October 2012

% Construct sinc function by definition.

dom = [-10 10];
fexact = chebfun(@(x) sin(x)./(x),dom);

% Set the tolerance
tol = 100 * chebfunpref('eps') * norm(fexact, inf);

%% 1. Test the Chebfun sinc function
x = chebfun('x', dom);
f = sinc(x);
pass(1) = norm(f - fexact, inf) < tol;

%% Test more sinc-like or sinc-related functions.
%% 2. Test sinc^2(x)
fexact = chebfun(@(x) sin(x).^2./(x).^2,dom);
f = sinc(x).^2;
pass(2) = norm(f - fexact, inf) < tol;

%% 3. Test sinc(x^2)
fexact = chebfun(@(x) sin(x.^2)./(x.^2),dom);
f = sinc(x.^2);
pass(3) = norm(f - fexact, inf) < tol;

%% 4. Test on shift and frequency
aa = [31.1215   16.5649   26.2971   68.9215   45.0542
      52.8533   60.1982   65.4079   74.8152    8.3821];
T = size(aa,2);
for i = 1:T
    a = aa(:,i);
    fexact = chebfun(@(x) sin(a(1)*(x-a(2)))./(a(1)*(x-a(2))), dom);
    f = sinc(a(1)*(x-a(2)));
    pass(3+i) = norm(f - fexact, inf) < norm(a,inf)*tol;
end

%% 5. Test on differentiation of sinc(x)
f = sinc(x);
fp = diff(f);
fpp = diff(f,2);

fexact = chebfun(@(x) sin(x)./x, dom);
fpexact = diff(fexact);
fppexact = diff(fexact,2);

pass(T+4) = norm(fp-fpexact, inf) < tol;
pass(T+5) = norm(fpp-fppexact, inf) < 10*tol;

%% 6. Test on integration of sinc(x)
f = sinc(x);
fi = sum(f);

fexact = chebfun(@(x) sin(x)./x, dom);
fiexact = sum(fexact);

pass(T+6) = norm(fiexact - fi, inf) < tol;

%% Test on other relevant integrals
%% 7. Integration of sinc(x)^2
f = sinc(x).^2;
fi = sum(f);
fexact = chebfun(@(x) sin(x).^2./(x.^2),dom);
fiexact = sum(fexact);

pass(T+7) = norm(fiexact - fi, inf) < tol;

%% 8. Integration of sinc(x^2)
f = sinc(x.^2);
fi = sum(f);
fexact = chebfun(@(x) sin(x.^2)./(x.^2),dom);
fiexact = sum(fexact);

pass(T+8) = norm(fiexact - fi, inf) < tol;
