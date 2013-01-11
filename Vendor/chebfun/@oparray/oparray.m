classdef oparray
% OPARRAY   Array of function handles.
% The OPARRAY class is a support class for chebop that implements arrays of
% function handles, together with matrix-style transformations and
% combinations of them. It helps chebops maintain "infinite-dimensional"
% implementations of themselves. 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.


    properties
        % This is the only field. It is always a cell, even in the 1x1 case.
        op = {};
    end
    
    methods
        
        function A = oparray(defn)
            if nargin == 0
                % Return an empty oparray
            elseif isa(defn,'oparray')
                A = defn;
            elseif nargin == 1
                if iscell(defn)
                    A.op = defn;
                else
                    A.op = { defn };
                end
            else
                error('OPARRAY:oparray:fail','Oparray failed.')
            end
        end
        
    end

end