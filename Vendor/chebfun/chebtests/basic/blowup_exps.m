function pass = blowup_exps
% Build a series of chebfuns with different non-integer exponents and check
% if these are recovered correctly.
%
% Mark Richardson

pass = [];
for j = 0:0.75:5

    f = chebfun(@(x) sin(100*x)./((1+x).^j.*(2-x).^(j+1)),[-1 2],'blowup',2);
    if ~all(f.exps == [-j -j-1])
        pass = [pass 0];
    else
	pass = [pass 1];
    end

end

