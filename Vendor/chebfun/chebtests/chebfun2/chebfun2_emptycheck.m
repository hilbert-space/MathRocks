function pass = chebfun2_emptycheck
% For empty chebfun2 objects, does each command deal with them
% appropriately?
% Alex Townsend, March 2013. 

% Check things work for empty chebfun2s.
f = chebfun2();
try
    get(f,'fun2');
    f + f;
    2*f;
    f*2;
    f.^2;
    2.^f;
    f.^f;
    sqrt(f);
    sum(f);
    integral2(f);
    % max(f)
    norm(f);
    squeeze(f);
    diff(f);
    cos(f);
    sin(f);
    sinh(f);
    f.^f + f;
    diag(f);
    trace(f);
    mean(f);
    minandmax2(f);
    median(f);
    flipud(f);
    flipdim(f,1);
    pass = 1;
catch
    pass = 0;
end
end
