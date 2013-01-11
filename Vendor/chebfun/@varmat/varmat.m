classdef varmat
% VARMAT  Variable-sized matrix object constructor.
% V = VARMAT(FUN) creates a variable-sized matrix object based on the
% function FUN. FUN should be a function of one argument N and return a
% a matrix of size NxN.
%
% VARMATs support arithmetic and referencing (slicing). It is mostly
% intended as a support class for CHEBOP and therefore is lightly
% documented. It may become inaccessible in future chebop releases.
%
% See also CHEBOP.

% Copyright 2011 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.
    
    properties
        defn = [];
        rowsel = [];
        colsel = [];
    end
    
    methods
        
        function A = varmat(defn)
            if nargin == 0
                % Return an empty varmat
            elseif isa(defn,'varmat')
                A = defn;
            elseif isa(defn,'function_handle')
                A.defn = defn;
            else
                error('VARMAT:varmat:fail','Varmat failed.')
            end
        end
        
    end
    
end