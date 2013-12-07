function Fout = abs(F)
% ABS   Absolute value of a chebfun.
% ABS(F) is the absolute value of the chebfun F.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    Fout = F;
    for k = 1:numel(F)
        Fout(k) = abscol(F(k));
        Fout(k).jacobian = anon('diag1 = diag(sign(F)); der2 = diff(Fout,u,''linop''); der = diag1*der2; nonConst = ~der2.iszero; if(any(nonConst)), warning(''chebfun:noADsupport'',''Chebops and AD do not support the abs nor sign method in the unknown function(s)/the functions being differentiated with respect to.''),warning(''off'',''chebfun:noADsupport''),end',{'Fout','F'},{Fout(k),F(k)},1,'abs');
        Fout(k).ID = newIDnum;
    end

end % abs()

function Fout = abscol(F)

    if isempty(F)                % Empty case

        Fout = F;

    elseif isreal(F)             % Real case

        r = roots(F,'nozerofun');% Abs is singular at roots 
        
        % Avoid adding new breaks where not needed
        if ~isempty(r)           
            tol = 100*chebfunpref('eps').*max(min(diff(F.ends)),1);
            % Remove if sufficiently close to an existing break points
            [rem, ignored] = find(abs(bsxfun(@minus,r,F.ends))<tol);
            r(rem) = [];
        end
        if ~isempty(r) 
            % Remove if no sign change over small perturbation on either
            % side of the break
            
            % NH removed this AUg 2013 as it breaks when f is very small.
            % We are better off introducing unneccessary breaks than missing
            % necessary ones!
            
            % Choose a perturbation that involves:
            %  * The vertical scale of F
            %  * The size of the values in F
            %  * The distance between roots
            % [TODO]: This should be more systematic.
%             r = unique(r);
%             mdr = min(diff(r));
%             if isempty(mdr), mdr = 1; end
%             pert = F.scl.*min(sqrt(eps), eps+max(abs(get(F, 'vals'))))/eps*tol*mdr
%             % Evaluate F on either side of proposed roots:
%             Fbks = feval(F, repmat(r,1,2) + repmat([-1 1]*pert, length(r), 1))
%             % Check for sign changes:
%             r(logical(sum(sign(Fbks), 2))) = [];
        end
        
        % Deal with exponents and nontrivial maps separately
        maps = get(F,'map');
        exps = get(F,'exps');
        if any(exps(:)) || ~all(strcmp('linear',{maps.name}))
            Fout = abscol_nontrivial(F,r);
            return
        end
        
        % Linear maps can be treated much more efficiently!
        
        % Get the ends with the new breakpoints
        ends = union( F.ends , r );
        ends = ends(:).';
        m = length(ends)-1;

        % Get the sizes of the funs in the intervals of F
        sizes = zeros( m , 1 );
        inds = zeros( m , 1 );
        for j=1:m
            i = find( F.ends > (ends(j)+ends(j+1))/2 , 1 ) - 1;
            if isempty(i)
                if isinf(ends(j))
                    ind(j) = 1;
                elseif isinf(ends(j+1))
                    ind(j) = F.nfuns;
                end
            else
                ind(j) = i;
            end
            sizes(j) = F.funs( ind(j) ).n;
        end

        % Init the new interval data
        f = {};

        % For each interval...
        for k=1:m

            % Is this interval already an interval of F?
            ia = find( F.ends == ends(k) , 1 );
            ib = find( F.ends == ends(k+1) , 1 );
            if ~isempty(ia) && ~isempty(ib)

                f{end+1} = { abs( F.funs(ia).vals ) , ends(k:k+1) };

            % Otherwise, this is a sub-interval and we need to re-sample.
            else

                % Get the function values in the interval.
                f{end+1} = { abs( feval( F.funs(ind(k)) , chebpts( sizes(k) , ends(k:k+1) ) ) ) , ends(k:k+1) };

            end

        end % loop over each interval

        % Assemble the result
        Fout = F;
        Fout.nfuns = m;
        Fout.ends = ends;
        % if there are delta functions
        if(size(F.imps,1)>=2) 
            % overlap to get the values of F
            % at all the ends
            [Fout F] = overlap(chebfun(0,ends),F);
            % copy the impulses
            Fout.imps = abs(F.imps);
        else
            Fout.imps = abs(feval(F,ends));
        end
        Fout.funs = simplify(fun(f));

    elseif isreal(1i*F)          % Imaginary case

        Fout = abscol(1i*F);

    else                         % Complex case

        Fout = add_breaks_at_roots(F);
        Fout = sqrt(conj(Fout).*Fout);

    end
    
    % take the absolute value of all impulses
    Fout.imps = abs(Fout.imps);

end

function Fout = abscol_nontrivial(F,r)

    % Add the new breaks
    Fout = add_breaks_at_roots(F,[],r);
    % Loop through funs
    for k = 1:Fout.nfuns
        vals = Fout.funs(k).vals;
        % Fun will be entirely negative or entirely positive (as no breaks)
        % We first check a point in the domain to determine if negative
        nv = numel(vals);
        if nv > 2
            neg = vals(round(nv/2)) <= 0;
        else
            neg = max(vals) <= 0;
        end
        % If negative, then coefficients are negated
        if neg
            Fout.funs(k).coeffs = -Fout.funs(k).coeffs;
        end
        % We simply take the abs of the values
        Fout.funs(k).vals = abs(Fout.funs(k).vals);
    end
    Fout.imps = abs(Fout.imps);
    
end
