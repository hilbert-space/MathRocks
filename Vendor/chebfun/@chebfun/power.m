function Fout = power(F1,F2)
% .^   Chebfun power.
%
% F.^G returns a chebfun F to the scalar power G, a scalar F to the
% chebfun power G, or a chebfun F to the chebfun power G.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if isa(F1,'chebfun') && isa(F2,'chebfun')
    % chebfun.^chebfun
    if size(F1)~=size(F2)
        error('CHEBFUN:power:quasi','Chebfun quasi-matrix dimensions must agree.')
    end
    Fout = F1;
    for k = 1:numel(F1)
        Fout(k) = powercol(F1(k),F2(k));
    end
elseif isa(F1,'chebfun')
    % chebfun.^double
    Fout = F1;
    if F2 == 0
        dom = F1.ends([1 end]);
        for k = 1:numel(F1)
            Fout(k) = chebfun(1,dom);
            Fout(k).jacobian = anon('der = zeros(dom); nonConst = 0;',{'dom'},{dom},1);
            Fout(k).ID = newIDnum();
        end
    else
        for k = 1:numel(F1)
            Fout(k) = powercol(F1(k),F2);
            Fout(k).jacobian = anon('diag1 = F2*diag(F1.^(F2-1)); der2 = diff(F1,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F1', 'F2'},{F1(k) F2},1,'power');
            Fout(k).ID = newIDnum();
        end
    end
else
    % double.^chebfun
    Fout = F2;
    for k = 1:numel(F2)
        Fout(k) = powercol(F1,F2(k));
        Fout(k).jacobian = anon('diag1 = diag(F1.^F2.*log(F1)); der2 = diff(F2,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero;',{'F1', 'F2'},{F1 F2(k)},1,'power');
        Fout(k).ID = newIDnum();
    end
end

% -----------------------------------------------------
function fout = powercol(f,b)

if (isa(f,'chebfun') && isa(b,'chebfun'))
    if f.ends(1)~=b.ends(1) ||  f.ends(end)~=b.ends(end)
        error('CHEBFUN:powercol:interval','F and G must be defined in the same interval')
    end
    fout = comp(f,@power,b);
    fout.jacobian = anon('[Jfu constJfu] = diff(f,u,''linop''); [Jbu constJbu] = diff(b,u,''linop''); der = diag(b.*f.^(b-1))*Jfu + diag(f.^b.*log(f))*Jbu; nonConst = (~Jfu.iszero | ~Jbu.iszero) | (constJbu | constJfu);',{'f' 'b'},{f b},1,'power');
    fout.ID = newIDnum();
else
    if isa(f,'chebfun')
        if b == 0
            % Trivial case
            fout = chebfun(1,[f.ends(1) f.ends(end)]);
        elseif b == 1
            % Identity
            fout = f;
        elseif b == .5
            % Sqrt
            fout = sqrt(f);
        elseif b == 2
            % Square
            fout = f.*f;
        else
            % General case
            % Integer and positive powers (exps not needed)
            if round(b) == b && b>0 && ~any(any(get(f,'exps')<0))
                fout = comp(f,@(x) power(x,b));
            else % Introduce exps
                if round(b) ~= b || b < 0
                    f = add_breaks_at_roots(f);
                end
                fout = f;
                % Loop through funs
                for k = 1:f.nfuns
                    fk = extract_roots(f.funs(k));
                    exps = fk.exps;
                    fk.exps = [0 0];
                    foutk = compfun(fk, @(x) power(x,b));
                    foutk.exps = b*exps;
                    foutk = replace_roots(foutk);
                    fout.funs(k) = foutk;
                end
                fout.imps = power(fout.imps,b);
            end
        end
        
        fout.trans = f.trans;
        
    else
        fout = comp(b, @(x) power(f,x));
        %fout = chebfun(@(x) f.^feval(b,x), b.ends);
        %fout.trans = b.trans;
    end
    
end