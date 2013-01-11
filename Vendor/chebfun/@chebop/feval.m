function Narg = feval(Nin,varargin)
%FEVAL Evaluate the operator of the chebop. 
% FEVAL(A,U1,U2,...,UM) for chebfuns for U1,...,UM applies the chebop A to 
% the functions Uk; i.e., it returns A(X,U1,U2,...,UM), where X is the
% dependent variable on the domain of A.
%
% M = FEVAL(A,N) for integer N and linear chebops A returns the matrix
% associated with A at size N. For nonlinear chebops, an error is returned.
% M = FEVAL(A,INF) returns the functional form of A if it is available.
%
% See also chebop/subsref, linop/feval.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if nargin < 2, 
    error('CHEBFUN:chebop:feval:nargin1',...
        'Incorrect number of input arguments.');
end

if isnumeric(varargin{1})
    if ~isfinite(varargin{1})
        Narg = Nin.opshow{:};
        return
    end
    [L linBC isLin] = linearise(Nin);
    if ~isLin
        error('CHEBOP:feval:expansion',...
            'Matrix expansion is only allowed for linear chebops.')
    end
    L = L & linBC;
    Narg = feval(L,varargin{:});
    return
end

if ~isa(Nin.op,'cell')
    % Linops are easy
    if isa(Nin.op,'linop')
        Narg = feval(Nin.op,varargin{:});
        return
    end
    
    % Count number of input variables
    numberOfInputVariables = nargin(Nin.op);
    % Make a linear chebfun on the domain
    xDom = {chebfun('x',Nin.domain.endsandbreaks)};
    
    if numberOfInputVariables == 1
        % No indepvar. One dep var.
        xDom = {}; % (doesn't appear in .op)
        if numel(varargin) > 1
            % Cannot have more than one depvar.
            error('CHEBFUN:chebop:feval:inv',...
                'Invalid input sequence to chebop/feval.')
        else
            vars = varargin(1);
        end
        
    elseif numberOfInputVariables > 2
        if numel(varargin) == 1
            % Single input (no indepvat)
            if numel(varargin{1}) == numberOfInputVariables
                % No indep var in op.
                xDom = {};
            elseif numel(varargin{1}) ~= numberOfInputVariables - 1
                % Incorrect number of depvars
                error('CHEBFUN:chebop:feval:inv',...
                    'Invalid input sequence to chebop/feval.')
            end
            quasi = varargin{1};
            vars = cell(1,numel(quasi));
            for quasiCounter = 1:numel(quasi)
                vars{quasiCounter} = quasi(:,quasiCounter);
            end
        elseif numel(varargin) == numberOfInputVariables
            % Correct count (simple)
            xDom = varargin(1); vars = varargin(2:end);   
        elseif numel(varargin) == 2 && numel(varargin{2}) == numberOfInputVariables - 1
            % Quasimatrix given. Convert to cell array.
            xDom = varargin(1); quasi = varargin{2};
            vars = cell(1,numel(quasi));
            for quasiCounter = 1:numel(quasi)
                vars{quasiCounter} = quasi(:,quasiCounter);
            end
        else 
            error('CHEBFUN:chebop:feval:inv',...
                'Invalid input sequence to chebop/feval.')
        end
        
    else % 2 inputs
        if numel(varargin) > 2
            error('CHEBFUN:chebop:feval:inv',...
                'Too many input arguments.')
        elseif numel(varargin) == 2
            % No indepvar (given in input)
            xDom = {};
        end
        vars = varargin;
    end
    % Evaluate!
    Narg = feval(Nin.op,xDom{:},vars{:});
    
else
    
    % Need to do a trick if the operator is a cell
    [m,n] = size(Nin.op);
    Narg = [];
    argument = varargin{1};
    for i = 1:length(Nin.op)
        if m > n % Cell with many rows, one column. Do a vertcat
            Narg = [Narg; Nin.op{i}(argument)];
        else
            Narg = [Narg, Nin.op{i}(argument)];
        end
    end
end
