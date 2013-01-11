classdef (InferiorClasses = {?double}) domain
% DOMAIN  Domain object constructor. 
%
% D = DOMAIN(A,B) or DOMAIN([A,B]) creates a domain object for the real
% interval [A,B]. If B<A an empty interval is returned.
%
% D = DOMAIN(V) for vector V of length at least 2 creates a domain for
% the interval [V(1),V(end)] with breakpoints at V(2:end-1). V is assumed
% to be correctly sorted with unique entries.
%
% The domain class is primarily used as a tool for creating linops, but it
% also has some other uses, including the chebfun overloads of the MATLAB
% ode routines (ode113, ode15s, and ode45) and interpolation routines
% (interp1, polyfit, and ratinterp).

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

    properties
        ends = []; % End and break points (should be at least a two-vector)
    end

    methods
        function d = domain(varargin)

            % Parse the inputs
            if nargin == 0
                % Return an empty domain
                return
            elseif isa(varargin{1},'domain')
                % Return input domain
                d = varargin{1};
                return
            end
            
            % Concatenate multi-inputs
            v = cat(2,varargin{:});     
            
            % Deal with empty intervals
            if (length(v) > 1) && (v(end) < v(1))
                v = [];
            end
            
            % For scalar input, make a two-vector
            if length(v) == 1, v = [v v]; end

            % Add the ends to the output domain
            d.ends = v;
            
        end

    end

end