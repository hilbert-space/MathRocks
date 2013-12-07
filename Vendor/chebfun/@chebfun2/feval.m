function v = feval(f,x,y,varargin)
%FEVAL  evaluate a chebfun2 at one or more points.
%
%  FEVAL(F,X,Y) evaluates the chebfun2 F and the point(s) in (X,Y), where
%    X and Y are doubles.
% 
%  FEVAL(F,X) evaluates the chebfun2 F along the complex valued chebfun X 
%    and returns  g(t) = F(real(X(t)),imag(X(t)))
% 
%  FEVAL(F,X,Y) returns g(t) = F(X(t),Y(t)), where X and Y are real valued
%  chebfuns with the same domain. 
%
% See also SUBSREF.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

fun = f.fun2;

% Check for empty function 
if ( isempty(f) ) 
    v = []; return; 
end

% check for zero function 
if ( all( f.fun2.U == 0 ))
    if ( all(size(x) == size(y) ) )
        v = zeros( size(x) );
        return;
    else
        error('CHEBFUN2:FEVAL','Evaluation arrays must be the same size.');
    end
end

if ( isa(x,'chebfun') )
    if ( ~isreal(x) ) % complex valued chebfun.
        % Extract chebfun along the path
        v = chebfun(@(t) fun.feval(real(x(t)),imag(x(t))),x.ends);  % F(real(X(t)),imag(X(t)))
    elseif ( isa(y,'chebfun') )
        if ( isreal(y) ) % both x and y are real valued.
            % check domains of x and y match
            if( x.ends == y.ends )
                v = chebfun(@(t) fun.feval(x(t),y(t)),x.ends);
            else
                error('CHEBFUN2:feval:path','Chebfun path has domain inconsistency');
            end
        else
            error('CHEBFUN2:feval:complex','Cannot evaluate along complex-valued chebfun');
        end
    end
elseif ( isnumeric(x) && isnumeric(y) )
    % evaluate at a set of coordinates in (X,Y) 
    fun2 = get(f,'fun2');
    v = feval(fun2,x,y,varargin{:});
else
    error('CHEBFUN2:feval:input','Unable to evaluate at nonnumeric values.');
end

end