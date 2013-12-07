classdef (InferiorClasses = {?double}) linop
    % LINOP  Linear chebop operator constructor.
    % LINOP(F), where F is a function of one argument N that returns an NxN
    % matrix, returns a linop object whose NxN finite realization is defined
    % by F.
    %
    % LINOP(F,L), where L is a function that can be applied to a chebfun,
    % defines an infinite-dimensional representation of the linop as well. L
    % may be empty.
    %
    % LINOP(F,L,D) specifies the domain D on which chebfuns are to be defined
    % for this operator. If omitted, it defaults to [-1,1].
    %
    % LINOP(F,L,D,M) also defines a nonzero differential order for the
    % operator.
    %
    % Normally one does not call LINOP directly. Instead, use one of the
    % five first functions in the see-also line, or from linearising a
    % chebop.
    %
    % See also domain/eye, domain/diff, domain/cumsum, chebfun/diag,
    % domain/zeros, chebop/chebop.
    
    % Copyright 2011 by The University of Oxford and The Chebfun Developers.
    % See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.
    
    %Default properties.
    properties
        domain = [];            % Domain of the operator
        varmat = [];            % Matrix form of the operator
        oparray = oparray;      % inf-dim representation
        opshow = [];            % Pretty-print string (if available)
        difforder = 0;          % Differential order
        iszero = 0;             % Operator == 0
        isdiag = 0;             % Diagonal (multiplication) operator
        lbc = struct([]);       % Left BCs
        lbcshow = [];           % Pretty-print string (if available)
        rbc = struct([]);       % Right BCs
        rbcshow = [];           % Pretty-print string (if available)
        bc = struct([]);        % Other/interior/mixed BCs
        bcshow = [];            % Pretty-print string (if available)
        numbc = 0;              % Total number of BCs
        scale = 0;              % Solve solution relative to this scale
        jumpinfo = [];          % Locations of enforced jumps
        blocksize = [0 0];      % For block linops
        ID = [];                % ID number (for caching)
    end
    
    methods
        function A = linop(varargin)
            
            % Update the ID (for caching of the matrix form and LU factors)
            A.ID = newIDnum();
            
            % Deal with the trivial cases
            if nargin == 0
                % Do nothing
                return
            elseif nargin == 1 && isa(varargin{1},'linop')
                % Copy the linop input
                A = varargin{1};
                return
            end
                
            % First argument defines the matrix part.
            if isa(varargin{1},'function_handle')
                A.varmat = varmat( varargin{1} );  %#ok<CPROP,PROP>
            elseif isa(varargin{1},'varmat')
                A.varmat = varargin{1};
            end

            % Second argument defines the operator.
            if nargin >= 2
                A.oparray = oparray(varargin{2});  %#ok<CPROP,PROP>
            end

            % Third argument supplies the function domain.
            if nargin >= 3
                A.domain = domain( [varargin{3}] ); %#ok<CPROP,PROP>
            end

            % 4th argument is differential order
            if nargin >= 4
                A.difforder = varargin{4};
            end

            % Constructor only supports scalar equations.
            A.blocksize = [1 1];
        end
    end
    
end